preview() {
    local file=$1 row_start=$2 height=$3 col_start=$4
    local offset=${5:-0}
    local width=$(( MAX_WIDTH - col_start - 1 ))
    local absolute_col=$(( PADDING_LEFT + col_start - 2 ))
    
    # 1. Clear the preview area
    local clear_block=""
    printf -v spaces "%*s" "$width" ""
    for ((i=0; i<height; i++)); do
        clear_block+="\e[$((row_start + i + PADDING_TOP));${absolute_col}H${BG_MAIN_ESC}${spaces}"
    done
    printf "%b" "$clear_block" >&2

    [[ ! -f "$file" ]] && return

    local line_count=0
    local preview_content=""
    
    # 2. Optimized Reading & ANSI Stripping (Portable)
    # Stage 1: Strip ANSI (sed)
    # Stage 2: Slice lines (sed -n 'start,endp')
    while IFS= read -r line; do
        line="${line//$'\t'/    }"
        line="${line:0:width}"
        
        printf -v row_str "\e[$((row_start + line_count + PADDING_TOP));${absolute_col}H${FG_HINT_ESC}%-*s${RESET}${BG_MAIN_ESC}" "$width" "$line"
        preview_content+="$row_str"
        ((line_count++))
    done < <(sed $'s/\e[[][^A-Za-z]*[A-Za-z]//g' "$file" | sed -n "$((offset + 1)),$((offset + height))p")
    
    printf "%b" "$preview_content" >&2
}