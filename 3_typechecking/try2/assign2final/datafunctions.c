#include "datatypes.h"
#include "symboltable.h"
#include <stdio.h>
#include "stdbool.h"
#include "stdlib.h"
#include "string.h"


decl_list* append_decl_list(list_node* decl_list_node) {
        if(decl_list_node->name == NULL)
                return head;

        /*First node*/
        if(head->decl_list_node == NULL) {
                head->decl_list_node = decl_list_node;
        }
        else { /*Move to the end of the list*/
                decl_list* temp = head;
                while(temp->next) {
                        temp = temp->next;
                }
                temp->next = malloc(sizeof(decl_list));
                temp->next->decl_list_node = decl_list_node;
                temp->next->next = NULL;
        }

        return head;
}


fcallvar_list* append_fcallvar_list(data_types datatype, int number_of_dim, kind expr_kind) {

        /*Gotta check about the scalar vs non-scalar things here*/
        /*First node*/
        if(fcallvar_head->datatype == error_type) {
                fcallvar_head->datatype = datatype;
                fcallvar_head->number_of_dim = number_of_dim;
                fcallvar_head->mykind = expr_kind;
        }
        else { /*Move to the end of the list*/
                fcallvar_list* temp = fcallvar_head;
                while(temp->next) {
                        temp = temp->next;
                }
                temp->next = malloc(sizeof(fcallvar_list));
                temp->next->datatype = datatype;
                temp->next->number_of_dim = number_of_dim;
                temp->next->mykind = expr_kind;
                temp->next->next = NULL;
        }
        return fcallvar_head;
}




/*Basically put everything present in the decl linked list to the symbol table*/
void insert_decl_list(kind mykind, data_types datatype) {

        decl_list* temp = head;

        while(temp) { /* TODOdone: Not able to differentiate between arrays and variables
                        TODO: Depending upon how the sym_table_entry are made for arrays and variables, these has to be changed accordingly.*/
                if(mykind != default_type)      {
                        if(mykind == struct_variable)
                        {
                                if(temp->decl_list_node->entry->mykind == variable)
                                        temp->decl_list_node->entry->mykind = struct_variable;
                                else if(temp->decl_list_node->entry->mykind == array)
                                        temp->decl_list_node->entry->mykind = struct_array;
                                else
                                        printf("\n+++ERROR+++\n");
                        }
                        else if(mykind == typedef_type)
                        {
                                temp->decl_list_node->entry->mykind = typedef_type;
                        }
                }
                /*TODO: before insertion we need to check if the symbol has already been driven down*/
                if(find_id(temp->decl_list_node->name, temp->decl_list_node->entry->scope, redeclaration) == NULL) {
                        if(temp->decl_list_node->entry->symbol_info.var_info == NULL)
                                temp->decl_list_node->entry->symbol_info.var_info = malloc(sizeof(variable_info));
                        temp->decl_list_node->entry->symbol_info.var_info->datatype=datatype;
                        insert_id(id_table, temp->decl_list_node->name, temp->decl_list_node->entry);
                        temp = temp->next;
                }
                else {
                        /*generate error*/
                        yyerror(" ");
                        printf(" idname (%s) redeclared", temp->decl_list_node->name);
                        break;
                }
        }
}

/*reinitializes the idlist */
void reinit_decl_list() {
        head = malloc(sizeof(decl_list));
        head->decl_list_node = NULL;
        head->next = NULL;
}

/*reinitializes the fcallvar_list */
void reinit_fcallvar_list() {
        fcallvar_head = malloc(sizeof(fcallvar_list));
        fcallvar_head->datatype = error_type;
        fcallvar_head->next = NULL;
}


bool check_func_call_param(decl_list* list) {//       fcallvar_list* funcdecl_version_list) {
        decl_list* decl_version=list;
        fcallvar_list* locl_version=fcallvar_head;

        //This should never arise.
        //if(decl_version==NULL) { /*This means that there is no parameters at the time of declaration*/
        //        if(locl_version->datatype!=error_type)
        //}
        while(decl_version)     {
                printf("\n\tlhs:%d rhs:%d",decl_version->decl_list_node->entry->symbol_info.var_info->datatype, locl_version->datatype);
                if(decl_version->decl_list_node->entry->symbol_info.var_info->datatype != locl_version->datatype)
                        return false;
                if(decl_version->decl_list_node->entry->symbol_info.var_info->number_of_dim>0 && locl_version->number_of_dim>0)
                {
                        yyerror(" ");
                        printf("\n\t scalar pass to an array");
                        return false;
                }
                if(decl_version->decl_list_node->entry->symbol_info.var_info->number_of_dim==0 && (locl_version->mykind==array && locl_version->number_of_dim==0))
                {
                        yyerror(" ");
                        printf("\n\t array pass to a scalar");
                        return false;
                }
                decl_version=decl_version->next;
                locl_version=locl_version->next;
        }
        return true;
}


void push_function_id(char* function_name, int current_scope, int number_of_parameters, data_types datatype) {
        sym_table_entry* entry = malloc(sizeof(sym_table_entry));
        entry->id = strdup(function_name);
        entry->mykind = function;
        entry->scope = current_scope;
        entry->symbol_info.func_info = malloc(sizeof(function_info));
        entry->symbol_info.func_info->datatype = datatype;
        entry->symbol_info.func_info->number_of_parameters = number_of_parameters;
        entry->symbol_info.func_info->function_info_head = head;
        reinit_decl_list();
        if(find_id(entry->id, current_scope, redeclaration) == NULL)
                insert_id(id_table, entry->id, entry);
        else {
                yyerror(" ");
                printf(" function name (%s) already used", function_name);
                free(entry);
        }
}


void check_return(char* function_name, bool return_found, int function_return_type_decl, int function_return_type_found){
        if(function_return_type_decl==void_data_type && return_found==false)
                {/*printf("\tOne of the perfect ways of declaring the void function without any return.");*/}
        else if(return_found==true){
                if(function_return_type_decl==function_return_type_found)
                {

                }
                else
                {
                        yyerror(" ");
                        printf(" Incompatible return type of Fn(%s)", function_name);

                }
        }
        else
        {
                yyerror(" ");
                printf(" no return found in this function (%s)", function_name);
        }
}
