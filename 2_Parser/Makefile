TARGET = parser
OBJECT = parser.tab.c parser.tab.o lex.yy.c *.o
CC = gcc
LEX = flex
YACC = bison -v
YACCFLAG =
LIBS = -lfl

parser: parser.tab.o symboltable.o hash_table.o
	$(CC) -o $(TARGET) symboltable.o hash_table.o parser.tab.o $(LIBS)

parser.tab.o: parser.tab.c lex.yy.c
	$(CC) -c parser.tab.c

symboltable.o: symboltable.c
	$(CC) -c symboltable.c

hash_table.o: hash_table.c
	$(CC) -c hash_table.c

lex.yy.c: lexer3.l
	$(LEX) lexer3.l

parser.tab.c: parser.y
	$(YACC) $(YACCFLAG) parser.y

clean:
	rm -f $(TARGET) $(OBJECT)
