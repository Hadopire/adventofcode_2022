package aoc;

import "core:strings"
import "core:strconv"
import "core:mem"
import "core:slice"

shifty :: proc(numbers: []int, n: int) -> int {
    size := len(numbers);
    nbs_idx := make([]int, size);
    buf := make([]int, size);
    for _, i in numbers do nbs_idx[i] = i;

    mod :: proc(x, n: int) -> int {
        return (x % n + n) % n;
    }

    for _ in 0..<n {
        for n, i in numbers {
            idx, _ := slice.linear_search(nbs_idx, i);
            target := mod(idx + n, size - 1);

            if idx < target {
                mem.copy_non_overlapping(&buf[idx], &nbs_idx[idx + 1], (target - idx) * size_of(int));
                mem.copy_non_overlapping(&nbs_idx[idx], &buf[idx], (target - idx) * size_of(int));
            } else {
                mem.copy_non_overlapping(&buf[target + 1], &nbs_idx[target], (idx - target) * size_of(int));
                mem.copy_non_overlapping(&nbs_idx[target + 1], &buf[target + 1], (idx - target) * size_of(int));
            }

            nbs_idx[target] = i;
        }

    }

    z, _ := slice.linear_search(numbers, 0);
    z_idx, _ := slice.linear_search(nbs_idx, z)
    return numbers[nbs_idx[(z_idx + 1000) % size]] + numbers[nbs_idx[(z_idx + 2000) % size]] + numbers[nbs_idx[(z_idx + 3000) % size]];
}

d20 :: proc(content: string) -> (result_t, result_t) {
    numbers: [dynamic]int;
    reserve(&numbers, 5000);

    content_it := content;
    for line in strings.split_lines_iterator(&content_it) {
        n, _ := strconv.parse_int(line);
        append(&numbers, n);
    }

    p1 := shifty(numbers[:], 1);
    for _, i in numbers do numbers[i] = numbers[i] * 811589153;
    p2 := shifty(numbers[:], 10);

    return p1, p2;
}