preview() {
    local file=$1 row_start=$2 height=$3 col_start=$4
    local offset=${5:-0}
    local width=$(( MAX_WIDTH - col_start - 1 ))
    [ "$width" -lt 1 ] && width=1
    local absolute_col=$(( PADDING_LEFT + col_start - 2 ))

    local clear_block="" spaces=$(printf "%*s" "$width" "")
    i=0; while [ "$i" -lt "$height" ]; do
        clear_block="${clear_block}"$'\033'"[$((row_start + i + PADDING_TOP));${absolute_col}H${BG_MAIN_ESC}${spaces}"
        i=$((i+1))
    done
    printf "%b" "$clear_block" >&2
    [ ! -f "$file" ] && return

    local _tmp=$(mktemp /tmp/tui_preview.XXXXXX)
    _pv_generate "$file" "$offset" "$height" "$width" > "$_tmp"

    local line_count=0 preview_content=""
    while IFS= read -r line; do
        line="${line//$'\t'/    }"
        local _cursor="\e[$((row_start + line_count + PADDING_TOP));${absolute_col}H${BG_MAIN_ESC}"
        if [ -z "$line" ]; then
            row_str="${_cursor}$(printf "%*s" "$width" "")"
        elif [ "${line#*$'\033['}" != "$line" ]; then
            local _stripped; _stripped=$(printf '%s' "$line" | sed $'s/\033[[][^A-Za-z]*[A-Za-z]//g')
            local _vlen=${#_stripped}
            if [ "$_vlen" -gt "$((width + 5))" ]; then
                row_str=$(printf "${_cursor}${FG_HINT_ESC}%-*s${RESET}${BG_MAIN_ESC}" "$width" "${_stripped:0:width}")
            else
                local _guarded; _guarded=$(printf '%s' "$line" | sed "s/$(printf '\e\[0m')/$(printf '\e[0m')$(printf '%b' "$BG_MAIN_ESC")/g")
                row_str="${_cursor}${_guarded}${RESET}${BG_MAIN_ESC}"
                local _pad=$(( width - _vlen ))
                [ "$_pad" -gt 0 ] && row_str="${row_str}$(printf "%*s" "$_pad" "")"
            fi
        else
            line="${line:0:width}"
            row_str=$(printf "${_cursor}${FG_HINT_ESC}%-*s${RESET}${BG_MAIN_ESC}" "$width" "$line")
        fi
        preview_content="${preview_content}${row_str}"
        line_count=$((line_count+1))
        [ "$line_count" -ge "$height" ] && break
    done < "$_tmp"
    rm -f "$_tmp"
    printf "%b" "$preview_content" >&2
}

_pv_generate() {
    local file=$1 offset=$2 height=$3 width=$4
    local mime=$(file --mime-type -b "$file" 2>/dev/null)
    [ -z "$mime" ] && mime="text/plain"
    local _pv_ext; _pv_ext=$(printf '%s' "${file##*.}" | tr '[:upper:]' '[:lower:]')

    case "$mime" in
        image/*)                     _pv_image "$file" "$height" "$width" ;;
        application/pdf)             _pv_pdf "$file" "$offset" "$height" "$width" ;;
        text/html)                   _pv_html "$file" "$offset" "$height" "$width" ;;
        application/json)            _pv_json "$file" "$offset" "$height" "$width" ;;
        audio/*|video/*)             _pv_media "$file" "$height" "$width" ;;
        application/gzip|application/x-bzip2|application/x-xz)
                                     _pv_tar "$file" "$height" "$width" ;;
        application/zip)             _pv_zip "$file" "$height" "$width" ;;
        application/vnd.rar)         _pv_rar "$file" "$height" "$width" ;;
        application/x-7z-compressed) _pv_7z "$file" "$height" "$width" ;;
        text/plain)
            case "$_pv_ext" in
                md|mkd|markdown)     _pv_markdown "$file" "$offset" "$height" "$width" ;;
                csv|tsv)             _pv_csv "$file" "$offset" "$height" "$width" ;;
                py|js|ts|c|h|rb|sh|pl|go|rs|java|php|css|scss|lua|sql|xml|yaml|yml)
                                     _pv_code "$file" "$offset" "$height" "$width" ;;
                1|2|3|4|5|6|7|8|9|man) _pv_man "$file" "$offset" "$height" "$width" ;;
                *)                   _pv_text "$file" "$offset" "$height" "$width" ;;
            esac ;;
        application/octet-stream|*)  _pv_binary "$file" "$offset" "$height" "$width" ;;
    esac | head -n "$height"
}

_pv_text() {
    local file=$1 offset=$2 height=$3 width=$4
    sed $'s/\033[[][^A-Za-z]*[A-Za-z]//g' "$file" \
      | sed -n "$((offset + 1)),$((offset + height))p"
}

_pv_image() {
    local file=$1 height=$2 width=$3
    if command -v catimg >/dev/null 2>&1; then
        timeout 5 catimg -w "$((width * 2 / 3))" "$file" 2>/dev/null
    elif command -v timg >/dev/null 2>&1; then
        timeout 5 timg -g "${width}x${height}" "$file" 2>/dev/null
    elif command -v exiv2 >/dev/null 2>&1; then
        timeout 5 exiv2 "$file" 2>/dev/null
    else
        file "$file" | head -n 1
    fi
}

_pv_pdf() {
    local file=$1 offset=$2 height=$3 width=$4
    if command -v pdftotext >/dev/null 2>&1; then
        local page=$(( offset / height + 1 ))
        timeout 5 pdftotext -f "$page" -l "$page" -layout "$file" - 2>/dev/null
    else
        _pv_binary "$file" "$offset" "$height" "$width"
    fi
}

_pv_html() {
    local file=$1 offset=$2 height=$3 width=$4
    if command -v lynx >/dev/null 2>&1; then
        timeout 5 lynx -dump -width "$width" "$file" 2>/dev/null \
          | sed -n "$((offset + 1)),$((offset + height))p"
    elif command -v w3m >/dev/null 2>&1; then
        timeout 5 w3m -dump -cols "$width" "$file" 2>/dev/null \
          | sed -n "$((offset + 1)),$((offset + height))p"
    else
        sed 's/<[^>]*>//g; s/&nbsp;/ /g; s/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g; /^$/d' "$file" \
          | sed -n "$((offset + 1)),$((offset + height))p"
    fi
}

_pv_json() {
    local file=$1 offset=$2 height=$3 width=$4
    if command -v jq >/dev/null 2>&1; then
        timeout 5 jq . "$file" 2>/dev/null
    else
        timeout 5 python -m json.tool "$file" 2>/dev/null
    fi | sed -n "$((offset + 1)),$((offset + height))p"
}

_pv_markdown() {
    local file=$1 offset=$2 height=$3 width=$4
    if command -v glow >/dev/null 2>&1; then
        timeout 5 glow -s dark -w "$width" "$file" 2>/dev/null
    elif command -v mdcat >/dev/null 2>&1; then
        timeout 5 mdcat --width "$width" "$file" 2>/dev/null
    elif command -v pandoc >/dev/null 2>&1; then
        timeout 5 pandoc -t plain --columns="$width" "$file" 2>/dev/null
    else
        sed \
          -e 's/^###*\s*//' \
          -e 's/\[\([^]]*\)]([^)]*)/\1/g' \
          -e 's/!\[\([^]]*\)]([^)]*)//g' \
          -e 's/[*_]\{1,2\}\([^*_]*\)[*_]\{1,2\}/\1/g' \
          -e 's/[`~]\{1,3\}[^`~]*[`~]\{1,3\}//g' \
          -e 's/^[>|]\s*//' \
          -e 's/^[\*\+\-]\s\+/\t/g' \
          -e 's/^\d\+\.\s\+/\t/g' \
          -e '/^---\s*$/d' \
          "$file"
    fi | sed -n "$((offset + 1)),$((offset + height))p"
}

