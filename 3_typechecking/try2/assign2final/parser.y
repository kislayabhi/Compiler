/* Created by Minjun Wu, 2016.03 2nd edition */
/* ===== Definition Section ===== */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "stdbool.h"
#include "symboltable.h"
#include "datatypes.h"
static int linenumber = 1;
int current_scope = 0;
int number_of_parameters=0;
int function_return_type=-1;
bool return_found=false;
int number_of_dim=0;
kind expr_kind = default_type;
%}

%union
{
	char *stringval;
	list_node *listnodeval;
	decl_list *decllistval;
	fcallvar_list* fcallvarlistvar;
	data_types datatypesval;
	int intval;
}

%token <stringval>ID
%token INTEGER_CONST
%token FLOAT_CONST
%token STRING_CONST
%token <datatypesval>VOID
%token <datatypesval>INT
%token <datatypesval>FLOAT
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

%type<listnodeval> init_id_unit
%type<decllistval> init_id_list
%type<decllistval> func_param_list
%type<listnodeval> func_param_unit
%type<fcallvarlistvar> func_call_param
%type<datatypesval> LL_type
%type<datatypesval> HL_type
%type<datatypesval> var_ref
%type<datatypesval> func_call
%type<datatypesval> const
%type<datatypesval> expr
%type<datatypesval> expr_1
%type<datatypesval> expr_2
%type<datatypesval> expr_3
%type<datatypesval> expr_4
%type<datatypesval> expr_5
%type<datatypesval> expr_6
%type<datatypesval> expr_7
%type<intval> func_stmt
%type<intval> return_stmt
%type<intval> func_stmts
%type<datatypesval> init_id_dim_unit
%type<datatypesval> init_expr_1
%type<datatypesval> init_expr_2
%type<datatypesval> init_expr_3
%type<datatypesval> init_expr_4
%type<datatypesval> init_expr_5
%type<datatypesval> init_expr_6
%type<datatypesval> init_expr_7

%start program

%%

/* ==== Grammar Section ==== */

/* Productions */               /* Semantic actions */
program		: global_decl_list
		;

global_decl_list: global_decl_list global_decl
                |
		;

global_decl	: nonfunction_decl	/* nonfunction decl: variable, struct, typedef, ID(from typedef) */
		| function_decl
		;

/** nunfunction declaration **/
nonfunction_decl: var_decl
		| type_decl
		;

/* variable declaration */
var_decl	: LL_type ID OP_ASSIGN init_id_dim_unit MK_SEMICOLON	{
										sym_table_entry* entry = malloc(sizeof(sym_table_entry));
										entry->id = strdup($2);
										entry->mykind = variable;
										entry->scope = current_scope;
										if(find_id(entry->id, current_scope, redeclaration) == NULL)
										{
											entry->symbol_info.var_info = malloc(sizeof(variable_info));
											entry->symbol_info.var_info->datatype = $1;
											insert_id(id_table, entry->id, entry);
										}
										else {
											yyerror(" ");
											printf("\t ID (%s) redeclared", $2);
										}
									}
		| LL_type init_id_list MK_SEMICOLON	{
								/* Time to push everything to the symbol table */
								insert_decl_list(default_type, $1);
								reinit_decl_list();
							}
		| HL_type init_id_list MK_SEMICOLON	{
								/* Time to push everything to the symbol table */
								insert_decl_list(struct_variable, $1);
								reinit_decl_list();
							}
		| HL_type MK_SEMICOLON
		| ID ID OP_ASSIGN init_id_dim_unit MK_SEMICOLON	{
									/*It is important to make sure that $1 is typedef type*/
									if(find_id($1, current_scope, undeclaration) == NULL)
									{
										yyerror(" ");
										printf("\t typename (%s) undeclared", $1);
									}
									else if(find_id($1, current_scope, undeclaration)->entry->mykind != typedef_type)
									{
										yyerror(" ");
										printf("\t typename (%s) undeclared", $1);
									}
									else
									{
										/* TODO: Create the semantic record for the typedef type which has info about the original type */
										/* and use it to modify the "entry->mykind" value present below */
										sym_table_entry* entry = malloc(sizeof(sym_table_entry));
										entry->id = strdup($2);
										entry->mykind = variable;
										entry->scope = current_scope;
										if(find_id(entry->id, current_scope, redeclaration) == NULL)
										{
											if(find_id($1, current_scope, undeclaration)->entry->symbol_info.var_info->datatype != high_order_type)
								                        {
								                                entry->symbol_info.var_info = malloc(sizeof(variable_info));
								                                entry->symbol_info.var_info->datatype = find_id($1, current_scope, undeclaration)->entry->symbol_info.var_info->datatype;
								                        }
											insert_id(id_table, entry->id, entry);
										}
										else {
											yyerror(" ");
											printf("\t ID (%s) redeclared", $2);
										}
									}
								}

		| ID init_id_list MK_SEMICOLON	{
							/*It is important to make sure that $1 is typedef type*/
							if(find_id($1, current_scope, undeclaration) == NULL)
							{
								yyerror(" ");
								printf("\t typename (%s) undeclared", $1);
							}
							else if(find_id($1, current_scope, undeclaration)->entry->mykind != typedef_type)
							{
								yyerror(" ");
								printf("\t typename (%s) undeclared", $1);
							}
							else
							{
								/* Time to push everything to the symbol table */
								/*TODO: Create the semantic record for the typedef type which has info about the original type*/
								insert_decl_list(default_type, high_order_type);
								reinit_decl_list();
							}
						}
		;
		/* int x=1; int x,y; struct A x; struct A {...}; struct A {...}x; struct{...}x*/

