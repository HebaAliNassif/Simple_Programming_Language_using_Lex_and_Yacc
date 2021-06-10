%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdbool.h>
#include <string.h>
#include "../header.h"
#include "../symbol_table.h"
#define YYERROR_VERBOSE
/*
 *Block\Scope data
 */
void newBlock();
void closeBlock();
int currentBlock = 0;
int blockCount = 0;
int parentBlock[100];
bool declareVariable(char *varName, bool initialized, int vartype, int AssignedValue,int BlockNum);
int currentVartype;
int assignedType;
bool validateTypeMatch(int vartype,int AssignedValue);
char *getTypeName(int value);
bool validateSameBlock(int BlockNum);
bool validateVarBeingUsed(char* varName,int currentBlock);
bool validateExpOperation(char* varName, int Vartype,  int Assignedtype,int CurrentBlock);
extern FILE *yyin;
extern FILE *yyout;
FILE *assembly;
char*operation;
int RegisterNum=0;
int yylex(void);
void yyerror(char *s);
%}

%union {
    int intVal;                    
	float floatVal;
    char* charVal;
    char* variableName;
    char* boolVal;
};

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
/*%token INTEGER 
%token FLOAT
%token CHAR
%token BOOL*/

%token <intVal> INTEGER 
%token <floatVal> FLOAT
%token <charVal> CHAR
%token <boolVal> BOOL

//variable
//%token IDENTIFIER 
%token <variableName> IDENTIFIER 

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
program:
        stmts   { exit(0); }
        | 
        ;

stmts:stmt
    | stmts stmt
    ;         
stmt:variableDecl SEMICOLON
    | multiVariableDecl SEMICOLON
    | expr SEMICOLON
    | functionCall SEMICOLON
    | function 
    | IDENTIFIER ASSIGN functionCall SEMICOLON  {validateVarBeingUsed($1,currentBlock);}              
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
     

varType: 
        TYPE_INT {currentVartype=0;}
        | TYPE_FLOAT {currentVartype=2;}
        | TYPE_CHAR {currentVartype=4;}
        | TYPE_BOOL {currentVartype=6;}
        ;
        
dataType: 
        INTEGER {assignedType=0;}
        | FLOAT {assignedType=2;}
        | CHAR {assignedType=4;}
        | BOOL {assignedType=6;}
        ;     
variableDecl:
            varType IDENTIFIER {declareVariable($2,false , currentVartype,-1,currentBlock);}
            | varType IDENTIFIER ASSIGN expr {declareVariable($2,true , currentVartype,assignedType,currentBlock);}
            | varType IDENTIFIER ASSIGN functionCall {declareVariable($2,true , currentVartype,assignedType,currentBlock);}
            | CONST varType IDENTIFIER {currentVartype=currentVartype+1; declareVariable($3,false, currentVartype,-1,currentBlock);}
            | CONST varType IDENTIFIER ASSIGN expr {currentVartype=currentVartype+1; declareVariable($3,true , currentVartype,assignedType,currentBlock);}
            | CONST varType IDENTIFIER ASSIGN functionCall {currentVartype=currentVartype+1; declareVariable($3,true , currentVartype,assignedType,currentBlock);}
            ; 

multiVariableDecl:  
                variableDecl COMA IDENTIFIER {declareVariable($3,false , currentVartype,-1,currentBlock);}                     
                | variableDecl COMA IDENTIFIER ASSIGN expr {declareVariable($3,true , currentVartype,assignedType,currentBlock);}      
                | multiVariableDecl COMA IDENTIFIER {declareVariable($3,false , currentVartype,-1,currentBlock);}              
                | multiVariableDecl COMA IDENTIFIER ASSIGN expr {declareVariable($3,true , currentVartype,assignedType,currentBlock);} 
                ;
expr:mathExpr
    | logicExpr
    | expr2
    ;
