%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdbool.h>
#include <string.h>
#include "../symbol_table.h"
#define YYERROR_VERBOSE
/*
 *Block\Scope data
 */
void newBlock();
void closeBlock();
bool functionBlock = 0;
int operant1_type[20];
int operant1_reg[20];
int operant1_rel_type[20];
int operant1_rel_reg[20];
int operant2_reg;
int operant2_rel_reg;
int currentBlock = 0;
int blockCount = 0;
int parentBlock[100];
int index = 0;
int index_1 = 0;
int currentIF = 0;
int labelS_count = 0;
bool isElseIF = 0;
int currentSwitch = 0;
int switchType = 0;
int forFirstReg = 0;
bool declareVariable(char *varName, bool initialized, int vartype, int AssignedValue,int BlockNum);
int currentVartype;
int assignedType;
bool validateTypeMatch(int vartype,int AssignedValue);
char *getTypeName(int value);
bool validateSameBlock(int BlockNum);
bool validateVarBeingUsed(char* varName,int currentBlock);
bool validateExpOperation(char* varName, int Vartype,  int Assignedtype,int CurrentBlock);
bool validateAssign(char *varName, int vartype, int AssignedValue,int BlockNum);
FILE *assembly;
FILE *symbolTableFile;
char*operation;
int RegisterNum=0;
void printSymbolTable();
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
///////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////
// Data types
/////////////////////////////
%token TYPE_INT 
%token TYPE_FLOAT
%token TYPE_CHAR
%token TYPE_BOOL
%token TYPE_VOID

/////////////////////////////
// Keywords
/////////////////////////////
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
%token RETURN

/////////////////////////////
// Values
/////////////////////////////
%token <intVal> INTEGER 
%token <floatVal> FLOAT
%token <charVal> CHAR
%token <boolVal> BOOL

/////////////////////////////
// Variable
/////////////////////////////
%token <variableName> IDENTIFIER 

/////////////////////////////
// Operators
/////////////////////////////
%token INC
%token DEC
%token EQUAL
%token NOT_EQUAL
%token GREATER_EQUAL
%token LESS_EQUAL
%token LOGICAL_AND
%token LOGICAL_OR
%token NOT

/////////////////////////////
// Math operation
////////////////////////////
%token ASSIGN

/////////////////////////////
// Others
////////////////////////////
%token SEMICOLON
%token COMA
%token Main
%token FUNC
%token CALL_FUNC
%token COLON
/////////////////////////////
// Precedence
/////////////////////////////
%left LEFTPARE RIGHTPARE CURLEFT CURRIGHT
%right ASSIGN
%left NOT_EQUAL LOGICAL_AND GREATER_EQUAL LESS_EQUAL LOGICAL_OR LESS GREATER  EQUAL
%left MINUS PLUS
%left MULT DIVI 
%nonassoc   ELSE

%%
///////////////////////////////////////////////////////////////////////////////////////
////////////////
// RULES
///////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////
// Language Structure
/////////////////////////////

program: mainStmt
    | functions mainStmt;

functions : FUNC function
    | functions FUNC function;

mainStmt:   TYPE_VOID Main  LEFTPARE RIGHTPARE {
                                                    newBlock(); 
                                                    fprintf(assembly,"Main:");
                                                    } 
                                                stmt_block {
                                                             closeBlock();
                                                                };

stmts:  stmt 
        | stmts stmt
        | stmt_block
        | stmts stmt_block;

stmt_block: CURLEFT {
                    newBlock();
                    } 
                CURRIGHT {
                        closeBlock();
                    } 
            | CURLEFT {
                    newBlock();
                    }  
                stmts CURRIGHT {
                            closeBlock();
                            };

stmt:   varDeclarationStmt SEMICOLON
        | postPrefixExpr SEMICOLON
        | ifStmt
        | forStmt
        | whileStmt
        | switchstmt
        | dowhileStmt
        | CALL_FUNC functionCall SEMICOLON;

/////////////////////////////
// Variables Declaration and Assignment
/////////////////////////////

varDeclarationStmt: variableDecl
                    | multiVariableDecl
                    | variableAssign;