LL_type		: INT {$$=int_data_type;}
		| FLOAT {$$=float_data_type;}
		;

HL_type		: struct_type {$$=high_order_type;} /*| ID*/
		;

init_id_list	: init_id_list MK_COMMA init_id_unit	{$$ = append_decl_list($3);}
		| init_id_unit	{$$ = append_decl_list($1);}
		;

init_id_unit	: ID {number_of_dim=0;}init_id_dim_list	{
						list_node* idunit = malloc(sizeof(list_node));
						idunit->name = strdup($1);
						idunit->entry = malloc(sizeof(sym_table_entry));
						idunit->entry->id = strdup($1);
						idunit->entry->mykind = array;
						idunit->entry->scope = current_scope;
						idunit->entry->symbol_info.var_info = malloc(sizeof(variable_info));
						idunit->entry->symbol_info.var_info->number_of_dim=number_of_dim;
						printf("\n N.O.D at normal declaration: %d", number_of_dim);

						/*TODO: append this node in the linked list*/
						$$ = idunit;
					}
		| ID 	{
				list_node* idunit = malloc(sizeof(list_node));
				idunit->name = strdup($1);
				idunit->entry = malloc(sizeof(sym_table_entry));
				idunit->entry->id = strdup($1);
				idunit->entry->mykind = variable;
				idunit->entry->scope = current_scope;
				/*TODO: append this node in the linked list*/
				$$ = idunit;
			}
		;

init_id_dim_list: init_id_dim_list MK_LB init_id_dim_unit MK_RB {number_of_dim++; if($3!=int_data_type){yyerror(" "); printf(" Array subscript is not an integer");}}
		| MK_LB init_id_dim_unit MK_RB {number_of_dim++; if($2!=int_data_type){yyerror(" "); printf(" Array subscript is not an integer");}}
		;

init_id_dim_unit: init_id_dim_unit OP_OR init_expr_1 {$$=$1;}
		| init_expr_1 {$$=$1;}/* init_id_dim_unit: Here is CONST-EXPR */
		;
init_expr_1	: init_expr_1 OP_AND init_expr_2 {$$=$3;}
		| init_expr_2 {$$=$1;}
		;
init_expr_2	: init_expr_2 logic_op2 init_expr_3 {$$=$3;}
		| init_expr_3 {$$=$1;}
		;
init_expr_3	: init_expr_3 logic_op3 init_expr_4 {$$=$3;}
		| init_expr_4 {$$=$1;}
		;
init_expr_4	: init_expr_4 add_op init_expr_5 {$$=$3;}
		| init_expr_5 {$$=$1;}
		| OP_MINUS init_expr_5 {$$=$2;}
		;
init_expr_5	: init_expr_5 mul_op init_expr_6 {$$=$3;}
		| init_expr_6 {$$=$1;}
		;
init_expr_6	: OP_NOT init_expr_7 {$$=$2;}
		| init_expr_7 {$$=$1;}
		;
