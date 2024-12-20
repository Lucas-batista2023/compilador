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
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lexico.c"
#include "utils.c"

int contaVar = 0;
int tipo;
int rotulo = 0;
int teste = 0;

%}

%token T_PROGRAMA
%token T_INICIO
%token T_FIMPROG
%token T_LEIA
%token T_ESCREVA
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ENQUANTO
%token T_FACA
%token T_FIMENQTO
%token T_MAIS
%token T_MENOS
%token T_VEZES
%token T_DIV
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_NAO
%token T_ATRIB
%token T_ABRE
%token T_FECHA
%token T_INTEIRO
%token T_LOGICO
%token T_V
%token T_F
%token T_IDENTIF
%token T_NUMERO
%token T_STRING

%start programa


%left T_MAIS T_MENOS
%left T_VEZES T_DIV
%left T_MAIOR T_MENOR T_IGUAL
%left T_E T_OU



%%
programa
    : cabecalho
        {
            
            fprintf(yyout, ".text\n");
            fprintf(yyout, "\t.globl main\n");
            fprintf(yyout, "main:	nop\n");
            contaVar = 0; 
        }
    variaveis
        {
            empilha(contaVar); 
            contaVar++;
        }
    T_INICIO lista_comandos T_FIMPROG
        {
            int conta = desempilha();
            fprintf(yyout, "fim:	nop\n");
            fprintf(yyout, "\tli $v0, 10\n");
            fprintf(yyout, "\tli $a0, 0\n");
            fprintf(yyout, "\tsyscall\n"); 

            fprintf(yyout, ".data\n"); 
            
            for (int i = 0; i < contaVar; i++) { 
                if (tabSimb[i].id && strlen(tabSimb[i].id) > 0) {
                    if (tabSimb[i].tip == INT) {
                    fprintf(yyout, "\t%s: .word 1\n", tabSimb[i].id);  
                }
                else if (tabSimb[i].tip == LOG) {                  
                fprintf(yyout, "\t%s: .word 1\n", tabSimb[i].id);  
                }
                }
            }

            fprintf(yyout, "\t_esp: .asciiz \" \"\n");
            fprintf(yyout, "\t_ent: .asciiz \"\\n\"\n");

            // Adicionando as constantes de string
            for (int i = 0; i < posTab; i++) {
                if (tabSimb[i].id && strlen(tabSimb[i].id) > 0 && tabSimb[i].tip == STR) {
                    fprintf(yyout, "\t%s: .asciiz %s\n", tabSimb[i].id, tabSimb[i].valStr);
                }
            }

        }
    ;

cabecalho
        : T_PROGRAMA T_IDENTIF
        ;

variaveis
        :
        | declaracao_variaveis
        ;

declaracao_variaveis
        : tipo lista_variaveis declaracao_variaveis
        | tipo lista_variaveis
        ;

tipo
        : T_INTEIRO {tipo = INT; }
        | T_LOGICO {tipo = LOG; }
        | T_STRING {tipo = STR; }
        ;

lista_variaveis
        : lista_variaveis T_IDENTIF 
                {
                        strcpy(elemTab.id, atomo);
                        elemTab.end = contaVar;
                        elemTab.tip = tipo;
                        insereSimbolo(elemTab);
                        contaVar++; }
        | T_IDENTIF
                {
                        strcpy(elemTab.id, atomo);
                        elemTab.end = contaVar;
                        elemTab.tip = tipo;
                        insereSimbolo(elemTab);
                        contaVar++; }
        ;

lista_comandos
        : lista_comandos comando
        | /*vazio*/
        ;

comando 
        : leitura
        | escrita
        | repeticao
        | selecao
        | atribuicao
        ;

leitura
    : T_LEIA T_IDENTIF
        {
            int pos = buscaSimbolo(atomo);
            if (tabSimb[pos].tip == STR) {
                fprintf(yyout, "\tli $v0, 8\n"); 
                fprintf(yyout, "\tli $a1, 200\n");
                fprintf(yyout, "\tsyscall\n");

                fprintf(yyout, "\tsw $v0, %s\n", tabSimb[pos].id);

            } else if (tabSimb[pos].tip == INT) {
                fprintf(yyout, "\tli $v0, 5\n");
                fprintf(yyout, "\tsyscall\n");
                fprintf(yyout, "\tsw $v0, %s\n", tabSimb[pos].id);


            } else {
                yyerror("Tipo não suportado para leitura!");
            }
        }
    ;

escrita
    : T_ESCREVA expressao
        {
            int tipo = desempilha();
            if (tipo == STR) {
                fprintf(yyout, "\tli $v0, 4\n"); 
                fprintf(yyout, "\tsyscall\n");
                
            } else if (tipo == INT) {
                fprintf(yyout, "\tli $v0, 1\n"); 
                fprintf(yyout, "\tsyscall\n");
                fprintf(yyout, "\tla $a0 _ent\n"); 
                fprintf(yyout, "\tli $v0, 4\n");
                fprintf(yyout, "\tsyscall\n");                
            } else {
                yyerror("Tipo não suportado para escrita!");
            }

        }
    ;

