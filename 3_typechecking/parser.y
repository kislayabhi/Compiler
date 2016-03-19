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
	A_usr_def_type_var user_defined_type;
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
%token <stringval>VOID
%token <stringval>INT
%token <stringval>FLOAT
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

%type<stringval> var_decl
%type<stringval> type
%type<idlisttype> init_id_list
%type<idlisttype> id_list
%type<stringval> init_id
%type<stringval> var_ref
%type<user_defined_type> struct_type
%type<user_defined_type> tag
%type<user_defined_type> type_decl


%start program

%%

/* ==== Grammar Section ==== */

/* Productions */               /* Semantic actions */
program		: global_decl_list
		;

global_decl_list: global_decl_list global_decl
                |
		;

global_decl	: decl_list function_decl/*This grammar is special in the sense
					   that ... you cannot have global
					   variables declared alone without
					   declaring any function.
					   */
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

type_decl 	: TYPEDEF type id_list MK_SEMICOLON 	{
								A_usr_def_type_var temp;
								temp.which_usrtype = typedef_type;
								temp.typename = strdup($1);
								/*Check if id_list is already there in the symbol table*/
								
							}
		| TYPEDEF VOID id_list MK_SEMICOLON /* Udt for void created */
		| TYPEDEF struct_type id_list MK_SEMICOLON /* Udt for struct_type created */
						           /* struct_type mein kaam ka sirf tag ka ID part hi hai...aur kaafi locha hai udhar */
							   /* Just like baki saarey types ek constant return kar rahey hain in place of semantic value */
							   /* This should also return some kind of kaam ka stuff. */
		| struct_type MK_SEMICOLON /* Here the term "struct_type" is to be used. type ke naam use karney padengey aisa prateet hota hai */
		;

/* init_idlist will always have the pointer to the head of the idlist*/
/* In the case of struct, along with the var_decl, type declaration also happens simultaneously. */
var_decl	: type init_id_list MK_SEMICOLON {
							if(!is_initidlist_empty()) {
								declare_variables($1);
								$$=strdup($1);
								reinit_idlist();
							}
						 }
		| struct_type id_list MK_SEMICOLON {
							/*see if the struct type exists or not*/
							if(is_struct_type_exists($1)) {
								if(!is_initidlist_empty()) {
									declare_usr_def_variables($1);
									$$=strdup($1.typename);
									reinit_idlist();
								}
							}
							else {
								yyerror();
								printf("\t struct type(name) undeclared \n");
								reinit_idlist();
							}
						   }
		| STRUCT ID id_list MK_SEMICOLON {
							A_usr_def_type_var temp;
							temp.which_usrtype = struct_type_explicit;
							temp.typename = strdup($2);
							/*see if the struct type exists or not*/
							if(is_struct_type_exists(temp)) {
								if(!is_initidlist_empty()) {
									declare_usr_def_variables(temp);
									$$=strdup(temp.typename);
									reinit_idlist();
								}
							}
							else {
								yyerror();
								printf("\t struct type(name) undeclared \n");
								reinit_idlist();
							}
						 }
		| ID id_list MK_SEMICOLON /* This is very similar to the last case of the above struct_type rule.
		 			     The only difference is that there STRUCT ID is replaced by ID when
					     a TYPEDEF is used	*//* That means here also we need to check if then
					     ID lies in the type table (not to be pushed here) *//* 4 represents typedef_type */ {

					     	A_usr_def_type_var temp;
						/*
					     	temp.which_usrtype = typedef_type;
					     	temp.typename = strdup($2);
						*/
						/*see if the typedef type exists or not*/
						/*
						if(is_typedef_type_exists(temp)) {
							if(!is_initidlist_empty()) {
								declare_usr_def_variables($1);
								$$=4;
								reinit_idlist();
							}
						}
						else {
							yyerror();
							printf("\t typedef type(name) undeclared \n");
							reinit_idlist();
						}
						*/
					     }
		;

