%{
#include <stdlib.h>
#include "../header.h"
#include "yacc.tab.h"

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

0                          return INTEGER;
                            

[1-9][0-9]*                return INTEGER;
                        

[0-9]+"."[0.9]*             return FLOAT;               
                        
   
\"[.]*\"                    return CHAR;    

"true"                      return BOOL;
"false"                     return BOOL; 

[a-zA-Z_]([a-zA-Z_]|[0-9])*  return IDENTIFIER;
                                  


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
[@ # $]                     yyerror("Unknown character: \n");
%%


int yywrap(void) {
    return 1;
}