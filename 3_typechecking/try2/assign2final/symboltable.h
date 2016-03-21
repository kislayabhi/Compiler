#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include "datatypes.h"
#define TABLE_LENGTH 100



typedef struct symbol_table{
        list_node* table[TABLE_LENGTH];
        int size;
} symbol_table;

/* Globally declare a symbol table pointer */
symbol_table *id_table;


/* General hashtable routines */
unsigned int generate_RSHash(char* , unsigned int);
void print_hash_table(symbol_table*, bool);
void delete_hash_table(symbol_table*, int);
void print_attributes(list_node*);


/* Symbol table management routines */
void init_symtab();
void print_symtab();
void cleanup_symtab(int);
void insert_id(symbol_table* my_table, char* name, sym_table_entry* current_entry);
list_node* find_id(char *text, int scope, find_reason reason);

#endif //SYMBOLTABLE_H
