package aoc

import "core:strings"
import "core:math"

tetra_len := len(tetraminos);
tetraminos := [5][4][4]u8{
    {
        {1,1,1,1},
        {0,0,0,0},
        {0,0,0,0},
        {0,0,0,0},
    },
    {
        {0,1,0,0},
        {1,1,1,0},
        {0,1,0,0},
        {0,0,0,0},
    },
    {
        {1,1,1,0},
        {0,0,1,0},
        {0,0,1,0},
        {0,0,0,0},
    },
    {
        {1,0,0,0},
        {1,0,0,0},
        {1,0,0,0},
        {1,0,0,0},
    },
    {
        {1,1,0,0},
        {1,1,0,0},
        {0,0,0,0},
        {0,0,0,0},
    },
};
tetra_heights := [5]int{1, 3, 3, 4, 2};
tetra_widths := [5]int{4, 3, 3, 1, 2};

collides :: proc(pos: vec2, shape: [4][4]u8, width: int, height: int, grid: [][7]u8) -> bool {
    if pos.x < 0 || pos.y < 0 || pos.x + width - 1 >= 7 do return true;

    for y in 0..<height {
        for x in 0..<width {
            if shape[y][x] + grid[pos.y + y][pos.x + x] > 1 {
                return true;
            }
        }
    }

    return false;
}

d17 :: proc(content: string) -> (result_t, result_t) {
    moves := transmute([]u8)content;
    grid := make([dynamic][7]u8, 10000);
    highest := 0;
    heights_offset : [7]int;
    tetra_idx, move_idx: int;
    cycle_start, cycle_end: int;
    hashes : [dynamic]u128;
    heights: [dynamic]int;
    reserve(&hashes, 10000);
    reserve(&heights, 10000);

    stop := false;
    for i := 0; !stop; i += 1 {
        tetramino := tetraminos[tetra_idx];
        tetra_height := tetra_heights[tetra_idx];
        tetra_width := tetra_widths[tetra_idx];
        tetra_idx += 1;
        if tetra_idx >= tetra_len do tetra_idx %= tetra_len;

        pos := vec2{2, highest + 3}

        if pos.y + tetra_height >= len(grid) {
            resize_dynamic_array(&grid, len(grid) * 2);
        }

        for true {
            move := moves[move_idx];
            move_idx += 1;
            if move_idx >= len(moves) do move_idx %= len(moves);

            m := vec2{move == '>' ? 1 : -1, 0};
            if !collides(pos + m, tetramino, tetra_width, tetra_height, grid[:]) {
                pos += m;
            }

            if !collides(pos - vec2{0,1}, tetramino, tetra_width, tetra_height, grid[:]) {
                pos -= vec2{0,1};
            } else do break;
        }

        highest = math.max(highest, pos.y + tetra_height);
        append(&heights, highest);
        for y in 0..<tetra_height {
            for x in 0..<tetra_width {
                if tetramino[y][x] != 0 {
                    grid[pos.y + y][pos.x + x] = tetramino[y][x];
                    heights_offset[pos.x + x] = pos.y; 
                }
            }
        }

        sum: int;
        for height in heights_offset do sum += highest - height;
        hash := u128(sum) << 64 | u128(move_idx) << 32 | u128(tetra_idx);
        for i := len(hashes) - 1; i >= 0; i -= 1 {
            if hash == hashes[i] {
                cycle_start = i;
                cycle_end = len(hashes);
                stop = true;
            }
        }
        append(&hashes, hash);
    }

    height_d := heights[cycle_end] - heights[cycle_start];
    cycle_d := cycle_end - cycle_start;

    p1 := height_d * ((2022 - cycle_start - 1) / cycle_d) + heights[cycle_start + ((2022 - cycle_start - 1) % cycle_d)];
    p2 := height_d * ((1000000000000 - cycle_start - 1) / cycle_d) + heights[cycle_start + ((1000000000000 - cycle_start - 1) % cycle_d)];

    return p1, p2;
}