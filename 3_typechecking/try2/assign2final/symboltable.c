#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "stdbool.h"
#include "symboltable.h"

void insert_id(symbol_table* my_table, char* name, sym_table_entry* current_entry)  {
	// insert the string at the generated hash.
	list_node *new_node = (list_node*)malloc(sizeof(list_node));
	new_node->name = strdup(name);
	new_node->next = NULL;
	new_node->entry = current_entry;

	unsigned int hash_value = generate_RSHash(name, strlen(name));

	/* We keep the array size of TABLE_LENGTH. */
	unsigned int table_index = hash_value % TABLE_LENGTH;

	if(!my_table->table[table_index]) {  	/* Initial case */
		my_table->table[table_index] = new_node;
		my_table->size++;
	}
	else  {
		bool collision = false;
		list_node *node;
		for(node = my_table->table[table_index]; ; node = node->next)  {
			if(node->next == NULL)
				break;
		}
	        /* Otherwise we add the new hash value at the last */
		node->next = new_node;
		my_table->size++;
	}
}

list_node* is_id_present(symbol_table *my_table, char* name, int scope, find_reason reason)  {
	int i;
	for(i = 0; i < TABLE_LENGTH; i++)  {
		if(my_table->table[i])  {
			list_node *start=my_table->table[i];
			for(; start!=NULL; start = start->next)
			if(scope == 2 || reason == redeclaration) {
				if(strcmp(start->name, name) == 0 && start->entry->scope == scope)
					return start;
			}
			else {
				if(strcmp(start->name, name) == 0 && (start->entry->scope == 1 || start->entry->scope == 0))
					return start;
			}

		}
	}
	return NULL;
}

void delete_hash_table(symbol_table *my_table, int scope)  { /* Clean hash table*/
	if(scope == 0)  {
		int i;
		for(i=0; i<TABLE_LENGTH; i++)  {
			if(my_table->table[i])  {
				list_node* temp1 = my_table->table[i];
				list_node* temp2;
				while(temp1)  {
					temp2 = temp1->next;
					free(temp1->name);
					free(temp1);
					temp1 = temp2;
				}
				my_table->table[i] = NULL;
			}
		}
		free(my_table);
	}
	else  {
		/*done: how to delete the variables pertaining to a specific scope.*/
		/*Instead of deleting them, it is better to negative the scope value.*/
		int i;
		for(i = 0; i < TABLE_LENGTH; i++)  {
			if(my_table->table[i])  {
				list_node *start=my_table->table[i];
				for(; start!=NULL; start = start->next)
					if(start->entry->scope == scope)
						start->entry->scope = -1*scope;

			}
		}
	}
}


/* qsort C-string comparison function */
int cstring_cmp(const void *a, const void *b) {
	const list_node *ia = a;
	const list_node *ib = b;
	return strcmp(ia->name, ib->name);
}


void print_hash_table(symbol_table *my_table, bool print_freq)  {
	int buffer_index=0;
	list_node buffer[my_table->size];
	int i;
	for(i = 0; i < TABLE_LENGTH; i++)  {
		if(my_table->table[i])  {
			list_node *start=my_table->table[i];
			for(; start!=NULL; start = start->next){
				printf("\n\t\t value: %s \t scope: %d \t kind: %d", start->name, start->entry->scope, start->entry->mykind);
				if(start->entry->mykind==0)
					printf("\t variable_type: %d", start->entry->symbol_info.var_info->datatype);
				}
		}
	}
}

unsigned int generate_RSHash(char* str, unsigned int len)  {
	unsigned int b    = 378551;
	unsigned int a    = 63689;
	unsigned int hash = 0;
	unsigned int i    = 0;

	for(i = 0; i < len; str++, i++)  {
		hash = hash * a + (*str);
		a = a * b;
	}
	return hash;
}
/* End Of RS Hash Function */

void init_symtab()  {	/* Initialize Symbol Table */
	id_table = (symbol_table*)malloc(sizeof(symbol_table));
	id_table->size = 0;
}


void print_symtab()  {  /* Print Symbol Table */
	printf("\n\nFrequency of identifiers");
	print_hash_table(id_table, true);
}

void cleanup_symtab(int scope)  {  /* Clean Symbol Table */
	delete_hash_table(id_table, scope);
}

list_node* find_id(char *name, int scope, find_reason reason)  {
	return is_id_present(id_table, name, scope, reason);
}
