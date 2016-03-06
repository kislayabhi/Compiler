/* ===== Definition Section ===== */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "stdbool.h"
#include "symboltable.h"
#include "datatypes.h"
static int linenumber = 1;
%}

%union {
	int intval;
	float floatval;
	char *stringval;
	A_var var;
	A_func func;
	idlist* idlisttype;

}
/*
   The following are just the token types. The grammar rules know nothing
   about tokens except their types. What I write in angle brackets is the
   variable(which is of a certain type as defined in the union) that stores
   the semantic value of that thing.
*/
%token <stringval>ID
%token <intval>ICONST
%token <floatval>FCONST
%token <stringval>SCONST
%token <intval>VOID
%token <intval>INT
%token <intval>FLOAT
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

%type<intval> var_decl
%type<intval> type
%type<idlisttype> init_id_list
%type<stringval> init_id


%start program

%%

/* ==== Grammar Section ==== */

/* Productions */               /* Semantic actions */
program		: global_decl_list
		;

global_decl_list: global_decl_list global_decl
                |
		;

global_decl	: decl_list function_decl
		| function_decl
		;

function_decl	: type ID MK_LPAREN param_list MK_RPAREN MK_LBRACE block MK_RBRACE
		/* | Other function_decl productions */
                /*Empty parameter list.*/
		| type ID MK_LPAREN MK_RPAREN MK_LBRACE block MK_RBRACE
                /*Function declarations. The above ones are function definitions*/
		| type ID MK_LPAREN param_list MK_RPAREN MK_SEMICOLON
		| type ID MK_LPAREN MK_RPAREN MK_SEMICOLON
		;

param_list	: param_list MK_COMMA  param
		| param
		;

param		: type ID
		| struct_type ID
		| type ID dim_fn
		| struct_type ID dim_fn
		;

dim_fn		: MK_LB expr_null MK_RB dimfn1
		;

dimfn1		: MK_LB expr MK_RB dimfn1
		|
		;

expr_null	: expr
		|
		;

block           : decl_list stmt_list
                | stmt_list
                | decl_list
                |
                ;

decl_list	: decl_list decl
		| decl
		;

decl		: type_decl
		| var_decl
		;

type_decl 	: TYPEDEF type id_list MK_SEMICOLON
		| TYPEDEF VOID id_list MK_SEMICOLON
		| TYPEDEF struct_type id_list MK_SEMICOLON
		| struct_type MK_SEMICOLON
		;
/* init_idlist will always have the pointer to the head of the idlist*/
var_decl	: type init_id_list MK_SEMICOLON {declare_variables($1); $$=$1; reinit_idlist();}
		| struct_type id_list MK_SEMICOLON
		| ID id_list MK_SEMICOLON
		;

/* Suppported types. */
type		: INT {$$=$1;}
		| FLOAT {$$=$1;}
		| VOID {$$=$1;}
        	| error {$$=-1;}
		;

struct_type	: STRUCT tag
		;

/* Struct variable body. */
tag		: ID MK_LBRACE decl_list MK_RBRACE
		| MK_LBRACE decl_list MK_RBRACE
		| ID MK_LBRACE MK_RBRACE
		| MK_LBRACE MK_RBRACE
		| ID
		;

id_list		: ID
		| id_list MK_COMMA ID
		| id_list MK_COMMA ID dim_decl
		| ID dim_decl
		;

dim_decl	: MK_LB cexpr MK_RB
		| dim_decl MK_LB cexpr MK_RB
		;

cexpr		: cexpr add_op mcexpr
		| mcexpr
		;

mcexpr		: mcexpr mul_op cfactor
		| cfactor
		;

cfactor		: const
		| MK_LPAREN cexpr MK_RPAREN
		;

/* Use the info of the type of the lhs to initialize the rhs*/
init_id_list	: init_id {$$=append_idlist($1);}
		| init_id_list MK_COMMA init_id {$$=append_idlist($3);}
		;

init_id		: ID {$$=strdup($1);}
		| ID dim_decl {$$=strdup($1);}
		| ID OP_ASSIGN relop_expr {$$=strdup($1);}
		;

stmt_list	: stmt_list stmt
		| stmt
		;

