package aoc

import "core:strings"
import "core:math"

WIDTH      :: 2500;
SIZE       :: WIDTH*WIDTH;
HALF_WIDTH :: WIDTH/2;

elf_t :: struct {
    pos: int,
    choice: int,
}

d23 :: proc(content: string) -> (result_t, result_t) {
    p1, p2: int;
    elves: [dynamic]elf_t;
    grid        := make([]^elf_t, SIZE);
    choice_grid := make([]int, SIZE);

    lines := strings.split_lines(content);
    for line, y in lines {
        byte_line := transmute([]u8)line;
        for char, x in byte_line {
            if char == '#' {
                elf := elf_t{ pos = x + HALF_WIDTH + (y + HALF_WIDTH) * WIDTH, choice = max(int) };
                idx := append(&elves, elf);
                grid[elf.pos] = &elves[len(elves) - 1];
            }
        }
    }

    choice_idx: int;
    choices := [][3]int {
        {-WIDTH, -WIDTH - 1, -WIDTH + 1},
        {WIDTH,   WIDTH - 1,  WIDTH + 1},
        {   -1,  -WIDTH - 1,  WIDTH - 1},
        {    1,  -WIDTH + 1,  WIDTH + 1},
    };

    for i := 0; true; i += 1 {
        choice_count := 0;
        for _, e_idx in elves {
            elf := &elves[e_idx];

            if grid[elf.pos-WIDTH-1] == nil && grid[elf.pos-WIDTH]   == nil && grid[elf.pos-WIDTH+1] == nil && grid[elf.pos-1]       == nil &&
               grid[elf.pos+1]       == nil && grid[elf.pos+WIDTH-1] == nil && grid[elf.pos+WIDTH]   == nil && grid[elf.pos+WIDTH+1] == nil {
                continue;
            }

            for j in 0..<4 {
                choice := &choices[(choice_idx + j) % 4];
                if grid[elf.pos + choice[0]] == nil && grid[elf.pos + choice[1]] == nil && grid[elf.pos + choice[2]] == nil {
                    elf.choice = elf.pos + choice[0];
                    choice_grid[elf.choice] += 1;
                    choice_count += 1;
                    break;
                }
            }
        }

        if choice_count == 0 {
            p2 = i + 1;
            break;
        }

        for _, e_idx in elves {
            elf := &elves[e_idx];
            if elf.choice != max(int) {
                value := choice_grid[elf.choice]
                if value == 1 {
                    grid[elf.pos] = nil;
                    grid[elf.choice] = elf;
                    elf.pos = elf.choice;
                }
            }

        }

        for _, e_idx in elves {
            elf := &elves[e_idx];
            if elf.choice != max(int) do choice_grid[elf.choice] = 0;
            elf.choice = max(int);
        }

        if i == 9 {
            min_p := vec2{max(int), max(int)};
            max_p :  vec2;
            for elf in elves {
                p := vec2{elf.pos % WIDTH, elf.pos / WIDTH};
                min_p.x = math.min(min_p.x, p.x);
                min_p.y = math.min(min_p.y, p.y);
                max_p.x = math.max(max_p.x, p.x);
                max_p.y = math.max(max_p.y, p.y);
            }
            p1 = (max_p.x - min_p.x + 1) * (max_p.y - min_p.y + 1) - len(elves);
        }
        
        choice_idx += 1;
    }


    return p1, p2;
}