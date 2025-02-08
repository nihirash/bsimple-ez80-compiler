# B Simple compiler

**B Simple**(reads like "Be Simple") is B-inspired programming language(it isn't C or B, or dialect of one of them, it's B-like language and compiler). It's general purpose typeless(everything is machine words) compiled language.

Language tries be not verbose and minimalistic but it should work fine for system software and many kinds of games. 

Main target was make simple language with simple compiler that will produce code for eZ80(I think it can be retargeted to another CPUs without any issues). 

Current code generator outputs assembly listing that can be built with [agon-ez80-assembler](https://github.com/envenomator/agon-ez80asm) which available both for PC(windows, linux and mac) and native Agon. 

## Documentation

Currently, project have no proper documentation but we have [Learn B Simple in Y minutes](Learn-bs-in-y-minutes.md) page that tries cover almost all language.

## Usage

### For Agon computer
 * Grab latest version from [RELEASES](https://github.com/nihirash/b-simple-ez80-compiler/releases) page
 * Extract archive to root of SD card
 * Libraries will be in `/BSimple/lib` directory, examples in `/BSimple/examples`
 * For building single source file call `bsc <filename>` it will produce file with same name but `.s` extension
 * Build your programm using [ez80asm](https://github.com/envenomator/agon-ez80asm) 

You can also create some kind of `build.txt` files that will automate compilation and assembly steps.

### For Linux/macOS
 * Clone repository
 * Build entire project using root Makefile

It should install binary in your `~/bin`(or correct `compiler/Makefile` file with your output path)

## Development

Compiler can be built with almost any standard C compiler(for native Agon version I'm using [agondev](https://github.com/envenomator/agondev)). 

## Known issues

 * No priority in calculations
 * Parenthesis not supported in expressions
 * Need make optimiser(peephole?!) 
 * Stack allocated vars limited for 40 words(120 bytes) per function call(cause index register usage)

## License 

Project licensed with GNU GPLv3.