/* Created by Minjun Wu, 2016.03 2nd edition */
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
program		: global_decl_list
		;

global_decl_list: global_decl_list global_decl
                |
		;

global_decl	: nonfunction_decl				/* nonfunction decl: variable, struct, typedef, ID(from typedef) */
		| function_decl
		;

/** nunfunction declaration **/
nonfunction_decl: var_decl 
		| type_decl
		;

/* variable declaration */
var_decl	: LL_type ID OP_ASSIGN init_id_dim_unit MK_SEMICOLON
		| LL_type init_id_list MK_SEMICOLON
		| STRUCT ID MK_LBRACE struct_block MK_RBRACE MK_SEMICOLON
		| HL_type init_id_list MK_SEMICOLON

		| ID ID OP_ASSIGN init_id_dim_unit MK_SEMICOLON
		| ID init_id_list MK_SEMICOLON
		;
							/* int x=1; int x,y; struct A x; struct A {...}; struct A {...}x; struct{...}x*/

LL_type		: INT | FLOAT ;

HL_type		: struct_type /*| ID*/ ;

/*  */
init_id_list	: init_id_list MK_COMMA init_id_unit
		| init_id_unit
		;

init_id_unit	: ID init_id_dim_list
		| ID
		;

init_id_dim_list: init_id_dim_list MK_LB init_id_dim_unit MK_RB
		| MK_LB init_id_dim_unit MK_RB
		;


init_id_dim_unit: init_id_dim_unit OP_OR init_expr_1 | init_expr_1 ;	/* init_id_dim_unit: Here is CONST-EXPR */
init_expr_1	: init_expr_1 OP_AND init_expr_2 | init_expr_2 ;
init_expr_2	: init_expr_2 logic_op2 init_expr_3 | init_expr_3 ;
init_expr_3	: init_expr_3 logic_op3 init_expr_4 | init_expr_4 ;
init_expr_4	: init_expr_4 add_op	init_expr_5 | init_expr_5 | OP_MINUS init_expr_5 ;
init_expr_5	: init_expr_5 mul_op	init_expr_6 | init_expr_6 ;
init_expr_6	: OP_NOT init_expr_7 | init_expr_7;
init_expr_7	: MK_LPAREN init_id_dim_unit MK_RPAREN
		| CONST
		;




/* struct type */
struct_type	: STRUCT ID 
		| STRUCT ID MK_LBRACE struct_block MK_RBRACE
		| STRUCT MK_LBRACE struct_block MK_RBRACE
		;

struct_block	: struct_block struct_block_unit MK_SEMICOLON
		| struct_block_unit MK_SEMICOLON
		/*|*/
		;

struct_block_unit: LL_type init_id_list
		| HL_type init_id_list
		| ID init_id_list
		;

/* typedef */
type_decl	: TYPEDEF LL_type init_id_list MK_SEMICOLON
		| TYPEDEF struct_type init_id_list MK_SEMICOLON		/* omit case: typedef newname1 newname2; */
		;


/********** function declaration *********/
function_decl	: LL_type ID MK_LPAREN func_param_list MK_RPAREN MK_SEMICOLON
		| LL_type ID MK_LPAREN MK_RPAREN MK_SEMICOLON
		| LL_type ID MK_LPAREN func_param_list MK_RPAREN MK_LBRACE func_stmts MK_RBRACE
		| LL_type ID MK_LPAREN MK_RPAREN MK_LBRACE func_stmts MK_RBRACE
		| LL_type ID MK_LPAREN MK_RPAREN MK_LBRACE MK_RBRACE

		| VOID ID MK_LPAREN func_param_list MK_RPAREN MK_SEMICOLON
		| VOID ID MK_LPAREN MK_RPAREN MK_SEMICOLON
		| VOID ID MK_LPAREN func_param_list MK_RPAREN MK_LBRACE func_stmts MK_RBRACE
		| VOID ID MK_LPAREN MK_RPAREN MK_LBRACE func_stmts MK_RBRACE
		| VOID ID MK_LPAREN MK_RPAREN MK_LBRACE MK_RBRACE
		;
		/* omit case: function has parameter but no stmts i.e. int fun(int x){"nothing here"} */
		/* parameter: function decl (=?) function definition, function call */
								/* assume: the parameter of func_decl has same grammer with func_def */

func_param_list	: func_param_list MK_COMMA func_param_unit
		| func_param_unit
		;

func_param_unit	: LL_type ID func_param_dim_list					/* omit case: int func(int,int); */
		| LL_type ID
		;

func_param_dim_list: func_param_dim_list_other MK_LB init_id_dim_unit MK_RB
		| MK_LB init_id_dim_unit MK_RB
		;
func_param_dim_list_other: func_param_dim_list_other MK_LB init_id_dim_unit MK_RB	/* case: int func(int x[][3]); */
		| func_param_dim_list_other MK_LB MK_RB
		| MK_LB init_id_dim_unit MK_RB
		| MK_LB MK_RB
		;

/** function definition **/
func_stmts	: func_stmts func_stmt
		| func_stmt
		; 

func_stmt	: nonfunction_decl
		| return_stmt
		| assign_stmt MK_SEMICOLON
		| func_call MK_SEMICOLON
		| contr_stmt
		| loop_stmt
		;

return_stmt 	: RETURN MK_SEMICOLON
		| RETURN expr MK_SEMICOLON
		;

assign_stmt	: var_ref OP_ASSIGN expr 				/* assignment-stmt do not support things like: "a=b=c=4;" */
		;

func_call	: ID MK_LPAREN func_call_param MK_RPAREN
		| ID MK_LPAREN MK_RPAREN
		;

func_call_param	: func_call_param MK_COMMA expr
		| expr
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
var_ref		: ID
		| var_ref id_dim_list
		| var_ref MK_DOT var_ref				/* case like: x[30].y ; x.y[2] etc. */
		;

id_dim_list	: id_dim_list MK_LB expr MK_RB
		| MK_LB expr MK_RB
		;

add_op		: OP_PLUS | OP_MINUS ;
mul_op		: OP_TIMES | OP_DIVIDE ;
logic_op2	: OP_EQ | OP_NE ;
logic_op3	: OP_LE | OP_GE | OP_LT | OP_GT ;

expr		: expr OP_OR expr_1 | expr_1 ;
expr_1		: expr_1 OP_AND expr_2 | expr_2 ;
expr_2		: expr_2 logic_op2 expr_3 | expr_3 ;
expr_3		: expr_3 logic_op3 expr_4 | expr_4 ;
expr_4		: expr_4 add_op	expr_5 | expr_5 | OP_MINUS expr_5 ;
expr_5		: expr_5 mul_op	expr_6 | expr_6 ;
expr_6		: OP_NOT expr_7 | expr_7;
expr_7		: MK_LPAREN expr MK_RPAREN
		| var_ref
		| CONST
		| func_call
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