_pv_csv() {
    local file=$1 offset=$2 height=$3 width=$4
    if command -v csvlook >/dev/null 2>&1; then
        timeout 5 csvlook "$file" 2>/dev/null
    else
        column -t -s, "$file" 2>/dev/null
    fi | sed -n "$((offset + 1)),$((offset + height))p"
}

_pv_code() {
    local file=$1 offset=$2 height=$3 width=$4
    if command -v bat >/dev/null 2>&1; then
        timeout 5 bat --color=always --style=plain --wrap=never "$file" 2>/dev/null
    elif command -v pygmentize >/dev/null 2>&1; then
        timeout 5 pygmentize -f terminal "$file" 2>/dev/null \
          | sed $'s/\033\[39;49;00m//g; s/\033\[49m//g'
    else
        _pv_text "$file" "$offset" "$height" "$width"
    fi | sed -n "$((offset + 1)),$((offset + height))p"
}

_pv_man() {
    local file=$1 offset=$2 height=$3 width=$4
    timeout 5 man ./"$file" 2>/dev/null | col -b 2>/dev/null \
      | sed -n "$((offset + 1)),$((offset + height))p"
    [ $? -gt 1 ] && _pv_text "$file" "$offset" "$height" "$width"
}

_pv_tar() {
    local file=$1 height=$2 width=$3
    timeout 5 tar -tf "$file" 2>/dev/null | head -n "$height"
}

_pv_zip() {
    local file=$1 height=$2 width=$3
    timeout 5 unzip -l "$file" 2>/dev/null | head -n "$height"
}

_pv_rar() {
    local file=$1 height=$2 width=$3
    timeout 5 unrar l "$file" 2>/dev/null | head -n "$height"
}

_pv_7z() {
    local file=$1 height=$2 width=$3
    timeout 5 7z l "$file" 2>/dev/null | head -n "$height"
}

_pv_media() {
    local file=$1 height=$2 width=$3
    if command -v mediainfo >/dev/null 2>&1; then
        timeout 5 mediainfo "$file" 2>/dev/null | head -n "$height"
    elif command -v ffprobe >/dev/null 2>&1; then
        timeout 5 ffprobe -hide_banner "$file" 2>&1 | head -n "$height"
    elif command -v soxi >/dev/null 2>&1; then
        timeout 5 soxi "$file" 2>/dev/null | head -n "$height"
    else
        file "$file" | head -n 1
    fi
}

_pv_binary() {
    local file=$1 offset=$2 height=$3 width=$4
    timeout 5 strings "$file" 2>/dev/null | sed -n "$((offset + 1)),$((offset + height))p"
    if [ $? -gt 0 ]; then
        timeout 5 xxd "$file" 2>/dev/null | head -n "$((height * 3))"
    fi
}