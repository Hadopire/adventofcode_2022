package aoc

import "core:strings"

d25 :: proc(content: string) -> (result_t, result_t) {
    it := content;
    sum: int;
    for line in strings.split_lines_iterator(&it) {
        pow_5 := 1;
        number := 0;
        for i := len(line)-1; i >= 0; i -= 1 {
            switch line[i] {
                case '2': number += pow_5 * 2;
                case '1': number += pow_5;
                case '-': number += pow_5 * -1;
                case '=': number += pow_5 * -2;
            }
            pow_5 *= 5;
        }

        sum += number;
    }

    str := make([]u8, 20);
    str_idx := len(str)-1;

    for sum != 0 {
        r := sum % 5;
        if r < 3 {
            str[str_idx] = '0' + u8(r);
            sum = (sum - r) / 5;
        } else {
            switch r {
                case 3: str[str_idx] = '=';
                case 4: str[str_idx] = '-';
            }
            sum = (sum + (5-r)) / 5;
        }

        str_idx -= 1;
    }

    return string(str[str_idx + 1:]), int(0);
}