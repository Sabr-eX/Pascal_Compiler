%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
int yyerror();
extern FILE *yyin;

int printLogs = 0;
%}

%token PROGRAM INTEGER REAL BEGINK END BOOLEAN CHAR IF ELSE TO DOWNTO VAR ARRAY FOR WHILE DO NOT AND OR READ WRITE ARRAY_DOT
%token PLUS MINUS MULTIPLY DIVIDE MOD 
%token EQUAL LESS GREATER LESSEQUAL GREATEREQUAL NOTEQUAL
%token NUMBER 
%token IDENTIFIER
%token SEMICOLON COMMA COLON DOT LPAREN RPAREN LBRACKET RBRACKET STRING THEN OF

%left PLUS MINUS 
%left MULTIPLY DIVIDE MOD
%left AND NOT OR
%left EQUAL LESS GREATER LESSEQUAL GREATEREQUAL NOTEQUAL
%%
stmt: { if(printLogs) printf("Parsing started\n"); } PROGRAM_DECLARATION VARIABLE_DECLARATION BODY_OF_PROGRAM { printf("\n\nParsing completed successfully\n"); }
;

/* TYPE DECLARATIONS */
DATATYPE:  { if(printLogs) printf("DATATYPE found - INTEGER\n"); } INTEGER 
| { if(printLogs) printf("DATATYPE found - REAL\n"); } REAL 
| { if(printLogs) printf("DATATYPE found - BOOLEAN\n"); } BOOLEAN 
| { if(printLogs) printf("DATATYPE found - CHAR\n"); } CHAR 
;

/* ARRAY ADD ON FOR EVERY ID */
ARRAY_ADD_ON_ID: { if(printLogs) printf("ARRAY_ADD_ON_ID found\n"); } LBRACKET BETWEEN_BRACKETS RBRACKET
;

BETWEEN_BRACKETS: { if(printLogs) printf("BETWEEN_BRACKETS found - NUMBER\n"); } NUMBER
| { if(printLogs) printf("BETWEEN_BRACKETS found - IDENTIFIER\n"); } IDENTIFIER

/* HEAD OF THE PROGRAM - PARSING */
PROGRAM_DECLARATION: PROGRAM IDENTIFIER SEMICOLON
;

VARIABLE_DECLARATION: VAR DECLARATION_LISTS
| VAR
;

DECLARATION_LISTS: DECLARATION_LIST DECLARATION_LISTS
| DECLARATION_LIST
;

DECLARATION_LIST: SINGLE_VARIABLE
| MULTIPLE_VARIABLE
| ARRAY_DECLARATION
;

SINGLE_VARIABLE: IDENTIFIER COLON DATATYPE SEMICOLON
;

MULTIPLE_VARIABLE: IDENTIFIER MORE_IDENTIFIERS COLON DATATYPE SEMICOLON
;

MORE_IDENTIFIERS: COMMA IDENTIFIER MORE_IDENTIFIERS 
| COMMA IDENTIFIER
;

ARRAY_DECLARATION: IDENTIFIER COLON ARRAY LBRACKET NUMBER ARRAY_DOT NUMBER RBRACKET OF DATATYPE SEMICOLON
; 

/* MAIN BODY OF THE PROGRAM */
BODY_OF_PROGRAM: BEGINK STATEMENTS END DOT
| BEGINK END DOT
;

STATEMENTS: STATEMENT STATEMENTS
| STATEMENT
;

STATEMENT: { if(printLogs) printf("STATEMENTLIST found - READ\n"); } READ_STATEMENT 
| { if(printLogs) printf("STATEMENTLIST found - WRITE\n"); } WRITE_STATEMENT 
| { if(printLogs) printf("STATEMENTLIST found - ASSIGNMENT\n"); } ASSIGNMENT_STATEMENT 
| { if(printLogs) printf("STATEMENTLIST found - CONDITIONAL\n"); } CONDITIONAL_STATEMENT 
| { if(printLogs) printf("STATEMENTLIST found - LOOPING\n"); } LOOPING_STATEMENT
;

READ_STATEMENT: READ LPAREN IDENTIFIER RPAREN SEMICOLON
| READ LPAREN IDENTIFIER ARRAY_ADD_ON_ID RPAREN SEMICOLON
;

WRITE_STATEMENT:WRITE LPAREN WRITE_IDENTIFIER_LIST RPAREN SEMICOLON
;

WRITE_IDENTIFIER_LIST: IDENTIFIER
| IDENTIFIER WRITE_MORE_IDENTIFIERS
| IDENTIFIER ARRAY_ADD_ON_ID
| IDENTIFIER ARRAY_ADD_ON_ID WRITE_MORE_IDENTIFIERS
| STRING
| STRING WRITE_MORE_IDENTIFIERS
| NUMBER
| NUMBER WRITE_MORE_IDENTIFIERS
;

WRITE_MORE_IDENTIFIERS: COMMA IDENTIFIER
| COMMA IDENTIFIER WRITE_MORE_IDENTIFIERS
| COMMA IDENTIFIER ARRAY_ADD_ON_ID
| COMMA IDENTIFIER ARRAY_ADD_ON_ID WRITE_MORE_IDENTIFIERS 
| COMMA STRING
| COMMA STRING WRITE_MORE_IDENTIFIERS
| COMMA NUMBER
| COMMA NUMBER WRITE_MORE_IDENTIFIERS
;