init_expr_7	: MK_LPAREN init_id_dim_unit MK_RPAREN {number_of_dim++; if($2!=int_data_type){yyerror(" "); printf(" Array subscript is not an integer");}}
		| const	{$$=$1;}
		| var_ref {$$=$1;}
		| func_call {$$=$1;}
		;

/* struct type */
struct_type	: STRUCT ID	{
					/* It is important to make sure that $2 is a struct type */
					if(find_id($2, current_scope, undeclaration) == NULL)
					{
						yyerror(" ");
						printf("\t struct typename (%s) undeclared", $2);
					}
					else if(find_id($2, current_scope, undeclaration)->entry->mykind != struct_type)
					{
						yyerror(" ");
						printf("\t struct typename (%s) undeclared", $2);
					}
				}
		| STRUCT ID MK_LBRACE {current_scope+=2;} struct_block {cleanup_symtab(current_scope); current_scope-=2;} MK_RBRACE /*But here we intend to push the ID if its not there*/ {
																	sym_table_entry* entry = malloc(sizeof(sym_table_entry));
																	entry->id = strdup($2);
																	entry->mykind = struct_type;
																	entry->scope = current_scope;
																	if(find_id(entry->id, current_scope, redeclaration) == NULL)
																		insert_id(id_table, entry->id, entry);
																	else {
																		yyerror(" ");
																		printf("\t ID (%s) redeclared", $2);
																	}
																}
		| STRUCT MK_LBRACE {current_scope+=2;} struct_block {cleanup_symtab(current_scope); current_scope-=2;} MK_RBRACE
		;

struct_block	: struct_block struct_block_unit MK_SEMICOLON
		| struct_block_unit MK_SEMICOLON
		;

struct_block_unit: LL_type init_id_list {
						/* Time to push everything to the symbol table */
						insert_decl_list(default_type, $1);
						reinit_decl_list();
					}
		| HL_type init_id_list {
						/* Time to push everything to the symbol table */
						insert_decl_list(default_type, $1);
						reinit_decl_list();
					}
		| ID init_id_list 	{
						/* Time to push everything to the symbol table */
						insert_decl_list(default_type, high_order_type);
						reinit_decl_list();
					}
		;

/* typedef */
type_decl	: TYPEDEF LL_type init_id_list MK_SEMICOLON /* Here we intend to push the init_id_list as typedef type */{
			insert_decl_list(typedef_type, $2);
			reinit_decl_list();
		}
		| TYPEDEF struct_type init_id_list MK_SEMICOLON		/* omit case: typedef newname1 newname2; */ {
			insert_decl_list(typedef_type, high_order_type);
			reinit_decl_list();
		}
		;


/********** function declaration *********/
function_decl	: LL_type ID MK_LPAREN func_param_list MK_RPAREN MK_SEMICOLON	{push_function_id($2, 0, number_of_parameters, $1); number_of_parameters = 0; reinit_decl_list();}
		| LL_type ID MK_LPAREN MK_RPAREN MK_SEMICOLON {push_function_id($2, 0, number_of_parameters, $1); number_of_parameters = 0;}
		| LL_type ID MK_LPAREN func_param_list MK_RPAREN MK_LBRACE {current_scope++;} { push_function_id($2, 0, number_of_parameters, $1);
												number_of_parameters = 0; reinit_decl_list();
												function_return_type = $1;} func_stmts {
																	check_return($2, return_found, function_return_type, $9);
																	cleanup_symtab(current_scope);
																	current_scope--;
																	function_return_type = -1;
																	return_found=false;} MK_RBRACE
		| LL_type ID MK_LPAREN MK_RPAREN MK_LBRACE {current_scope++;} {	push_function_id($2, 0, number_of_parameters, $1);
										number_of_parameters = 0;
										function_return_type = $1;} func_stmts {
															check_return($2, return_found, function_return_type, $8);
															cleanup_symtab(current_scope);
															current_scope--;
															function_return_type = -1;
															return_found=false;} MK_RBRACE
		| LL_type ID MK_LPAREN MK_RPAREN MK_LBRACE MK_RBRACE {push_function_id($2, 0, number_of_parameters, $1); number_of_parameters = 0;}
		| VOID ID MK_LPAREN func_param_list MK_RPAREN MK_SEMICOLON {	push_function_id($2, 0, number_of_parameters, void_data_type);number_of_parameters = 0;reinit_decl_list();}
		| VOID ID MK_LPAREN MK_RPAREN MK_SEMICOLON {	push_function_id($2, 0, number_of_parameters, void_data_type);number_of_parameters = 0;}
		| VOID ID MK_LPAREN func_param_list MK_RPAREN MK_LBRACE {current_scope++;} {	push_function_id($2, 0, number_of_parameters, void_data_type);
												number_of_parameters = 0; reinit_decl_list();
												function_return_type = void_data_type;} func_stmts {
																			check_return($2, return_found, function_return_type, $9);
																			cleanup_symtab(current_scope);
																			current_scope--;
																			function_return_type = -1;
																			return_found=false;} MK_RBRACE
		| VOID ID MK_LPAREN MK_RPAREN MK_LBRACE {current_scope++;} {	push_function_id($2, 0, number_of_parameters, void_data_type);
										number_of_parameters = 0;
										function_return_type = void_data_type;} func_stmts {
																	check_return($2, return_found, function_return_type, $8);
																	cleanup_symtab(current_scope);
																	current_scope--;
																	function_return_type = -1;
																	return_found=false;} MK_RBRACE
		| VOID ID MK_LPAREN MK_RPAREN MK_LBRACE MK_RBRACE {	push_function_id($2, 0, number_of_parameters, void_data_type); number_of_parameters = 0;}
		;
		/* omit case: function has parameter but no stmts i.e. int fun(int x){"nothing here"} */
		/* parameter: function decl (=?) function definition, function call */
								/* assume: the parameter of func_decl has same grammar with func_def */

