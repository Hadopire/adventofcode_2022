package aoc

import "core:strings"
import "core:slice"

next_token :: proc(buf: []u8, i: ^int, depth_offset: ^int) -> (int, bool) {
    if depth_offset^ > 0 {
        depth_offset^ -= 1;
        return 0, false;
    }

    for buf[i^] == ',' do i^ += 1;
    defer i^ += 1;

    if buf[i^] == '1' && buf[i^ + 1] == '0' {
        i^ += 1;
        return ':', true;
    } else if buf[i^] == ']' {
        return 0, false;
    }

    return int(buf[i^]), buf[i^] >= '0' && buf[i^] <= '9';
}

cmp :: proc(a, b: []u8) -> slice.Ordering {
    ai:= 0;
    bi:= 0;
    a_depth_offset, b_depth_offset: int;
    token_a, is_digit_a := next_token(a, &ai, &a_depth_offset);
    token_b, is_digit_b := next_token(b, &bi, &b_depth_offset);

    for ai < len(a) || bi < len(b) {
        if token_a == '[' && is_digit_b {
            b_depth_offset += 1;
            token_a, is_digit_a = next_token(a, &ai, &a_depth_offset);
        } else if token_b == '[' && is_digit_a {
            a_depth_offset += 1;
            token_b, is_digit_b = next_token(b, &bi, &b_depth_offset);
        } else if token_a != token_b {
            return slice.Ordering(sign(token_a - token_b));
        } else {
            token_a, is_digit_a = next_token(a, &ai, &a_depth_offset);
            token_b, is_digit_b = next_token(b, &bi, &b_depth_offset);
        }
    }

    return slice.Ordering.Equal;
}

d13 :: proc(content: string) -> (result_t, result_t) {
    pairs := strings.split(content, "\n\n");
    all_packets := make([]([]u8), len(pairs) * 2 + 2);
    all_packets[0] = transmute([]u8)string("[[2]]");
    all_packets[1] = transmute([]u8)string("[[6]]");
    
    p1, p2 := 0, 1;
    for pair, i in pairs {
        lists := strings.split_lines(pair);
        a := transmute([]u8)lists[0];
        b := transmute([]u8)lists[1];

        if cmp(a, b) == slice.Ordering.Less do p1 += i + 1;

        all_packets[i*2 + 2] = a;
        all_packets[i*2 + 3] = b;
    }

    slice.sort_by_cmp(all_packets, cmp);

    for packet, i in all_packets {
        if string(packet) == "[[2]]" || string(packet) == "[[6]]" {
            p2 *= i + 1;
        }
    }

    return p1, p2;
}