TARGET = parser
OBJECT = parser.tab.c parser.tab.o lex.yy.c symboltable.o parser.output
CC = gcc
LEX = flex
YACC = bison -v
YACCFLAG =
LIBS = -lfl

parser: parser.tab.o symboltable.o datafunctions.o
	$(CC) -o $(TARGET) parser.tab.o symboltable.o datafunctions.o $(LIBS)

datafunctions.o:  datafunctions.c
	$(CC) -c datafunctions.c

parser.tab.o: parser.tab.c lex.yy.c
	$(CC) -c parser.tab.c

lex.yy.c: lexer3.l
	$(LEX) lexer3.l

symboltable.o:	symboltable.c
		$(CC) -c symboltable.c

parser.tab.c: parser.y
	$(YACC) $(YACCFLAG) parser.y


clean:
	rm -f $(TARGET) $(OBJECT)
