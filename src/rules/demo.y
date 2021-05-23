%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "../header.h"

//////////////////////////////////////phase2/////////////////////////////////////////
///////////To be updated:
void freeNode(nodeType *p);
int ex(nodeType *p);
int yylex(void);

void yyerror(char *s);
int sym[26];                    // symbol table 

%}


%union {
    int iValue;                 // integer value 
    char sIndex;                // symbol table index 
    nodeType *nPtr;             // node pointer 
}
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
%token IF;
%token ELSE;
%token SWITCH;
%token CASE;
%token DEFAULT;
%token FOR;
%token DO;
%token WHILE;
%token BREAK;
%token CONTINUE;
%token RETURN;

// Values
%token INTEGER 
%token FLOAT
%token CHAR
%token BOOL

//variable
%token IDENTIFIER 

//operators

%token INC;
%token DEC;
%token EQUAL;
%token NOT_EQUAL;
%token GREATER_EQUAL;
%token LESS_EQUAL;
%token SHL;
%token SHR;
%token LOGICAL_AND;
%token LOGICAL_OR;
/////////////////////////////
//math operation
////////////////////////////
%token ASSIGN;

/////////////////////////////
//Others
////////////////////////////
%token SEMICOLON;
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
%type <nPtr> program
%%
program:stmt
        |
        ;

        
stmt:variableDecl SEMICOLON  
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
            | varType IDENTIFIER ASSIGN dataType
            | CONST varType IDENTIFIER
            | CONST varType IDENTIFIER ASSIGN dataType;
 
%%
//////////////////////////////////////////////////////////////////phase2///////////////////////////////////////////////
nodeType *con(int value) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeCon;
    p->con.value = value;

    return p;
}

nodeType *id(int i) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeId;
    p->id.i = i;

    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    int i;

    /* allocate node, extending op array */
    if ((p = malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType *))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    va_end(ap);
    return p;
}

void freeNode(nodeType *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    free (p);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
