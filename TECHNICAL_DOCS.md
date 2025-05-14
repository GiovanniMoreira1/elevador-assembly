# Documentação Técnica do Sistema de Elevador

Este documento detalha o funcionamento técnico de cada rotina e função do sistema de elevador em Assembly 8051.

## Rotinas Principais

### INICIO
```assembly
INICIO:
    MOV ANDAR_ATUAL, #00H
    MOV ANDAR_DESTINO, #00H
    MOV DISPLAY_VALOR, #00H
    SETB SW_EMERGENCIA
```
- **Função**: Inicialização do sistema
- **Detalhes**:
  - Inicializa o andar atual como 0
  - Inicializa o andar destino como 0
  - Inicializa o valor do display como 0
  - Configura o botão de emergência como normalmente fechado

### VOLTA
```assembly
VOLTA:
    SETB LED_EMERG_5
    SETB LED_EMERG_4
    SETB LED_EMERG_3
    SETB LED_EMERG_2
```
- **Função**: Loop principal do sistema
- **Detalhes**:
  - Mantém os LEDs de emergência desligados (SETB = 1 = desligado)
  - Verifica o estado do botão de emergência
  - Chama a rotina de leitura do teclado
  - Compara andar atual com destino

### TECLADO
```assembly
TECLADO:
    MOV R0, #1
    ; scan row3
    SETB P0.0
    CLR P0.3
    CALL colScan
    ; ... (scans outras linhas)
```
- **Função**: Leitura do teclado matricial
- **Detalhes**:
  - Inicializa R0 com 1 para mapeamento das teclas
  - Escaneia cada linha do teclado sequencialmente
  - Utiliza colScan para verificar colunas
  - Aguarda soltura da tecla após detecção

### colScan
```assembly
colScan:
    JNB P0.6, gotKey
    INC R0
    JNB P0.5, gotKey
    INC R0
    JNB P0.4, gotKey
    INC R0
    RET
```
- **Função**: Escaneamento de colunas do teclado
- **Detalhes**:
  - Verifica cada coluna (P0.4 até P0.6)
  - Incrementa R0 para cada coluna verificada
  - Retorna quando encontra tecla pressionada

### MOVE_ELEV
```assembly
MOVE_ELEV:
    MOV A, ANDAR_ATUAL
    CJNE A, ANDAR_DESTINO, VERIFICAR
    RET
```
- **Função**: Controle de movimento do elevador
- **Detalhes**:
  - Compara andar atual com destino
  - Chama VERIFICAR se forem diferentes
  - Retorna se já estiver no andar destino

### VERIFICAR
```assembly
VERIFICAR:
    CLR C
    MOV A, ANDAR_DESTINO
    SUBB A, ANDAR_ATUAL
    JC DESCER
    AJMP SUBIR
```
- **Função**: Determina direção do movimento
- **Detalhes**:
  - Limpa carry flag
  - Subtrai andar atual do destino
  - Se carry = 1, chama DESCER
  - Se carry = 0, chama SUBIR

### SUBIR
```assembly
SUBIR:
    SETB MOTOR_B0
    CLR MOTOR_B1
    SETB LED_SUBIR
    CLR LED_DESCER
```
- **Função**: Controla movimento de subida
- **Detalhes**:
  - Configura motor para subir (MOTOR_B0=1, MOTOR_B1=0)
  - Ativa LED de subida
  - Desativa LED de descida
  - Incrementa andar atual
  - Atualiza display

### DESCER
```assembly
DESCER:
    CLR MOTOR_B0
    SETB MOTOR_B1
    SETB LED_DESCER
    CLR LED_SUBIR
```
- **Função**: Controla movimento de descida
- **Detalhes**:
  - Configura motor para descer (MOTOR_B0=0, MOTOR_B1=1)
  - Ativa LED de descida
  - Desativa LED de subida
  - Decrementa andar atual
  - Atualiza display

### EMERGENCIA
```assembly
EMERGENCIA:
    SETB LED_SUBIR
    SETB LED_DESCER
    CLR LED_EMERG_5
    CLR LED_EMERG_4
    CLR LED_EMERG_3
    CLR LED_EMERG_2
```
- **Função**: Tratamento de situação de emergência
- **Detalhes**:
  - Desativa LEDs de direção
  - Ativa LEDs de emergência
  - Força valores inválidos no display
  - Para o motor

### DELAY
```assembly
DELAY:
NEXT:   MOV R5, #50
AGAIN:  DJNZ R5, AGAIN
        DJNZ R4, NEXT
        RET
```
- **Função**: Gera delay programável
- **Detalhes**:
  - Utiliza dois contadores (R4 e R5)
  - R5 controla laço interno (50 iterações)
  - R4 controla laço externo (configurável)
  - Usado para controlar velocidade do elevador

### MOSTRAR_DISPLAY
```assembly
MOSTRAR_DISPLAY:
    MOV DPTR, #TABELA_DISPLAY
    MOV A, DISPLAY_VALOR
    MOVC A, @A+DPTR
    MOV P1, A
    RET
```
- **Função**: Atualiza display de 7 segmentos
- **Detalhes**:
  - Carrega endereço da tabela de códigos
  - Obtém código correspondente ao valor
  - Envia para o display (P1)

## Tabelas e Constantes

### TABELA_DISPLAY
```assembly
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
```
- **Função**: Tabela de códigos para display
- **Detalhes**:
  - Contém códigos para dígitos 0-9
  - Cada código representa segmentos ativos
  - Usado para converter número em padrão de display

## Observações Técnicas

1. **Memória**:
   - Variáveis do sistema em endereços específicos
   - Uso eficiente de registradores
   - Tabela de códigos em memória de programa

2. **Interrupções**:
   - Verificação contínua de emergência
   - Tratamento imediato de botão de emergência
   - Proteção contra comandos inválidos

3. **Timing**:
   - Delay programável para controle de velocidade
   - Debounce de teclado implementado
   - Verificações periódicas de estado

4. **Segurança**:
   - Sistema de emergência normalmente fechado
   - Parada imediata em caso de emergência
   - Indicadores visuais de estado 