stmt		: MK_LBRACE block MK_RBRACE
		/* | While Statement here */
		| WHILE MK_LPAREN relop_expr_list MK_RPAREN stmt
	        | FOR MK_LPAREN assign_expr_list MK_SEMICOLON relop_expr_list MK_SEMICOLON assign_expr_list MK_RPAREN stmt
		/* | If then else here */
		| IF MK_LPAREN relop_expr MK_RPAREN stmt ELSE stmt
		/* | If statement here */
		| IF MK_LPAREN relop_expr MK_RPAREN stmt
		/* | read and write library calls -- note that read/write are not keywords */
		| ID MK_LPAREN relop_expr_list MK_RPAREN
		| var_ref OP_ASSIGN relop_expr MK_SEMICOLON
		| relop_expr_list MK_SEMICOLON
		| MK_SEMICOLON
		| RETURN MK_SEMICOLON
		| RETURN relop_expr MK_SEMICOLON
		;

assign_expr_list : nonempty_assign_expr_list
                |
                ;

nonempty_assign_expr_list       : nonempty_assign_expr_list MK_COMMA assign_expr
                		| assign_expr
				;

assign_expr     : ID OP_ASSIGN relop_expr
                | relop_expr
		;

relop_expr	: relop_term
		| relop_expr OP_OR relop_term
		;

relop_term	: relop_factor
		| relop_term OP_AND relop_factor
		;

relop_factor	: expr
		| expr rel_op expr
		;

/* Relational operators added.*/
rel_op		: OP_LT
		| OP_LE
		| OP_GT
		| OP_GE
		| OP_EQ
		| OP_NE
		;

relop_expr_list	: nonempty_relop_expr_list
		|
		;

nonempty_relop_expr_list	: nonempty_relop_expr_list MK_COMMA relop_expr
				| relop_expr
				;

expr		: expr add_op term
		| term
		;

add_op		: OP_PLUS
		| OP_MINUS
		;

term		: term mul_op factor
		| factor
		;

mul_op		: OP_TIMES
		| OP_DIVIDE
		;

factor		: MK_LPAREN relop_expr MK_RPAREN
		/* | -(<relop_expr>) */
		| OP_NOT MK_LPAREN relop_expr MK_RPAREN
                /* OP_MINUS condition added as C could have a condition like: "if(-(i < 10))".	*/
		| OP_MINUS MK_LPAREN relop_expr MK_RPAREN
		| const
		/* | - constant, here - is an Unary operator */
		| OP_NOT const
                /*OP_MINUS condition added as C could have a condition like: "if(-10)".	*/
		| OP_MINUS const
		| ID MK_LPAREN relop_expr_list MK_RPAREN
		/* | - func ( <relop_expr_list> ) */
		| OP_NOT ID MK_LPAREN relop_expr_list MK_RPAREN
                /* OP_MINUS condition added as C could have a condition like: "if(-read(i))".	*/
		| OP_MINUS ID MK_LPAREN relop_expr_list MK_RPAREN
		| var_ref
		/* | - var-reference */
		| OP_NOT var_ref
                /* OP_MINUS condition added as C could have a condition like: "if(-a)".	*/
		| OP_MINUS var_ref
		;

var_ref		: ID
		| var_ref dim
		| var_ref struct_tail
		;

dim		: MK_LB expr MK_RB
		;

struct_tail	: MK_DOT ID
		;

const		: ICONST
		| FCONST
		| SCONST
		;
%%
#include "lex.yy.c"

int scope = 0;
int main (int argc, char *argv[])
{
    init_symtab();

    /* idlist is used at the time of variable declaration */
    init_idlist();

    if(argc>0)
        yyin = fopen(argv[1],"r");
    else
        yyin=stdin;
    yyparse();
    printf("%s\n", "Parsing completed. No errors found.");
    printf("%s\n", "PRINTING THE CONTENTS OF THE SYMBOL TABLE");
    print_symtab();
    cleanup_symtab();
    cleanup_idlist();
    return 0;
} /* main */

yyerror (mesg)
char *mesg;
  {
      printf("%s\t%d\t%s\t%s\n", "Error found in Line ", linenumber, "next token: ", yytext );
      printf("%s\n", mesg);
      exit(1);
  }
