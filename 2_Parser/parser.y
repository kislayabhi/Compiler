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
                        ;
/*
                        | function_def
                        | struct_or_union_decl
                        | parameter_decl_init
                        ;
*/
function_decl           : return_type function_name MK_LPAREN parameter_or_type_list MK_RPAREN MK_SEMICOLON
                        ;
/*
function_def            : return_type function_name MK_LPAREN parameter_list MK_RPAREN MK_LBRACE function_body MK_RBRACE
                        ;
struct_or_union_decl    : STRUCT structure_tag MK_LBRACE structure_body MK_RBRACE structure_variables MK_SEMICOLON
                        ;
parameter_decl_init     : type variable_array_list
                        ;
*/
return_type             : type
                        | VOID
                        ;
function_name           : ID
                        ;
parameter_or_type_list  : include_comma parameter_or_type_decl
                        |
                        ;
include_comma           : parameter_or_type_list MK_COMMA
                        |
                        ;
parameter_or_type_decl  : type
                        | variable_decl
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




/*
global_decl             : type function_name MK_LPAREN parameter_list MK_RPAREN MK_LBRACE statement_list MK_RBRACE;

type                    : INT | FLOAT | VOID;
function_name           : ID;
parameter_list          : parameter_list MK_COMMA parameter | parameter | ;
parameter               : type ID array_braces_list_one;
array_braces_list_one   : array_braces_list_one array_braces | blank_array_braces | ;
array_braces            : MK_LB argument_data MK_RB;
argument_data           : CONST;
blank_array_braces      : MK_LB CONST MK_RB | MK_LB MK_RB;
statement_list          : statement_list statement | statement | ;
statement               : type identifier_dec_list MK_SEMICOLON | identifier_dec_list MK_SEMICOLON | MK_SEMICOLON;
identifier_dec_list     : identifier_dec_list assignment MK_COMMA identifier_dec assignment | identifier_dec assignment;
identifier_dec          : ID array_braces_list_two;
array_braces_list_two   : array_braces_list_two array_braces | ;
assignment              : OP_ASSIGN CONST | ;
*/
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