func_param_list	: func_param_list MK_COMMA {number_of_dim=0;} func_param_unit {number_of_parameters++; $$=append_decl_list($4);}
		| {number_of_dim=0;} func_param_unit {number_of_parameters++; $$=append_decl_list($2);}
		;

func_param_unit	: LL_type ID func_param_dim_list {
			sym_table_entry* entry = malloc(sizeof(sym_table_entry));
			entry->id = strdup($2);
			entry->mykind = array;
			entry->scope = 1; /*Irrespective of the scope inc/dec I am putting 1 here.*/
			list_node* idunit = malloc(sizeof(list_node));
			idunit->name = strdup($2);
			idunit->entry = entry;
			if(find_id(entry->id, current_scope, redeclaration) == NULL)
			{
				entry->symbol_info.var_info = malloc(sizeof(variable_info));
				entry->symbol_info.var_info->datatype = $1;
				entry->symbol_info.var_info->number_of_dim=number_of_dim;
				printf("\n N.O.D at declaration: %d", number_of_dim);
				insert_id(id_table, entry->id, entry);
			}
			else {
				yyerror(" ");
				printf("\t ID (%s) redeclared", $2);
			}
			$$ = idunit;
		}
		/* omit case: int func(int,int); */
		| LL_type ID {
			sym_table_entry* entry = malloc(sizeof(sym_table_entry));
			entry->id = strdup($2);
			entry->mykind = variable;
			entry->scope = 1;
			list_node* idunit = malloc(sizeof(list_node));
			idunit->name = strdup($2);
			idunit->entry = entry;
			if(find_id(entry->id, current_scope, redeclaration) == NULL)
			{
				entry->symbol_info.var_info = malloc(sizeof(variable_info));
				entry->symbol_info.var_info->datatype = $1;
				insert_id(id_table, entry->id, entry);
			}
			else {
				yyerror(" ");
				printf("\t ID (%s) redeclared", $2);
			}
			$$ = idunit;
		}
		;

func_param_dim_list: func_param_dim_list_other MK_LB init_id_dim_unit MK_RB {number_of_dim++; if($3!=int_data_type){yyerror(" "); printf(" Array subscript is not an integer");}}
		| MK_LB init_id_dim_unit MK_RB {number_of_dim++; if($2!=int_data_type){yyerror(" "); printf(" Array subscript is not an integer");}}
		;
func_param_dim_list_other: func_param_dim_list_other MK_LB init_id_dim_unit MK_RB {number_of_dim++; if($3!=int_data_type){yyerror(" "); printf(" Array subscript is not an integer");}}	/* case: int func(int x[][3]); */
		| func_param_dim_list_other MK_LB MK_RB {number_of_dim++;}
		| MK_LB init_id_dim_unit MK_RB {number_of_dim++; if($2!=int_data_type){yyerror(" "); printf(" Array subscript is not an integer");}}
		| MK_LB MK_RB {number_of_dim++;}
		;

