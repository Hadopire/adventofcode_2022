package aoc

import "core:strings"
import "core:strconv"

d04 :: proc(content: string) -> (u64, u64) {
    first, second : u64;
    
    it := content;
    for line in strings.split_lines_iterator(&it) {
        if (len(line) == 0) do break;

        r0, r1 : [2]u64;
        offset, at : int;

        r0[0], _ = strconv.parse_u64(line, 10, &at); offset += at + 1;
        r0[1], _ = strconv.parse_u64(line[offset:], 10, &at); offset += at + 1;
        r1[0], _ = strconv.parse_u64(line[offset:], 10, &at); offset += at + 1;
        r1[1], _ = strconv.parse_u64(line[offset:], 10, &at);

        rb0 : u128 = ~(~u128(0) << (r0[1] - r0[0] + 1)) << r0[0];
        rb1 : u128 = ~(~u128(0) << (r1[1] - r1[0] + 1)) << r1[0];
        overlap := rb0 & rb1;
        
        first += u64(overlap == rb0 || overlap == rb1);
        second += u64(overlap > 0);
    }

    return first, second;
}