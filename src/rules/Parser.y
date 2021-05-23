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
program:stmts
        | ;

stmts:stmt
    | stmts stmt
    ;         
stmt:variableDecl SEMICOLON
    | multiVariableDecl SEMICOLON
    | expr SEMICOLON
    | functionCall SEMICOLON
    | function 
    | IDENTIFIER ASSIGN functionCall SEMICOLON                   
    | BREAK SEMICOLON                  
    | CONTINUE SEMICOLON 
    | returnStmt SEMICOLON                               
    | ifStmt                     
    | switchStmt                 
    | caseStmt                   
    | whileStmt                  
    | doWhileStmt SEMICOLON           
    | forStmt  
    | SEMICOLON                                             
    ;
     

varType: TYPE_INT
        | TYPE_FLOAT
        | TYPE_CHAR
        | TYPE_BOOL
        | TYPE_VOID;
dataType: INTEGER
        | FLOAT
        | CHAR
        | BOOL;     
variableDecl: varType IDENTIFIER 
            | varType IDENTIFIER ASSIGN expr
            | varType IDENTIFIER ASSIGN functionCall
            | CONST varType IDENTIFIER
            | CONST varType IDENTIFIER ASSIGN expr
            | CONST varType IDENTIFIER ASSIGN functionCall;

multiVariableDecl:  variableDecl ',' IDENTIFIER                      
                | variableDecl ',' IDENTIFIER ASSIGN expr       
                | multiVariableDecl ',' IDENTIFIER                
                | multiVariableDecl ',' IDENTIFIER ASSIGN expr; 

expr:   expr ASSIGN expr           
        | expr '+' expr        
        | expr '-' expr         
        | expr '*' expr     
        | expr '/' expr    
        | expr '%' expr         
        | expr '|' expr         
        | expr '^' expr         
        | expr '&' expr         
        | '!' expr         
        | '~' expr         
        | expr '<' expr         
        | expr '>' expr
        | expr INC
        | INC expr
        | expr DEC
        | DEC expr  
        | expr EQUAL expr
        | expr NOT_EQUAL expr
        | expr GREATER_EQUAL expr
        | expr LESS_EQUAL expr
        | expr SHL expr
        | expr SHR expr
        | expr LOGICAL_AND expr
        | expr LOGICAL_OR expr
        | dataType
        | IDENTIFIER        
        ;

functionCall: IDENTIFIER '(' functionArgumentsPassed ')';
functionArgumentsPassed:expr
                | functionArgumentsPassed ',' expr
                | ;
function:   functionHeader body ;

functionHeader:    varType IDENTIFIER '(' functionArgumentsDecl ')' ;

functionArgumentsDecl:            
                    | variableDecl                        
                    | functionArgumentsDecl ',' variableDecl 
                    ;                   
body:'{'  '}'
    | '{' stmts '}';  

returnStmt:RETURN expr                 
    | RETURN 
    | RETURN functionCall                            
    ;

ifStmt:un_matched_if
    | matched_if
    ;
un_matched_if:  IF '(' expr ')' body
                | IF '(' expr ')' stmt;
matched_if:    IF '(' expr ')' body ELSE body
                | IF '(' expr ')' stmt ELSE stmt;

switchStmt:SWITCH '(' expr ')' body;

caseStmt: CASE expr ':' stmt             
    | DEFAULT ':' stmt             
    ;
whileStmt:WHILE '(' expr ')' body
        | WHILE '(' expr ')' stmt;      

doWhileStmt:DO body WHILE '(' expr ')';  

forStmt:forHeader body
        |forHeader stmt; 
forHeader: FOR '(' variableDecl SEMICOLON expr SEMICOLON expr ')';

 
%%

void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
