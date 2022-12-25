package aoc

import "core:strings"
import "core:strconv"
import "core:math"

cell_t :: enum u8 {
    empty = 0,
    wall = '#',
    floor = '.',
}

cardinal_directions : []vec2 = {
    { 1,  0},
    { 0,  1},
    {-1,  0},
    { 0, -1},
};

wrapping_t :: struct {
    pos, dir: vec2,
};

follow_path :: proc(start: vec2, path: string, grid: []cell_t, wrappings: map[wrapping_t]wrapping_t, width, height: int) -> int {
    dir_idx: int;
    pos := start;

    path_it := path[:];
    for len(path_it) > 0 {
        offset: int;
        n, _ := strconv.parse_int(path_it, 10, &offset);

        if n != 0 {
            dir := cardinal_directions[dir_idx];
            for i in 0..<n {
                new_pos := pos + dir;
                if grid[new_pos.x + new_pos.y * width] == .empty {
                    wrapping := wrappings[{new_pos, dir}];
                    new_pos = wrapping.pos;
                    dir = wrapping.dir;
                }

                if grid[new_pos.x + new_pos.y * width] == .wall do break;
                else {
                    pos = new_pos;
                    for d, i in cardinal_directions do if d == dir do dir_idx = i;
                }

            }
        } else {
            offset = 1;

            if path_it[0] == 'L' do dir_idx = (4 + dir_idx - 1) % 4;
            else do dir_idx = (dir_idx + 1) % 4;
        }

        path_it = path_it[offset:];
    }

    return (pos.x) * 4 + (pos.y) * 1000 + dir_idx;
}

d22 :: proc(content: string) -> (result_t, result_t) {
    input := strings.split(content, "\n\n");
    lines := strings.split_lines(input[0]);
    
    width, height: int;
    start: vec2;
    for line in lines do width = math.max(width, len(line));
    height = len(lines) + 2;
    width += 2;
    grid := make([]cell_t, width * height);

    for line_str, y in lines {
        line := transmute([]u8)line_str;
        for char, x in line {
            if char != ' ' {
                grid[(x+1) + (y+1) * width] = cell_t(char);
                if start.y == 0 do start = vec2{x, 1};
            }
        }
    }

    p1_wrappings: map[wrapping_t]wrapping_t;
    p2_wrappings: map[wrapping_t]wrapping_t;

    // compute wrappings for part 1
    for y in 1..<height - 1 {
        x := 0;
        for grid[x + y * width] == .empty do x += 1;
        start := x - 1;
        for grid[x + y * width] != .empty do x += 1;
        end := x;

        p1_wrappings[{pos = {start, y}, dir = {-1, 0}}] = {pos = {end   - 1, y}, dir = {-1, 0}};
        p1_wrappings[{pos = {end,   y}, dir = { 1, 0}}] = {pos = {start + 1, y}, dir = { 1, 0}};
    }

    for x in 1..<width - 1 {
        y := 0;
        for grid[x + y * width] == .empty do y += 1;
        start := y - 1;
        for grid[x + y * width] != .empty do y += 1;
        end := y;

        p1_wrappings[{pos = {x, start}, dir = {0, -1}}] = {pos = {x, end   - 1}, dir = {0, -1}};
        p1_wrappings[{pos = {x, end  }, dir = {0,  1}}] = {pos = {x, start + 1}, dir = {0,  1}};
    }


    // compute wrappings for part 2 by turning a cube along the connected faces of the 2d unwrapped cube.
    side_len := math.max(height/4,width/4);
    // first map faces index to their position on the grid
    faces_pos: [6]vec2;
    for face_idx, y := 0, 1; y < height - 1; y += side_len{
        for x := 1; x < width - 1; x += side_len {
            if grid[x + y * width] != .empty {
                faces_pos[face_idx] = {x, y};
                face_idx += 1;
            }
        }
    }

    // then store neighbouring faces on the grid
    faces_neighbours: [6][4]int;
    for face_pos, i in faces_pos {
        for j in 0..<4 {
            faces_neighbours[i][j] = -1;
            p := face_pos + cardinal_directions[j] * side_len;
            for neigh, k in faces_pos {
                if neigh == p {
                    faces_neighbours[i][j] = k;
                }
            }
        }
    }

    ivec3 :: [3]int;
    // this function turns a cube, with 'face_idx' facing us, along neighbouring faces on the grid, until 'target' faces us.
    // it then returns the direction 'face_idx' ends up facing.
    find_side_face :: proc(grid: []cell_t, visited: []bool, face_idx: int, faces_neighbours: [6][4]int, target: ivec3, front := ivec3{0,0,-1}) -> (vec2, int) {
        if target.z == -1 do return front.xy, face_idx;
        visited[face_idx] = true;
        
        for dir, i in cardinal_directions {
            neighbour_face := faces_neighbours[face_idx][i];
            if neighbour_face != -1 && !visited[neighbour_face] {
                sin := vec2{         dir.x,         -dir.y};
                cos := vec2{1 - abs(dir.x), 1 - abs(dir.y)};
                target := ivec3{ target.z * sin.x + target.x * cos.x, target.y * cos.y - target.z * sin.y, target.y * sin.y + target.z * cos.x * cos.y - target.x * sin.x };
                front  := ivec3{ front.z  * sin.x + front.x  * cos.x, front.y  * cos.y - front.z  * sin.y, front.y  * sin.y + front.z  * cos.x * cos.y - front.x  * sin.x };
                
                _front, _face_idx := find_side_face(grid, visited, neighbour_face, faces_neighbours, target, front);
                if _face_idx != -1 do return _front.xy, _face_idx;
            }
        }

        return front.xy, -1;
    }

    // now, for each missing neighbouring face on the grid, find which face it connects to by rotating a 3d cube.
    // then compute the appropriate wrappings.
    for p, i in faces_pos {
        for _, j in faces_neighbours[i] {
            if faces_neighbours[i][j] != -1 do continue;

            visited: [6]bool;
            d := cardinal_directions[j];
            n_d, n_idx := find_side_face(grid, visited[:], i, faces_neighbours, {d.x, d.y, 0});

            clamped_d := vec2{ math.max(0, d.x),  math.max(0, d.y ) };
            src_dir   := vec2{         abs(d.y),           abs(d.x) };
            src_start := p + clamped_d * (side_len - 1) + d;
            src_end   := src_start + src_dir * side_len;

            n           := faces_pos[n_idx];
            clamped_n_d := vec2{ math.max(0, n_d.x), math.max(0, n_d.y) };
            dst_dir     := vec2{         abs(n_d.y),         abs(n_d.x) };
            dst_start   := n + clamped_n_d * (side_len - 1) + n_d;
            dst_end     := dst_start + dst_dir * (side_len - 1);

            if d == n_d || (d.x & n_d.y != 0 && d.x != n_d.y) || (d.y & n_d.x != 0 && d.y != n_d.x) {
                dst_start, dst_end = dst_end, dst_start;
                dst_dir = -dst_dir;
            }

            for src_start.x <= src_end.x && src_start.y <= src_end.y {
                wrap_key := wrapping_t{ pos = src_start,    dir = d };
                wrap     := wrapping_t{ pos = dst_start - n_d, dir = -n_d };
                p2_wrappings[wrap_key] = wrap;
                
                src_start += src_dir;
                dst_start += dst_dir;
            }

        }
    }

    p1 := follow_path(start, input[1], grid, p1_wrappings, width, height);
    p2 := follow_path(start, input[1], grid, p2_wrappings, width, height);

    return p1, p2;
}