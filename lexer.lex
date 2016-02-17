%option yylineno noyywrap
%{
#include <stdio.h>
#include "symboltable.h"

int linenumber=0;
int tokens=0;
int comments=0;
int operators=0;
int separators=0;
int intliterals=0;
%}

letter [A-Za-z]
digit [0-9]
elphanum ({letter}|{digit})
ID {letter}({letter}|{digit}|"_")*
OPERATORS (>=)|(<=)|(!=)|(==)|("||")|(&&)|!|[+*/\-<>=]
COMMENTS [/][*]([^*]|(\*+([^*/]|[\r\n\t])))*[*]+[/]
SEPARATORS [{}[\]();,.]
INTLITERALS [0-9]+
STRINGLITERALS ["](.|[\r\t])*["]
LINES [\r\n]|[\r]|[\n]
RWORDS return|typedef|if|else|int|float|for|struct|union|void|while
FLOATS (([0-9]*[.]?[0-9]+)[Ee][+-]?[0-9]+)|([0-9]*[.][0-9]+)|([0-9]+[.][0-9]*)
WHITESPACE " " 
ERROR .|\n 
%x comment
%%
"/*" BEGIN(comment); yymore(); 
<comment>[^*\n]* yymore();	
<comment>"*"+[^*/\n]* yymore();
<comment>\n linenumber++; yymore();
<comment>"*"+"/" comments++; tokens++; insert_comment(yytext); BEGIN(INITIAL); 
{LINES}    {linenumber++;}
{STRINGLITERALS}    {tokens++; printf("STRINGLITERALS: \t %s \n", yytext);}
{RWORDS}    {tokens++; printf("RESERVED WORDS: \t %s \n", yytext);}
{ID}    { tokens++; insert_id(yytext); printf("ID: \t %s \n", yytext);}
{FLOATS}    { tokens++; printf("FLOATS: \t %s \n", yytext);}
{OPERATORS}    { tokens++; operators++;  printf("OPERATORS: \t %s \n", yytext);}
{SEPARATORS}    { tokens++; separators++; printf("SEPARATORS: \t %s \n", yytext);}
{INTLITERALS}    { tokens++; printf("INTLITERALS: \t %s \n", yytext);}
{WHITESPACE}
{ERROR}    { printf("\n Error near line %d : %s \n", yylineno, yytext); }
%%

int main(int argc, char **argv)
{
    argc--; ++argv;
    init_symtab();	/* Initialize Symbol/Comment tables */
    init_comtab();
    if (argc > 0)
        yyin = fopen(argv[0], "r");
    else
        yyin = stdin;
    yylex();
    printf("\nnumber of tokens %d\n",tokens);
    printf("number of lines %d\n",linenumber);
    printf("There are %d comments:\n",comments);
    print_comtab();	/* Print Comments and Symbols */
    print_symtab();
    cleanup_comtab();	/* Clean up tables */
    cleanup_symtab();
    printf("\n");
    return 0;
}
