     1	nop
     2	lui $1, 0x1234
     3	nop
     4	nop
     5	sw $1, 4($0)
     6	nop
     7	nop
     8	ori $1, 0x5678
     9	nop
    10	nop
    11	sw $1, 4($0)
    12	nop
    13	nop
    14	lui $2, 0xfedc
    15	nop
    16	nop
    17	sw $2, 8($0)
    18	nop
    19	nop
    20	ori $2, 0xba98
    21	nop
    22	nop
    23	sw $2, 8($0)
    24	nop
    25	nop
    26	sw $1, 0($2)
    27	sw $1, 4($2)
    28	sw $2, 8($1)
    29	sw $2, 12($1)
    30	sh $1, 0($2)
    31	sh $1, 2($2)
    32	sh $2, 8($1)
    33	sh $2, 10($1)
    34	sb $1, 0($2)
    35	sb $1, 1($2)
    36	sb $1, 2($2)
    37	sb $1, 3($2)
    38	sb $2, 8($1)
    39	sb $2, 9($1)
    40	sb $2, 10($1)
    41	sb $2, 11($1)
    42	lw $3, 4($0)
    43	lh $4, 4($0)
    44	lh $5, 6($0)
    45	lhu $6, 8($0)
    46	lhu $7, 10($0)
    47	lb $8, 4($0)
    48	lb $9, 5($0)
    49	lb $10, 6($0)
    50	lb $11, 7($0)
    51	lbu $12, 8($0)
    52	lbu $13, 9($0)
    53	lbu $14, 10($0)
    54	lbu $15, 11($0)
    55	sw $3, 4($0)
    56	sw $4, 4($0)
    57	sw $5, 4($0)
    58	sw $6, 4($0)
    59	sw $7, 4($0)
    60	sw $8, 4($0)
    61	sw $9, 4($0)
    62	sw $10, 4($0)
    63	sw $11, 4($0)
    64	sw $12, 4($0)
    65	sw $13, 4($0)
    66	sw $14, 4($0)
    67	sw $15, 4($0)
    68	lw $16, 4($0)
    69	lh $17, 4($0)
    70	lh $18, 6($0)
    71	lhu $19, 8($0)
    72	lhu $20, 10($0)
    73	lb $21, 4($0)
    74	lb $22, 5($0)
    75	lb $23, 6($0)
    76	lb $24, 7($0)
    77	lbu $25, 8($0)
    78	lbu $26, 9($0)
    79	lbu $27, 10($0)
    80	lbu $28, 11($0)
    81	sw $16, 4($0)
    82	sw $17, 4($0)
    83	sw $18, 4($0)
    84	sw $19, 4($0)
    85	sw $20, 4($0)
    86	sw $21, 4($0)
    87	sw $22, 4($0)
    88	sw $23, 4($0)
    89	sw $24, 4($0)
    90	sw $25, 4($0)
    91	sw $26, 4($0)
    92	sw $27, 4($0)
    93	sw $28, 4($0)
    94	nop
    95	nop