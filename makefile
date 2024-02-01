FLEX=flex
BISON=bison
CC=gcc
CFLAGS=
LIBS=
SYNTATIC= syntactic.y
PROGRAM = dcmat
LEX = lex.l


$(PROGRAM): $(LEX)
	$(FLEX) $(LEX)
	$(BISON) -d $(SYNTATIC)
	$(CC) -c *.c -I.
	$(CC) *.o -o $(PROGRAM)

clean:
	rm -f lex.yy.c
	rm -f *.tab.*
	rm -f *.o
	rm -f $(PROGRAM)