# Sistema de Elevador em Assembly 8051

Este projeto implementa um sistema de controle de elevador utilizando o microcontrolador 8051 em Assembly. O sistema possui diversas funcionalidades para controlar o movimento do elevador, exibir informações e gerenciar situações de emergência.

## Funcionalidades

### Controle de Movimento
- Movimento automático entre andares
- Controle bidirecional (subida e descida)
- Sistema de motor com dois bits de controle (MOTOR_B0 e MOTOR_B1)
- LEDs indicativos de direção (LED_SUBIR e LED_DESCER)

### Interface com Usuário
- Teclado matricial 4x4 para seleção de andares
- Display de 7 segmentos para mostrar o andar atual
- Mapeamento de teclas para seleção de andares (1-10)
- Tecla especial (11) para zerar o destino

### Sistema de Emergência
- Botão de emergência (SW_EMERGENCIA)
- LEDs indicativos de emergência (LED_EMERG_2 até LED_EMERG_5)
- Parada imediata do elevador em caso de emergência
- Display mostra valor inválido (16) durante emergência

### Características Técnicas
- Endereçamento de memória para variáveis do sistema:
  - ANDAR_ATUAL (10H)
  - ANDAR_DESTINO (11H)
  - DISPLAY_VALOR (12H)
- Sistema de delay programável para controle de velocidade
- Verificação contínua de estado do elevador
- Tratamento de interrupções e estados de emergência

## Pinagem

### LEDs e Display
- LED_SUBIR: P2.7
- LED_DESCER: P2.0
- LEDs de Emergência: P2.2 até P2.5
- Display de 7 segmentos: P1

### Controle do Motor
- MOTOR_B0: P3.0 (bit menos significativo)
- MOTOR_B1: P3.1 (bit mais significativo)

### Teclado
- Linhas: P0.0 até P0.3
- Colunas: P0.4 até P0.6

### Botão de Emergência
- SW_EMERGENCIA: P3.2

## Funcionamento

1. O sistema inicia com o elevador no andar 0
2. O usuário pode selecionar um andar através do teclado
3. O sistema compara o andar atual com o destino
4. O elevador se move na direção apropriada
5. Durante o movimento:
   - LEDs indicam a direção
   - Display mostra o andar atual
   - Sistema verifica constantemente o botão de emergência
6. Em caso de emergência:
   - O elevador para imediatamente
   - LEDs de emergência são ativados
   - Display mostra valor inválido

## Observações

- O sistema utiliza um botão de emergência normalmente fechado
- O display de 7 segmentos utiliza codificação específica para cada dígito
- O sistema possui proteção contra comandos inválidos
- A velocidade do elevador é controlada através de delays programáveis

## 🧠 Autores

- **Artur Chaves** — RA: 222230237  
- **Giovanni Moreira** — RA: 222230104  

---

> Simulado e testado com sucesso no EdSim51.
