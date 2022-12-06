package aoc

import "core:strings"
import "core:strconv"
import "core:slice"

d01 :: proc(content: string) -> (result_t, result_t) {
    lines := strings.split_lines(content);
    calories := make([dynamic]u64);
    
    for i := 0; i < len(lines); i += 1 {
        sum : u64 = 0;
        for ; i < len(lines); i += 1 {
            value, ok := strconv.parse_u64(lines[i]);
            if !ok {
                break;
            }

            sum += value;
        }

        append(&calories, sum);
    }
    
    slice.reverse_sort(calories[:len(calories)]);
    return calories[0], calories[0] + calories[1] + calories[2];
}