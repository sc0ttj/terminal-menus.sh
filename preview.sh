preview() {
    local file=$1 row_start=$2 height=$3 col_start=$4
    local offset=${5:-0}
    local width=$(( MAX_WIDTH - col_start - 1 ))
    local absolute_col=$(( PADDING_LEFT + col_start - 2 ))

    local spaces=$(printf "%*s" "$width" "")
    local clear_block=""
    i=0; while [ "$i" -lt "$height" ]; do
        clear_block="${clear_block}\e[$((row_start + i + PADDING_TOP));${absolute_col}H${BG_MAIN_ESC}${spaces}"
        i=$((i+1))
    done
    printf "%b" "$clear_block" >&2

    [ ! -f "$file" ] && return

    local line_count=0
    local preview_content=""
    local preview_tmp=$(mktemp /tmp/tui_preview.XXXXXX)

    sed $'s/\e[[][^A-Za-z]*[A-Za-z]//g' "$file" | sed -n "$((offset + 1)),$((offset + height))p" > "$preview_tmp"

    while IFS= read -r line; do
        line="${line//$'\t'/    }"
        line="${line:0:width}"

        row_str=$(printf "\e[$((row_start + line_count + PADDING_TOP));${absolute_col}H${FG_HINT_ESC}%-*s${RESET}${BG_MAIN_ESC}" "$width" "$line")
        preview_content="${preview_content}${row_str}"
        line_count=$((line_count + 1))
    done < "$preview_tmp"

    rm -f "$preview_tmp"
    printf "%b" "$preview_content" >&2
}
