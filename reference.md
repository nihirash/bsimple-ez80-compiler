# BSimple Language Reference 

- [BSimple Language Reference](#bsimple-language-reference)
  - [Core Concepts](#core-concepts)
    - [Key Features](#key-features)
    - [Data Model](#data-model)
      - [Machine Word](#machine-word)
      - [Literals](#literals)
    - [Comments](#comments)
  - [Operations](#operations)
    - [File Inclusion and External Resources](#file-inclusion-and-external-resources)
      - [`import`](#import)
      - [`include`](#include)
      - [`incbin`](#incbin)
    - [Variables](#variables)
      - [Global Variables](#global-variables)
      - [Local Variables](#local-variables)
    - [Expressions and Operators](#expressions-and-operators)
      - [Arithmetic](#arithmetic)
      - [Bitwise Operators](#bitwise-operators)
      - [Memory Access](#memory-access)
      - [Arrays](#arrays)
      - [Comparisons](#comparisons)
    - [String Literals](#string-literals)
      - [Behavior](#behavior)
      - [Implications](#implications)
      - [Example](#example)
    - [Control Flow](#control-flow)
      - [`if` Statement](#if-statement)
      - [`while` Loop](#while-loop)
      - [`for` Loop](#for-loop)
      - [`repeat` / `until`](#repeat--until)
      - [`label` / `goto`](#label--goto)
    - [Functions](#functions)
      - [Definition](#definition)
      - [No Return](#no-return)
      - [Local Variables](#local-variables-1)
    - [Built-in Functions](#built-in-functions)
      - [Math](#math)
  - [Standard Library](#standard-library)
    - [Output](#output)
    - [String Manipulation](#string-manipulation)
  - [System Functions](#system-functions)
  - [Number Parsers](#number-parsers)
  - [File I/O](#file-io)
    - [File Operations](#file-operations)
    - [Utilities](#utilities)
  - [Entry Point: `main(argc, argv)` or `main()`](#entry-point-mainargc-argv-or-main)
    - [Command-Line Arguments](#command-line-arguments)
    - [Syntax](#syntax)
    - [Example](#example-1)
  - [Limitations](#limitations)
  - [Example Program](#example-program)

---

## Core Concepts


**BSimple** is a **mid-level**, **compiled**, **typeless** programming language with C-like syntax, designed for building **system software**, **games**, and **low-level utilities**. 

### Key Features

- **Typeless**: All variables are 24-bit signed machine words.
- **Minimal Syntax**: Compact and straightforward C/B-like syntax.
- **Compiled to Assembly**: Full control over hardware and performance.
- **Case-Sensitive Identifiers**: `Var`, `var`, and `VAR` are different.
- **String Literals as Pointers**: Strings are stored as global data, and passed as pointers.

---

### Data Model

#### Machine Word

- **Size**: 24-bit signed integer
- **Range**: -8,388,608 to 8,388,607
- **Variable Size**: 3 bytes (or N * 3 bytes for arrays)

#### Literals

- **Decimal**: `123`, `-456`
- **Hexadecimal**: `$1F4` = 500
- **Strings**: `"Hello"` will points to data segment(to NULL-terminated string)

---

### Comments

- Only **single-line comments** are supported
- Begin with `#` and continue to the end of the line

```bsimple
# This is a comment
```

---

## Operations

### File Inclusion and External Resources

#### `import`

Include external **assembly routines**:

```bsimple
import "../lib/startup.i"
```

Runtime will be included with your startup code.

#### `include`

Include **BSimple source files**:

```bsimple
include "utils.bs"
```

#### `incbin`

Include **binary files** as global data labels:

```bsimple
incbin font_data, "font.bin"
```


### Variables

#### Global Variables

Declared outside functions just in body of program.

```bsimple
var score;
var buffer[128];  # 128 * 3 = 384 bytes
```

#### Local Variables

Declared inside functions with `var`. Max: **40 entries** (stack-based).

```bsimple
function()
{
    var temp, result;

    var local_arr[10];
}
```

---

### Expressions and Operators

#### Arithmetic

- Operators: `+`, `-`, `*`, `/`, `%`
- **Left-to-right** evaluation (no precedence)

```bsimple
a = 3 + 2 * 5;  # Interpreted as ((3 + 2) * 5)
```

#### Bitwise Operators

- `|` - OR
- `&` - AND
- `~` - XOR

#### Memory Access

- `*ptr` - Dereference
- `&var` - Address of variable

```bsimple
a = *$40040;
p = &a;
```

#### Arrays

```bsimple
[ arr -> 0 ] = 10;
[ arr -> 1 ] = [ arr -> 0 ] * 2;
```

#### Comparisons

Return `-1` if true, `0` if false:

```bsimple
a = b > c;
b = a == 0;
```

---

### String Literals

#### Behavior

- Every string literal is **automatically stored in the data segment**
- Compiler generates a **global variable** for each string
- String expressions return a **pointer** to the string in memory

```bsimple
puts("Hello, world!");  # Pointer to string is passed to function
```

#### Implications

- String literals can be used **anywhere a pointer is expected**
- No need to manually define global string buffers for literals
- Internally, the compiler handles storage and pointer passing

#### Example

```bsimple
hello()
{
    printf("Sum: %d\r\n", sum(2, 3));  # Pointer to format string passed to printf
}
```

---

### Control Flow

#### `if` Statement

```bsimple
if a > 0 {
    puts("Positive");
}
```

#### `while` Loop

```bsimple
while i < 10 {
    i = i + 1;
}
```

#### `for` Loop

```bsimple
var i;

for (i = 0; i < 10; i = i + 1) {
    printf("%d", i);
}
```

#### `repeat` / `until`

```bsimple
repeat {
    i = i + 1;
} until i == 10;
```

#### `label` / `goto`

```bsimple
label retry;
goto retry;
```

---

### Functions

#### Definition

```bsimple
sum(x, y)
{
    return x + y;
}
```

#### No Return

```bsimple
hello()
{
    puts("Hi");
}
```

#### Local Variables

Maximum: **40 stack-based** variables per function

---

### Built-in Functions

#### Math

- `abs(x)` - Absolute value
- `neg(x)` - Negation
- `rand()` - Random (full range)
- `rand_range(min, max)` - In range
- `udiv(a, b)` - Unsigned division
- `swap(&a, &b)` - Swap two memory cells

---

##  Standard Library

Located in `lib/stdlib.i`

### Output

This functions are included in `lib/startup.i`

- `puts(ptr)` - Print string (fast, without formatting)
- `printf(fmt, ...)` - Formatted print
  - `%d` Decimal
  - `%x` Hex
  - `%o` Octal
  - `%b` Binary
  - `%c` Character
  - `%s` String (pointer)
  - `%%` Literal `%`

### String Manipulation

- `strlen(ptr)` - String length
- `strcmp(a, b)` - Compare (returns `-1` if equal)
- `strstarts(a, b)` - Prefix check
- `strcpy(dst, src)` - Copy string
- `strcat(dst, src)` - Append
- `strchr(str, ch)` - First occurrence
- `strstr(str, substr)` - Substring search

---

## System Functions

- `cls()` - Clear screen
- `vdp_mode(mode)` - Video mode
- `sleep(sec)` - Delay in seconds
- `sleepf(frames)` - Delay in frames
- `gotoxy(x, y)` - Move cursor
- `putc(ch)` - Print character
- `set_cursor_mode(mode)` - Show/hide cursor
- `use_graphics_cursor()` / `use_text_cursor()` - Cursor type
- `beep()` - Make some noise
- `play_note(ch, vol, freq, dur)` - Sound tone
- `readline(ptr, size)` - reads line using MOS routine. Returns key what was used for finishing(enter or ESC)


## Number Parsers

Convert string to numeric value:

```bsimple
parse_bin("1010")   
parse_oct("123")    
parse_dec("-42")    
parse_hex("FF")     
```

---

## File I/O

Located in `lib/files.i`

### File Operations

```bsimple
fp = fopen("file.txt", "w");
fputs(fp, "text");
fclose(fp);
```

### Utilities

- `fopen(path, mode)` - opens file with C like file modes("r", "w", "a", "w+" etc)
- `fclose(fp)`
- `fputs(fp, str)`
- `fputc(fp, ch)`
- `fprintf(fp, fmt, ...)`
- `fread(fp, ptr, size)`
- `fgetc(fp)`
- `flseek(fp, offset)`
- `feof(fp)`
- `frename(old, new)`
- `mkdir(name)`
- `fcopy(from, to)`
- `cwd(path)`
- `delete(name)`

---

## Entry Point: `main(argc, argv)` or `main()`

### Command-Line Arguments

BSimple supports an enhanced `main()` function that can receive command-line arguments, similar to C.

### Syntax

```bsimple
main(argc, argv)
```

- `argc`: Number of arguments (an integer)
- `argv`: Pointer to an array of string pointers (i.e., `char**` in C terms)

Each argument string is automatically stored as a global string literal and passed as a pointer.

### Example

```bsimple
import "../lib/startup.i"

main(argc, argv) {  
    if argc == 0 {
        puts("No arguments\r\n");
        exit();
    }

    printf("Arguments count: %d\r\n\r\n", argc);
    
    var i;
    i = 0;
    while i < argc {
        printf(" [ *argv -> %d ] = `%s`\r\n", i, [ *argv -> i ]);
        i = i + 1;
    }
}
```

If your program does not require arguments, you can still use a simple `main()` without parameters.

---

## Limitations

- **No operator precedence**: Evaluate expressions left-to-right
- **No dynamic allocation**
- **No user-defined structures**
- **Stack limited to 40 local variables**

---

## Example Program

```bsimple
import "../lib/startup.i"
import "../lib/stdlib.i"

sum(a, b) {
    return a + b;
}

main()
{
    puts("Welcome to BSimple!\r\n");

    printf("Sum: %d\r\n", sum(5, 7));

    var name[30];
    var key;

    puts("Enter your name: ");
    key = readline(&name, 30);

    if key == 13 {
        printf("\r\nHello, %s\r\n", &name);
    }
}
```
