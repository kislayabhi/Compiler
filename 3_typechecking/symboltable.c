#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "stdbool.h"
#include "symboltable.h"

bool insert_hash(symbol_table *my_table, id_type_t idtype, char *text, node_attribute* ptr_atrb)  {
	// insert the string at the generated hash.
	list_node *new_node = (list_node*)malloc(sizeof(list_node));
	new_node->value = (char*)malloc(strlen(text)+1);
	new_node->freq = 1;
	new_node->next = NULL;
	new_node->currnode_attribute = ptr_atrb;
	new_node->id_type = idtype;

	unsigned int hash_value = generate_RSHash(text, strlen(text));

	/* We keep the array size of TABLE_LENGTH. */
	unsigned int table_index = hash_value % TABLE_LENGTH;

	if(!my_table->table[table_index]) {  	/* Initial case */
		my_table->table[table_index] = new_node;
		strcpy(new_node->value, text);
		my_table->size++;
	}
	else  {
		bool collision = false;
		list_node *node, *prev;
		for(node = my_table->table[table_index]; ; node = node->next)  {
			prev = node;

			if(strcmp(node->value, text) == 0)  {
				node->freq++;
				collision = true;
				free(new_node->value);
				free(new_node);
				break;
			}

			if(node->next == NULL)
				break;
		}
		if(collision == false)  {
		        /* Otherwise we add the new hash value at the last */
			strcpy(new_node->value, text);
			node->next = new_node;
			my_table->size++;
		}
	}
}

bool is_id_present(symbol_table *my_table, char* text)  {
	int i;
	for(i = 0; i < TABLE_LENGTH; i++)  {
		if(my_table->table[i])  {
			list_node *start=my_table->table[i];
			for(; start!=NULL; start = start->next)
				if(strcmp(start->value, text) == 0)
					return true;
		}
	}
	return false;
}

void delete_hash_table(symbol_table *my_table)  { /* Clean hash table*/
	int i;
	for(i=0; i<TABLE_LENGTH; i++)  {
		if(my_table->table[i])  {
			list_node* temp1 = my_table->table[i];
			list_node* temp2;
			while(temp1)  {
				temp2 = temp1->next;
				free(temp1->value);
				free(temp1);
				temp1 = temp2;
			}
			my_table->table[i] = NULL;
		}
	}
	free(my_table);
}


/* qsort C-string comparison function */
int cstring_cmp(const void *a, const void *b) {
	const list_node *ia = a;
	const list_node *ib = b;
	return strcmp(ia->value, ib->value);
}

void print_attributes(id_type_t type, list_node* node) {
	if(type==variable) {
		int type_fl_int = node->currnode_attribute->Avar_ptr->var_type;
		printf("\t\t value: %d",node->currnode_attribute->Avar_ptr->var_value.int_value);
	}
}

void print_hash_table(symbol_table *my_table, bool print_freq)  {
	int buffer_index=0;
	list_node buffer[my_table->size];
	int i;
	for(i = 0; i < TABLE_LENGTH; i++)  {
		if(my_table->table[i])  {
			list_node *start=my_table->table[i];
			if(print_freq)
				for(; start!=NULL; start = start->next)  {
					buffer[buffer_index].value = malloc(strlen(start->value) + 1);
					strcpy(buffer[buffer_index].value, start->value);
					buffer[buffer_index].id_type = start->id_type;
					buffer[buffer_index].currnode_attribute = start->currnode_attribute;
					buffer[buffer_index++].freq = start->freq;
				}
			else
				for(; start!=NULL; start = start->next) {
					printf("%s \n", start->value);
				}
		}
	}

	if(print_freq)  {
		qsort(buffer, my_table->size, sizeof(list_node), cstring_cmp);
		int i;
		for(i=0; i<my_table->size; i++) {
			printf("\n %s %d", buffer[i].value, buffer[i].freq);
			print_attributes(buffer[i].id_type, buffer+i);
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


/* Globally declare a symbol table pointer */
symbol_table *id_table;

void init_symtab()  {	/* Initialize Symbol Table */
	id_table = (symbol_table*)malloc(sizeof(symbol_table));
	id_table->size = 0;
}
void insert_id(id_type_t idtype, char *text, node_attribute* ptr_atrb_sym)  {  /* Populate Symbol Table */
	insert_hash(id_table, idtype, text, ptr_atrb_sym);
}

void print_symtab()  {  /* Print Symbol Table */
	printf("\n\nFrequency of identifiers");
	print_hash_table(id_table, true);
}

void cleanup_symtab()  {  /* Clean Symbol Table */
	delete_hash_table(id_table);
}

bool find_id(char *text)  {
	is_id_present(id_table, text);
}
