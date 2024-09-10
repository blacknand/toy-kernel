/* Declare constants for the mutliboot header */
.set ALIGN,         1<<0                /* align loaded modules on page boundaries */
.set MEMINFO,       1<<1                /* provide memory map */
.set FLAGS,         ALIGN | MEMINFO     /* the Multiboot 'flag' field */
.set MAGIC,         0x1BADB002          /* 'magic number' lets bootload find the header */
.set CHECKSUM,      -(MAGIC + FLAGS)    /*  checksum of above, to prove we are multiboot */
