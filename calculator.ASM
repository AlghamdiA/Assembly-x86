	TITLE	Ayman's Assembly Calculator
	PAGE	70, 132
;
;	Name: Ayman Alghamdi	
;	This is a calculator. It does addition, subtraction, 
;	multiplication, and division. The user need to enter
;	an equation in form of NUM1 OP NUM2 then press <ENTER>.
;	E.g. 55 + 7 <ENTER>.
;	The program uses macros for input and output of messages
;	and exiting the program, and a subroutine for the output
;	the result, addition, subtraction, multiplication,
;	and division.
;	The input is an equation in form of NUM1 OP NUM2.
;
;
;	Define constants and macros
;
CR	EQU	0DH	;define carriage return  
LF	EQU	0AH	;define LINE FEED
EOT	EQU	'$'	;define end of text marker of INT 21H
SPACE	EQU	' '	;define space character
	
;
WRITE	MACRO		;wirte text to screen
	LEA	DX, #1
	MOV	AH, 09H
	INT	21H
	#EM
;
READ	MACRO		;read string from kaybord
	LEA	DX, #1
	MOV	AH, 0AH
	INT	21H
	#EM
;
GET	MACRO		;gets one character with echo from keybord
	MOV	AH, 01H
	INT	21H
	#EM
;
PUT	MACRO		;writes one character to monitor
	MOV	DL, #1
	MOV	AH, 02H
	INT	21H
	#EM
;
EXIT	MACRO		;exites program
	MOV	AX, 4C00H
	INT	21H
	#EM
;
;	jump over the variable declarations
;

	JMP	START 	;by pass variable definitions

	;variable definitions

;**********************************************
CRLF	DB	CR, LF, EOT 

ERROROPCODE:	DB	LF, LF, "Invalid equation ", LF, EOT
INBUF	DB	15, ?, 15 DUP	?
BNUM1   DB  	20 DUP ?
BNUM2   DB  	20 DUP ?
MSG1	DB	CR, LF, "Enter an equation in form of NUM1 OP NUM2 <ENTER>: ", LF, EOT
operation	DB	?, EOT
AGAIN1	DB	CR, LF, LF, "Do it again? Y or N:   ", EOT
RESMSG	DB 	CR, LF, LF, " = ", EOT
MINSIGN DB	"- ", EOT
FNUM	DB	20 Dup ?
FNUM2 	DB	20 Dup ?

 

;	The main program
START:
	CALL	CLS		;clear the screen
START0:		
	WRITE	MSG1		; Aske for an equation
	READ	INBUF		; get equation
	CALL	A2B8		; tokenize the equation and convert it to binary
	
	CALL    MATH		; check which operation use.
	CALL	B2A8		; convert binare to ASCII
	
	CALL	OUTPUT
	WRITE	FNUM2		; print the final result to screen
AGAIN:		
	WRITE	AGAIN1		;Ask if you want to repeat program 
	GET			;get response				
	CMP	AL, 'Y'		;If yes, start over
	JE	START			
	CMP	AL, 'y'		;other way to say yes
	JE	START
	EXIT          		; else exit  

;************************************* 
;
;	Subroutine  A2B8
;
;	A subroutine to tokenize the input and convert it binary value.
;	Then it will save it in memory as BNUM1, BNUM2, and operation.
;
;	Entry:	Nene
;
;	EXIT:	None
;
A2B8:
	LEA	SI, INBUF+2
	MOV BL, [SI-1]		; SIZE OF THE INPUT.
	MOV	AX, 0
    	MOV	CX, 0
	MOV	BH, 10
GETNUM1:	
	CMP	B[SI], SPACE
	JE	DONE
	MOV	AL, B[SI]	; move the character to AL
	PUSH	AX		; take the character out
	MOV	AX, CX		; move the result to AX
	MUL	BH		; multiply by 10 to convert the result to binary
	MOV	CX, AX		; save the result in cx.
	POP	AX		; turn the character.
	SUB	AL, 30H		;convert to hex
	MOV	AH, 0		;cleare ah
	ADD	CX, AX		; add the number to result in cx
	INC	SI
	DEC BL			;DEC size of input
	JMP	GETNUM1		; do next character

DONE:
	MOV	W[BNUM1], CX	; save first number to buffer
	LEA	DI, operation	

OPERA:
	INC	SI 
	DEC BL			;DEC size of input
	CMP	B[SI], SPACE	;if SI = space
	JE	OPERA
	MOV	AH, [SI]	;save operation to AH
	MOV	[DI], AH	;save operation in memory
	MOV	AX, 0
    	MOV	CX, 0
	MOV	BH, 10	
	

GETNUM2:
	INC SI
	DEC BL			;DEC size of input
	CMP	BL, 0		; check if it end of input
	JE	DONEE
	CMP	B[SI], SPACE
	JE	GETNUM2
	MOV	AL, B[SI]	; move the character to AL
	PUSH	AX		; take the character out
	MOV	AX, CX		; move the result to AX
	MUL	BH		; multiply by 10 to convert to binary
	MOV	CX, AX		; save the result in cx.
	POP	AX		; turn the character.
	SUB	AL, 30H		;convert to hex
	MOV	AH, 0		;cleare ah
	ADD	CX, AX		; add the number to result in cx
	JMP	GETNUM2		; do next character

DONEE:
	MOV	W[BNUM2], CX	; save the second number to buffer
	RET         
             
