Trabalho de Compiladores

Descrição do Projeto

Este projeto tem como objetivo desenvolver um compilador que gera código para a arquitetura MIPS (Microprocessor without Interlocked Pipeline Stages). O compilador permite a escrita de programas em uma linguagem de alto nível e traduz esses programas para código de máquina MIPS, facilitando a execução em sistemas embarcados.

**Estrutura do Projeto**

O projeto é composto pelos seguintes arquivos:

- lexico.l: Arquivo que contém a definição do analisador léxico.
- sintatico.y: Arquivo que contém a definição do analisador sintático.
- utils.c: Arquivo com funções utilitárias para o compilador.
- Makefile: Script para compilar o projeto e gerar o executável.

**Funcionalidades**

- Análise Léxica: Identificação de tokens a partir do código fonte.
- Análise Sintática: Verificação da estrutura do código e construção da árvore sintática.
- Geração de Código: Tradução do código fonte para instruções MIPS.
- Suporte a Literais: Permite a escrita de valores literais no código fonte.

**Como Compilar e Executar**

1. Clone o repositório:
git clone <URL_DO_REPOSITORIO>
cd <NOME_DA_PASTA>

2. Compile o projeto:
Execute o comando abaixo para compilar o projeto e gerar o executável:
make

3. Executar o compilador:
Para compilar um programa fonte, use o seguinte comando:
./simples <nome_do_arquivo>.simples

O arquivo gerado terá o mesmo nome do arquivo fonte, mas com a extensão .asm.

**Exemplo de Uso**

Para compilar um programa de exemplo chamado fatorial.simples, você pode usar o seguinte comando:

./simples fatorial

Isso gerará um arquivo fatorial.asm com o código MIPS correspondente.
