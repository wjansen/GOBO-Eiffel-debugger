GOBO-Eiffel-debugger
====================

Branch "extra" contains two additions to GOBO's Eiffel compiler GEC 
(see https://github.com/gobo-eiffel/gobo.git for the original, 
this also branch "master"). 

 - Implementation of object introspection (but different from 
   class INTERNALS described in B.Meyer: "Eiffel: The Language") 
   and of persistence closure (again different from class STORABLE, 
   both differences are caused by request for more flexibility). 
   For details see file "doc/persistence/persist.pdf". 

   Object introspection is a basic need of debugging, precisely 
   of printing variable values. So after implementing 
   object introspection the idea was born to implement also
   a debugger. This is what the repository title promises.
   
 - Implementation of a graphical debugger for GEC.

   The debugger provides
    - managing breakpoints: position, conditional, watching variables
    - running the system in a stop-and-go manner 
    - saving/restoring intermediate system states 
    - moving up and down the call stack
    - displaying variables and their fields, evaluating expressions 
    - listing and searching class texts 

   The debugger manual is contained in file "doc/debugger/debug.pdf".

After downloading the package the installation follows the guidelines 
of installing GEC from scratch: switch to "$GOBO/work/bootstrap" 
and follow the instructions in file "Readme.txt". This installs 
among others the debugger. But before doing so it may be necessary 
to download some prerequisites (in particular, the graphics library)
and to make some adaptions. The installation details are given in the manual. 
