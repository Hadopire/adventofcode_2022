package aoc

import "core:strings"
import "core:strconv"

vec2 :: [2]int;

sign :: proc(n: $T) -> T {
    return T(n > 0) - T(n < 0);
}

d09 :: proc(content: string) -> (result_t, result_t) {
    knots: [10]vec2
    visited_first := make(map[vec2]bool, 1024);
    visited_second:= make(map[vec2]bool, 1024);

    visited_first[{0,0}] = true;
    visited_second[{0,0}] = true;
    it := content;
    for line in strings.split_lines_iterator(&it) {
        if len(line) == 0 do break;

        head_dir: vec2;
        switch line[0] {
            case 'R': head_dir.x = 1;
            case 'L': head_dir.x = -1;
            case 'U': head_dir.y = 1;
            case 'D': head_dir.y = -1;
        }

        n, _ := strconv.parse_int(line[2:]);
        target := knots[0] + head_dir * n;

        for knots[0] != target {
            knots[0] += head_dir;

            for i := 1; i < len(knots); i += 1 {
                difference := knots[i-1] - knots[i];
                if abs(difference.x) <= 1 && abs(difference.y) <= 1 do break;

                knots[i] += { sign(difference.x), sign(difference.y) };
                if i == 1 do visited_first[knots[i]] = true;
                else if i == 9 do visited_second[knots[i]] = true;
            }
        }
    }

    return len(visited_first), len(visited_second);
}