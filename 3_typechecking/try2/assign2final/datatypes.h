#ifndef DATATYPES_H
#define DATATYPES_H

#include "stdbool.h"

typedef enum {
        variable,
        struct_variable,
        array,
        struct_array,
        function,
        typedef_type,
        struct_type,
        default_type
} kind;


/***********hash linked list*****************/
typedef struct sym_table_entry{
        char* id;
        int scope;
        kind mykind;
} sym_table_entry;

/*For Linked List*/
typedef struct list_node{
        char* name;
        sym_table_entry* entry;
        struct list_node* next;
} list_node;


/***********flat decl linked list*****************/
typedef struct decl_list {
        list_node *decl_list_node;
        struct decl_list *next;
}  decl_list;

/* head of the init linked list is declared here globally */
decl_list* head;


/*****for redeclaration or undeclaration search in the hash table*****/
typedef enum {
        redeclaration,
        undeclaration
} find_reason;

void reinit_decl_list();
void insert_decl_list(kind mykind);
decl_list* append_decl_list(list_node* decl_list_node);

#endif //DATATYPES_H
