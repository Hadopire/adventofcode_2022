package aoc

import "core:strings"
import "core:strconv"
import "core:slice"
import q "core:container/queue"
import "core:intrinsics"
import "core:math"

valve_t :: struct {
    id: int,
    flow_rate: int,
    tunnels: [dynamic]^valve_t,
};

precompute_dists_from :: proc(valves: []valve_t, from_to_d: ^[][]int, start: int) {
    queue: q.Queue(int);
    q.init(&queue, len(valves));

    q.push_back(&queue, start);
    for q.len(queue) > 0 {
        valve_idx := q.pop_front(&queue);

        for connected in valves[valve_idx].tunnels {
            dist := from_to_d[start][valve_idx] + 1;
            if connected.id != start && (from_to_d[start][connected.id] == 0 || dist < from_to_d[start][connected.id]) {
                from_to_d[start][connected.id] = dist;
                q.push_back(&queue, connected.id);
            }
        }
    }
}

maximum_score :: proc(valves: []valve_t, from: int, from_to_d: [][]int, minutes: int, closed: u64, total: int, set_best_score: ^map[u64]int = nil) -> int {
    if set_best_score != nil {
        value, _ := set_best_score[closed];
        set_best_score[closed] = math.max(value, total);
    }
    
    max_score := 0;
    closed_it := closed;
    for closed_it != 0 {
        to := int(intrinsics.count_trailing_zeros(closed_it));
        bit := u64(1) << u64(to);

        new_minutes := minutes - from_to_d[from][to] - 1;
        if new_minutes > 0 {
            score := valves[to].flow_rate * new_minutes;
            max_score = math.max(max_score, score + maximum_score(valves, to, from_to_d, new_minutes, closed ~ bit, total + score, set_best_score));
        }

        closed_it ~= bit;
    }


    return max_score;
}

d16 :: proc(content: string) -> (result_t, result_t) {
    start: int;
    lines := strings.split_lines(content);
    valves := make([]valve_t, len(lines));
    name_to_id := make(map[string]int, len(lines) * 2);
    connects_to := make([]([]string), len(lines));
    from_to_d := make([][]int, len(lines));
    for _, i in from_to_d do from_to_d[i] = make([]int, len(lines));

    for line, i in lines {
        name_to_id[line[6:8]] = i;
        if line[6:8] == "AA" do start = i;
        offset: int;
        valves[i].flow_rate, _ = strconv.parse_int(line[23:], 10, &offset);
        valves[i].id = i;
        connects_to[i] = strings.split(line[offset + 48 - (line[offset + 46] == 's' ? 0 : 1):], ", ");
    }

    for names, i in connects_to {
        for name in names {
            idx, _ := name_to_id[name];
            append(&valves[i].tunnels, &valves[idx]);
        }
    }

    closed: u64;
    for valve, i in valves {
        precompute_dists_from(valves, &from_to_d, i);
        if valve.flow_rate > 0 {
            closed |= u64(1) << u64(i);
        }
    }

    p1 := maximum_score(valves, start, from_to_d, 30, closed, 0);

    p2 := 0;
    set_best_score: map[u64]int;
    maximum_score(valves, start, from_to_d, 26, closed, 0, &set_best_score);
    map_slice := slice.map_entries(set_best_score);
    for i in 0..<len(map_slice) {
        for j in i+1..<len(map_slice) {
            if (map_slice[i].key | map_slice[j].key) == closed {
                p2 = math.max(p2, map_slice[i].value + map_slice[j].value);
            }
        }
    }

    return p1, p2;
}