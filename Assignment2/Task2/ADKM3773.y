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

%%
stmt: { if(printLogs) printf("Parsing started\n"); } PROGRAM_DECLARATION VARIABLE_DECLARATION BODY_OF_PROGRAM { printf("Parsing completed successfully\n"); }
;

/* TYPE DECLARATIONS */
DATATYPE:  { if(printLogs) printf("DATATYPE found - INTEGER\n"); } INTEGER 
| { if(printLogs) printf("DATATYPE found - REAL\n"); } REAL 
| { if(printLogs) printf("DATATYPE found - BOOLEAN\n"); } BOOLEAN 
| { if(printLogs) printf("DATATYPE found - CHAR\n"); } CHAR 
;

RELOP: { if(printLogs) printf("RELOP found - EQUAL\n"); } EQUAL 
| { if(printLogs) printf("RELOP found - LESS\n"); } LESS 
| { if(printLogs) printf("RELOP found - GREATER\n"); } GREATER 
| { if(printLogs) printf("RELOP found - LESSEQUAL\n"); } LESSEQUAL 
| { if(printLogs) printf("RELOP found - GREATEREQUAL\n"); } GREATEREQUAL 
| { if(printLogs) printf("RELOP found - NOTEQUAL\n"); } NOTEQUAL
;

OPERATOR: { if(printLogs) printf("OPERATOR found - PLUS\n"); } PLUS 
| { if(printLogs) printf("OPERATOR found - MINUS\n"); } MINUS 
| { if(printLogs) printf("OPERATOR found - MULTIPLY\n"); } MULTIPLY 
| { if(printLogs) printf("OPERATOR found - DIVIDE\n"); } DIVIDE 
| { if(printLogs) printf("OPERATOR found - MOD\n"); } MOD
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

WRITE_STATEMENT: WRITE LPAREN STRING RPAREN SEMICOLON
| WRITE LPAREN WRITE_IDENTIFIER_LIST RPAREN SEMICOLON
;

WRITE_IDENTIFIER_LIST: IDENTIFIER
| IDENTIFIER WRITE_MORE_IDENTIFIERS
| IDENTIFIER ARRAY_ADD_ON_ID
| IDENTIFIER ARRAY_ADD_ON_ID WRITE_MORE_IDENTIFIERS
;

WRITE_MORE_IDENTIFIERS: COMMA IDENTIFIER
| COMMA IDENTIFIER WRITE_MORE_IDENTIFIERS
| COMMA IDENTIFIER ARRAY_ADD_ON_ID
| COMMA IDENTIFIER ARRAY_ADD_ON_ID WRITE_MORE_IDENTIFIERS 
;

/* ASSIGNMENT */
ASSIGNMENT_STATEMENT: IDENTIFIER COLON EQUAL EXPRESSION_LIST SEMICOLON
;

EXPRESSION_LIST: EXPRESSION
| EXPRESSION_LIST OPERATOR EXPRESSION_LIST
| LPAREN EXPRESSION_LIST RPAREN
;

EXPRESSION: 
| IDENTIFIER
| IDENTIFIER ARRAY_ADD_ON_ID
| NUMBER
;

/* CONDITIONAL STATEMENT */
CONDITIONAL_STATEMENT: IF LPAREN CONDITION RPAREN THEN BODY_OF_CONDITIONAL ELSE BODY_OF_CONDITIONAL SEMICOLON
| IF CONDITION THEN BODY_OF_CONDITIONAL ELSE BODY_OF_CONDITIONAL SEMICOLON
| IF LPAREN CONDITION RPAREN THEN BODY_OF_CONDITIONAL SEMICOLON
| IF CONDITION THEN BODY_OF_CONDITIONAL SEMICOLON
;

BODY_OF_CONDITIONAL: BEGINK STATEMENTS_INSIDE_CONDITIONAL END
| BEGINK END
;

STATEMENTS_INSIDE_CONDITIONAL: STATEMENT_INSIDE_CONDITIONAL STATEMENTS_INSIDE_CONDITIONAL
| STATEMENT_INSIDE_CONDITIONAL
;

CONDITION: EXPRESSION RELOP EXPRESSION
| NOT EXPRESSION
| EXPRESSION AND EXPRESSION
| EXPRESSION OR EXPRESSION
| EXPRESSION OPERATOR EXPRESSION EQUAL EXPRESSION
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

WHILE_LOOP: WHILE LPAREN CONDITION RPAREN DO BODY_OF_LOOP SEMICOLON
| WHILE CONDITION DO BODY_OF_LOOP SEMICOLON
;

FOR_LOOP_TO: FOR IDENTIFIER COLON EQUAL EXPRESSION TO EXPRESSION DO BODY_OF_LOOP SEMICOLON
;

FOR_LOOP_DOWNTO: FOR IDENTIFIER COLON EQUAL EXPRESSION DOWNTO EXPRESSION DO BODY_OF_LOOP SEMICOLON
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
        printf("Input file found, Parsing....\n");
        yyparse();
    }
}

int yyerror(){
    printf("\n\nSyntax error\n");
    return 0;
}