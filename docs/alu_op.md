# Docs

## Alu

### alu_op

	0: 1 + 2
	1: 1 - 2
	2: 1 and 2
	3: 1 or 2
	4: 1 sll 2 (if input2 == 0, input1 << 8)
	5: 1 sra 2 (if input2 == 0, input1 >> 8)
	6: 1 == 2 (if 1==2, return 0, else return 1)
	7: 1 < 2 (unsigned) (if 1 < 2, return 1, else return 0)
	8: 1
	9: 2
	A~E: Reserved
	F: 0
