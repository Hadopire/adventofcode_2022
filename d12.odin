package aoc

import "core:strings"
import "core:container/queue"
import "core:math"

d12 :: proc(content: string) -> (result_t, result_t) {
    start, end: int;
    grid := transmute([]u8)content;
    for c, i in grid {
        if c == 'S' {
            grid[i] = 'a';
            start = i;
        } else if c == 'E' {
            grid[i] = 'z';
            end = i;
        }
    }

    size := len(content);
    width: int;
    for c, i in grid {
        if c == '\n' {
            width = i + 1;
            break;
        }
    }
    
    p2 := max(int);
    visited := make([]bool, size);
    dists := make([]int, size);
    cqueue: queue.Queue(int);
    queue.init(&cqueue, size);
   
    queue.push_back(&cqueue, end);
    dirs:= [4]int{-1, 1, -width, width};
    for queue.len(cqueue) > 0 {
        cidx := queue.pop_front(&cqueue);
        if visited[cidx] == true do continue;
        visited[cidx] = true;

        for i in dirs {
            idx := cidx + i;
            if idx >= 0 && idx < size && grid[idx] != '\n' && !visited[idx] && grid[cidx] - 1 <= grid[idx] {
                dists[idx] = dists[cidx] + 1;
                queue.push_back(&cqueue, idx);

                if grid[idx] == 'a' do p2 = math.min(p2, dists[idx]);
            }
        }
    }

    return dists[start], p2;
}