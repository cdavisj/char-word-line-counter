    .arch armv6             // armv6 architecture
    .arm                    // arm 32-bit instruction set
    .fpu vfp                // floating point co-processor
    .syntax unified         // modern sytax

    // include files
    #include "cw.h"

    // name imports
    .extern     cntchar
    .extern     cntword
    .extern     cntline
    .extern     printf

    .section .rodata
.Lmsg:
    .string "lines:%8.8d words:%8.8d Chars:%8.8d\n"

    .text
    //////////////////////////////////////////////////////
    // void result(void)                                     //
    //////////////////////////////////////////////////////

    .global result              // global for linking to
    .type   result, %function   // define as a function
    .equ    FP_OFF, 4           // fp offset in main stack frame

result:
    // function prologue
    push    {fp, lr}            // save fp and lr on stack
    add     fp, sp, FP_OFF      // set frame pointer to frame base

    ldr r0, =.Lmsg              // load address of .Lmsg to r0      (arg1)
    ldr r1, =cntline            // load line count to r1            (arg2)
    ldr r1, [r1]                // ...
    ldr r2, =cntword            // load word count to r2            (arg3)
    ldr r2, [r2]                // ...
    ldr r3, =cntchar            // load char count to r3            (arg4)
    ldr r3, [r3]

    bl      printf              // call printf
    
    // function epilogue
    sub     sp, fp, FP_OFF      // restore stack frame top
    pop     {fp, lr}            // remove frame and restore
    bx      lr                  // return to caller

    // function footer
    .size   result, (. - result)// set size for function
.end
