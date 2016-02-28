/* ===== Definition Section ===== */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static int linenumber = 1;
%}


%token ID
%token CONST
%token VOID
%token INT
%token FLOAT
%token IF
%token ELSE
%token WHILE
%token FOR
%token STRUCT
%token TYPEDEF
%token OP_ASSIGN
%token OP_OR
%token OP_AND
%token OP_NOT
%token OP_EQ
%token OP_NE
%token OP_GT
%token OP_LT
%token OP_GE
%token OP_LE
%token OP_PLUS
%token OP_MINUS
%token OP_TIMES
%token OP_DIVIDE
%token MK_LB
%token MK_RB
%token MK_LPAREN
%token MK_RPAREN
%token MK_LBRACE
%token MK_RBRACE
%token MK_COMMA
%token MK_SEMICOLON
%token MK_DOT
%token ERROR
%token RETURN

%start program

%%

/* ==== Grammar Section ==== */

/* Productions */               /* Semantic actions */
program                 : global_decl_list
                        ;
global_decl_list        : global_decl_list global_decl
                        |
                        ;
global_decl             : function_decl
                        | function_def
                        ;
/*
                        | struct_or_union_decl
                        | parameter_decl_init
                        ;
*/
function_decl           : return_type ID MK_LPAREN parameter_list MK_RPAREN MK_SEMICOLON
                        | return_type ID MK_LPAREN MK_RPAREN MK_SEMICOLON
                        ;
function_def            : return_type ID MK_LPAREN parameter_list MK_RPAREN MK_LBRACE function_body MK_RBRACE
                        | return_type ID MK_LPAREN MK_RPAREN MK_LBRACE function_body MK_RBRACE
                        ;
/*
struct_or_union_decl    : STRUCT structure_tag MK_LBRACE structure_body MK_RBRACE structure_variables MK_SEMICOLON
                        ;
parameter_decl_init     : type variable_array_list
                        ;
*/
function_body           : statement_list
                        ;
statement_list          : statement_list statement
                        |
                        ;
statement               : horz_decl_init_list
                        | horz_init_list
                        | return_statement
                        | function_call MK_SEMICOLON
                        ;
/*
                        | for_while_if

*/
                        ;
return_statement        : RETURN sign CONST MK_SEMICOLON
                        | RETURN CONST MK_SEMICOLON
                        | RETURN sign id MK_SEMICOLON
                        | RETURN id MK_SEMICOLON
                        ;
horz_init_list          : derived_id assignment MK_SEMICOLON
                        ;
derived_id              : id MK_DOT id
                        | id
                        ;
id                      : ID
                        | ID array_braces array_braces_list
                        | ID blank_array_braces array_braces_list
                        ;
horz_decl_init_list     : parameter_decl assignment more_horz_param_list MK_SEMICOLON
                        | parameter_decl assignment MK_SEMICOLON
                        ;
more_horz_param_list    : MK_COMMA ID assignment more_horz_param_list
                        | MK_COMMA ID assignment
                        ;
assignment              : OP_ASSIGN function_call
                        | OP_ASSIGN expression_list_list
                        |
                        ;
expression_list_list    : CONST
                        | CONST expression_list
                        | id expression_list
                        | expression_list
                        ;
expression_list         : arithmetic_units primary expression_list
                        | arithmetic_units primary
                        ;
primary                 : id
                        | CONST
                        | MK_LPAREN expression_list_list MK_RPAREN
                        ;
function_call           : ID MK_LPAREN MK_RPAREN
                        ;
return_type             : type
                        | VOID
                        ;
parameter_list          : parameter_decl
                        | parameter_list MK_COMMA parameter_decl
                        ;
parameter_decl          : variable_decl
                        | array_decl
                        ;
variable_decl           : type ID
                        ;
array_decl              : type ID array_braces array_braces_list
                        | type ID blank_array_braces array_braces_list
                        ;
array_braces_list       : array_braces_list array_braces
                        |
                        ;
array_braces            : MK_LB CONST MK_RB
                        ;
blank_array_braces      : MK_LB MK_RB
                        ;
type                    : INT
                        | FLOAT
                        ;
sign                    : OP_PLUS
                        | OP_MINUS
                        ;
arithmetic_units        : sign
                        | OP_TIMES
                        | OP_DIVIDE
                        ;
%%

#include "lex.yy.c"
main (argc, argv)
int argc;
char *argv[];
  {
     	yyin = fopen(argv[1],"r");
     	yyparse();
     	printf("%s\n", "Parsing completed. No errors found.");
  }


yyerror (mesg)
char *mesg;
{
	printf("%s\t%d\t%s\t%s\n", "Error found in Line ", linenumber, "next token: ", yytext );
  	printf("%s\n", mesg);
  	exit(1);
}
