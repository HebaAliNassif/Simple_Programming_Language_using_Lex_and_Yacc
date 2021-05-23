%{
#include <stdlib.h>
#include "../header.h"
#include "yacc.tab.h"

void yyerror(char *);
%}

%%

%{
// ===========
// Definitions
// ===========
%}

DIGIT               [0-9]
INTEGER             {DIGIT}+
FLOAT               {DIGIT}+"."{DIGIT}*
LETTER              [a-zA-Z_]
IDENTIFIER          {LETTER}({LETTER}|{DIGIT})*
LINE_COMMENT        "//"(.)*

%%

%{
// =====
// Rules
// =====
%}

{INTEGER} {       printf("An integer: %s (%d)\n", yytext, atoi(yytext))
                  yyval = atoi(yytext);
                  return yyval;
}

{FLOAT} {         printf("A float: %s (%f)\n", yytext, atof(yytext))
                  yyval = atof(yytext);
                  return yyval;
}

{IDENTIFIER} {    printf("An identifier: %s\n", yytext)
                  return yytext;
}






%{ // Data Types %}
"int"                       return TYPE_INT;
"float"                     return TYPE_FLOAT;
"char"                      return TYPE_CHAR;
"bool"                      return TYPE_BOOL;
"void"                      return TYPE_VOID;


%{ // Branch tokens %}
"const"                     return CONST;
"if"                        return IF;
"else"                      return ELSE;
"switch"                    return SWITCH;
"case"                      return CASE;
"default"                   return DEFAULT;
"for"                       return FOR;
"do"                        return DO;
"while"                     return WHILE;
"break"                     return BREAK;
"continue"                  return CONTINUE;
"return"                    return RETURN;


%{ // Operators %}
"++"                        return INC;
"--"                        return DEC;
"=="                        return EQUAL;
"!="                        return NOT_EQUAL;
">="                        return GREATER_EQUAL;
"<="                        return LESS_EQUAL;
"<<"                        return SHL;
">>"                        return SHR;
"&&"                        return LOGICAL_AND;
"||"                        return LOGICAL_OR;
[-+*/%&|^~!<>=(){}[\],:;]   return *yytext;
[ \t\n]+                    ;                             /* ignore whitespace */
.                           yyerror("Unknown character: "%s\n", yytext);
%%

%{
// ===========
// Subroutines
// ===========
%}

int yywrap(void) {
    return 1;
}