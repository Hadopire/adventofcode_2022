package aoc

import "core:strings"
import "core:math"

d08 :: proc(content: string) -> (result_t, result_t) {
    first, second: u64;
    lines := strings.split_lines(content);
    width, height := len(lines[0]), len(lines);
    if len(lines[height-1]) == 0 {
        height -= 1;
    }

    // part 1 5Head
    is_visible := make([]bool, width * height);
    for y := 0; y < height; y += 1 {
        max_height: u8;
        current_score: u64;
        for x := 0; x < width; x += 1 {
            is_visible[x + y*width] = lines[y][x] > max_height;
            max_height = math.max(max_height, lines[y][x]);
        }
        
        max_height = 0;
        for x := width - 1; x >= 0; x -= 1 {
            is_visible[x + y*width] = lines[y][x] > max_height || is_visible[x + y*width];
            max_height = math.max(max_height, lines[y][x]);
        }
    }

    for x := 0; x < width; x += 1 {
        max_height: u8;
        for y := 0; y < height; y += 1 {
            is_visible[x + y*width] = lines[y][x] > max_height || is_visible[x + y*width];
            max_height = math.max(max_height, lines[y][x]);
        }
        
        max_height = 0;
        for y := height - 1; y >= 0; y -= 1 {
            is_visible[x + y*width] = lines[y][x] > max_height || is_visible[x + y*width];
            max_height = math.max(max_height, lines[y][x]);

            first += u64(is_visible[x + y*width]);
        }
    }

    // part 2 Pepega
    for i := 0; i < width * height; i += 1 {
        col, row := i % width, i / width;
        tree_height := lines[row][col];
        score: [4]u64;

        for x := col - 1; x >= 0; x -= 1 {
            score.x += 1;
            if lines[row][x] >= tree_height do break;
        }

        for x := col + 1; x < width; x += 1 {
            score.y += 1;
            if lines[row][x] >= tree_height do break;
        }

        for y := row - 1; y >= 0; y -= 1 {
            score.z += 1;
            if lines[y][col] >= tree_height do break;
        }

        for y := row + 1; y < height; y += 1 {
            score.w += 1;
            if lines[y][col] >= tree_height do break;
        }

        second = math.max(score.x * score.y * score.z * score.w, second);
    }

    return first, second;
}