varType:    TYPE_INT {
                        currentVartype=0;
                        }
            | TYPE_FLOAT {
                            currentVartype=2;
                            }
            | TYPE_CHAR {
                            currentVartype=4;
                            }
            | TYPE_BOOL {
                            currentVartype=6;
                            };
        
dataType:   BOOL {
                    assignedType=6;
                    fprintf(assembly,"\n MOV R%d, %s", RegisterNum, $1);
                    }
            | INTEGER {
                        assignedType=0;
                        fprintf(assembly,"\n MOV R%d, %d", RegisterNum, $1);
                        }
            | FLOAT {
                        assignedType=2;
                        fprintf(assembly,"\n MOV R%d, %f", RegisterNum, $1);
                        }
            | CHAR {
                        assignedType=4;
                        fprintf(assembly,"\n MOV R%d, %c", RegisterNum, $1);
                        };

variableDecl:   varType IDENTIFIER {
                                        declareVariable($2, false , currentVartype,-1, currentBlock);
                                        }
                | varType IDENTIFIER  ASSIGN expression { 
                                                            if(declareVariable($2,true , currentVartype, assignedType, currentBlock)) 
                                                                {
                                                                    fprintf(assembly, "\n MOV %s , R%d", $2 , RegisterNum);
                                                                    };
                                                            } 
                | CONST varType IDENTIFIER ASSIGN expression {
                                                                currentVartype = currentVartype + 1;
                                                                if(declareVariable($3, true , currentVartype, assignedType, currentBlock))
                                                                    {
                                                                        fprintf(assembly, "\n MOV %s , R%d", $3 , RegisterNum);
                                                                        };
                                                                }
                | varType IDENTIFIER  ASSIGN CALL_FUNC functionCall { 
                                                                        if(declareVariable($2, true , currentVartype, assignedType, currentBlock)) 
                                                                            {
                                                                                fprintf(assembly, "\n MOV %s , R%d", $2 , RegisterNum);
                                                                                };
                                                                        } 
                | CONST varType IDENTIFIER ASSIGN CALL_FUNC functionCall {
                                                                            currentVartype = currentVartype + 1;
                                                                            if(declareVariable($3, true , currentVartype, assignedType, currentBlock))
                                                                                {
                                                                                    fprintf(assembly, "\n MOV %s , R%d", $3 , RegisterNum);
                                                                                    };
                                                                            }; 

multiVariableDecl:  variableDecl COMA IDENTIFIER {
                                                    declareVariable($3, false , currentVartype,-1, currentBlock);
                                                    }                     
                    | variableDecl COMA IDENTIFIER ASSIGN expression {
                                                                        int declared = declareVariable($3, true , currentVartype, assignedType, currentBlock);
                                                                        }      
                    | multiVariableDecl COMA IDENTIFIER {
                                                            int declared = declareVariable($3, false , currentVartype, -1, currentBlock);
                                                            }              
                    | multiVariableDecl COMA IDENTIFIER ASSIGN expr {
                                                                        int declared = declareVariable($3, true , currentVartype, assignedType, currentBlock);
                                                                        };

variableAssign: IDENTIFIER {
                                currentVartype = getVarType($1); 
                                setVarUsedBefore($1);
                                }  
                        ASSIGN variableAssignTypes {
                                                        if(validateAssign($1, currentVartype, assignedType, currentBlock))
                                                        {
                                                            fprintf(assembly,"\n MOV %s , R%d",$1 ,RegisterNum);  setInitialized($1);
                                                            }
                                                        };

variableAssignTypes:    expression
                        | CALL_FUNC functionCall; 

/////////////////////////////
// Expressions
/////////////////////////////

expression: logicExpr;
    
