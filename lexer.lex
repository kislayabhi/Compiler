%option noyywrap
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
OPERATORS (>=)|(<=)|(!=)|(==)|([|][|])|(&&)|!|[+*/\-<>=]
COMMENTS [/][*]([^*]|(\*+([^*/]|[\r\n\t])))*[*]+[/]
SEPARATORS [{}[\]();,.]
INTLITERALS [0-9]+
STRINGLITERALS ["](.|[\n\r\t])*["]
LINES [\r\n|\r|\n]
%x comment
%%
"/*" BEGIN(comment); yymore(); 
<comment>[^*\n]* yymore();	
<comment>"*"+[^*/\n]* yymore();
<comment>\n linenumber++; yymore();
<comment>"*"+"/" comments++; tokens++; insert_comment(yytext); BEGIN(INITIAL); 
{LINES}    {linenumber++;}
{STRINGLITERALS}    {tokens++;}
{ID}    { tokens++; insert_id(yytext); }
{OPERATORS}    { tokens++; operators++; }
{SEPARATORS}    { tokens++; separators++; }
{INTLITERALS}    { tokens++; }
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