/* Suppported types. */
type		: INT {$$=strdup($1);}
		| FLOAT {$$=strdup($1);}
		| VOID {$$=strdup($1);}
        	| error {char* temp = "error"; $$=strdup(temp);}
		;

struct_type	: STRUCT tag { $$=$2; }
		;

/* Struct variable body. */ /* As long as you have braces, then it means type declaration. */
/* Variable declaration is inherent in all the cases as it depends on the id_list */
/* The last one means the use of the structure as a type. */
tag		: ID MK_LBRACE decl_list MK_RBRACE /* type_decl */ {
									$$.which_usrtype = struct_type_explicit;
									$$.typename = strdup($1);
									/* Here we actually want to push the typename as id and for now there is no symbol table attribute
									associated with it */
									insert_id($$.which_usrtype, $$.typename, NULL);
								   }
		| MK_LBRACE decl_list MK_RBRACE {
							$$.which_usrtype = struct_type_implicit;
							$$.typename = NULL;
							/* Here we actually want to push the typename as id and for now there is no symbol table attribute
							associated with it */
							insert_id($$.which_usrtype, $$.typename, NULL);
						}
		| ID MK_LBRACE MK_RBRACE /* type_decl */ {
								$$.which_usrtype = struct_type_explicit;
								$$.typename = strdup($1);
								/* Here we actually want to push the typename as id and for now there is no symbol table attribute
								associated with it */
								if(is_struct_type_exists($$)) {
									yyerror();
									printf("\t struct type(name) redeclared \n");
								}
								else {
									insert_id($$.which_usrtype, $$.typename, NULL);
								}
							}
		| MK_LBRACE MK_RBRACE {
						$$.which_usrtype = struct_type_implicit;
						$$.typename = NULL;
						/* Here we actually want to push the typename as id and for now there is no symbol table attribute
						associated with it */
						insert_id($$.which_usrtype, $$.typename, NULL);
				      }
		;

id_list		: ID 	{
				if(find_id($1) == false && find_in_idlist($1) == false)
					$$ = append_idlist($1);
				else
				{
					yyerror();
					printf("\t ID(name) redeclared \n");
					$$ = append_idlist(NULL);
				}
			}
		| id_list MK_COMMA ID   {
						if(find_id($3) == false && find_in_idlist($3) == false)
							$$ = append_idlist($3);
						else
						{
							yyerror();
							printf("\t ID(name) redeclared \n");
							$$ = append_idlist(NULL);
						}
					}
		| id_list MK_COMMA ID dim_decl  {
							if(find_id($3) == false && find_in_idlist($3) == false)
								$$ = append_idlist($3);
							else
							{
								yyerror();
								printf("\t ID(name) redeclared \n");
								$$ = append_idlist(NULL);
							}
						}
		| ID dim_decl  {
					if(find_id($1) == false && find_in_idlist($1) == false)
						$$ = append_idlist($1);
					else
					{
						yyerror();
						printf("\t ID(name) redeclared \n");
						$$ = append_idlist(NULL);
					}
				}
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
init_id_list	: init_id {
				if(find_id($1) == false && find_in_idlist($1) == false)
					$$ = append_idlist($1);
				else
				{
					yyerror();
					printf("\t ID(name) redeclared \n");
					$$ = append_idlist(NULL);
				}
			  }
		| init_id_list MK_COMMA init_id {$$ = append_idlist($3);}
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

assign_expr     : ID OP_ASSIGN relop_expr /*TODO: here we have to check whether
					    ID has already been declared or not.*/
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

/*TODO: For every error encountered, you have to print the line for the error */
var_ref		: ID 	{ if(find_id($1) == false) {
				yyerror();
				printf("\t ID(name) undeclared \n");
				}
			}
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
			extern int yylineno;
			printf("%s%d, %s\"%s\"\n", "Error found in Line: ", yylineno, "next token: ", yytext );
		}
