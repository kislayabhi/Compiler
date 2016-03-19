#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include "datatypes.h"
#define TABLE_LENGTH 100

/* Node attributes can be of 2 types */
typedef union node_attribute{
        A_var* Avar_ptr;
        A_func* Afunc_ptr;
        A_usr_def_type_var* Ausr_def_type_var_ptr;
} node_attribute;

/*For Linked List*/
typedef struct list_node{
        char *value; /*This basically stores the name of the id*/
        int freq;
        id_type_t id_type;
        node_attribute* currnode_attribute;
        struct list_node* next;
} list_node;

typedef struct symbol_table{
        list_node* table[TABLE_LENGTH];
        int size;
} symbol_table;

/* General hashtable routines */
unsigned int generate_RSHash(char* , unsigned int);
bool insert_hash(symbol_table*, id_type_t, char*, node_attribute*);
void print_hash_table(symbol_table*, bool);
void delete_hash_table(symbol_table*);
void print_attributes(id_type_t, list_node*);


/* Symbol table management routines */
void init_symtab();
void print_symtab();
void cleanup_symtab();
void insert_id(id_type_t, char *text, node_attribute*);
bool find_id(char *text);
bool find_id_with_attribute(char* text, list_node* attribute);

/* Comment table management routines */
void init_comtab();
void print_comtab();
void cleanup_comtab();
void insert_comment(char *comment);

#endif //SYMBOLTABLE_H
