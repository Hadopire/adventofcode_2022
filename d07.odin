package aoc

import "core:strings"
import "core:strconv"
import "core:math"

directory_t :: struct {
    parent: int,
    size: u64,
}

d07 :: proc(content: string) -> (result_t, result_t) {
    dirs: [dynamic]directory_t;

    current_dir := -1;
    command_it := content;
    for command_line in strings.split_lines_iterator(&command_it) {
        if len(command_line) == 0 do break;

        if command_line[2] == 'c' {
            // $ cd
            dirname := command_line[5:];

            if strings.compare(dirname, "..") == 0 {
                current_dir = dirs[current_dir].parent;
            } else {
                append(&dirs, directory_t{ parent = current_dir });
                current_dir = len(dirs) - 1;
            }
        } else {
            // $ ls
            ls_it := command_it;
            for ls_line in strings.split_lines_iterator(&ls_it) {
                if len(ls_line) == 0 || ls_line[0] == '$' do break;
                
                command_it = ls_it;
                if ls_line[0] != 'd' {
                    file_size, _  := strconv.parse_u64(ls_line);
                    dirs[current_dir].size += file_size;
                }
            }

            dir_size := dirs[current_dir].size;
            for parent := dirs[current_dir].parent; parent != -1; parent = dirs[parent].parent {
                dirs[parent].size += dir_size;
            }
        }
    }

    first, second : u64 = 0, max(u64);
    current_space := 70000000 - dirs[0].size;
    missing_space := 30000000 - current_space;
    for dir in dirs {
        if dir.size <= 100000 do first += dir.size;
        if dir.size >= missing_space do second = math.min(second, dir.size);
    }

    return first, second;
}