%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "../header.h"


void freeNode(nodeType *p);
int ex(nodeType *p);
int yylex(void);

void yyerror(char *s);
int sym[26];                    /* symbol table */
StatementNode* root = NULL;
%}

%union {
    int iValue;                 /* integer value */
    char sIndex;                /* symbol table index */
    nodeType *nPtr;             /* node pointer */
    exprNode* exprNodePtr;///class to be implemented
}
////////////////
// Tokens 
////////////////

// Data types
%token <location> TYPE_INT
%token <location> TYPE_FLOAT
%token <location> TYPE_CHAR
%token <location> TYPE_BOOL
%token <location> TYPE_VOID

// Keywords
%token <location> CONST


// Values
%token <token> INTEGER
%token <token> FLOAT
%token <token> CHAR
%token <token> BOOL
%token <token> IDENTIFIER

//////////////////////////////
// Non-terminal Symbols Types
////////////////////////////// 
%type <exprNodePtr>  expr

/////////////////////////////
//orders
/////////////////////////////
%left       '-' '+'
%left       '*' '/' '%'
%left       '|'
%left       '^'
%left       '&'
%right      '='
%right      '!' '~'

%%

expr:   expr '=' expr           { $$ = opr('=', 2, $1, $3); }
        | expr '+' expr         { $$ = opr('+', 2, $1, $3); }
        | expr '-' expr         { $$ = opr('-', 2, $1, $3); }
        | expr '*' expr         { $$ = opr('*', 2, $1, $3); }
        | expr '/' expr         { $$ = opr('/', 2, $1, $3); }
        | expr '%' expr         { $$ = opr('%', 2, $1, $3); }
        | expr '|' expr         { $$ = opr('|', 2, $1, $3); }
        | expr '^' expr         { $$ = opr('^', 2, $1, $3); }
        | expr '&' expr         { $$ = opr('&', 2, $1, $3); }
        | expr '!' expr         { $$ = opr('!', 2, $1, $3); }
        | expr '~' expr         { $$ = opr('~', 2, $1, $3); }
        | expr '<' expr         { $$ = opr('<', 2, $1, $3); }
        | expr '>' expr         { $$ = opr('>', 2, $1, $3); }
        ;
Vartype: TYPE_INT
        | TYPE_FLOAT
        | TYPE_CHAR
        | TYPE_BOOL
        | TYPE_VOID;
Datatype: INTEGER
        | FLOAT
        | CHAR
        | BOOL;     
variableDecl: Vartype IDENTIFIER 
            | Vartype IDENTIFIER '=' Datatype
            | Vartype IDENTIFIER '=' IDENTIFIER
            | CONST Vartype IDENTIFIER
            | CONST Vartype IDENTIFIER '=' Datatype
            | CONST Vartype IDENTIFIER '=' IDENTIFIER;

%%

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

void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
