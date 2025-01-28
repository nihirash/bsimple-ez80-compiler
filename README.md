# B Simple compiler

**B Simple**(reads like "Be Simple") is B-inspired programming language(it isn't C or B, or dialect of one of them, it's B-like language and compiler). It's general purpose typeless(everything is machine words) compiled language.

Language tries be not verbose and minimalistic but it should work fine for system software and many kinds of games. 

Main target was make simple language with simple compiler that will produce code for eZ80(I think it can be retargeted to another CPUs without any issues). 

Current code generator outputs assembly listing that can be built with [agon-ez80-assembler](https://github.com/envenomator/agon-ez80asm) which available both for PC(windows, linux and mac) and native Agon. 

## Development

Compiler can be built with almost any standard C compiler(for native Agon version I'm using [agondev](https://github.com/envenomator/agondev)). 

## Known issues

 * No priority in calculations

 * Code requires optimiser

## License 

Project licensed with MIT License.