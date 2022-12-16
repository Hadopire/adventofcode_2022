package aoc

import "core:strings"
import "core:strconv"
import "core:math"
import "core:slice"

range_t :: [2]int;

edge_t :: struct {
    start, end: vec2,
};

sensor_t :: struct {
    position: vec2,
    sensor_range: int,
}

d15 :: proc(content: string) -> (result_t, result_t) {
    row :: 2000000;
    max_coord :: 4000000;
    beacons_on_row: [dynamic]int;
    row_ranges: [dynamic]range_t;
    edges: [dynamic]edge_t;
    sensors: [dynamic]sensor_t;
    p1, p2: u64;

    it := content;
    for line in strings.split_lines_iterator(&it) {
        sensor, beacon: vec2;
        offset, at := 12, 0;
        sensor.x, _ = strconv.parse_int(line[offset:], 10, &at); offset += at + 4;
        sensor.y, _ = strconv.parse_int(line[offset:], 10, &at); offset += at + 25;
        beacon.x, _ = strconv.parse_int(line[offset:], 10, &at); offset += at + 4;
        beacon.y, _ = strconv.parse_int(line[offset:], 10, &at);
        difference := sensor - beacon;
        sensor_range := abs(difference.x) + abs(difference.y);
        append(&sensors, sensor_t{ sensor, sensor_range });

        // p1
        if beacon.y == row {
            _, found := slice.linear_search(beacons_on_row[:], beacon.y);
            if !found {
                append(&beacons_on_row, beacon.y);
                p1 -= 1;
            }
        }

        dist_from_row := abs(row - sensor.y);
        if (dist_from_row <= sensor_range) {
            range := range_t{
                sensor.x - sensor_range + dist_from_row,
                sensor.x + sensor_range - dist_from_row,
            };
            append(&row_ranges, range);
        }

        // p2
        append(&edges, edge_t{
            sensor - vec2{0, sensor_range + 1},
            sensor - vec2{sensor_range, 1},
        });
        append(&edges, edge_t{
            sensor - vec2{sensor_range + 1, 0},
            sensor + vec2{-1, sensor_range},
        });
        append(&edges, edge_t{
            sensor + vec2{0, sensor_range + 1},
            sensor + vec2{sensor_range, 1},
        });
        append(&edges, edge_t{
            sensor + vec2{sensor_range + 1, 0},
            sensor + vec2{1, -sensor_range},
        });
    }

    // p1
    slice.sort_by(row_ranges[:], proc(i, j: range_t) -> bool { return i.x < j.x; });
    for i := 0; i < len(row_ranges); i += 1 {
        start := row_ranges[i].x;
        end := row_ranges[i].y;
        for j := i + 1; j < len(row_ranges); j += 1 {
            if row_ranges[j].x <= end {
                end = math.max(end, row_ranges[j].y);
                i = j;
            } else do break;
        }
        p1 += u64(end - start + 1);
    }

    // p2
    edge_loop: for edge in edges {
        dir := edge.end - edge.start;
        dir.x = sign(dir.x);
        dir.y = sign(dir.y);

        seg_loop: for p := edge.start; p - dir != edge.end; p += dir {
            if p.x >= 0 && p.x <= max_coord && p.y >= 0 && p.y <= max_coord {
                for sensor in sensors {
                    difference := sensor.position - p;
                    dist := abs(difference.x) + abs(difference.y);
                    if dist <= sensor.sensor_range {
                        continue seg_loop;
                    }
                }

                p2 = u64(p.x * 4000000 + p.y);
                break edge_loop;
            }
        }
    }

    return p1, p2;
}