mathExpr:   mathExpr PLUS {
                            operant1_type[index] = assignedType; 
                            operant1_reg[index] = RegisterNum++;
                            index++;
                            } 
                        mathExpr {
                                    index--; 
                                    validateTypeMatch(operant1_type[index], assignedType);  
                                    operant2_reg = RegisterNum++;  
                                    fprintf(assembly, "\n ADD R%d, R%d, R%d", RegisterNum,operant1_reg[index], operant2_reg);
                                    }       
            | mathExpr MINUS {
                                operant1_type[index] = assignedType; 
                                operant1_reg[index] = RegisterNum++; index++;
                                } 
                            mathExpr {
                                        index--; 
                                        validateTypeMatch(operant1_type[index], assignedType);  
                                        operant2_reg = RegisterNum++;  
                                        fprintf(assembly, "\n SUB R%d, R%d, R%d", RegisterNum,operant1_reg[index], operant2_reg);
                                        }
            | mathExpr MULT {
                                operant1_type[index] = assignedType; 
                                operant1_reg[index] = RegisterNum++; 
                                index++;
                                } 
                            mathExpr {
                                        index--; 
                                        validateTypeMatch(operant1_type[index], assignedType);  
                                        operant2_reg = RegisterNum++;  
                                        fprintf(assembly, "\n MUL R%d, R%d, R%d", RegisterNum, operant1_reg[index], operant2_reg);
                                        }
            | mathExpr DIVI {
                                operant1_type[index] = assignedType; 
                                operant1_reg[index] = RegisterNum++; index++;
                                } 
                            mathExpr {
                                    index--; 
                                    validateTypeMatch(operant1_type[index], assignedType);  
                                    operant2_reg = RegisterNum++;  
                                    fprintf(assembly, "\n DIV R%d, R%d, R%d", RegisterNum, operant1_reg[index], operant2_reg);
                                    }
            | expr;

relationExpr:   relationExpr LESS {
                                        operant1_rel_type[index_1]  = assignedType;  
                                        operant1_rel_reg[index_1] = RegisterNum++; 
                                        index_1++;
                                        } 
                                relationExpr {
                                                index_1--; 
                                                validateTypeMatch(operant1_rel_type[index_1], assignedType);  
                                                assignedType = 6; 
                                                operant2_reg = RegisterNum++;  
                                                fprintf(assembly, "\n CMPL R%d, R%d, R%d", RegisterNum, operant1_rel_reg[index_1], operant2_reg);
                                                }        
                | relationExpr GREATER {
                                            operant1_rel_type[index_1] = assignedType;  
                                            operant1_rel_reg[index_1] = RegisterNum++; 
                                            index_1++;
                                            } 
                                    relationExpr {
                                                    index_1--; 
                                                    validateTypeMatch(operant1_rel_type[index_1], assignedType);  
                                                    assignedType = 6; 
                                                    operant2_reg = RegisterNum++;  
                                                    fprintf(assembly, "\n CMPG R%d, R%d, R%d", RegisterNum, operant1_rel_reg[index_1], operant2_reg);
                                                    }
                | relationExpr EQUAL {
                                        operant1_rel_type[index_1]  = assignedType;  
                                        operant1_rel_reg[index_1] = RegisterNum++; 
                                        index_1++;
                                        } 
                                relationExpr {
                                                index_1--; 
                                                validateTypeMatch(operant1_rel_type[index_1], assignedType);  
                                                assignedType = 6; 
                                                operant2_reg = RegisterNum++;  
                                                fprintf(assembly, "\n CMPE R%d, R%d, R%d", RegisterNum, operant1_rel_reg[index_1], operant2_reg);
                                                }
                | relationExpr NOT_EQUAL {
                                            operant1_rel_type[index_1]  = assignedType;  
                                            operant1_rel_reg[index_1] = RegisterNum++; index_1++;
                                            } 
                                    relationExpr {
                                                    index_1--; 
                                                    validateTypeMatch(operant1_rel_type[index_1], assignedType);  
                                                    assignedType = 6; 
                                                    operant2_reg = RegisterNum++;  
                                                    fprintf(assembly, "\n CMPNE R%d, R%d, R%d", RegisterNum, operant1_rel_reg[index_1], operant2_reg);
                                                    }
                | relationExpr GREATER_EQUAL {
                                                operant1_rel_type[index_1]  = assignedType;  
                                                operant1_rel_reg[index_1] = RegisterNum++; index_1++;
                                                } 
                                        relationExpr {
                                                        index_1--; 
                                                        validateTypeMatch(operant1_rel_type[index_1], assignedType);  
                                                        assignedType = 6; 
                                                        operant2_reg = RegisterNum++;  
                                                        fprintf(assembly, "\n CMPGE R%d, R%d, R%d", RegisterNum,operant1_rel_reg[index_1], operant2_reg);
                                                        }
                | relationExpr LESS_EQUAL {
                                            operant1_rel_type[index_1]  = assignedType;  
                                            operant1_rel_reg[index_1] = RegisterNum++; 
                                            index_1++;
                                            } 
                                    relationExpr {
                                                    index_1--; 
                                                    validateTypeMatch(operant1_rel_type[index_1], assignedType);  
                                                    assignedType = 6; 
                                                    operant2_reg = RegisterNum++;  
                                                    fprintf(assembly, "\n CMPLE R%d, R%d, R%d", RegisterNum,operant1_rel_reg[index_1], operant2_reg);
                                                    }
                | mathExpr
                | NOT mathExpr;

