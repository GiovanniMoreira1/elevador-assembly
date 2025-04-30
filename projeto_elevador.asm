        ORG 0000H
        LJMP INICIO 

ANDAR_ATUAL    EQU 10H 
ANDAR_DESTINO  EQU 11H 
DISPLAY_VALOR  EQU 12H 
LED_SUBIR 	   EQU P2.7 ; necessário alterar os pinos dos LEDs de P1 para P2
LED_DESCER	   EQU P2.0
MOTOR_B0	   EQU P3.0 ; controla o sentido do motor - bit menos significativo
MOTOR_B1	   EQU P3.1 ; controla o sentido do motor - bit mais significativo

        ORG 0100H
INICIO:

VOLTA:
	CALL TECLADO ; chama rotina que lê o teclado
    MOV A, ANDAR_ATUAL
    CJNE A, ANDAR_DESTINO, MOVE_ELEV ; compara andar atual e andar destino, se forem diferentes, chama a rotina MOVE_ELEV
    CLR MOTOR_B0
	CLR MOTOR_B1
	SJMP VOLTA ; repete o processo

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

colScan: ; escaneamento das colunas
    JNB P0.6, gotKey 
    INC R0
    JNB P0.5, gotKey 
    INC R0
    JNB P0.4, gotKey 
    INC R0
    RET 

gotKey:
    MOV ANDAR_DESTINO, R0 ; armazena o número da tecla pressionada como andar destino
    CJNE R0, #0BH, aguardaSoltar ; verifica se a tecla pressionada foi a de "zerar" (tecla 11 no mapeamento)
    SJMP setZero

aguardaSoltar: ; espera a tecla ser solta
    JB P0.4, SAIR
    SJMP aguardaSoltar

setZero: ; se pressionar a tecla 11, define o destino como 0
    MOV ANDAR_DESTINO, #00H
    SJMP MOSTRAR_DISPLAY ; atualiza o display para mostrar o zero
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

MOSTRAR_DISPLAY: ; percorre a tabela com os códigos dos números para o display de 7 segmentos
    MOV DPTR, #TABELA_DISPLAY
    MOV A, DISPLAY_VALOR
    MOVC A, @A+DPTR
    MOV P1, A ; exibe o valor correspondente no display
    RET

DELAY:
NEXT:   MOV R5, #50 ; laço externo do delay
AGAIN:  DJNZ R5, AGAIN ; laço interno
        DJNZ R4, NEXT
        RET

MOVE_ELEV:
    MOV A, ANDAR_ATUAL
    CJNE A, ANDAR_DESTINO, VERIFICAR ; verifica se atual != destino
	RET

VERIFICAR:
	CLR C ; limpa o carry para não ter interferência no SUBB
	MOV A, ANDAR_DESTINO
	SUBB A, ANDAR_ATUAL ; subtrai o andar_destino do andar_atual, portanto:
                         ; se destino > atual = elevador sobe (carry = 0)
                         ; se destino < atual = elevador desce (carry = 1)
    JC DESCER ; chama a rotina se carry = 1 (atual > destino)
    AJMP SUBIR ; rotina caso carry = 0 (atual < destino)

SUBIR:
	SETB MOTOR_B0 ; bit0_motor = 1
	CLR MOTOR_B1 ; bit1_motor = 0 -> sentido horário
	SETB LED_SUBIR ; acende LED indicando subida
	CLR LED_DESCER ; apaga LED de descida
    INC ANDAR_ATUAL ; incrementa o andar atual
    MOV DISPLAY_VALOR, ANDAR_ATUAL 
    CALL MOSTRAR_DISPLAY ; mostra no display 7seg o andar atualizado após subir 1 andar
	MOV R4, #120 ; delay
    CALL DELAY
    SJMP MOVE_ELEV ; volta para verificar se chegou no destino

DESCER:
	CLR MOTOR_B0 ; bit0_motor = 0
	SETB MOTOR_B1 ; bit1_motor = 1 -> sentido anti-horário
	SETB LED_DESCER ; acende LED indicando descida
	CLR LED_SUBIR ; apaga LED de subida
    DEC ANDAR_ATUAL ; decrementa o andar atual
    MOV DISPLAY_VALOR, ANDAR_ATUAL
    CALL MOSTRAR_DISPLAY ; mostra no display 7seg o andar atualizado após descer 1 andar
    MOV R4, #120 ; delay
	CALL DELAY
    SJMP MOVE_ELEV ; volta para verificar se chegou no destino

SAIR:
    RET