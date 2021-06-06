/*References
 *https://troydhanson.github.io/uthash/userguide.html
 */

#include "uthash.h"
#include <stdbool.h>

enum variableType
{
    IntegerVarType,
    ConstIntegerVarType,
    FloatVarType, 
    ConstFloatVarType,
    CharVarType,
    ConstCharVarType, 
    BoolVarType
};

struct variable 
{
    enum variableType varType;
	char varName[60]; 
	int blockNumber;
	bool initialized; 
	bool usedBefore; 
	UT_hash_handle hh; 
};

struct variable* symbolTable = NULL;

//Symbol table methods

bool SymContains(char* varName) 
{
	struct variable * var;
	HASH_FIND_STR(symbolTable, varName, var);
	if (var == NULL)  
    {
        return false; 
    }
	return  true;
}
bool addVariableToSym(char* varName, bool initialized, enum variableType type, int blockNum)
{
	if (SymContains(varName)) { 
		return false;
	}
    struct variable * var = (struct variable*) malloc(sizeof(struct variable));
	var->initialized = initialized;
	var->blockNumber = blockNum;
	var->varType = type;
    var->usedBefore = false;
    strcpy(var->varName, varName);
	HASH_ADD_STR(symbolTable, varName, var);
    return true;
}
bool checkInitialization(char* varName, int scope)
{
    if (SymContains(varName)) {
        struct variable * var;
	    HASH_FIND_STR(symbolTable, varName, var);
		if (var->initialized == true)
        {
            return true;
        }
    }
    return false;
}
bool setInitialized(char* varName)
{
	struct variable * var;
	HASH_FIND_STR(symbolTable, varName, var);
	if (var != NULL) {
		var->initialized = true;
        return true;
	}
    return false;
}

int getBlockNumber(char* varName) 
{
	struct variable * var;
	HASH_FIND_STR(symbolTable, varName, var);
	if (var != NULL) {
		return var->blockNumber;
	}
	else {
		return -1;
	}
}
enum variableType getVarType(char* varName) 
{
	
	struct variable * var;
	HASH_FIND_STR(symbolTable, varName, var);
	if (var != NULL) {
		return var->varType;
	}
	else {
		return -1;
	}
}
bool checkVarUsedBefore(char* varName) 
{
	
	struct variable * var;
	HASH_FIND_STR(symbolTable, varName, var);
	if (var != NULL) {
		return var->usedBefore;
	}
	else {
		return false;
	}
}
bool setVarUsedBefore(char* varName) 
{
	struct variable * var;
	HASH_FIND_STR(symbolTable, varName, var);
	if (var != NULL) {
        var->usedBefore = true;
		return true;
	}
	return false;
}
const char* getVarTypeName(enum variableType type) 
{
	if(type==IntegerVarType || ConstIntegerVarType){return "int";}
	if(type==FloatVarType || ConstFloatVarType){return "float";}
	if(type==CharVarType || ConstCharVarType){return "char";}
	if(type==BoolVarType ){return "bool";}	
}	
bool checkVarType(char* varName , enum variableType type)
{   
	struct variable * var;
	HASH_FIND_STR(symbolTable, varName, var);
	if ((var->varType == type || var->varType == type+1)) 
    {
        return true;
    } 
	return false;
}
bool checkConstantInitialized(char* varName) 
{
	struct variable * var;
	HASH_FIND_STR(symbolTable, varName, var);
	if (var != NULL) {
		if ((var->varType%2) != 0 && var->initialized == true)
        {
            return false;
        }
    }
	return true;
}