repeticao
        : T_ENQUANTO 
        { 
                fprintf(yyout, "L%d:\tnop\n", ++rotulo);
                empilha(rotulo); }
        expressao T_FACA 
        {       
                int tipo = desempilha();
                if (tipo != LOG)
                        yyerror("Incompatibilidade de tipo na repetição!");
                fprintf(yyout, "\tbeqz $a0, L%d\n", ++rotulo);
                empilha(rotulo); }
        lista_comandos T_FIMENQTO
        { 
                int y = desempilha();
                int x = desempilha();
                fprintf(yyout, "\tj L%d\nL%d:\tnop\n", x, y); } 
        ;

selecao
        : T_SE expressao T_ENTAO
        {
                int tipo = desempilha();
                if (tipo != LOG )
                        yyerror("Incompatibilidade de tipo na seleção!");
                fprintf(yyout, "\tbeqz $a0, L%d\n", ++rotulo);
                empilha(rotulo);
        }
        lista_comandos T_SENAO
        { 
                int y = desempilha();
                fprintf(yyout, "\tj L%d\n", ++rotulo);
                empilha(rotulo);
                fprintf(yyout, "L%d:\tnop\n", y);
        }
        lista_comandos T_FIMSE
        {
                int x = desempilha();
                fprintf(yyout, "L%d:\tnop\n", x);
        }
        ;

atribuicao
        : T_IDENTIF
        {
                int pos = buscaSimbolo(atomo);
                empilha(pos); } 
        
         T_ATRIB expressao
        {      
                int tipo = desempilha();
                int pos = desempilha(); 

                if (tipo != tabSimb[pos].tip) {
                yyerror("Incompatibilidade de tipos!");
                }
                fprintf(yyout, "\tsw $a0, %s\n", tabSimb[pos].id); }
        ;

expressao
    : expressao T_MAIS {
        //-- Empilha --
        fprintf(yyout, "\tsw $a0 0($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp -4\n");
    }
    expressao {
        testaTipo(INT,INT,INT);
        //-- Desempilha --
        fprintf(yyout, "\tlw $t1 4($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp 4\n");
        //-- SOMA --
        fprintf(yyout, "\tadd $a0, $t1, $a0\n");
    }
    | expressao T_MENOS {
        //-- Empilha --
        fprintf(yyout, "\tsw $a0 0($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp -4\n");
    }
    expressao {
        testaTipo(INT,INT,INT);
        //-- Desempilha --
        fprintf(yyout, "\tlw $t1 4($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp 4\n");
        //-- SUBT --
        fprintf(yyout, "\tsub $a0, $t1, $a0\n");
    }
    | expressao T_VEZES {
        //-- Empilha --
        fprintf(yyout, "\tsw $a0 0($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp -4\n");
    }
    expressao {
        testaTipo(INT,INT,INT);
        //-- Desempilha --
        fprintf(yyout, "\tlw $t1 4($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp 4\n");
        //-- MULT --
        fprintf(yyout, "\tmult $t1, $a0\n");
        fprintf(yyout, "\tmflo $a0\n");
    }
    | expressao T_DIV {
        //-- Empilha --
        fprintf(yyout, "\tsw $a0 0($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp -4\n");
    }
    expressao {
        testaTipo(INT,INT,INT);
        //-- Desempilha --
        fprintf(yyout, "\tlw $t1 4($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp 4\n");
        //-- DIVI --
        fprintf(yyout, "\tdiv $t1, $a0\n");
        fprintf(yyout, "\tmflo $a0\n");
    }
    | expressao T_MAIOR {
        //-- Empilha --
        fprintf(yyout, "\tsw $a0 0($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp -4\n");
    }
    expressao {
        //-- Desempilha --
        testaTipo(INT,INT,LOG);
        fprintf(yyout, "\tlw $t1 4($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp 4\n");
        //-- CMMA --
        fprintf(yyout, "\tslt $a0, $a0, $t1\n");
    }
    | expressao T_MENOR {
        //-- Empilha --
        fprintf(yyout, "\tsw $a0 0($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp -4\n");
    }
    expressao {
        testaTipo(INT,INT,LOG);
        //-- Desempilha --
        fprintf(yyout, "\tlw $t1 4($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp 4\n");
        //-- CMME --
        fprintf(yyout, "\tslt $a0, $t1, $a0\n");
    }
    | expressao T_IGUAL {
        //-- Empilha --
        fprintf(yyout, "\tsw $a0 0($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp -4\n");
    }
    expressao {
        testaTipo(INT, INT, LOG);
        //-- Desempilha --
        fprintf(yyout, "\tlw $t1 4($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp 4\n");
        rotulo++;
        //-- CMIG --
        fprintf(yyout, "\tbeq $a0, $t1, L%d\n", rotulo);
        empilha(rotulo);
        fprintf(yyout, "\tli $a0, 0\n");
        rotulo++;
        fprintf(yyout, "\tj L%d\n", rotulo);
        empilha(rotulo);
        int y = desempilha();
        int x = desempilha();
        fprintf(yyout, "L%d:\tli $a0, 1\n", x);
        fprintf(yyout, "L%d:\tnop\n", y);
    }
    | expressao T_E {
        //-- Empilha --
        fprintf(yyout, "\tsw $a0 0($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp -4\n");
    }
    expressao {
        testaTipo(LOG, LOG, LOG);
        //-- Desempilha --
        fprintf(yyout, "\tlw $t1 4($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp 4\n");
        rotulo++;
        //-- CONJ --
        fprintf(yyout, "\tbeqz $a0, L%d\n", rotulo);
        fprintf(yyout, "\tbeqz $t1, L%d\n", rotulo);
        empilha(rotulo);
        fprintf(yyout, "\tli $a0, 1\n");
        rotulo++;
        fprintf(yyout, "\tj L%d\n", rotulo);
        empilha(rotulo);
        int y = desempilha();
        int x = desempilha();
        fprintf(yyout, "L%d:\tli $a0, 0\n", x);
        fprintf(yyout, "L%d:\tnop\n", y);
    }
    | expressao T_OU {
        //-- Empilha --
        fprintf(yyout, "\tsw $a0 0($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp -4\n");
    }
    expressao {
        testaTipo(LOG, LOG, LOG);
        //-- Desempilha --
        fprintf(yyout, "\tlw $t1 4($sp)\n");
        fprintf(yyout, "\taddiu $sp $sp 4\n");
        rotulo++;
        //-- DISJ --
        fprintf(yyout, "\tbnez $a0, L%d\n", rotulo);
        fprintf(yyout, "\tbnez $t1, L%d\n", rotulo);
        empilha(rotulo);
        fprintf(yyout, "\tli $a0, 0\n");
        rotulo++;
        fprintf(yyout, "\tj L%d\n", rotulo);
        empilha(rotulo);
        int y = desempilha();
        int x = desempilha();
        fprintf(yyout, "L%d:\tli $a0, 1\n", x);
        fprintf(yyout, "L%d:\tnop\n", y);
    }
    | termo;


