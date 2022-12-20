package aoc

import "core:os"
import "core:fmt"
import "core:strings"
import "core:time"
import "core:mem"
import "core:mem/virtual"

day_proc :: proc(string) -> (result_t, result_t);
result_t :: union {
    int,
    u64,
    string,
};

run :: proc(day: string, procedure: day_proc, iter: int = 1) -> f64 {
    filename: string = strings.concatenate({day, ".txt"});
    defer delete(filename)

    content, ok := os.read_entire_file(filename); 
    if !ok {
        fmt.println("Failed to read file ", filename);
        return 0;
    }
    defer delete(content);

    arena : virtual.Arena;
    prev_allocator : mem.Allocator;
        
    assert(virtual.arena_init_growing(&arena) == virtual.Allocator_Error.None);
    prev_allocator, context.allocator = context.allocator, virtual.arena_allocator(&arena);
    defer {
        context.allocator = prev_allocator;
        virtual.arena_destroy(&arena);
    };
    
    acc : f64 = 0.0;
    part1, part2 : result_t;
    for i := 0; i < iter; i += 1  {
        content_copy := make([]u8, len(content));
        copy(content_copy, content);
        stopwatch : time.Stopwatch;

        time.stopwatch_start(&stopwatch);
        part1, part2 = procedure(string(content_copy));
        time.stopwatch_stop(&stopwatch);

        acc += time.duration_milliseconds(stopwatch._accumulation);
        if i + 1 != iter do virtual.arena_free_all(&arena);
    }
    average_time := acc / f64(iter);

    print_result_t :: proc(result: result_t) {
        #partial switch in result {
            case string: {
                padding := 0;
                it := result;
                for line in strings.split_lines_iterator(&it.(string)) {
                    for i in 0..<padding do fmt.printf(" ");
                    fmt.println(line);
                    padding = 11;
                }
            }
            case: fmt.printf("%v\n", result)
        }
    }

    fmt.printf("%s -- %fms\n   part 1: ", day, average_time);
    print_result_t(part1);
    fmt.printf("   part 2: ");
    print_result_t(part2);
    return average_time;
}

main :: proc() {
    days := map[string]day_proc {
        "d01" = d01,
        "d02" = d02,
        "d03" = d03,
        "d04" = d04,
        "d05" = d05,
        "d06" = d06,
        "d07" = d07,
        "d08" = d08,
        "d09" = d09,
        "d10" = d10,
        "d11" = d11,
        "d12" = d12,
        "d13" = d13,
        "d14" = d14,
        "d15" = d15,
        "d16" = d16,
        "d17" = d17,
        "d18" = d18,
        "d19" = d19,
    }; defer delete(days);

    iter := 1;
    keys : [dynamic]string; defer delete(keys);
    for i := 1; i < len(os.args); i += 1 {
        if strings.compare(os.args[i], "-bench") == 0 {
            iter = 100;
            continue;
        }

        _, ok := days[os.args[i]];
        if !ok {
            fmt.println("Invalid argument: ", os.args[i]);
            return;
        }

        append(&keys, os.args[i]);
    }

    total_time : f64;
    if len(keys) > 0 {
        for key in keys do total_time += run(key, days[key], iter);
    } else {
        for day, procedure in days do total_time += run(day, procedure, iter);
    }

    fmt.println("total - ", total_time, "ms");
}