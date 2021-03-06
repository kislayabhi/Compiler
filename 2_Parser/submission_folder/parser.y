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
%right "then" ELSE /*Same precedence but "shift" wins"*/
%right "lessthanlparen" MK_LPAREN
%right "reduce_error" MK_SEMICOLON
%%

/* ==== Grammar Section ==== */

/* Productions */        /* Semantic actions */
program                 : global_decl_list
                        ;
global_decl_list        : global_decl_list global_decl
                        | MK_SEMICOLON
                        |
                        ;
global_decl             : function_decl MK_SEMICOLON
                        | function_def
                        | horz_decl_init_list MK_SEMICOLON
                        | horz_init_list MK_SEMICOLON
                        | function_call MK_SEMICOLON
                        | struct_or_union_decl MK_SEMICOLON
                        | derived_id error MK_SEMICOLON{yyerrok; printf("Unidentified typename or Id (global)\n");}
                        ;
function_decl           : type ID MK_LPAREN parameter_list MK_RPAREN
                        | type ID MK_LPAREN MK_RPAREN
                        | VOID ID MK_LPAREN parameter_list MK_RPAREN
                        | VOID ID MK_LPAREN MK_RPAREN
                        ;
function_def            : type ID MK_LPAREN parameter_list MK_RPAREN MK_LBRACE function_body MK_RBRACE
                        | type ID MK_LPAREN MK_RPAREN MK_LBRACE function_body MK_RBRACE
                        | VOID ID MK_LPAREN parameter_list MK_RPAREN MK_LBRACE function_body MK_RBRACE
                        | VOID ID MK_LPAREN MK_RPAREN MK_LBRACE function_body MK_RBRACE
                        ;
struct_or_union_decl    : STRUCT id MK_LBRACE struct_material_list MK_RBRACE struct_members
                        | STRUCT MK_LBRACE struct_material_list MK_RBRACE struct_members
                        | STRUCT id MK_LBRACE struct_material_list MK_RBRACE
                        | STRUCT MK_LBRACE struct_material_list MK_RBRACE
                        | STRUCT id struct_members
                        | STRUCT id MK_LBRACE error MK_RBRACE struct_members {yyerrok; printf("only member definitions are allowed in a struct\n");}
                        | STRUCT id MK_LBRACE error MK_RBRACE {yyerrok; printf("only member definitions are allowed in a struct\n");}
                        ;
struct_material_list    : struct_or_union_decl MK_SEMICOLON struct_material_list
                        | horz_decl_init_list MK_SEMICOLON struct_material_list
                        |
                        ;
struct_members          : derived_id MK_COMMA struct_members
                        | derived_id
                        ;
function_body           : statement_list
                        ;
statement_list          : statement_list statement
                        |
                        ;
statement               : return_statement MK_SEMICOLON
                        | function_call MK_SEMICOLON
                        | control_flow
                        | control_arguments MK_SEMICOLON
                        | struct_or_union_decl MK_SEMICOLON
                        | MK_SEMICOLON
                        | derived_id error MK_SEMICOLON{yyerrok; printf("Unidentified typename or Id (local)\n");}
                        | control_arguments error MK_SEMICOLON{yyerrok; printf("Errors with assignment operator\n");}
                        ;
