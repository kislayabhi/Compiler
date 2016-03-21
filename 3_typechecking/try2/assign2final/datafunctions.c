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

/*Basically put everything present in the decl linked list to the symbol table*/
void insert_decl_list(kind mykind) {

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
                        insert_id(id_table, temp->decl_list_node->name, temp->decl_list_node->entry);
                        temp = temp->next;
                }
                else {
                        /*generate error*/
                        yyerror();
                        printf("\n idname (%s) redeclared", temp->decl_list_node->name);
                        break;
                }
        }
}

/*reinitializes the idlist TODO: Memory leak happening right now*/
void reinit_decl_list() {
        head = malloc(sizeof(decl_list));
        head->decl_list_node = NULL;
        head->next = NULL;
}
