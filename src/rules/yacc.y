%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdbool.h>
#include "../header.h"
#include "../symbol_table.h"

/*
 *Block\Scope data
 */
void newBlock();
void closeBlock();
int currentBlock = 0;
int blockCount = 0;
int parentBlock[100];

int yylex(void);
void yyerror(char *s);

%}
/*
%union {
    int intVal;                    
	float floatVal;
    char charVal;
    char* variableName;
    bool boolVal;
};*/

%start program
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
/*
%token <intVal> INTEGER 
%token <floatVal> FLOAT
%token <charVal> CHAR
%token <boolVal> BOOL
*/
//variable
%token IDENTIFIER 
//%token <variableName> IDENTIFIER 

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
%token COMA
/////////////////////////////
//orders
/////////////////////////////
%left '-' '+'
%left '*' '/' '%'
%left '|'
%left '^'
%left '&'
%left EQUAL
%left NOT_EQUAL
%left GREATER_EQUAL
%left '<' '>'
%left LESS_EQUAL
%left LOGICAL_OR
%left LOGICAL_AND
%left SHR SHL
%right ASSIGN
%right '!' '~'




%nonassoc   ELSE
%%
program:stmts   { exit(0); }
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

multiVariableDecl:  variableDecl COMA IDENTIFIER                      
                | variableDecl COMA IDENTIFIER ASSIGN expr       
                | multiVariableDecl COMA IDENTIFIER                
                | multiVariableDecl COMA IDENTIFIER ASSIGN expr; 

expr:mathExpr
    | logicExpr
    | expr2;
mathExpr: expr ASSIGN expr 
        | IDENTIFIER ASSIGN expr          
        | expr '+' expr        
        | expr '-' expr         
        | expr '*' expr     
        | expr '/' expr    
        | expr '%' expr            
        | expr '<' expr         
        | expr '>' expr
        | expr INC
        | INC expr
        | expr DEC
        | DEC expr  
        | expr EQUAL expr
        | expr NOT_EQUAL expr
        | expr GREATER_EQUAL expr
        | expr '^' expr 
        | expr LESS_EQUAL expr;
logicExpr: expr '|' expr                 
        | expr '&' expr         
        | '!' expr         
        | '~' expr              
        | expr SHL expr
        | expr SHR expr
        | expr LOGICAL_AND expr
        | expr LOGICAL_OR expr;
expr2:  dataType
        | IDENTIFIER        
        ;

functionCall: IDENTIFIER '(' functionArgumentsPassed ')';
functionArgumentsPassed:expr
                | functionArgumentsPassed COMA expr
                | ;
function:   functionHeader body ;

functionHeader:    varType IDENTIFIER '(' functionArgumentsDecl ')' ;

functionArgumentsDecl:            
                    | variableDecl                        
                    | functionArgumentsDecl COMA variableDecl 
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
                | IF '(' expr ')' stmt ELSE stmt
                | IF '(' expr ')' body ELSE stmt
                | IF '(' expr ')' stmt ELSE body;

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

void newBlock(){
	if(blockCount == 0) 
	    parentBlock[0] = 0;
    
    blockCount++;
	parentBlock[blockCount] = currentBlock;
	currentBlock = blockCount;
}

void closeBlock(){
	currentBlock--;
}


void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
