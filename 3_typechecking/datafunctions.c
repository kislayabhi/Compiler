#include "datatypes.h"
#include "symboltable.h"
#include <stdio.h>
#include "stdbool.h"
#include "stdlib.h"
#include "string.h"

/*Function to put the id with its attributes in the symbol table*/
idlist* head;

void init_idlist() {
        head=(idlist*)malloc(sizeof(idlist));
        head->idname = NULL;
        head->next = NULL;
}

idlist* append_idlist(char* node) {
        if(head->idname == NULL) { /*First node*/
                head->idname = strdup(node);
        }
        else {  /*Move to the end of the list*/
                idlist* temp = head;
                while(temp->next) {
                        temp=temp->next;
                }
                temp->next = (idlist*)malloc(sizeof(idlist));
                temp->next->idname = strdup(node);
                temp->next->next = NULL;
        }
        return head;
}

/*reinitializes the idlist TODO: Memory leak happening right now*/
void reinit_idlist() {
        head=(idlist*)malloc(sizeof(idlist));
        head->idname = NULL;
        head->next = NULL;
}

/*completely deletes the idlist TODO: Just for checking purpose for now*/
void cleanup_idlist() {
        reinit_idlist();
}

/*Basically put everything present in the linked list to the symbol table*/
void declare_variables(int type) {
        idlist* temp = head;
        /* TODO: Attribute object construction and feeding it and pushing
        it alongside the id name. */
        node_attribute* tempnode_attr = malloc(sizeof(node_attribute));
        tempnode_attr->Avar_ptr = malloc(sizeof(A_var));
        tempnode_attr->Avar_ptr->var_type = type;

        /* At the time of declaration, if not initialized otherwise, the
        variables are default initialized to zero. */
        if(type == int_type)
                tempnode_attr->Avar_ptr->var_value.int_value=0;
        else if(type == float_type)
                tempnode_attr->Avar_ptr->var_value.float_value=0.0;

        while(temp) {
                insert_id(variable, temp->idname, tempnode_attr);
                temp=temp->next;
        }
}