logicExpr:  logicExpr LOGICAL_AND {
                                    operant1_rel_type[index_1]  = assignedType; 
                                    operant1_rel_reg[index_1] = RegisterNum++; 
                                    index_1++; 
                                    } 
                            logicExpr {
                                        index_1--; 
                                        validateTypeMatch(operant1_rel_type[index_1], assignedType);  
                                        assignedType = 6; 
                                        operant2_rel_reg = RegisterNum++;  
                                        fprintf(assembly, "\n AND R%d, R%d, R%d", RegisterNum,operant1_rel_reg[index_1], operant2_rel_reg);
                                        }
            | logicExpr LOGICAL_OR {
                                        operant1_rel_type[index_1]  = assignedType;   
                                        operant1_rel_reg[index_1] = RegisterNum++; 
                                        index_1++;
                                        } 
                                logicExpr {
                                            index_1--; 
                                            validateTypeMatch(operant1_rel_type[index_1], assignedType);  
                                            assignedType = 6; 
                                            operant2_reg = RegisterNum++;  
                                            fprintf(assembly, "\n OR R%d, R%d, R%d", RegisterNum,operant1_rel_reg[index_1], operant2_rel_reg);
                                            }
            | relationExpr;

expr:   dataType  
        | IDENTIFIER  {
                        validateVarBeingUsed($1, currentBlock);
                        assignedType = getVarType($1);
                        fprintf(assembly, "\n MOV R%d, %s", RegisterNum, $1);
                        };

postPrefixExpr: IDENTIFIER INC {
                                    validateExpOperation($1, assignedType, assignedType, currentBlock);
                                    fprintf(assembly, "\n MOV R%d, %s", RegisterNum, $1);
                                    fprintf(assembly, "\n MOV R1 , %s", $1);
                                    fprintf(assembly, "\n INC R1");
                                    fprintf(assembly, "\n MOV %s , R1", $1);
                                    }
                | INC IDENTIFIER {
                                    validateExpOperation($2, assignedType, assignedType, currentBlock);
                                    fprintf(assembly, "\n MOV R%d, %s", RegisterNum, $2);
                                    fprintf(assembly, "\n INC R1");
                                    fprintf(assembly, "\n MOV %s , R1",$2);
                                    }
                | IDENTIFIER DEC {
                                    validateExpOperation($1, assignedType, assignedType, currentBlock);
                                    fprintf(assembly, "\n MOV R%d, %s", RegisterNum,$1);
                                    fprintf(assembly, "\n MOV R1 , %s", $1);
                                    fprintf(assembly, "\n DEC R1");
                                    fprintf(assembly, "\n MOV %s , R1", $1);
                                    }
                | DEC IDENTIFIER {
                                    validateExpOperation($2, assignedType, assignedType, currentBlock);
                                    fprintf(assembly, "\n MOV R%d, %s", RegisterNum,$2);
                                    fprintf(assembly, "\n DEC R1");
                                    fprintf(assembly, "\n MOV %s , R1", $2);
                                    };



/////////////////////////////
// If/else if/else Statement
/////////////////////////////

ifStmt: ifstmt_start else_if optional_else {
                                                fprintf(assembly, "\n LabelIfExit%d: ", currentIF++);
                                                }
        | ifstmt_start optional_else {
                                        fprintf(assembly, "\n LabelIfExit%d: ", currentIF++)
                                        };

ifstmt_start:
    IF LEFTPARE logicExpr RIGHTPARE {
                                        fprintf(assembly, "\n JF R%d, LabelElseExit%d \t", RegisterNum, currentBlock); 
                                        validateTypeMatch(6, assignedType);
                                        } 
                                body;

