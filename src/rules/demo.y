%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "../header.h"
int yylex(void);
void yyerror(char *s);

%}

///////////////////////////////////////////////////////////////////////////////////////
////////////////
// Tokens 
////////////////

// Data types
%token TYPE_INT 
%token TYPE_FLOAT
%token TYPE_CHAR
%token TYPE_BOOL
%token TYPE_VOID

// Keywords
%token CONST
%token IF
%token ELSE
%token SWITCH
%token CASE
%token DEFAULT
%token FOR
%token DO
%token WHILE
%token BREAK
%token CONTINUE
%token RETURN

// Values
%token INTEGER
%token FLOAT
%token CHAR
%token BOOL

//variable
%token IDENTIFIER

//operators

%token INC
%token DEC
%token EQUAL
%token NOT_EQUAL
%token GREATER_EQUAL
%token LESS_EQUAL
%token SHL
%token SHR
%token LOGICAL_AND
%token LOGICAL_OR
/////////////////////////////
//math operation
////////////////////////////
%token ASSIGN

/////////////////////////////
//Others
////////////////////////////
%token SEMICOLON
/////////////////////////////
//orders
/////////////////////////////
%left       '-' '+'
%left       '*' '/' '%'
%left       '|'
%left       '^'
%left       '&'
%left  EQUAL
%left  NOT_EQUAL
%left GREATER_EQUAL
%left LESS_EQUAL
%right      ASSIGN
%right      '!' '~'

%nonassoc   ELSE
%%
program:stmt
        |
        ;

        
stmt:variableDecl SEMICOLON  {printf("variableDecl SEMICOLON is choosen ");}
    | SEMICOLON                                   
    ;
     


dataType: INTEGER
        | FLOAT
        | CHAR
        | BOOL;     
variableDecl: varType IDENTIFIER {printf("varType IDENTIFIER is choosen ");}
            | varType IDENTIFIER ASSIGN dataType
            | CONST varType IDENTIFIER
            | CONST varType IDENTIFIER ASSIGN dataType;
varType: TYPE_INT {printf("TYPE_INT is choosen ");}
        | TYPE_FLOAT
        | TYPE_CHAR
        | TYPE_BOOL
        | TYPE_VOID; 
%%

void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
