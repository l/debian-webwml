/*
 * Sample code with a few buffer overflows.
 */

#include <stdio.h>
#include <stdlib.h>

int main( int argc, char *argv[] )
{
    char dir[1024];
    char cmd[1200];
    char buff[1024];
    FILE *fp = NULL;
    int i = 0;

    if ( argc == 2 )
    {
      strcpy( dir, argv[ 1 ] );
    }
    else
    {
      if ( getenv( "HOME" ) != NULL )
      {
	sprintf( dir, "%s", getenv( "HOME" ) );
      }
      else
      {
	strcpy( dir, "/" );
      }
    }

    snprintf(cmd, sizeof(cmd)-1, "%s %s", "ls", dir );
    fp = popen( cmd, "r" );
    if ( fp == NULL )
    {
      printf("Failed to invoke: %s\n", cmd );
      return -1;
    }

    while( i = fread( buff, 1, sizeof(buff), fp ) )
    {
      printf( buff );
    }
	
    pclose( fp );
    
    return 0;
}
