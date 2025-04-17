# Projeto de Elevador em Assembly 8051 🚀

Este projeto simula o funcionamento de um elevador simples utilizando Assembly para o microcontrolador 8051 no simulador [EdSim51](http://edsim51.com/).

## 📋 Descrição

O sistema simula um elevador com os seguintes recursos:
- Leitura de entrada via **teclado matricial 4x3** (andar de destino).
- Exibição do andar atual/destino em um **display de 7 segmentos**.
- Movimentação automática do elevador entre andares, com subida e descida.
- Controle de motor simulando:
  - **Subida:** motor gira no sentido horário.
  - **Descida:** motor gira no sentido anti-horário.

## ⚙️ Tecnologias e Ferramentas

- Linguagem: **Assembly 8051**
- Simulador: **EdSim51**

## 📦 Organização da Memória

- `ORG 0000H`: Redirecionamento para a rotina principal (`INICIO`).
- `ORG 0100H`: Início da execução do código principal.

## 🔧 Funcionalidades

- **Leitura do Teclado:** As teclas são escaneadas por linha e coluna. O valor pressionado é salvo como o andar de destino.
- **Comparação:** Verifica se o andar atual é diferente do destino.
- **Movimentação:**
  - Se o destino for maior que o atual, incrementa o andar e gira o motor no sentido horário.
  - Se for menor, decrementa o andar e gira o motor no sentido anti-horário.
- **Display:** Exibe o andar atual ou o selecionado.
- **Motor:** Simula os sentidos de rotação com os pinos `P2.0` e `P2.1`.

## 🎛️ Pinos Utilizados

| Componente         | Pinos            |
|--------------------|------------------|
| Teclado Matricial  | `P0.0 - P0.6`     |
| Display 7 segmentos| `P1`             |
| Motor (Ponte H)    | `P2.0`, `P2.1`    |

## 🚨 Observações

- A lógica de movimentação utiliza `CJNE` e `SUBB` para comparar os andares e controlar a direção.
- O valor 0 (tecla "0") é tratado separadamente e configurado como `#0BH` (posição na matriz).
- O sistema aguarda o botão ser solto antes de prosseguir, evitando múltiplas leituras.

## 🧠 Autores

- **Artur Chaves** — RA: 222230237  
- **Giovanni Moreira** — RA: 222230104  

---

> Simulado e testado com sucesso no EdSim51.