else_if:    else_if ELSE IF LEFTPARE logicExpr RIGHTPARE { 
                                                            newBlock(); 
                                                            fprintf(assembly, "\n JF R%d, LabelElseExit%d \t", RegisterNum, currentBlock); 
                                                            validateTypeMatch(6, assignedType); closeBlock();
                                                            } 
                                                    body
            | ELSE IF LEFTPARE logicExpr RIGHTPARE { 
                                                        newBlock(); 
                                                        fprintf(assembly, "\n JF R%d, LabelElseExit%d \t",RegisterNum,currentBlock); 
                                                        validateTypeMatch(6, assignedType); 
                                                        closeBlock();
                                                        }
                                                body;

optional_else:  ELSE body 
                |   ;

body:   {
            newBlock();
            } 
        stmt_block {
                        closeBlock(); 
                        fprintf(assembly, "\n JMP LabelIfExit%d \n LabelElseExit%d: \t", currentIF, currentBlock);
                        };

/////////////////////////////
// Switch-case Statement
/////////////////////////////

switchstmt: SWITCH {
                        newBlock();
                        } 
                LEFTPARE IDENTIFIER {
                                        validateVarBeingUsed($4, currentBlock); 
                                        switchType = getVarType($4);
                                        RegisterNum = 0;
                                        fprintf(assembly, "\n MOV RS , %s",$4);
                                        }
                                RIGHTPARE CURLEFT casestmt CURRIGHT {
                                                                fprintf(assembly, "\n LabelSwitchExit%d: \t", currentSwitch++); 
                                                                closeBlock();
                                                                };

casestmt:   CASE expr COLON {
                            validateTypeMatch(assignedType, switchType);
                            fprintf(assembly, "\n CMPE R%d, RS, R%d", ++RegisterNum, RegisterNum );
                            fprintf(assembly, "\n JF R%d, LabelCaseExit%d \t", RegisterNum,labelS_count);
                            }  
                        stmts BREAK SEMICOLON { 
                                                fprintf(assembly, "\n JMP LabelSwitchExit%d \t", currentSwitch);
                                                fprintf(assembly, "\n LabelCaseExit%d: \t", labelS_count++);
                                                } 
                                            casestmt  
            | DEFAULT COLON stmts BREAK SEMICOLON {}
            | DEFAULT COLON BREAK SEMICOLON {}
            |   ;

/////////////////////////////
// For Loop Statement
/////////////////////////////

forStmt:    FOR {
                    newBlock(); 
                    RegisterNum=0;
                    } 
                LEFTPARE initStmt { 
                                        fprintf(assembly, "\n LabelFor%d:", currentBlock);
                                        }
                                logicExpr { 
                                                forFirstReg = RegisterNum; 
                                                validateTypeMatch(6, assignedType);  
                                                fprintf(assembly, "\n JF R%d, LabelForExit%d \t", forFirstReg, currentBlock);
                                                } 
                                        SEMICOLON loopCond RIGHTPARE stmt_block {
                                                                                    fprintf(assembly, "\n JMP LabelFor%d: \n LabelForExit%d: ", currentBlock , currentBlock); 
                                                                                    newBlock();
                                                                                    } ;

initStmt:   variableAssign SEMICOLON
		    | SEMICOLON;

loopCond:   postPrefixExpr 
		    | IDENTIFIER {
                            forFirstReg = assignedType;
                            } 
                        ASSIGN mathExpr {
                                            validateVarBeingUsed($1, currentBlock); 
                                            validateTypeMatch(forFirstReg, currentBlock);
                                            };

/////////////////////////////
// While Statement
/////////////////////////////

whileStmt: WHILE {
                    newBlock(); 
                    fprintf(assembly, "\n LabelWhile%d:", currentBlock);
                    } 
                LEFTPARE logicExpr { 
                                        fprintf(assembly, "\n JF R%d, LabelWhileExit%d \t", RegisterNum, currentBlock); 
                                        RegisterNum = 0;
                                        } 
                                    RIGHTPARE stmt_block {
                                                            fprintf(assembly, "\n JMP LabelWhile%d \n LabelWhileExit%d: ", currentBlock , currentBlock);
                                                            closeBlock();
                                                            };

/////////////////////////////
// Do-While Statement
/////////////////////////////

