package aoc

import "core:os"
import "core:fmt"
import "core:strings"
import "core:time"

day_proc :: proc(string) -> (u64, u64);

run :: proc(day: string, procedure : day_proc) {
    filename: string = strings.concatenate({day, ".txt"});
    defer delete(filename);

    content, ok := os.read_entire_file(filename); 
    if !ok {
        fmt.println("Failed to read file ", filename);
        return;
    }
    defer delete(content);

    stopwatch : time.Stopwatch;
    time.stopwatch_start(&stopwatch);
    part1, part2 := procedure(string(content));
    time.stopwatch_stop(&stopwatch);

    fmt.println(day, " -- ", time.duration_milliseconds(stopwatch._accumulation), "ms\n   part 1: ", part1, "\n   part 2: ", part2);
}

main :: proc() {
    days := map[string]day_proc {
        "d01" = d01,
    };

    if (len(os.args) > 1) {
        procedure, ok := days[os.args[1]];
        if (ok) {
            run(os.args[1], procedure);
        } else {
            fmt.println("Invalid argument: ", os.args[1]);
        }
    } else {
        for day, procedure in days {
            run(day, procedure);
        }
    }
}