control_flow            : WHILE MK_LPAREN control_arguments MK_RPAREN statement
                        | WHILE MK_LPAREN control_arguments MK_RPAREN MK_LBRACE function_body MK_RBRACE
                        | IF MK_LPAREN control_arguments MK_RPAREN statement                            %prec "then"
                        | IF MK_LPAREN control_arguments MK_RPAREN statement ELSE statement
                        | IF MK_LPAREN control_arguments MK_RPAREN statement ELSE MK_LBRACE function_body MK_RBRACE
                        | IF MK_LPAREN control_arguments MK_RPAREN MK_LBRACE function_body MK_RBRACE    %prec "then"
                        | IF MK_LPAREN control_arguments MK_RPAREN MK_LBRACE function_body MK_RBRACE ELSE statement
                        | IF MK_LPAREN control_arguments MK_RPAREN MK_LBRACE function_body MK_RBRACE ELSE MK_LBRACE function_body MK_RBRACE
                        | FOR MK_LPAREN control_arguments MK_SEMICOLON control_arguments MK_SEMICOLON control_arguments MK_RPAREN statement
                        | FOR MK_LPAREN control_arguments MK_SEMICOLON control_arguments MK_SEMICOLON control_arguments MK_RPAREN MK_LBRACE function_body MK_RBRACE
                        | IF MK_LPAREN error MK_RBRACE {yyerrok; printf("Errors in if(***) condition\n");}
                        | FOR MK_LPAREN error MK_RBRACE {yyerrok; printf("Errors in for(***) condition\n");}
                        | WHILE MK_LPAREN error MK_RBRACE {yyerrok; printf("Errors in while(***) condition\n");}
                        ;
control_arguments       : expression_list_list
                        | horz_init_list
                        | horz_decl_init_list
                        ;
return_statement        : RETURN sign CONST
                        | RETURN CONST
                        | RETURN sign id
                        | RETURN id
                        | RETURN
                        ;
horz_init_list          : derived_id hard_assignment
                        ;
derived_id              : id MK_DOT id
                        | id
                        ;
id                      : ID                                                    %prec "lessthanlparen"
                        | ID array_braces array_braces_list
                        | ID blank_array_braces array_braces_list
                        ;
horz_decl_init_list     : parameter_decl hard_assignment more_horz_param_list
                        | parameter_decl hard_assignment
                        | parameter_decl
                        | parameter_decl more_horz_param_list
                        ;
more_horz_param_list    : MK_COMMA ID hard_assignment more_horz_param_list
                        | MK_COMMA ID hard_assignment
                        | MK_COMMA ID
                        | MK_COMMA ID more_horz_param_list
                        ;
hard_assignment         : OP_ASSIGN function_call
                        | OP_ASSIGN expression_ll_with_id
                        ;
expression_list_list    : CONST
                        | CONST expression_list
                        | derived_id expression_list
                        | expression_list
                        ;
expression_ll_with_id   : expression_list_list
                        | derived_id
                        ;
expression_list         : expression expression_list
                        | expression
                        ;
expression              : arithmetic_units primary
                        | arithmetic_units                                              %prec "lessthanlparen"
                        | arithmetic_units MK_LPAREN expression_ll_with_id MK_RPAREN
                        | MK_LPAREN expression_ll_with_id MK_RPAREN
                        ;
primary                 : id
                        | CONST
                        ;
function_call           : ID MK_LPAREN MK_RPAREN
                        | ID MK_LPAREN argument_list MK_RPAREN
                        ;
argument_list           : argument
                        | argument_list MK_COMMA argument
                        ;
argument                : id
                        | CONST
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
                        | MK_LB ID MK_RB
                        ;
blank_array_braces      : MK_LB MK_RB
                        ;
type                    : INT
                        | FLOAT
                        ;
sign                    : OP_PLUS
                        | OP_MINUS
                        | OP_NOT
                        ;
arithmetic_units        : sign
                        | OP_TIMES
                        | OP_DIVIDE
                        | binary_units
                        ;
binary_units            : OP_OR
                        | OP_AND
                        | OP_EQ
                        | OP_NE
                        | OP_LT
                        | OP_GT
                        | OP_LE
                        | OP_GE
                        ;
%%

#include "lex.yy.c"

main (argc, argv)
int argc;
char *argv[];
  {
        init_symtab();
        yyin = fopen(argv[1],"r");
     	yyparse();
  }


yyerror (mesg)
char *mesg;
{
	printf("%s\t%d\t%s\t%s\n", "Error found in Line ", linenumber, "next token: ", yytext );
  	printf("%s\t", mesg);
}
