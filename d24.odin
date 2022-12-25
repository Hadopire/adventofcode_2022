package aoc

import "core:strings"
import "core:mem"

d24 :: proc(content: string) -> (result_t, result_t) {
    lines := strings.split_lines(content);
    width  := cast(u64) len(lines[0]);
    height := cast(u64) len(lines);

    walls           := make([]u128, height);
    north_blizzards := make([]u128, height);
    south_blizzards := make([]u128, height);
    east_blizzards  := make([]u128, height);
    west_blizzards  := make([]u128, height);
    positions       := make([]u128, height);
    
    positions[0] |= 1 << (width - 2)
    for line, y in lines {
        byte_line := transmute([]u8)line;
        for char, x in byte_line {
            switch char {
                case '#': walls[y]           |= 1 << (width - u64(x) - 1);
                case '^': north_blizzards[y] |= 1 << (width - u64(x) - 1);
                case 'v': south_blizzards[y] |= 1 << (width - u64(x) - 1);
                case '>': east_blizzards[y]  |= 1 << (width - u64(x) - 1);
                case '<': west_blizzards[y]  |= 1 << (width - u64(x) - 1);
            }
        }
    }

    prev_north_blizzards := make([]u128, height);
    prev_south_blizzards := make([]u128, height);
    prev_positions       := make([]u128, height);
    p1, p2, trip_count: int;
    for ; true; p2 += 1 {
        mem.copy_non_overlapping(&prev_north_blizzards[0], &north_blizzards[0], len(north_blizzards) * size_of(u128));
        mem.copy_non_overlapping(&prev_south_blizzards[0], &south_blizzards[0], len(south_blizzards) * size_of(u128));
        mem.copy_non_overlapping(&prev_positions[0],       &positions[0],       len(positions) * size_of(u128));
        for y in 0..<height {
            east_blizzards[y] = ((east_blizzards[y] >> 1) | (east_blizzards[y] & 2 << (width - 3))) & ~walls[y];
            west_blizzards[y] = ((west_blizzards[y] << 1) | (west_blizzards[y] >> (width - 3)) & 2) & ~walls[y];
            north_blizzards[y] = prev_north_blizzards[((y - 2 + height) % (height - 2)) + 1]        & ~walls[y];
            south_blizzards[y] = prev_south_blizzards[((y - 4 + height) % (height - 2)) + 1]        & ~walls[y];

            positions[y] |= prev_positions[y] >> 1;
            positions[y] |= prev_positions[y] << 1;
            positions[y] |= prev_positions[(y + 1 + height) % (height)];
            positions[y] |= prev_positions[(y - 1 + height) % (height)];
            positions[y] &= ~walls[y];
            positions[y] = positions[y] & ~(east_blizzards[y] | west_blizzards[y] | north_blizzards[y] | south_blizzards[y]);
        }

        if (positions[height - 1] & 2) != 0 && trip_count == 0 {
            trip_count += 1;
            p1 = p2;
            for y in 0..<height-1 do positions[y] = 0;
        } else if (positions[0] & (1 << (width - 2))) != 0 && trip_count == 1 {
            trip_count += 1;
            for y in 1..<height do positions[y] = 0;
        } else if (positions[height - 1] & 2) != 0 && trip_count == 2 do break;
    }

    return p1 + 1, p2 + 1;
}