dowhileStmt: DO {
                    newBlock(); 
                    RegisterNum = 0; 
                    fprintf(assembly, "\n LabelDo%d: \t", currentBlock);
                    } 
                stmt_block WHILE LEFTPARE expression RIGHTPARE SEMICOLON {
                                                                            fprintf(assembly,"\n JT R%d, LabelDo%d \t",RegisterNum, currentBlock);  
                                                                            closeBlock();
                                                                            };   

/////////////////////////////
// Function
/////////////////////////////

functionCall:   IDENTIFIER {
                                RegisterNum = 0;
                                } 
                            LEFTPARE functionArgumentsPassed RIGHTPARE {
                                                                            fprintf(assembly,"\n CALL %s \t",$1);
                                                                            };

functionArgumentsPassed: expression {
                                        RegisterNum ++;
                                        }
                | functionArgumentsPassed COMA expression {
                                                            RegisterNum++;
                                                            }
                |   ;

function: functionHeader functionBody {
                                            closeBlock(); 
                                            fprintf(assembly, "\nReturn\t\n"); 
                                            functionBlock = 0
                                            };

functionHeader: varType IDENTIFIER {
                                        functionBlock = 1; 
                                        newBlock(); 
                                        RegisterNum = 0; 
                                        if(declareVariable($2,false , currentVartype, -1, 0)) 
                                            fprintf(assembly,"\n%s: \t", $2);
                                        } 
                                    LEFTPARE functionArgumentsDecl RIGHTPARE ;

functionArgumentsDecl:  varType IDENTIFIER {
                                                declareVariable($2, false , currentVartype, -1, currentBlock);
                                                }                  
                        | functionArgumentsDecl COMA varType IDENTIFIER {
                                                                            declareVariable($4, false , currentVartype, -1, currentBlock);
                                                                            }
                        |   ;

functionBody:   CURLEFT stmts returnStmt CURRIGHT
                | CURLEFT returnStmt CURRIGHT;

returnStmt: RETURN expression SEMICOLON              
            | RETURN functionCall SEMICOLON;


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
		if(validateSameBlock(getBlockNumber(varName)) == false){	
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
bool validateAssign(char *varName, int vartype, int AssignedValue,int BlockNum){
    bool alreadyExists= SymContains(varName);
    bool Match=validateTypeMatch(vartype,AssignedValue);
	if(Match==false) {return false;}
	if(alreadyExists == false)
	{	
        yyerror("Variable is not initialized");
        return false;
    }
	else{
        if(vartype%2 == 1)
        {
            yyerror("Constant cannot be reassigned");
            return false;
        }
		if(validateSameBlock(BlockNum) == false){	
			yyerror("You cannot assignen this variable.");
            return false;
        }
		else{
			return true;
		}
	}
    return false;		
}
bool validateTypeMatch(int vartype,int AssignedValue){

	if(AssignedValue != -1 && vartype!= AssignedValue && vartype!=AssignedValue+1 && vartype+1!=AssignedValue)
    {   char*VarTypeName=getTypeName(vartype);
        char*AssignedTypeName=getTypeName(AssignedValue);
        char*msg="Type Mismatch between ";
        char *msgError=malloc(strlen(msg)+strlen(VarTypeName)+strlen(AssignedTypeName)+50);
        strcpy(msgError, msg);
        strcat(msgError, AssignedTypeName);
        strcat(msgError, " variable and ");
        strcat(msgError, VarTypeName);
        strcat(msgError, " variable");
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
		if(initialized == false && functionBlock == false){
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
void printSymbolTable()
{   struct variable *var;
	fprintf(symbolTableFile,"Variable Name|Variable Type|ScopeNumber|Initialized|used");

	for (var = symbolTable; var != NULL; var = (struct variable*)(var->hh.next)) {
		fprintf(symbolTableFile,"\n%s|%s|%d|%s|%s", var->varName, getVarTypeName(var->varType), var->blockNumber, var->initialized? "Yes" : "No",var->usedBefore? "Yes" : "No");
	}
}
void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(void) {
    assembly= fopen("assembly", "w");
    symbolTableFile= fopen("symbolTableFile", "w");
    yyparse();
    printSymbolTable();
    fclose (assembly);
    fclose (symbolTableFile);
    return 0;
}
