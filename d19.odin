package aoc

import "core:strings"
import "core:strconv"
import "core:math"
import q "core:container/queue"

blueprint_t :: struct {
    ore_robot_ore_cost: i16,
    clay_robot_ore_cost: i16,
    obsidian_robot_ore_cost: i16,
    obsidian_robot_clay_cost: i16,
    geode_robot_ore_cost: i16,
    geode_robot_obsidian_cost: i16,
    max_ore_cost: i16,
    max_clay_cost: i16,
    max_obsidian_cost: i16,
};

factory_state_t :: struct {
    ore: i16,
    ore_per_minute: i16,
    clay: i16,
    clay_per_minute: i16,
    obsidian: i16,
    obsidian_per_minute: i16,
    minutes: i16,
    score: i16,
}

factory_tick :: proc(state: ^factory_state_t, n: i16) {
    state.ore += state.ore_per_minute * n;
    state.clay += state.clay_per_minute * n;
    state.obsidian += state.obsidian_per_minute * n;
    state.minutes -= n;
}

max_geodes :: proc(blueprint: blueprint_t, _state: factory_state_t) -> i16 {
    queue: q.Queue(factory_state_t);
    q.init(&queue, 1000);
    q.push(&queue, _state);

    max_score: i16;
    for q.len(queue) > 0 {
        state := q.pop_front(&queue);        
        if state.score + (state.minutes * state.minutes) <= max_score do continue;
        if state.obsidian + (state.minutes * state.minutes) < blueprint.geode_robot_obsidian_cost {
            max_score = math.max(max_score, state.score);
            continue;
        }

        if state.ore_per_minute > 0 && state.obsidian_per_minute > 0 {
            current_state := state;
            wait_for_ore := cast(i16) math.ceil(f32(math.max(0, blueprint.geode_robot_ore_cost - current_state.ore)) / f32(current_state.ore_per_minute));
            wait_for_obsidian := cast(i16) math.ceil(f32(math.max(0, blueprint.geode_robot_obsidian_cost - current_state.obsidian)) / f32(current_state.obsidian_per_minute));
            wait_time := math.max(wait_for_ore, wait_for_obsidian);

            if wait_time < state.minutes {
                factory_tick(&current_state, wait_time + 1);
                current_state.ore -= blueprint.geode_robot_ore_cost;
                current_state.obsidian -= blueprint.geode_robot_obsidian_cost;

                current_state.score += current_state.minutes;
                max_score = math.max(max_score, current_state.score);
                q.push_front(&queue, current_state);

                if wait_time == 0 do continue;
            }
        }
    
        if state.ore_per_minute > 0 && state.clay_per_minute > 0 && state.obsidian_per_minute < blueprint.max_obsidian_cost {
            current_state := state;
            wait_for_ore := cast(i16) math.ceil(f32(math.max(0, blueprint.obsidian_robot_ore_cost - current_state.ore)) / f32(current_state.ore_per_minute));
            wait_for_clay := cast(i16) math.ceil(f32(math.max(0, blueprint.obsidian_robot_clay_cost - current_state.clay)) / f32(current_state.clay_per_minute));
            wait_time := math.max(wait_for_ore, wait_for_clay);

            if wait_time < state.minutes {
                factory_tick(&current_state, wait_time + 1);
                current_state.obsidian_per_minute += 1;
                current_state.ore -= blueprint.obsidian_robot_ore_cost;
                current_state.clay -= blueprint.obsidian_robot_clay_cost;

                q.push_front(&queue, current_state);
            }
        }

        if state.ore_per_minute > 0 && state.clay_per_minute < blueprint.max_clay_cost {
            current_state := state;
            wait_time := cast(i16) math.ceil(f32(math.max(0, blueprint.clay_robot_ore_cost - current_state.ore)) / f32(current_state.ore_per_minute));

            if wait_time < state.minutes {
                factory_tick(&current_state, wait_time + 1);
                current_state.clay_per_minute += 1;
                current_state.ore -= blueprint.clay_robot_ore_cost;

                q.push_front(&queue, current_state);
            }
        }

        if state.ore_per_minute < blueprint.max_ore_cost {
            current_state := state;
            wait_time := cast(i16) math.ceil(f32(math.max(0, blueprint.ore_robot_ore_cost - current_state.ore)) / f32(current_state.ore_per_minute));

            if wait_time < state.minutes {
                factory_tick(&current_state, wait_time + 1);
                current_state.ore_per_minute += 1;
                current_state.ore -= blueprint.ore_robot_ore_cost;

                q.push_front(&queue, current_state);
            }
        }
    }

    return max_score;
}

d19 :: proc(content: string) -> (result_t, result_t) {
    blueprints: [dynamic]blueprint_t;
    p1, p2 := 0, 1;

    it := content;
    for line in strings.split_lines_iterator(&it) {
        bp: blueprint_t;
        offset, at := 10, 0;

        strconv.parse_int(line[offset:], 10, &at); offset += at + 23;
        n, _ := strconv.parse_int(line[offset:], 10, &at); offset += at + 28;        
        bp.ore_robot_ore_cost = i16(n);
        n, _ = strconv.parse_int(line[offset:], 10, &at); offset += at + 32;        
        bp.clay_robot_ore_cost = i16(n);
        n, _ = strconv.parse_int(line[offset:], 10, &at); offset += at + 9;        
        bp.obsidian_robot_ore_cost = i16(n);
        n, _ = strconv.parse_int(line[offset:], 10, &at); offset += at + 30;        
        bp.obsidian_robot_clay_cost = i16(n);
        n, _ = strconv.parse_int(line[offset:], 10, &at); offset += at + 9;        
        bp.geode_robot_ore_cost = i16(n);
        n, _ = strconv.parse_int(line[offset:], 10, &at);
        bp.geode_robot_obsidian_cost = i16(n);

        bp.max_ore_cost = math.max(bp.ore_robot_ore_cost, bp.clay_robot_ore_cost);
        bp.max_ore_cost = math.max(bp.max_ore_cost, bp.obsidian_robot_ore_cost);
        bp.max_clay_cost = bp.obsidian_robot_clay_cost;
        bp.max_obsidian_cost = bp.geode_robot_obsidian_cost;
        append(&blueprints, bp);
    }

    for bp, i in blueprints {
        p1 += cast(int) (i16(i + 1) * max_geodes(bp, factory_state_t{ore_per_minute = 1, minutes = 24}));
        if i < 3 {
            q := max_geodes(bp, factory_state_t{ore_per_minute = 1, minutes = 32});
            p2 *= int(q);
        }
    }

    return p1, p2;
}