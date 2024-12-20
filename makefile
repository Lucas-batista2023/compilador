simples: lexico.l sintatico.y utils.c;
	flex -t lexico.l > lexico.c;\
	bison -v -d sintatico.y -o sintatico.c;\
	gcc sintatico.c -o simples;

limpa:;
	rm lexico.c sintatico.c sintatico.h sintatico.output simples






