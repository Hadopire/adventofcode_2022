package aoc

import "core:strings"
import "core:strconv"
import "core:container/queue"
import "core:slice"

operand_type_t :: enum {
    literal,
    old,
};

operator_t :: enum {
    addition,
    multiplication,
};

monkey_t :: struct {
    items: queue.Queue(u64),
    operands_type: [2]operand_type_t,
    operands_value: [2]u64,
    operator: operator_t,
    test: u64,
    targets: [2]int,
};

d11 :: proc(content: string) -> (result_t, result_t) {
    monkeys_p1, monkeys_p2: [dynamic]monkey_t;
    activity_p1, activity_p2: [dynamic]u64;
    modulus: u64 = 1;

    it := content;
    for monkey_str in strings.split_iterator(&it, "\n\n") {
        if len(monkey_str) == 0 do break;

        split := strings.split_lines(monkey_str);
        monkey: monkey_t;

        items_it := split[1][18:];
        for item_str in strings.split_iterator(&items_it, ", ") {
            n, _ := strconv.parse_u64(item_str);
            queue.push_back(&monkey.items, n);
        }

        op_str := strings.split(split[2][19:], " ");
        monkey.operator = op_str[1][0] == '+' ? .addition : .multiplication;
        monkey.operands_type[0] = .old;
        switch(op_str[2][0]) {
            case 'o': monkey.operands_type[1] = .old;
            case: {
                n, _ := strconv.parse_u64(op_str[2]);
                monkey.operands_type[1] = .literal;
                monkey.operands_value[1] = n;
            }
        }

        monkey.test, _ = strconv.parse_u64(split[3][21:]);
        monkey.targets[0], _ = strconv.parse_int(split[5][30:]);
        monkey.targets[1], _ = strconv.parse_int(split[4][29:]);
       
        modulus *= monkey.test;

        idx := len(monkeys_p1);
        append(&monkeys_p1, monkey);
        monkey.items.data = make([dynamic]u64, len(monkeys_p1[idx].items.data));
        copy(monkey.items.data[:], monkeys_p1[idx].items.data[:]);
        append(&monkeys_p2, monkey);
        append(&activity_p1, 0);
        append(&activity_p2, 0);
    }

    for _ in 0..<20 {
        for _, i in monkeys_p1 {
            monkey := &monkeys_p1[i];
            activity_p1[i] += u64(queue.len(monkey.items));

            for queue.len(monkey.items) != 0 {
                item := queue.pop_front(&monkey.items);
                operand := monkey.operands_type[1] == .literal ? monkey.operands_value[1] : item;
                switch monkey.operator {
                    case .addition: item += operand;
                    case .multiplication: item *= operand;
                }

                item /= 3;

                target := monkey.targets[int(item % monkey.test == 0)];
                queue.push_back(&monkeys_p1[target].items, item);
            }
        }
    }

    for _ in 0..<10000 {
        for _, i in monkeys_p2 {
            monkey := &monkeys_p2[i];
            activity_p2[i] += u64(queue.len(monkey.items));

            for queue.len(monkey.items) != 0 {
                item := queue.pop_front(&monkey.items);
                operand := monkey.operands_type[1] == .literal ? monkey.operands_value[1] : item;
                switch monkey.operator {
                    case .addition: item += operand;
                    case .multiplication: item *= operand;
                }

                if item >= modulus {
                    item %= modulus;
                }

                target := monkey.targets[int(item % monkey.test == 0)];
                queue.push_back(&monkeys_p2[target].items, item);
            }

        }
    }

    slice.reverse_sort(activity_p1[:]);
    slice.reverse_sort(activity_p2[:]);
    return activity_p1[0] * activity_p1[1], activity_p2[0] * activity_p2[1];
}