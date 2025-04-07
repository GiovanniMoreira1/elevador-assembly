    ORG 0000H
    LJMP INICIO

    ORG 0100H
INICIO:
    MOV R7, #00
VOLTA:
    CALL TECLADO
    SJMP VOLTA     

TECLADO:
	MOV R0, #1 ; clear R0 - the first key is key0
	; scan row3
	SETB P0.0 ; set row2
	CLR P0.3 ; clear row3
	CALL colScan ; call column-scan subroutine

	; scan row2
	SETB P0.3 ; set row1
	CLR P0.2 ; clear row2
    CALL colScan ; call column-scan subroutine	

	; scan row1
	SETB P0.2 ; set row0
	CLR P0.1 ; clear row1
	CALL colScan ; call column-scan subroutine
		
	; scan row0
	SETB P0.1 ; set row3
	CLR P0.0 ; clear row0
	CALL colScan ; call column-scan subroutine

	JMP SAIR
    
colScan:
	JNB P0.6, gotKey ; if col0 is cleared - key found
	INC R0 ; otherwise move to next key
	JNB P0.5, gotKey ; if col1 is cleared - key found
	INC R0 ; otherwise move to next key
	JNB P0.4, gotKey ; if col2 is cleared - key found
	INC R0 ; otherwise move to next key
	RET ; return from subroutine - key not found

gotKey:
    MOV A,R0
	MOV R7, A
	CLR A
	CJNE R0, #0BH, aguardaSoltar
	AJMP setZero

aguardaSoltar:
	JB P0.4, SAIR
	SJMP aguardaSoltar

setZero:
	MOV R7, #00H
	RET

SAIR:
	RET  