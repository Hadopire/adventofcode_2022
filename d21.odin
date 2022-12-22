package aoc

import "core:strings"
import "core:strconv"
import "core:mem"

monkey_number_t :: struct {
    name: string,
    is_value: bool,
    value: f64,
    has_unknown: bool,
    op: u8,
    monkeys: [2]int,
}

monkey_number_value :: proc(idx: int, monkey_numbers: []monkey_number_t) -> f64 {
    number := &monkey_numbers[idx];
    if number.is_value do return number.value;

    a := monkey_number_value(number.monkeys[0], monkey_numbers);
    b := monkey_number_value(number.monkeys[1], monkey_numbers);
    number.is_value = true;

    switch number.op {
        case '+': number.value = a + b;
        case '-': number.value = a - b;
        case '*': number.value = a * b;
        case '/': number.value = a / b;
    }

    return number.value;
}

combine_like_terms :: proc(idx: int, monkey_numbers: []monkey_number_t) -> f64 {
    number := &monkey_numbers[idx];
    if number.name == "humn" {
        number.has_unknown = true;
        return 0;
    } else if number.is_value {
        return number.value;
    }

    a := combine_like_terms(number.monkeys[0], monkey_numbers);
    b := combine_like_terms(number.monkeys[1], monkey_numbers);

    if monkey_numbers[number.monkeys[0]].has_unknown || monkey_numbers[number.monkeys[1]].has_unknown {
        number.has_unknown = true;
        return 0;
    }

    number.is_value = true;
    switch number.op {
        case '+': number.value = a + b;
        case '-': number.value = a - b;
        case '*': number.value = a * b;
        case '/': number.value = a / b;
    }

    return number.value;
}

solve :: proc(idx: int, monkey_numbers: []monkey_number_t) -> f64 {
    number := &monkey_numbers[idx];
    if number.name == "humn" {
        number.value = number.value;
        return number.value;
    }

    known_idx, unknown_idx := number.monkeys[0], number.monkeys[1];
    known, unknown := &monkey_numbers[known_idx], &monkey_numbers[unknown_idx];
    if known.has_unknown {
        unknown_idx, known_idx = known_idx, unknown_idx;
        unknown, known = known, unknown;
    }

    switch number.op {
        case '+': unknown.value = number.value - known.value;
        case '-': unknown.value = known_idx == number.monkeys[0] ? known.value - number.value : number.value + known.value;
        case '*': unknown.value = number.value / known.value;
        case '/': unknown.value = known_idx == number.monkeys[0] ? known.value / number.value : number.value * known.value;
        case '=': unknown.value = known.value;
    }

    return solve(unknown_idx, monkey_numbers);
}

d21 :: proc(content: string) -> (result_t, result_t) {
    lines := strings.split_lines(content);
    p1_monkeys := make([]monkey_number_t, len(lines));
    p2_monkeys := make([]monkey_number_t, len(lines));
    name_to_idx: map[string]int;
    names := make([][2]string, len(lines));
    root_index: int;

    for line, i in lines {
        monkey_number: monkey_number_t;
        monkey_number.name = line[0:4];
        monkey_number.value, monkey_number.is_value = strconv.parse_f64(line[6:]);
        if !monkey_number.is_value {
            names[i][0] = line[6:10];
            names[i][1] = line[13:17];
            monkey_number.op = line[11];
        }

        p1_monkeys[i] = monkey_number;
        name_to_idx[monkey_number.name] = i;

        if monkey_number.name == "root" do root_index = i;
    }

    for _, i in p1_monkeys {
        if !p1_monkeys[i].is_value {
            p1_monkeys[i].monkeys[0] = name_to_idx[names[i][0]];
            p1_monkeys[i].monkeys[1] = name_to_idx[names[i][1]];
        }
    }

    mem.copy_non_overlapping(&p2_monkeys[0], &p1_monkeys[0], len(p1_monkeys) * size_of(monkey_number_t));
    p2_monkeys[root_index].op = '=';

    p1 := monkey_number_value(root_index, p1_monkeys);
    combine_like_terms(p2_monkeys[root_index].monkeys[0], p2_monkeys);
    combine_like_terms(p2_monkeys[root_index].monkeys[1], p2_monkeys);
    p2 := solve(root_index, p2_monkeys);

    return int(p1), int(p2);
}