mathExpr: 
        | IDENTIFIER ASSIGN expr   {validateExpOperation($1,currentVartype,assignedType,currentBlock);}        
        | expr '+' expr        
        | expr '-' expr 
        | '-' expr        
        | expr '*' expr     
        | expr '/' expr    
        | expr '%' expr            
        | expr '<' expr         
        | expr '>' expr
        | IDENTIFIER INC {validateExpOperation($1,currentVartype,currentVartype,currentBlock);fprintf(assembly,"\n MOV R0 , %s",$1);fprintf(assembly,"\n MOV R1 , %s",$1);fprintf(assembly,"\n INC R1");fprintf(assembly,"\n MOV %s , R1",$1);}
        | INC IDENTIFIER {validateExpOperation($2,currentVartype,currentVartype,currentBlock);fprintf(assembly,"\n MOV R1 , %s",$2);fprintf(assembly,"\n INC R1");fprintf(assembly,"\n MOV %s , R1",$2);}
        | IDENTIFIER DEC {validateExpOperation($1,currentVartype,currentVartype,currentBlock);fprintf(assembly,"\n MOV R0 , %s",$1);fprintf(assembly,"\n MOV R1 , %s",$1);fprintf(assembly,"\n DEC R1");fprintf(assembly,"\n MOV %s , R1",$1);}
        | DEC IDENTIFIER {validateExpOperation($2,currentVartype,currentVartype,currentBlock);fprintf(assembly,"\n MOV R1 , %s",$2);fprintf(assembly,"\n DEC R1");fprintf(assembly,"\n MOV %s , R1",$2);} 
        | expr EQUAL expr
        | expr NOT_EQUAL expr
        | expr GREATER_EQUAL expr
        | expr '^' expr 
        | expr LESS_EQUAL expr
        ;
logicExpr: expr '|' expr                 
        | expr '&' expr         
        | '!' expr         
        | '~' expr              
        | expr SHL expr
        | expr SHR expr
        | expr LOGICAL_AND expr
        | expr LOGICAL_OR expr
        ;
expr2:  dataType 
        | IDENTIFIER  {validateVarBeingUsed($1,currentBlock);}      
        ;

functionCall: IDENTIFIER '(' functionArgumentsPassed ')';

functionArgumentsPassed:expr
                | functionArgumentsPassed COMA expr
                | 
                ;
function:   functionHeader body ;

functionHeader: varType IDENTIFIER '(' functionArgumentsDecl ')' ;

functionArgumentsDecl:            
                    | variableDecl                        
                    | functionArgumentsDecl COMA variableDecl 
                    ;                   
body:'{' {newBlock();} '}' {closeBlock();}
    | '{' {newBlock();} stmts '}' {closeBlock();}
    ;  

returnStmt:RETURN expr                 
    | RETURN functionCall                            
    ;

ifStmt:un_matched_if
    | matched_if
    ;
un_matched_if:  IF '(' expr ')' body
                | IF '(' expr ')' stmt
                ;
matched_if:    IF '(' expr ')' body ELSE body
                | IF '(' expr ')' stmt ELSE stmt
                | IF '(' expr ')' body ELSE stmt
                | IF '(' expr ')' stmt ELSE body
                ;

switchStmt:SWITCH '(' expr ')' body;

caseStmt: CASE expr ':' stmt             
    | DEFAULT ':' stmt             
    ;
whileStmt:WHILE '(' expr ')' body
        | WHILE '(' expr ')' stmt
        ;      

doWhileStmt:DO body WHILE '(' expr ')';  

