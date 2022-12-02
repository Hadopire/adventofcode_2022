package aoc

import "core:os"
import "core:fmt"
import "core:strings"
import "core:time"

day_proc :: proc(string) -> (u64, u64);

run :: proc(day: string, procedure : day_proc, iter : int = 1) {
    filename: string = strings.concatenate({day, ".txt"});
    defer delete(filename);

    content, ok := os.read_entire_file(filename); 
    if !ok {
        fmt.println("Failed to read file ", filename);
        return;
    }
    defer delete(content);


    acc : f64 = 0.0;
    part1, part2 : u64;
    for i := 0; i < iter; i += 1  {
        stopwatch : time.Stopwatch;

        time.stopwatch_start(&stopwatch);
        part1, part2 = procedure(string(content));
        time.stopwatch_stop(&stopwatch);

        acc += time.duration_milliseconds(stopwatch._accumulation);
    }

    fmt.println(day, " -- ", acc / f64(iter), "ms\n   part 1: ", part1, "\n   part 2: ", part2);
}

main :: proc() {
    days := map[string]day_proc {
        "d01" = d01,
        "d02" = d02,
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

    if len(keys) > 0 {
        for key in keys do run(key, days[key], iter);
    } else {
        for day, procedure in days do run(day, procedure, iter);
    }
}