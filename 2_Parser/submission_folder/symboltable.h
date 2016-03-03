#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#define TABLE_LENGTH 100

/*For Linked List*/
typedef struct list_node{
    char *value;
    int freq;
    struct list_node* next;
} list_node;

typedef struct symbol_table{
    list_node* table[TABLE_LENGTH];
    int size;
} symbol_table;

/* General hashtable routines */
unsigned int generate_RSHash(char* , unsigned int);
bool insert_hash(symbol_table*, char*);
void print_hash_table(symbol_table*, bool);
void delete_hash_table(symbol_table*);


/* Symbol table management routines */
void init_symtab();
void print_symtab();
void cleanup_symtab();
void insert_id(char *text);
bool find_id(char *text);

/* Comment table management routines */
void init_comtab();
void print_comtab();
void cleanup_comtab();
void insert_comment(char *comment);

#endif //SYMBOLTABLE_H
