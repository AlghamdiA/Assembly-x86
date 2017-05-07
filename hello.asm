	TITLE WHO ARE YOU
	PAGE	60,132
;	Ayman Alghamdi
;	It will ask for your name, then print it on the screen along with a welcome message.
;	This is a program to e
CR	EQU	0DH
LF	EQU	0AH
EOT	EQu	'$'

	JMP	START
INBUF	DB	50, ?, 50 DUP ?
INMSG	DB	CR, LF, LF, "Please type your name, then press ENTER:  ", EOT
HELLO	DB	CR, LF, "Welcome to Assemple Programming, ", EOT
BYE	DB	CR, LF, LF,  "Thank you and come again sometime.", EOT


start:	LEA	DX, INMSG
	MOV	AH, 09H
	INT	21H

	LEA	DX, INBUF
	MOV	AH, 0AH
	INT	21H


	LEA	SI, INBUF+2
	MOV	BL, [SI-1]
	MOV	BH, 0
	MOV	B[BX + SI], EOT



	LEA	BX, HELLO
	MOV	AH, 09H
	INT	21H


	LEA	DX, INBUF+2
	MOV	AH, 09H
	INT	21H

	LEA	DX, BYE
	MOVE	AH, 09H
	INT	21H

	MOV	AX, 4C00H
	INT	21H
	END