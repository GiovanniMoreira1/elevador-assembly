        ORG 0000H
        LJMP INICIO 

ANDAR_ATUAL    EQU 10H 
ANDAR_DESTINO  EQU 11H 
DISPLAY_VALOR  EQU 12H 
LED_SUBIR 	   EQU P2.7 ; necessário alterar os pinos dos LEDs de P1 para P2
LED_DESCER	   EQU P2.0
MOTOR_B0	   EQU P3.0 ; controla o sentido do motor - bit menos significativo
MOTOR_B1	   EQU P3.1 ; controla o sentido do motor - bit mais significativo
SW_EMERGENCIA  EQU P3.2
LED_EMERG_5    EQU P2.5
LED_EMERG_4    EQU P2.4
LED_EMERG_3    EQU P2.3
LED_EMERG_2    EQU P2.2

        ORG 0100H
INICIO:
	SETB SW_EMERGENCIA ; por padrão ligado (normalmente fechado), se abrir o botão desliga (emergência)

VOLTA:
	SETB LED_EMERG_5
	SETB LED_EMERG_4
	SETB LED_EMERG_3
	SETB LED_EMERG_2

	JB SW_EMERGENCIA, CONTINUA ; se estiver ativado, continua normalmente
	AJMP EMERGENCIA ; senão, vai pra emergência

CONTINUA:
	CALL TECLADO ; chama rotina que lê o teclado
    MOV A, ANDAR_ATUAL
    CJNE A, ANDAR_DESTINO, MOVE_ELEV ; compara andar atual e andar destino, se forem diferentes, chama a rotina MOVE_ELEV
    CLR MOTOR_B0 ; zera os dois bits de direção do motor
	CLR MOTOR_B1
	SJMP VOLTA

EMERGENCIA:
	SETB LED_SUBIR
	SETB LED_DESCER
	CLR LED_EMERG_5
	CLR LED_EMERG_4
	CLR LED_EMERG_3
	CLR LED_EMERG_2

	MOV B, 10H ; força os valores para o display aparecer algo (no caso, valor inválido de 16)
	MOV 12H, B
	MOV 11H, B
	AJMP VOLTA

TECLADO:
    MOV R0, #1 ; inicia com 1 para mapear as teclas

    ; scan row3
    SETB P0.0 ; ativa a linha
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
    JNB P0.6, gotKey ; verifica se coluna está em 0, indicando tecla pressionada
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
    JB P0.4, SAIR ; espera até que a coluna fique em 1 de novo (tecla solta)
    SJMP aguardaSoltar

setZero: ; se pressionar a tecla 11, define o destino como 0
    MOV ANDAR_DESTINO, #00H
    MOV DISPLAY_VALOR, #00H
    CALL MOSTRAR_DISPLAY
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
    MOVC A, @A+DPTR ; acessa o código correspondente ao valor
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
	SUBB A, ANDAR_ATUAL ; subtrai o andar_atual do andar_destino, portanto:
                         ; se destino > atual = elevador sobe (carry = 0)
                         ; se destino < atual = elevador desce (carry = 1)
    JC DESCER ; chama a rotina se carry = 1 (atual > destino)
    AJMP SUBIR ; rotina caso carry = 0 (atual < destino)

SUBIR:
    SETB MOTOR_B0 ; ativa direção de subida
    CLR MOTOR_B1
    SETB LED_SUBIR
    CLR LED_DESCER

    ; VERIFICA SE FOI PRESSIONADO BOTÃO DE EMERGÊNCIA DURANTE O MOVIMENTO
    JB SW_EMERGENCIA, SEGUE_SUBIDA ; se não apertou emergência, continua
    AJMP EMERGENCIA

SEGUE_SUBIDA:
    INC ANDAR_ATUAL
    MOV DISPLAY_VALOR, ANDAR_ATUAL 
    CALL MOSTRAR_DISPLAY
    MOV R4, #120
    CALL DELAY
    SJMP MOVE_ELEV ; verifica novamente

DESCER:
    CLR MOTOR_B0 ; ativa direção de descida
    SETB MOTOR_B1
    SETB LED_DESCER
    CLR LED_SUBIR

    JB SW_EMERGENCIA, SEGUE_DESCIDA ; se não apertou emergência, continua
    AJMP EMERGENCIA

SEGUE_DESCIDA:
    DEC ANDAR_ATUAL
    MOV DISPLAY_VALOR, ANDAR_ATUAL
    CALL MOSTRAR_DISPLAY
    MOV R4, #120
    CALL DELAY
    SJMP MOVE_ELEV ; verifica novamente

SAIR:
    RET