;************************************* 
;	Subroutine  MATH
;
;	A subroutine to check what operation will use.
; 
;	Entry:	None
;	EXIT:	None
MATH:
	LEA	DI, operation
	CMP	B[DI], '+'
	JE	DoADD
	CMP	B[DI], '*'
	JE	DoMULT 
	CMP	B[DI], '/'
	JE	DoDIV 
	CMP	B[DI], '-'
	JE	DoSUB 
	WRITE	ERROROPCODE	;Error if operation input not correct		  
	JMP	START0		 

;************************************* 
;	Subroutine  DoADD
;
;	A subroutine to do addtion BNUM1 + BNUM2.
; 
;	Entry:	Non
;	EXIT:	AX hold the result
DoADD:
	
	WRITE	RESMSG		; write result messege
	MOV	AX, W[BNUM1]
	ADD	AX, W[BNUM2]
	LEA	DI, FNUM	
	RET

;************************************* 
;	Subroutine  DoSUB
;
;	A subroutine to do subtraction BNUM1 - BNUM2.
;	If BNUM1 is less than BNUM2, it will sawp and do
;	print '-' then do BNUM2 - BNUM1.
; 
;	Entry:	Non
;	EXIT:	AX hold the result
DoSUB:
		
	
	MOV	AX, W[BNUM1]
	CMP	AX, W[BNUM2]	; check if BNUM1 less than BNUM2
	JC	SWAPNUM		; if yes, sawp the places.
	WRITE	RESMSG		; write result messege
	SUB	AX, W[BNUM2]	
	RET

SWAPNUM:
	WRITE	RESMSG		; write result messege
    	WRITE	MINSIGN	 ;print minus sign to the screen.
   	MOV	AX, W[BNUM2]	; swap and BNUM2 - BNUM1
	SUB	AX, W[BNUM1]
	RET

;************************************* 
;	Subroutine  DoMULT
;
;	A subroutine to do BNUM1 * BNUM2
;		
;	Entry:	Non
;	EXIT:	AX hold the result
DoMULT:
	WRITE	RESMSG		; write result messege
	MOV	AX, W[BNUM1]
	MUL	BNUM2
	RET

;************************************* 
;	Subroutine  DoDIV
;
;	A subroutine to devide BNUM1/BNUM2
;		
;	Entry:	Non
;	EXIT:	AX hold the result

DoDIV:
	WRITE	RESMSG		; write result messege
	MOV	DX, 0
	MOV	AX, W[BNUM1]
	DIV	BNUM2
	RET



;************************************************
;
;	Subroutine  B2A8
;
;	A subroutine to convert 8 bit binary value tp 3 bytes of 
;	printable ASCII. No errors are detected in this module since none
;	are possible.
;	
;	Entry:	holds the 8 bit binary value to be converted to ASCII
;		DI point to a 3 byte buffer to store the ASCII characters
;	EXIT:	AL destroyed
;

B2A8:
	LEA	DI, FNUM	;point DI to ASCII save
	MOV	W[DI], 3030H	;preload ASCII buffer with number bias
	MOV	B[DI+2], 30H
B2A1:
	SUB	AL, 100		;subtract 100's placeholeder value
	JC	B2A2		;if negative, we subtracted too much
	INC	B[DI]		;if positive, add 1 to ASCII byte
	JMP	B2A1		;continue counting place values until minus
B2A2:
	ADD	AL, 100		;restore AL to previos valu oversubtracted
B2A3:
	SUB	AL, 10		;subtract 10's placeholeder value
	JC	B2A4		;if negative, we subtracted too much
	INC	B[DI+1]		;if positive, add 1 to ASCII byte
	JMP	B2A3		;continue counting place values until minus
B2A4:
	
	ADD	AL, 10		;restore AL to previos valu oversubtracted
	ADD	[DI+2], AL	;create units character
	MOV	B[DI+3], EOT	;mark end of the text
	RET

;************************************************
;
;	Subroutine  OUTPUT
;
;	A subroutine delete zeros that at the beging of the result and store 
;	the result in second buffer.
;	are possible.
;	
;	Entry:	DI point to a buffer to store the ASCII characters without zeros
;		SI point a buffer has ASCII result characters thatmight have zero
;		at the beging
;	EXIT:	
;
OUTPUT:

	LEA	SI, FNUM	;point to the result
	LEA	DI, FNUM2	;point to the save buffer
TT1:
	CMP	B[SI], '0'	;check if it '0'
	JE	CHECKEND	; yes, check if it end of buffer
	JMP	COPYALL		; if not '0', start copy.

COPYALL:

	MOV	[DI], [SI]	; start copying
	INC	SI		
	INC	DI
	CMP	B[SI], EOT	; check if it end of buffer
	JNE	COPYALL		; if not, keep copy.
	MOV	B[DI+1], EOT	; if yes, add '$' to end of result
	RET

CHECKEND:
	CMP	B[SI+1], EOT	; check if it end of buffer
	JE	ITZRORO		; if yes, copy zero.
	INC	SI		; if not, and back to check next
	JMP	TT1


ITZRORO:
	ADD	B[DI], 30H	; if the result '0'
	MOV	B[DI+1], EOT
	RET

;************************************************
;	SUBROTINE CLS
;

CLS:	MOV	AX, 0600H	;Set function code for scroll down
	MOV	BH, 07		;select active page
	MOV	CX, 000H	;start location
	MOV	DX, 184FH	;end location
	INT	10H		;call BIOS
	MOV	AH, 02H		;cursor set function
	MOV	BH, 00		;select page
	MOV	DX, 0000	;crusor coordinates
	INT	10H		;call BIOS
	RET
