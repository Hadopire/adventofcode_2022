package aoc

import "core:intrinsics"
import "core:strings"

char_to_bit_idx: [256]byte = {
    'a'= 1,'b'= 2,'c'= 3,'d'= 4,'e'= 5,'f'= 6,'g'= 7,'h'= 8,'i'= 9,'j'=10,'k'=11,'l'=12,'m'=13,
    'n'=14,'o'=15,'p'=16,'q'=17,'r'=18,'s'=19,'t'=20,'u'=21,'v'=22,'w'=23,'x'=24,'y'=25,'z'=26,
    'A'=27,'B'=28,'C'=29,'D'=30,'E'=31,'F'=32,'G'=33,'H'=34,'I'=35,'J'=36,'K'=37,'L'=38,'M'=39,
    'N'=40,'O'=41,'P'=42,'Q'=43,'R'=44,'S'=45,'T'=46,'U'=47,'V'=48,'W'=49,'X'=50,'Y'=51,'Z'=52,
}

to_bitset :: proc(str: []u8) -> (bitset : u64){
    for char in str do bitset |= (1 << char_to_bit_idx[char]);
    return;    
}

d03 :: proc(content: string) -> (u64, u64) {
    first, second : u64;
    it := content;
    for line in strings.split_lines_iterator(&it) {
        if len(line) == 0 do break;

        half_length := len(line) / 2; 
        a := to_bitset(transmute([]u8)line[:half_length]);
        b := to_bitset(transmute([]u8)line[half_length:]);
        first += intrinsics.count_trailing_zeros(a & b);
    }

    it = content;
    for first_line in strings.split_lines_iterator(&it) {
        if len(first_line) == 0 do break;

        second_line, _ := strings.split_lines_iterator(&it);
        third_line, _ := strings.split_lines_iterator(&it);

        a := to_bitset(transmute([]u8)first_line);
        b := to_bitset(transmute([]u8)second_line);
        c := to_bitset(transmute([]u8)third_line);
        second += intrinsics.count_trailing_zeros(a & b & c);
    }

    return first, second;
}