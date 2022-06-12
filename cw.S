    .arch armv6             // armv6 architecture
    .arm                    // arm 32-bit instruction set
    .fpu vfp                // floating point co-processor
    .syntax unified         // modern sytax

    //  include files
    #include    "cw.h"

    // name imports
    .extern     setup
    .extern     rd
    .extern     result
    
    // name exports
    .global     buffer
    .global     cntchar
    .global     cntword
    .global     cntline

    .data       // segment
    // allocate space for (1) buffer, (2) cntchar (3) cntword
    // (4) cntline; make sure to watch alignments!
    cntchar:    .word 0
                .align 2
    cntword:    .word 0
                .align 2
    cntline:    .word 0
    buffer:     .space BUFSZ

    .text       // segment

    //////////////////////////////////////////////////////
    // int main(int argc, char **argv)                  //
    // program usage: cw [file]                         //
    //                                                  //
    // you can use any scratch register r0-r3           //
    // you can use these preserved registers            //
    // r4 -> cntline                                    //
    // r5 -> cntword                                    //
    // r6 -> cntchar                                    //
    // r7 -> delim flag                                 //
    //////////////////////////////////////////////////////

    .global main                // global for linking to
    .type   main, %function     // define as a function
    .equ    EXIT_SUCCESS, 0
    .equ    EXIT_FAILURE, 1
    .equ    FP_OFF, 20          // fp offset in stack frame

main:
    // function prologue
    // do not edit
    push    {r4-r7,fp, lr}      // save fp and lr on stack
    add     fp, sp, FP_OFF      // set frame pointer to frame base

    bl      setup               // call setup(argc, argv)
    cmp     r0, 0               // returns 0 if ok, -1 otherwise
    beq     .Lok
    mov     r0, EXIT_FAILURE
    b       .Lexit

.Lok:
    // initialize cntchar, cntword, cntline to 0, and delim to 1
    mov     r4, 0               // cntline = 0
    mov     r5, 0               // cntword = 0
    mov     r6, 0               // cntchar = 0
    mov     r7, 1               // delim = 1

.Louterloop:
    // call rd()
    bl      rd                  // read another buffer
    cmp     r0, 0               // if r0 <= 0 then EOF
    ble     .Ldone

    // Scratch registers:
    // r0 -> bufsz or current char
    // r1 -> bufptr
    // r2 -> endptr

    // setup bufptr and endptr for inner loop
    ldr     r1, =buffer         // load buffer into r1
    add     r2, r1, r0          // calculate endptr for r2

.Lwhile:
    cmp     r1, r2              // if bufptr reached endptr, end while loop
    bge     .Lendwh             // ...

    ldrb    r0, [r1]            // load current char to r0

    // begin switch statement
    cmp     r0, '\n'            // if curr char is newline, go to newline block
    beq     .Lnewline           // ...

    cmp     r0, ' '             // if curr char is space, go to space block 
    beq     .Lspace             // ...

    cmp     r0, '\t'            // if curr char is tab, go to tab block
    beq     .Ltab               // ...

    // default
    add     r6, r6, 1           // we have reg char, update cntchar
    mov     r7, 0               // update delim flag
    b       .Lendsw             // end switch 

.Lnewline:
    // we have a newline
    add     r4, r4, 1           // update cntline

    // fall through
.Lspace:
.Ltab:
    // we have a space or tab, or fell through from newline
    cmp     r7, 0               // if we had a delim, don't update cntword
    bne     .Lendsw             // ...

    mov     r7, 1               // update delim flag
    add     r5, r5, 1           // update cntword

.Lendsw:
    add     r1, r1, 1           // progress bufptr
    b       .Lwhile             // loop back for .Lwhile

.Lendwh:
    b       .Louterloop         // loop back for .Louterloop

.Ldone:
    // call result()
    ldr     r0, =cntline        // store line count in cntline
    str     r4, [r0]            // ...

    ldr     r0, =cntword        // store word count in cntword
    str     r5, [r0]            // ...

    ldr     r0, =cntchar        // store char count in cntchar
    str     r6, [r0]            // ...

    bl      result              // call result() to print results

    mov     r0, EXIT_SUCCESS    // fall through to .Lexit

.Lexit:
    // function epilogue
    sub     sp, fp, FP_OFF      // restore stack frame top
    pop     {r4-r7,fp,lr}       // remove frame and restore
    bx      lr                  // return to caller

    // function footer
    .size   main, (. - main)    // set size for function
.end
