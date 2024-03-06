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
	$(BISON) -d $(SYNTATIC) -Wcounterexamples
	$(CC) -c *.c -I.
	$(CC) *.o -o $(PROGRAM) -lm 

clean:
	rm -f lex.yy.c
	rm -f *.tab.*
	rm -f *.o
	rm -f $(PROGRAM)