%{
#include <stdlib.h>
#include "../header.h"
#include "yacc.tab.h"
#include <string.h>

void yyerror(char *);
%}



%{
// ===========
// Definitions
// ===========
%}

%%

"int"                       return TYPE_INT;
"float"                     return TYPE_FLOAT;
"char"                      return TYPE_CHAR;
"bool"                      return TYPE_BOOL;
"void"                      return TYPE_VOID;

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

[\"].*[\"]                    {yylval.charVal=strdup(yytext);return CHAR;} 
[0-9]+\.[0-9]+             {yylval.floatVal=atof(yytext);return FLOAT;}  
0                          {yylval.intVal=atoi(yytext);return INTEGER;}
                            

[1-9][0-9]*                {yylval.intVal=atoi(yytext);return INTEGER;}
                        

                                   

"true"                      {yylval.boolVal=strdup(yytext);return BOOL;}
"false"                     {yylval.boolVal=strdup(yytext);return BOOL;}

[a-zA-Z_]([a-zA-Z_]|[0-9])*  {yylval.variableName=strdup(yytext);return IDENTIFIER;}
                                  


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

"="                         return ASSIGN;
";"                         return SEMICOLON;
","                         return COMA;
[-+*/%&|^~!<>(){}[:\]]   return *yytext;
[ \t\n]+                    ;                      

%%


int yywrap(void) {
    return 1;
}