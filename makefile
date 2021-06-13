compiler:
	flex src\rules\lex.l
	mv lex.yy.c src\rules
	bison -d -v src\rules\yacc.y
	gcc src\rules\lex.yy.c src\rules\yacc.tab.c -o compiler

start:
	start compiler.exe

clear:
	cd src/rules
	rm -rf 'src\rules\yacc.tab.h' 'src\rules\lex.yy.c' 'src\rules\yacc.tab.c'