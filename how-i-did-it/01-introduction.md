# BSimple. Diary of a Madman, or How I Decided to Write a Compiler.

## Introduction
Every programmer should write their own programming language at some point. Once, as a joke, I posted on Twitter that if my tweet got 666 likes, I would create my own Lisp-like programming language in Scala. I wrote it as a joke and didn’t think about the consequences—until my phone started blowing up with notifications, and I realized I was in trouble.

The Lisp-like language was written, it worked, and, surprisingly, it didn’t even work too badly—at least as far as such Lisp implementations go. But writing an interpreter in a monstrous language like Scala is one thing. Creating a "REAL" compiler and a full-fledged programming language is another.

My fascination with retro computers (and pseudo-retro computers) made me think that a compiler should at the very least be able to compile for them, and at best, run on them.

It's a fun challenge, but when you look at it as a whole, it seems overwhelming. So if you, too, have an unresolved itch to create your own programming language, I'll show you the path I took. But don’t consider this a textbook on writing compilers.

### BSimple Compiler

The BSimple compiler is not what you would call a good compiler—neither in terms of architecture nor efficiency. Plus, it comes with some built-in limitations: it doesn’t construct an abstract syntax tree but instead directly generates an assembly listing. Compiling into raw machine code wouldn’t have been much harder in practice, but this approach allowed me to cut some corners related to project linking.

### What Is the BSimple Programming Language?

BSimple is a simple compiled programming language that is syntactically similar to B and C. It has only one data type: a machine word. Variables can be defined globally or on the stack. The function calling convention is cdecl (with parameters passed on the stack).

Operations are described using a stack and two registers (an accumulator and an auxiliary register; in the case of the Z80 processor, HL and DE).

### What Does a BSimple Program Look Like?

```
import "../lib/startup.i"
import "../lib/stdlib.i"

main() {
    var s;
    # S will contain pointer to string literal
    s = "Example string";

    printf("Hello, world!\r\n");

    # Parse number with specified base
    printf("\r\nNum parsers: %b\r\n", parse_num("11100111", 2));

    printf("%s\r\n", s);
}
```

For anyone familiar with C-like languages, this program looks quite readable. The only thing that requires some explanation is the import directive—it simply includes assembly code in the listing. This is how startup code and runtime are connected.

At the early stages, even assembling a multi-file project can be handled through the assembler and this kind of import of precompiled files, which allows me to avoid thinking about a linker for a while.