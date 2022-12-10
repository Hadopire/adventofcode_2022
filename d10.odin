package aoc

import "core:strings"
import "core:strconv"

d10 :: proc(content: string) -> (result_t, result_t) {
    first: int;
    clock: int;
    crt := make([]u8, 40 * 6 + 5);
    x, next_signal := 1, 20;

    it := content;
    for line in strings.split_lines_iterator(&it) {
        if len(line) == 0 do break;

        latency, operand: int;
        switch line[0] {
            case 'n': latency = 1;
            case 'a': {
                latency = 2;
                operand, _ = strconv.parse_int(line[5:]);
            }
        }

        for i in 0..<latency {
            crt_clock := clock + i;
            px := crt_clock % 40;
            offset := crt_clock / 40;

            if abs(px - x) <= 1 {
                crt[crt_clock + offset] = '#';
            } else {
                crt[crt_clock + offset] = '.';
            }
        }

        if clock + latency >= next_signal {
            first += x * next_signal;
            next_signal += 40;
        }

        x += operand;
        clock += latency;
    }

    for i in 0..<5 do crt[40+i*41] = '\n';
    return first, string(crt[:]);
}