/** function definition **/
func_stmts	: func_stmts func_stmt	{if(function_return_type != -1) { /*This check is so that we are only interested in statements in which we have initialized this global variable*/
						if(return_found==false)
						{
							if($2-10 == -1) {
								return_found = true;
								$$ = void_data_type;
							}
							else if($2-10 > -1) {
								return_found = true;
								$$ = $2-10;
							}
							else{
								$$ = -1;
							}
						}

					}
					}
		| func_stmt {if(function_return_type != -1) {
				if(return_found == false)
				{
					if($1 - 10 == -1) {
						return_found=true;
						$$=void_data_type;
					}
					else if($1-10 > -1) {
						return_found=true;
						$$ = $1-10;
					}
					else{
						$$ = -1;
					}
				}
			}}
		;

func_stmt	: nonfunction_decl {$$=-1;}
		| return_stmt {$$=$1;}
		| assign_stmt MK_SEMICOLON {$$=-1;}
		| func_call MK_SEMICOLON {$$=-1;}
		| contr_stmt {$$=-1;}
		| loop_stmt {$$=-1;}
		;

return_stmt 	: RETURN MK_SEMICOLON {$$=9;}
		| RETURN expr MK_SEMICOLON {$$=$2+10;}
		;

assign_stmt	: var_ref OP_ASSIGN expr /*TODO: Gotta check the lhs vs the rhs*/ {	/* assignment-stmt do not support things like: "a=b=c=4;" */
					if($1!=$3){
						yyerror(" ");
						printf(" Incompatible assignment operation. Type is not matching. ");
					}
				}
		;

func_call	: ID MK_LPAREN func_call_param MK_RPAREN /* Make sure that ID is already present. */	{
			/* We need to calculate the number_of_parameters that are being passed via the func_call_param and this
			has to be matched with the semantic value of the function name if it was declared earlier */
			if(find_id($1, current_scope, undeclaration) == NULL)
			{
				yyerror(" ");
				printf(" function (%s) is not declared", $1);
				number_of_parameters = 0;
				$$=error_type;
			}
			else if(find_id($1, current_scope, undeclaration)->entry->mykind != function)
			{
				yyerror(" ");
				printf(" function (%s) is not declared", $1);
				number_of_parameters = 0;
				$$=error_type;
			}
			else
			{
				if(find_id($1, current_scope, undeclaration)->entry->symbol_info.func_info->number_of_parameters < number_of_parameters)
				{
					yyerror(" ");
					printf(" too many arguments to function (%s)", $1);
				}
				else if(find_id($1, current_scope, undeclaration)->entry->symbol_info.func_info->number_of_parameters > number_of_parameters)
				{
					yyerror(" ");
					printf(" too few arguments to function (%s)", $1);
				}
				/*Not yet accurate. We need to match the datatypes of variables in func_call_param*/
				else if(!check_func_call_param(find_id($1, current_scope, undeclaration)->entry->symbol_info.func_info->function_info_head))
				{
					yyerror(" ");
					printf(" The function (%s) called arguments don't match the ones declared.", $1);
				}
				else
					printf("\n accurate");

				number_of_parameters = 0;
				reinit_fcallvar_list();
				$$ = find_id($1, current_scope, undeclaration)->entry->symbol_info.func_info->datatype;
			}
		}
		| ID MK_LPAREN MK_RPAREN /*Make sure that ID is already present*/	{
			if(find_id($1, current_scope, undeclaration) == NULL)
			{
				yyerror(" ");
				printf(" function (%s) is not declared", $1);
				number_of_parameters = 0;
			}
			else if(find_id($1, current_scope, undeclaration)->entry->mykind != function)
			{
				yyerror(" ");
				printf(" function (%s) is not declared", $1);
				number_of_parameters = 0;
			}
			else
			{
				if(find_id($1, current_scope, undeclaration)->entry->symbol_info.func_info->number_of_parameters != 0)
				{
					yyerror(" ");
					printf(" too few arguments to function (%s)", $1);
				}
				else
					printf(" Pika Pika");
				number_of_parameters = 0;
			}
			reinit_fcallvar_list();
		}
		;
