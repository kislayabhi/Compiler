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
/********* Data types of variables *********/
typedef enum {
        int_data_type,
        float_data_type,
        void_data_type,
        high_order_type,
        string_constant,
        error_type
} data_types;


/* typedef type's semantic value is also the variable_info */
typedef struct variable_info {
        data_types datatype;
        int number_of_dim;
} variable_info;

struct function_info;

typedef struct sym_table_entry {
        char* id;
        int scope;
        kind mykind;
        union {
                variable_info* var_info;
                struct function_info* func_info;
        } symbol_info;
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

typedef struct function_info {
        int number_of_parameters;/* This stores the number of parameters in the function. */
        data_types datatype;/* This stores the return type of the function. */
        decl_list* function_info_head;
} function_info;

typedef struct fcallvar_list {
        data_types datatype; /* This stores the datatype of the variable. Using this for classifying scalar vs array. */
        int number_of_dim; /* If the datatype of the variable is array, then this stores the number of brackets. */
        kind mykind;
        struct fcallvar_list* next;
} fcallvar_list;
fcallvar_list* fcallvar_head;

void reinit_decl_list();
void insert_decl_list(kind mykind, data_types datatype);
decl_list* append_decl_list(list_node* decl_list_node);
void push_function_id(char* function_name, int current_scope, int number_of_parameters, data_types datatype);
void check_return(char* function_name, bool return_found, int function_return_type_decl, int function_return_type_found);
fcallvar_list* append_fcallvar_list(data_types datatype, int number_of_dim, kind expr_kind);
void reinit_fcallvar_list();

#endif //DATATYPES_H
