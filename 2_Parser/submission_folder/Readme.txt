----------------USING THE SYMBOL TABLE----------
I have to use the symbol table here since maintaining typedefs with a generic
production for declaring variable which works irrespective of the type is very
error prone(I think so.) The purpose of the symbol table is to fill in any
variable as a typename when declared with typedef and use it as a generic type for
the rest of the program.


----------------ERROR RECOVERY-------------------
Since the C-- is a vast language and it becomes very vague on where to implement
error recovery, I chose a few places where we can use it.

Error recovery is implemented in the following things:
1. Unidentified typename or Id in local functions.
2. Unidentified typename or Id in global functions.
3. Only member definitions are allowed in a struct.
4. Errors with assignment operator.
5. Errors in for(***) condition.
6. Errors in if(***) condition.
7. Errors in while(***) condition.

To check if my code works properly in these cases compile my code first using the
MakeFile present in the current folder.
Once the parser executable is created, Go to the Err_recovery folder.
I have made a test file named: "Test5" and have provided a Makefile for you
to run that. Go there and run "$make".


----------------MY TESTS THAT YOU CAN TRY-------------------
Go to the folder TestCases/ where I have written some files which you can test
your compiler on.

Thanks.
Abhijeet Kislay
5199935
