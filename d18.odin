package aoc

import "core:strings"
import "core:strconv"
import q "core:container/queue"

vec3 :: [3]int;

d18 :: proc(content: string) -> (result_t, result_t) {
    p1, p2: int;
    voxels: [24][24][24]bool;
    input: [dynamic]vec3;
    
    it := content;
    for line in strings.split_lines_iterator(&it) {
        p: vec3;
        offset, at: int;
        p.x, _ = strconv.parse_int(line[offset:], 10, &at); offset += at + 1;
        p.y, _ = strconv.parse_int(line[offset:], 10, &at); offset += at + 1;
        p.z, _ = strconv.parse_int(line[offset:]);

        p += {1,1,1};
        voxels[p.x][p.y][p.z] = true;
        append(&input, p);
    }

    // p1
    dirs: []vec3 = {{1,0,0}, {0,1,0}, {0,0,1}, {-1,0,0}, {0,-1,0}, {0,0,-1}};
    for p in input {
        for dir in dirs {
            n_pos := p + dir;
            if !voxels[n_pos.x][n_pos.y][n_pos.z] {
                p1 += 1;
            }
        }
    }

    // p2
    visited: [24][24][24]bool;
    queue: q.Queue(vec3);
    q.init(&queue, 10000);
    q.push_back(&queue, vec3{0,0,0});
    visited[0][0][0] = true;
    for q.len(queue) > 0 {
        p := q.pop_front(&queue);

        for dir in dirs {
            n_pos := p + dir;
            if n_pos.x < 0 || n_pos.y < 0 || n_pos.z < 0 || n_pos.x >= 24 || n_pos.y >= 24 || n_pos.z >= 24 do continue;

            if voxels[n_pos.x][n_pos.y][n_pos.z] {
                p2 += 1;
            } else if !visited[n_pos.x][n_pos.y][n_pos.z] {
                visited[n_pos.x][n_pos.y][n_pos.z] = true;
                q.push_back(&queue, n_pos);
            }
        }
    }

    return p1, p2;
}