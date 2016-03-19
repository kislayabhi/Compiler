#ifndef DATATYPES_H
#define DATATYPES_H

#include "stdbool.h"

typedef enum {
        variable,
        func_name,
        struct_type_implicit,
        struct_type_explicit,
        typedef_type,
        usr_def_type_variable
} id_type_t;

typedef enum {
        int_type,
        float_type,
        void_type,
        array_type
} var_type_t;

/*
A_var and A_func are the node attributes, either one of them is attached to the
identifiers node that is present in the hash map.
*/
typedef struct {
        var_type_t var_type;
        union {
                int int_value;
                float float_value;
        } var_value;
} A_var;

typedef struct {
        char *func_name;
        int arg_num;
} A_func;

typedef struct {
        id_type_t which_usrtype;
        char* typename;
} A_usr_def_type_var;

/*Linked list of the arguments of a function*/
struct arguments_list_t {
        A_var attribute;
        struct arguments_list_t* next;
};
typedef struct arguments_list_t arguments_list;


/*Variable declaration in bulk via a list*/
/*
        I am not putting identifiers information into the symbol table directly.
        I am first making a linked list of sorts such that when variables are
        declared in bulk, first they all get accumulated in the linked list and
        then the whole linked list is pushed into the symbol table.
*/
typedef struct idlist{
        char *idname;
        struct idlist *next;
}  idlist;
idlist* head; /*head of the init linked list is declared here*/

void init_idlist();
bool find_in_idlist(char* idname);
bool is_initidlist_empty();
bool is_struct_type_exists(A_usr_def_type_var);
idlist* append_idlist(char* node);
void reinit_idlist();  /*reinitializes the idlist*/
void cleanup_idlist(); /*completely deletes the idlist*/
void declare_variables(int type);
void declare_usr_def_variables(A_usr_def_type_var);


#endif //DATATYPES_H
