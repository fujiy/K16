

データ16bit
プログラム24bit

アドレス16bit

# 命令

## データ

| Instruction | Opcode |           |
|-------------|--------|-----------|
| Im {a, b}   | 20     | 16bit即値 |
|             |        |           |

## 算術

| Instruction | Opcode |             |
|-------------|--------|-------------|
| ADD a b     | c0     | a + b       |
| ADD a im    | 80     | im + a      |
| SUB a b     | c1     | a + b       |
| SUB a im    | 81     | im - a      |
| AND a b     | c2     | a & b       |
| AND a im    | 82     | im & a      |
| OR a b      | c3     | a &#124; b  |
| OR a im     | 83     | im &#124; a |
| XOR a b     | c4     | a ^ b       |
| XOR a im    | 84     | im ^ a      |


## 分岐・ジャンプ

| Instruction | Opcode |                         |
|-------------|--------|-------------------------|
| JUMP im     | 60     | jump( im )              |
| JUMP  p     | 68     | jump( p )               |
| BR c im     | 70     | if c == 0 then jump(im) |
| BR c im     | 71     | if c /= 0 then jump(im) |
| BR c im     | 72     | if c <  0 then jump(im) |
| BR c im     | 73     | if c <= 0 then jump(im) |
| BR c im     | 74     | if c >  0 then jump(im) |
| BR c im     | 75     | if c >= 0 then jump(im) |
| BR c p      | 78     | if c == 0 then jump(p)  |
| BR c p      | 79     | if c /= 0 then jump(p)  |
| BR c p      | 7a     | if c <  0 then jump(p)  |
| BR c p      | 7b     | if c <= 0 then jump(p)  |
| BR c p      | 7c     | if c >  0 then jump(p)  |
| BR c p      | 7d     | if c >= 0 then jump(p)  |

## 関数

| Instruction | Opcode |
|-------------|--------|
| CALL im     | 3s     |
| CALL s p    | 50     |
| LEAVE       | 51     |
| PUSH s a    | 52     |
| RETUEN s a  | 53     |

## その他

| Instruction | Opcode |
|-------------|--------|
| NOP         | 00     |
| HALT        | 01     |

# 内部構造

## レジスタ

| Register | Name                   | Size  |
|----------|------------------------|-------|
| IP       | Instruction Pointer    | 16bit |
| BP       | Base Pointer           | 16bit |
| SP       | Stack Pointer          | 8bit  |
| RP       | Return Base Pointer    | 16bit |
| AS       | Argument Stack Pointer | 8bit  |
