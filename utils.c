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
enum {
    INT,
    LOG,
    STR // Novo tipo para strings
};

#define TAM_TAB 100
#define TAM_STR 200

struct elemTabSimbolos {
    char id[100]; 
    int end; 
    int tip;
    char valStr[TAM_STR]; // Valor da string (apenas para tipo STR)
} tabSimb[TAM_TAB], elemTab;

int posTab = 0; 

int buscaSimbolo(char *s) {
    int i;
    for (i = posTab - 1; strcmp(tabSimb[i].id, s) && i >= 0; i--)
        ;
    if (i == -1) {
        char msg[200];
        sprintf(msg, "Identificador [%s] não encontrado!", s);
        yyerror(msg);
    }
    return i;
}

void insereSimbolo(struct elemTabSimbolos elem) {
    int i;
    if (posTab == TAM_TAB)
        yyerror("Tabela de Símbolos cheia!");
    for (i = posTab - 1; strcmp(tabSimb[i].id, elem.id) && i >= 0; i--)
        ;
    if (i != -1) {
        char msg[200];
        sprintf(msg, "Identificador [%s] duplicado!", elem.id);
        yyerror(msg);
    }
    tabSimb[posTab++] = elem;
}

// Inserção de uma string na tabela de símbolos
void insereString(char *id, char *valor) {
    struct elemTabSimbolos elem;
    //Armazena o novo identificador
    strcpy(elem.id, id);
    elem.tip = STR;
    elem.end = posTab; // Pode ser usado como índice para a tabela de strings
    //Garantir que não copie mais caracteres do que o permitido
    strncpy(elem.valStr, valor, TAM_STR - 1);
    elem.valStr[TAM_STR - 1] = '\0'; // Garante que a string seja terminada
    insereSimbolo(elem);
}

// Pilha Semântica
#define TAM_PIL 100
int pilha[TAM_PIL];
int topo = -1;

void empilha(int valor) {
    if (topo == TAM_PIL)
        yyerror("Pilha semântica cheia!");
    pilha[++topo] = valor;
}

int desempilha(void) {
    if (topo == -1)
        yyerror("Pilha semântica vazia!");
    return pilha[topo--];
}

void testaTipo(int tipo1, int tipo2, int ret) {
    int t1 = desempilha();
    int t2 = desempilha();
    if (t1 != tipo1 || t2 != tipo2) {
        yyerror("Incompatibilidade de tipo!");
    }
    empilha(ret);
}