termo
    : T_NUMERO 
        {   
            fprintf(yyout, "\tli $a0 %s\n", atomo);
            empilha(INT);
        }
    | T_IDENTIF 
        { 
            int pos = buscaSimbolo(atomo);
            if (tabSimb[pos].tip == STR) {
                fprintf(yyout, "\tsw $a0, 0($sp)\n");
                empilha(STR);
            } else {
                fprintf(yyout, "\tlw $a0 %s\n", tabSimb[pos].id);
                empilha(tabSimb[pos].tip);
            }
        }
    | T_STRING {
            char id[100];
            snprintf(id, sizeof(id), "_const%d", teste++); // Gera um identificador único para o rótulo
            insereString(id, atomo); // Salva a string na tabela de símbolos

            fprintf(yyout, "\tla $a0 %s\n", id);
            empilha(STR);
        }

    | T_V {
            fprintf(yyout, "\tli $a0, 1\n");
            empilha(LOG);
        }
    | T_F {
            fprintf(yyout, "\tli $a0, 0\n");
            empilha(LOG);
        }
    | T_NAO termo {
            int tipo = desempilha();
            if (tipo != LOG) yyerror("Incompatibilidade de tipos");
            rotulo++;
            fprintf(yyout, "\tbeqz $a0, L%d\n", rotulo); 
            fprintf(yyout, "\tli $a0, 0\n");
            rotulo++;
            fprintf(yyout, "\tj L%d\n", rotulo);
            --rotulo;
            fprintf(yyout, "L%d:\tli $a0, 1\n", rotulo++);
            fprintf(yyout, "L%d:\tnop\n", rotulo);
            empilha(LOG);
        }
    | T_ABRE expressao T_FECHA
    ;

%%

int main(int argc, char *argv[]){

        char nameIn[30], nameOut[30], *p;
        if(argc < 2){
                printf("Uso:\n\t%s <nomefonte>[.simples]\n\n", argv[0]);
                return 10;
        }

                p = strstr(argv[1], ".simples");
                if(p) *p = 0;
                strcpy(nameIn, argv[1]);
                strcat(nameIn, ".simples");
                strcpy(nameOut, argv[1]);
                strcat(nameOut, ".asm");
                yyin = fopen(nameIn, "rt");
                yyout = fopen(nameOut, "wt");

                yyparse();
                puts("Programa ok!");
                fclose(yyin);
                fclose(yyout);
                return 0;
}












