#include "datatypes.h"
#include "symboltable.h"
#include <stdio.h>
#include "stdbool.h"
#include "stdlib.h"
#include "string.h"

/*Function to put the id with its attributes in the symbol table*/

void init_idlist() {
        head=(idlist*)malloc(sizeof(idlist));
        head->idname = NULL;
        head->next = NULL;
}

bool is_initidlist_empty() {
        if(head->idname)
                return false;
        else
                return true;
}

bool is_struct_type_exists(A_usr_def_type_var usrdef_type) {
        if(usrdef_type.which_usrtype == struct_type_implicit)
                return true;
        if(usrdef_type.which_usrtype == struct_type_explicit) {
                /*Find this thing in the symbol table*/
                /*If found, return true*/
                list_node *attribute;
                if(find_id_with_attribute(usrdef_type.typename, attribute) == true) {
                        return true; /*TODO: The case of handling a typedef is still not seen*/
                }
        }
        return false;
}

bool find_in_idlist(char* id) {

        if(head->idname == NULL) { /*First node*/
                return false;
        }
        idlist* temp = head;

        while(temp) {

                if(strcmp(temp->idname, id) == 0)
                        return true;

                temp=temp->next;
        }
        return false;
}

idlist* append_idlist(char* node) {
        if(node==NULL)
                return head;

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

/* Put the provided idlist in the user defined symbol table */
void declare_usr_def_variables(A_usr_def_type_var usr_type) {
        idlist* temp = head;
        node_attribute* tempnode_attr = malloc(sizeof(node_attribute));
        tempnode_attr->Ausr_def_type_var_ptr = malloc(sizeof(A_usr_def_type_var));
        tempnode_attr->Ausr_def_type_var_ptr->which_usrtype = usr_type.which_usrtype;
        tempnode_attr->Ausr_def_type_var_ptr->typename = strdup(usr_type.typename);
        while(temp) {
                insert_id(variable, temp->idname, tempnode_attr);
                temp=temp->next;
        }
}
