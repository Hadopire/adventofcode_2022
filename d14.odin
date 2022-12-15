package aoc

import "core:strings"
import "core:strconv"
import "core:math"

d14 :: proc(content: string) -> (result_t, result_t) {
    ymax, p1, p2: int;
    width, height :: 1000, 1000;
    grid := make([]bool, width * height);

    it := content;
    for line in strings.split_lines_iterator(&it) {
        next_vec2 :: proc(str: ^string) -> (vec2, bool) {
            if len(str) == 0 do return {}, false;

            offset: int;
            ret: vec2;

            ret.x, _ = strconv.parse_int(str^, 10, &offset);
            str^ = str[offset + 1:];
            ret.y, _ = strconv.parse_int(str^, 10, &offset);
            str^ = str[math.min(len(str^), offset + 4):];
            return ret, true;
        }

        line_it := line;
        prev, _ := next_vec2(&line_it);
        ymax = math.max(ymax, prev.y);
        for next in next_vec2(&line_it) {
            d := next - prev;
            d.x = sign(d.x);
            d.y = sign(d.y);

            for pos := prev; pos != next; pos += d {
                grid[pos.x + pos.y * width] = true;
            }
            grid[next.x + next.y * width] = true;

            prev = next;
            ymax = math.max(ymax, prev.y);
        }
    }

    for x in (500 - (1+2*ymax))..=(500 + (1+2*ymax)) {
        grid[x + (ymax + 2) * width] = true;
    }

    for ; !grid[500]; p2 += 1 {
        sand_idx := 500;
        for !grid[sand_idx] {
            for !grid[sand_idx + width] do sand_idx += width;

            if !grid[sand_idx + width - 1] {
                sand_idx += width - 1;
            } else if !grid[sand_idx + width + 1] {
                sand_idx += width + 1;
            } else {
                grid[sand_idx] = true;
            }

            if p1 == 0 && sand_idx / width >= ymax do p1 = p2;
        }
    }

    return p1, p2;
}