/* ASSIGNMENT */
ASSIGNMENT_STATEMENT: IDENTIFIER COLON EQUAL EXPRESSION_LIST SEMICOLON
| IDENTIFIER ARRAY_ADD_ON_ID COLON EQUAL EXPRESSION_LIST SEMICOLON
;

EXPRESSION_LIST: TERM
| EXPRESSION_LIST PLUS EXPRESSION_LIST
| EXPRESSION_LIST MINUS EXPRESSION_LIST
| EXPRESSION_LIST MULTIPLY EXPRESSION_LIST
| EXPRESSION_LIST DIVIDE EXPRESSION_LIST
| EXPRESSION_LIST MOD EXPRESSION_LIST
| LPAREN EXPRESSION_LIST RPAREN
;

TERM: 
| IDENTIFIER
| IDENTIFIER ARRAY_ADD_ON_ID
| NUMBER
;

/* CONDITIONAL STATEMENT */
CONDITIONAL_STATEMENT: IF CONDITION THEN BODY_OF_CONDITIONAL ELSE BODY_OF_CONDITIONAL SEMICOLON
| IF CONDITION THEN BODY_OF_CONDITIONAL SEMICOLON
;

BODY_OF_CONDITIONAL: BEGINK STATEMENTS_INSIDE_CONDITIONAL END
| BEGINK END /* empty body */
;

STATEMENTS_INSIDE_CONDITIONAL: STATEMENT_INSIDE_CONDITIONAL STATEMENTS_INSIDE_CONDITIONAL
| STATEMENT_INSIDE_CONDITIONAL
;

CONDITION: IDENTIFIER /* Assuming boolean value is stored in identifier */
| IDENTIFIER ARRAY_ADD_ON_ID /* Assuming boolean value is stored in array */
| EXPRESSION_LIST EQUAL EXPRESSION_LIST /* a = b */
| EXPRESSION_LIST LESS EXPRESSION_LIST /* a < b */
| EXPRESSION_LIST GREATER EXPRESSION_LIST /* a > b */ 
| EXPRESSION_LIST LESSEQUAL EXPRESSION_LIST /* a <= b */
| EXPRESSION_LIST GREATEREQUAL EXPRESSION_LIST /* a >= b */
| EXPRESSION_LIST NOTEQUAL EXPRESSION_LIST /* a != b */
| NOT CONDITION /* NOT a */
| CONDITION AND CONDITION /* a AND b */
| CONDITION OR CONDITION /* a OR b */
;


STATEMENT_INSIDE_CONDITIONAL: { if(printLogs) printf("STATEMENTLIST found - READ\n"); } READ_STATEMENT
| { if(printLogs) printf("STATEMENTLIST found - WRITE\n"); } WRITE_STATEMENT
| { if(printLogs) printf("STATEMENTLIST found - ASSIGNMENT\n"); } ASSIGNMENT_STATEMENT
| { if(printLogs) printf("STATEMENTLIST found - LOOPING\n"); } LOOPING_STATEMENT
;

/* LOOPING STATEMENT */
LOOPING_STATEMENT: WHILE_LOOP
| FOR_LOOP_TO
| FOR_LOOP_DOWNTO
;

WHILE_LOOP: WHILE CONDITION DO BODY_OF_LOOP SEMICOLON
;

FOR_LOOP_TO: FOR IDENTIFIER COLON EQUAL EXPRESSION_LIST TO EXPRESSION_LIST DO BODY_OF_LOOP SEMICOLON
;

FOR_LOOP_DOWNTO: FOR IDENTIFIER COLON EQUAL EXPRESSION_LIST DOWNTO EXPRESSION_LIST DO BODY_OF_LOOP SEMICOLON
;

BODY_OF_LOOP: BEGINK STATEMENTS_INSIDE_LOOP END
;

STATEMENTS_INSIDE_LOOP: STATEMENT_INSIDE_LOOP STATEMENTS_INSIDE_LOOP
| STATEMENT_INSIDE_LOOP
;

STATEMENT_INSIDE_LOOP: { if(printLogs) printf("STATEMENTLIST found - READ\n"); } READ_STATEMENT
| { if(printLogs) printf("STATEMENTLIST found - WRITE\n"); } WRITE_STATEMENT
| { if(printLogs) printf("STATEMENTLIST found - ASSIGNMENT\n"); } ASSIGNMENT_STATEMENT
| { if(printLogs) printf("STATEMENTLIST found - CONDITIONAL\n"); } CONDITIONAL_STATEMENT
;


%%

void main()
{
    yyin = fopen("sample.txt", "r");
    if(yyin == NULL){
        if(printLogs) printf("File not found\n");
        exit(1);
    }
    else{
        if(printLogs) printf("Input file found, Parsing....\n");
        yyparse();
    }
}

int yyerror(){
    printf("\n\nSyntax error found\n");
    return 0;
}