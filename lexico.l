/*+=============================================================
|
| UNIFAL = Universidade Federal de Alfenas.
|
| BACHARELADO EM CIENCIA DA COMPUTACAO.
| Trabalho . . : Geracao de codigo MIPS
| Disciplina : Compiladores
| Professor . : Luiz Eduardo da Silva
| Aluno . . . . . : Lucas Gabriel da Silva Batista
| Data . . . . . . : 13/12/2024
+=============================================================*/

%{
#include "sintatico.h"
#include <string.h> // Para usar strcpy
int yyerror(char *);
int numLinha = 1;
char atomo[100];
%}

identificador [a-zA-Z]([a-zA-Z0-9])*
numero [0-9]+
string    \"([^\"])*\"  
espaco [ \t\r]+
novalinha [\n]

%%
programa                {return T_PROGRAMA; }
inicio                  {return T_INICIO; }
fimprograma             {return T_FIMPROG; }
leia                    {return T_LEIA; }
escreva                 {return T_ESCREVA; }
se                      {return T_SE; }
entao                   {return T_ENTAO; }
senao                   {return T_SENAO; }
fimse                   {return T_FIMSE; }
enquanto                {return T_ENQUANTO; }
faca                    {return T_FACA; }
fimenquanto             {return T_FIMENQTO; }

inteiro                 {return T_INTEIRO; }
logico                  {return T_LOGICO; }

"+"                     {return T_MAIS; }
"-"                     {return T_MENOS; }
"*"                     {return T_VEZES; }
"div"                   {return T_DIV; }

">"                     {return T_MAIOR; }
"<"                     {return T_MENOR; }
"="                     {return T_IGUAL; }

e                       {return T_E; }
ou                      {return T_OU; }
nao                     {return T_NAO; }

"<-"                    {return T_ATRIB; }
"("                     {return T_ABRE; }
")"                     {return T_FECHA; }

V                       {return T_V; }
F                       {return T_F; }

{identificador}         {strcpy(atomo, yytext); return T_IDENTIF; }
{numero}                {strcpy(atomo, yytext); return T_NUMERO; }
{string}                {strcpy(atomo, yytext); return T_STRING; } 
{espaco}                ;
{novalinha}             numLinha++;

.                       yyerror("lexico - simbolo desconhecido");

%%

int yywrap (void){
    return 1;
}

int yyerror(char *s){
    printf("Erro na linha %d: %s\n", numLinha, s);
    exit(100);
}