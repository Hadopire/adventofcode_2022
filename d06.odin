package aoc

find_marker :: proc(content: string, n: int) -> u64 {
    byte_stream := transmute([]u8)content;
    seen_pos : [max(u8)]int;
    unique_count : int;

    for i := 0; i < len(byte_stream); i += 1 {
        char := byte_stream[i];
        seen_offset := i - seen_pos[char];

        if (seen_offset <= unique_count) {
            unique_count = seen_offset;
        } else {
            unique_count += 1;
        }

        if (unique_count == n) do return u64(i + 1);
        seen_pos[char] = i;
    }

    return max(u64);
}

d06 :: proc(content: string) -> (result_t, result_t) {
    return find_marker(content, 4), find_marker(content, 14);
}