forStmt:forHeader body
        |forHeader stmt
        ; 
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
bool declareVariable(char *varName, bool initialized, int vartype, int AssignedValue,int BlockNum){
	bool alreadyExists= SymContains(varName);
    bool Match=validateTypeMatch(vartype,AssignedValue);
	if(Match==false) {return false;}
	if(alreadyExists == false)
	{	
        addVariableToSym(varName, initialized, vartype, BlockNum);
        return true;
    }
	else{
		if(validateSameBlock(BlockNum) == false){	
			addVariableToSym(varName, initialized, vartype, BlockNum);
            return true;
        }
		else{
            char*msg="Repeated declaration of the Variable ";
            char *msgError=malloc(strlen(varName)+strlen(msg));
            strcpy(msgError, msg);
            strcat(msgError, varName);
			yyerror(msgError);
			return false;
		}
	}		
}
bool validateTypeMatch(int vartype,int AssignedValue){

	if(AssignedValue != -1 && vartype!= AssignedValue && vartype!=AssignedValue+1 && vartype+1!=AssignedValue)
    {   char*VarTypeName=getTypeName(vartype);
        char*AssignedTypeName=getTypeName(AssignedValue);
        char*msg="Type Mismatch assigning ";
        char *msgError=malloc(strlen(msg)+strlen(VarTypeName)+strlen(AssignedTypeName)+4);
        strcpy(msgError, msg);
        strcat(msgError, AssignedTypeName);
        strcat(msgError, " to ");
        strcat(msgError, VarTypeName);
        yyerror(msgError);
	    return false;
	}
	return true;
}
char *getTypeName(int value){
    if(value==0) return "int";
    if(value==2) return "float";
    if(value==4) return "char";
    if(value==6) return "bool";
    return "unknown type";
}
bool validateSameBlock(int BlockNum){
    if(BlockNum == currentBlock || BlockNum == 0) {
        return true;
    }

	int parentBlockNum = currentBlock;
	
	while(parentBlockNum != 0){
	    parentBlockNum = parentBlock[parentBlockNum];
		if(BlockNum == parentBlockNum){
		    return true;
		}
	}
	return false;
}
bool validateVarBeingUsed(char* varName,int currentBlock){
	bool alreadyExists=SymContains(varName); 
	if(alreadyExists==false){
        currentVartype=-1;
        assignedType=-1;
		char*msg="Undeclared Variable ";
        char *msgError=malloc(strlen(varName)+strlen(msg));
        strcpy(msgError, msg);
        strcat(msgError, varName);
		yyerror(msgError);
		return false;
	}
	else {
        int VarBlock=getBlockNumber(varName);
        if(VarBlock>currentBlock)
        {
            char*msg=" is not declared in the current scope";
            char *msgError=malloc(strlen(msg)+strlen(varName)+9);
            strcpy(msgError, "Variable ");
            strcat(msgError, varName);
            strcat(msgError, msg);
            yyerror(msgError); 
           return false;
        }
		bool initialized=checkInitialization(varName,currentBlock);
		if(initialized == false){
            char*msg=" is used before being initialized";
            char *msgError=malloc(strlen(msg)+strlen(varName)+9);
            strcpy(msgError, "Variable ");
            strcat(msgError, varName);
            strcat(msgError, msg);
            yyerror(msgError); 
			return false;
		}
		else{
            bool setUsed=setVarUsedBefore(varName);
			return validateSameBlock(currentBlock);
		}

	}
}
bool validateExpOperation(char* varName, int Vartype,  int Assignedtype,int CurrentBlock){
	bool alreadyExists=SymContains(varName); 
	if(alreadyExists==false) 
    {
        char*msg="Undeclared Variable ";
        char *msgError=malloc(strlen(varName)+strlen(msg));
        strcpy(msgError, msg);
        strcat(msgError, varName);
		yyerror(msgError);   
        return false;
    }

	bool Matched=validateTypeMatch(Vartype, Assignedtype);
	if(Matched==false) 
    {
        return false;
    }
    else{
        setInitialized(varName);
    }

	if(!checkConstantInitialized(varName))
    {   char*msg="Assigning another value to a const variable ";
        char *msgError=malloc(strlen(varName)+strlen(msg));
        strcpy(msgError, msg);
        strcat(msgError, varName);
		yyerror(msgError);
		return false;
    }
	return validateVarBeingUsed(varName,currentBlock);
}
void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(void) {
    assembly= fopen("assembly", "w");
    yyparse();
    fclose (assembly);
    return 0;
}
