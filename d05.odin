package aoc

import "core:container/queue"
import "core:strings"
import "core:strconv"

d05 :: proc(content: string) -> (result_t, result_t) {
    stacks0, stacks1 : [9]queue.Queue(u8);
    it := content;
    for line in strings.split_lines_iterator(&it) {
        if len(line) == 0 do break;

        offset, idx := 1, 0;
        for ; offset < len(line) ; offset += 4{
            if (line[offset] == '1') do break;
            if (line[offset] != ' ') {
                queue.push_back(&stacks0[idx], line[offset]);
                queue.push_back(&stacks1[idx], line[offset]);
            }
            idx += 1;
        }
    }

    for line in strings.split_lines_iterator(&it) {
        if len(line) == 0 do break;
       
        nb, src, dst : uint;
        offset, at := 5, 0;

        nb, _ = strconv.parse_uint(line[offset:], 10, &at); offset += at + 6;
        src, _ = strconv.parse_uint(line[offset:], 10, &at); offset += at + 4;
        dst, _ = strconv.parse_uint(line[offset:], 10, &at);

        for i := uint(0); i < nb; i += 1 {
            queue.push_front(&stacks0[dst - 1], queue.pop_front(&stacks0[src - 1]));
            queue.push_front(&stacks1[dst - 1], queue.get(&stacks1[src - 1], nb - i - 1));
        }

        queue.consume_front(&stacks1[src - 1], int(nb));
    }

    first, second : [dynamic]u8
    for _, idx in stacks0 {
        if stacks0[idx].len == 0 do continue;
        append(&first, queue.front(&stacks0[idx]));
    }
    
    for _, idx in stacks1 {
        if stacks1[idx].len == 0 do continue;
        append(&second, queue.front(&stacks1[idx]));
    }

    return string(first[:]), string(second[:]);
}