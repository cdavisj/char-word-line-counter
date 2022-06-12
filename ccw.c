#include <stdio.h>
#include <stdlib.h>
#include "cw.h"

char buffer[BUFSZ];
int  cntchar;   // count of chars IN words,not \n, \t or ' '
int  cntword;   // number of words
int  cntline;   // number of \n

int setup(int, char **);
int rd(void);
void result(void); 

/*
 * usage: ccw [file]
 */
int
main(int argc, char **argv)
{
    if (setup(argc, argv) != 0)
        return EXIT_FAILURE;

    int bufsz;                  // size of buffer after each call to rd()
    char* endptr;               // pointer to end of buffer
    char* bufptr;               // pointer to curr char in buffer
    int delim = 1;              // flag for prev char a delim

    // iterate as long as rd() returns a valid buffer (> 0)
    while ((bufsz = rd()) > 0) {
        bufptr = buffer;                // set bufptr to beginning of buffer
        endptr = buffer + bufsz;        // set endptr to end of buffer

        // iterate as long as bufptr hasn't reached endptr
        while (bufptr < endptr) {
            switch (*bufptr) {
            case '\n':
                cntline++;              // we have a newline -- update cntline

                // fall through
            case ' ':
            case '\t':
                if (!delim) {
                    delim = 1;
                    cntword++;
                }
                break;
            
            default:
                cntchar++;              // we have a normal char -- update cntchar
                delim = 0;
            }

            // progress bufptr
            bufptr++;
        }
    }
    
//#define _PA4DBG_
#ifdef _PA4DBG_
     printf("lines:%8.8d words:%8.8d Chars:%8.8d\n", cntline,cntword,cntchar);
#else
    result();
#endif
    return EXIT_SUCCESS;
}
