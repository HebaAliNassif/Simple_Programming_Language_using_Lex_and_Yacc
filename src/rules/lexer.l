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
INTEGER             [0-9]+
FLOAT               (([0-9]*\.[0-9]+)|([0-9]+\.[0-9]*))
EXP                 ([eE][-+]?{INTEGER})
REAL                ({INTEGER}{EXP}|{FLOAT}{EXP}?)
LETTER              [a-zA-Z_]
IDENTIFIER          {LETTER}({LETTER}|{DIGIT})*
LINE_COMMENT        "//"(.)*

%%

%{
// =====
// Rules
// =====
%}

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
[-+*/%&|^~!<>=(){}[\],:;]   return yytext[0];
[ \t\n]+                    ;                             /* ignore whitespace */
.                           yyerror("Unknown character");
%%

%{
// ===========
// Subroutines
// ===========
%}

int yywrap(void) {
    return 1;
}