/* number_of_dim is to be checked only when the datatype of the expression is non-scalar(array) */
func_call_param	: func_call_param MK_COMMA {number_of_dim=0;expr_kind=default_type;} expr {printf("\n\t n.o.d: %d", number_of_dim);$$=append_fcallvar_list($4, number_of_dim, expr_kind); number_of_dim=0; number_of_parameters++;expr_kind=default_type;}
		| {number_of_dim=0;expr_kind=default_type;} expr {printf("\n\t n.o.d: %d", number_of_dim);$$=append_fcallvar_list($2, number_of_dim, expr_kind); number_of_dim=0; number_of_parameters++;expr_kind=default_type;}
		;

contr_stmt	: IF MK_LPAREN if_block MK_RPAREN contr_block
		| IF MK_LPAREN if_block MK_RPAREN contr_block ELSE contr_block
		;

if_block	: expr
		| assign_stmt
		;

contr_block	: func_stmt
		| MK_LBRACE func_stmts MK_RBRACE
		;

loop_stmt	: FOR MK_LPAREN for_block MK_SEMICOLON for_block MK_SEMICOLON for_block MK_RPAREN contr_block
		| WHILE MK_LPAREN if_block MK_RPAREN MK_LBRACE func_stmts MK_RBRACE
		;

for_block	: expr
		| assign_stmt
		|
		;

/********* important settings *************/
var_ref		: ID	{
				if(find_id($1, current_scope, undeclaration) == NULL) {
					yyerror(" ");
					printf("\t ID (%s) undeclared \n", $1);
				}
				else
				{
					if(find_id($1, current_scope, undeclaration)->entry->mykind == variable || find_id($1, current_scope, undeclaration)->entry->mykind == array)
					{
						$$ = find_id($1, current_scope, undeclaration)->entry->symbol_info.var_info->datatype;
						expr_kind=find_id($1, current_scope, undeclaration)->entry->mykind;
					}
					else
					{
						$$ = high_order_type;
					}
				}
			}
		| var_ref id_dim_list
		| var_ref MK_DOT var_ref /* case like: x[30].y ; x.y[2] etc. */
		;

id_dim_list	: id_dim_list MK_LB expr MK_RB {number_of_dim++; if($3!=int_data_type){yyerror(" "); printf(" Array subscript is not an integer");}}
		| MK_LB expr MK_RB {number_of_dim++; if($2!=int_data_type){yyerror(" "); printf(" Array subscript is not an integer");}}
		;

add_op		: OP_PLUS | OP_MINUS ;
mul_op		: OP_TIMES | OP_DIVIDE ;
logic_op2	: OP_EQ | OP_NE ;
logic_op3	: OP_LE | OP_GE | OP_LT | OP_GT ;

expr		: expr OP_OR expr_1 {$$=$3;}
		| expr_1 {$$=$1;}
expr_1		: expr_1 OP_AND expr_2 {$$=$3;}
		| expr_2 {$$=$1;}
expr_2		: expr_2 logic_op2 expr_3 {$$=$3;}
		| expr_3 {$$=$1;}
expr_3		: expr_3 logic_op3 expr_4 {$$=$3;}
		| expr_4 {$$=$1;}
expr_4		: expr_4 add_op	expr_5 {$$=$3;}
		| expr_5 {$$=$1;}
		| OP_MINUS expr_5 {$$=$2;}
expr_5		: expr_5 mul_op	expr_6 {$$=$3;}
		| expr_6 {$$=$1;}
expr_6		: OP_NOT expr_7 {$$=$2;}
		| expr_7 {$$=$1;}
expr_7		: MK_LPAREN expr MK_RPAREN {$$=$2;}
		| var_ref {$$=$1;}
		| const {$$=$1; expr_kind=default_type;}
		| func_call {$$=$1; expr_kind=default_type;}
		;

const 		: INTEGER_CONST {$$=int_data_type;}
		| FLOAT_CONST {$$=float_data_type;}
		| STRING_CONST {$$=string_constant;}
		;
%%

#include "lex.yy.c"
main (argc, argv)
int argc;
char *argv[];
  {
  	init_symtab();
	reinit_decl_list();
	reinit_fcallvar_list();
     	yyin = fopen(argv[1],"r");
     	yyparse();
	print_symtab();
	cleanup_symtab(0);
     	printf("%s\n", "\nParsing completed. No errors found.");
  }


yyerror (mesg)
char *mesg;
{
	printf("\n%s\t%d\t", "Error found in Line ", linenumber);
  	printf("%s\n", mesg);
}
