package aoc

import "core:strings"

score :: proc(a: u64, b: u64) -> u64 {
    return a + 1 + ((4 + a - b) % 3) * 3;
}

to_play :: proc(them : u64, result : u64) -> u64 {
    return (3 + them + (result - 1)) % 3;
}

d02 :: proc(content: string) -> (u64, u64) {
    lines := strings.split_lines(content);
    defer delete(lines);

    first, second : u64 = 0, 0;
    for line in lines {
        if len(line) == 0 do break;

        me := u64(line[2] - 'X');
        them := u64(line[0] - 'A');

        first += score(me, them);
        second += score(to_play(them, me), them);
    }

    return first, second;
}