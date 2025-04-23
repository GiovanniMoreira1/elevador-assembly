        ORG 0000H
        LJMP INICIO

ANDAR_ATUAL    EQU 10H
ANDAR_DESTINO  EQU 11H
DISPLAY_VALOR  EQU 12H
LED_SUBIR 	   EQU P2.7
LED_DESCER	   EQU P2.0
MOTOR_B0	   EQU P3.0
MOTOR_B1	   EQU P3.1

        ORG 0100H
INICIO:

VOLTA:
	CALL TECLADO
    MOV A, ANDAR_ATUAL
    CJNE A, ANDAR_DESTINO, MOVE_ELEV ; compara andar atual e andar destino, se forem diferentes, chama a rotina MOVE_ELEV
    CLR MOTOR_B0
	CLR MOTOR_B1
	SJMP VOLTA     

TECLADO:
    MOV R0, #1 ; inicia com 1 para mapear as teclas

    ; scan row3
    SETB P0.0 
    CLR P0.3 
    CALL colScan 

    ; scan row2
    SETB P0.3 
    CLR P0.2 
    CALL colScan 	

    ; scan row1
    SETB P0.2 
    CLR P0.1 
    CALL colScan 

    ; scan row0
    SETB P0.1 
    CLR P0.0 
    CALL colScan

    JMP SAIR

colScan:
    JNB P0.6, gotKey 
    INC R0
    JNB P0.5, gotKey 
    INC R0
    JNB P0.4, gotKey 
    INC R0
    RET 

gotKey:
    MOV ANDAR_DESTINO, R0
    CJNE R0, #0BH, aguardaSoltar
    SJMP setZero

aguardaSoltar:
    JB P0.4, SAIR
    SJMP aguardaSoltar

setZero:
    MOV ANDAR_DESTINO, #00H
    SJMP MOSTRAR_DISPLAY
    RET

TABELA_DISPLAY:
    DB C0H ; 0
    DB F9H ; 1
    DB A4H ; 2
    DB B0H ; 3
    DB 99H ; 4
    DB 92H ; 5
    DB 82H ; 6
    DB F8H ; 7
    DB 80H ; 8
    DB 98H ; 9

MOSTRAR_DISPLAY:
    MOV DPTR, #TABELA_DISPLAY
    MOV A, DISPLAY_VALOR
    MOVC A, @A+DPTR
    MOV P1, A
    RET

DELAY:
NEXT:   MOV R5, #50
AGAIN:  DJNZ R5, AGAIN
        DJNZ R4, NEXT
        RET

MOVE_ELEV:
    MOV A, ANDAR_ATUAL
    CJNE A, ANDAR_DESTINO, VERIFICAR ; verifica se atual != destino
	RET

VERIFICAR:
	CLR C
	MOV A, ANDAR_DESTINO
	SUBB A, ANDAR_ATUAL ; caso seja positivo, o programa chama a rotina subir (carry = 0), caso a subb resulte em negativo o carry eh ativado, portanto o DESCER eh chamado
    JC DESCER
    AJMP SUBIR

SUBIR:
	SETB MOTOR_B0
	CLR MOTOR_B1
	SETB LED_DESCER
	CLR LED_SUBIR
    INC ANDAR_ATUAL
    MOV DISPLAY_VALOR, ANDAR_ATUAL
    CALL MOSTRAR_DISPLAY
	MOV R4, #120 ; tempo pro delay (achei aceitavel 120)
    CALL DELAY
    SJMP MOVE_ELEV ; volta para verificar se chegou no destino

DESCER:
	CLR MOTOR_B0
	SETB MOTOR_B1
	SETB LED_SUBIR
	CLR LED_DESCER
    DEC ANDAR_ATUAL
    MOV DISPLAY_VALOR, ANDAR_ATUAL
    CALL MOSTRAR_DISPLAY
    MOV R4, #120 ; delay
	CALL DELAY
    SJMP MOVE_ELEV ; volta para verificar se chegou no destino


SAIR:
    RET  
