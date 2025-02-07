# Learn BSimple in Y minutes

BSimple is the compiled language for eZ80 CPU(mostly for Agon computers) that can be executed on Agon Light/Console8 or your PC/Mac.

BSimple is mid-level programming language and compiles to assembly. All identifiers are case-sensitive - so `ID`, `Id` and `iD` are different identifiers.

```perl
# In BSimple language only single line comments available 
# They're starting from '#' symbol and everything to the end of line will be
# interpreted as commentary

# There're only one datetype - machine word(24 bit) and all variables are 3 bytes
# (or N*3 bytes for arrays with size of N elements, cause every element if 3 bytes
# long)

# For importing assembly routines just use keyword "import"
# All libraries and includes are just assembly listings. 

# Startup and application header should be imported in main
# file
import "../lib/startup.i"
import "../lib/stdlib.i"
import "../lib/files.i"

# Declaring global variables and arrays are possible with var keyword
var global_var1;
var global_var2;
# Arrays can be defined here too. This array will be 30 bytes or 10 elements
var global_array[10];

var buffer[173]; 

# You can define your own functions in any order

# For defining function write it's name and argument list inside paparentheses
sum(x, y) 
# After this you should write code block(It always starts with '{' and ends with '}')
{
    # If your function should return value(it can be number or pointer) - just use keyword `return`
    # and put some expression into it
    return x + y;
}

# You can have functions without arguments
# They look almost the same just argument list is empty
hello()
{
    # You can define local variables(they will be allocated on stack)
    # only one limitation - you cannot allocate more than 40 entries on stack
    # Cause index register access limitations, but for most cases it's acceptable
    var s;
    
    # For assigment to variable use standard for C-like languages syntax with just using equals sign
    # Currently there no support for order of execution in calculations and 
    # all expression will be executed from left to right
    s = sum(1, 1) + 1;
    
    # You can call library functions here
    # When you pass string literal to compiler - it creates global variable with 
    # this string and passes to function pointer on this string
    printf("Hello, world!\r\n1+2=%d\r\n", s);
    # Function can ommit explicit returning of some value - so just don't use return statement 
}

# Here example of supported expressions
expressions()
{
    var a, b, c, d, arr[3];
    # Variables aren't initialized on startup - it's better initialize it before usage
    a = 3;
    # standard math is available, will be executed in order of scription
    # so you should read it as ((a + 1) * 10 / 5) - 1
    b = a + 1 * 10 / 5 - 1;

    # You can get modulo of number with `%`

    c = b % 16;

    # Some bitwise operations are supported:
    # * `|` for bitwise or
    # * `&` for bitwise and
    # * `~` for bitwise xor
    c = b | $7ffd & $f0 ~ -1; # For writting hex numbers use `$` prefix

    # Expressions also can contain function calls
    d = sum(sum(1, 2), c);

    # you can read memory value direcly by address using `*`
    a = *$40040 & $ff;
    
    # Or from variable that points to specified address
    b = $40040;
    c = *b;

    # You can fetch pointer to any variable using special symbol `&` - so 
    # b is points to memory cell where variable a is stored
    b = &a;

    # for accessing to array items can be used special syntax
    
    # This line will store value from var `b` into first element of array `arr`
    [arr->0] = b;
    # Array elements also can be read
    [arr->1] = [arr->0] * 15;

    # Also all comparsion operators can be used in expressions
    # on true statement they will return value `-1` and `0` on false. 
    a = b > c;
    b = c <= a;
    c = a < d;
    a = c >= d;
    d = a == c;
    a = a != [arr->0];

    # Also we have some additional functions that can be used

    # Rand just returns
    a = rand();

    # Or even request random number in specified range
    b = rand_range(100, 1000);

    # You can get absolute value
    c = abs(-1000);

    # Or just change sign of number
    b = neg(c);

    # Our little secret - unsigned dividing
    a = udiv(c, 16); # c / 16

    # Sometimes you'll need swap two variables - so you can use
    # `swap(ptr1, ptr2)` and swap two memory cells.
    # Important - pass here pointers to variables or absolute address
    swap(&a, &b); 

}

# BSimple supports simple execution control routines
control() 
{
    var a, b;

    a = -1;
    b = 10;

    # Most basic way is conditional checks
    # Any non zero value allow execution on inner block
    if a < b {
        printf("Condition was passed - code was executed");

        # You can use unconditional jumps to specified label inside your function
        goto skip_here;
    }

    # Return statement can be called from any place of function
    return;

    label skip_here;

    a = 0;
    # For implementing loops you can use `while` keyword
    while a < 100 {
        printf("Line %d\r\n", a);

        a = a + 1;
    }
}

# Examples of usage standard library
stdlib() 
{
    var line[30], c;

    cls();          # Cleans screen
    vdp_mode(3);    # Switches videomode
    exec("ls -l");  # Execute any MOS command
    
    # Reads line using MOS text input handler
    # First argument - input buffer, second - max lenght in bytes
    #
    # Return value will contains what key you used for finishing procedure
    # 13 for `Return`(`Enter`), 27 for `ESC`
    c = readline(&line, 90); 

    if c == 13 {
        # `printf` allows you use formatted printing
        # Supported formatters are:
        # * %x - for hex. numbers
        # * %d - for decimal numbers
        # * %o - for oct. numbers
        # * %b - for bin. numbers
        # * %c - for characters(by value)
        # * %s - for strings(by pointer, not formatted zero-terminated)
        #
        # * %% - just for printing '%' symbol
        printf("\r\nYou are entered: %s(%d bytes long)\r\n", &line, strlen(&line));
        # Also you've seen here `strlen(ptr)` - it returns lenght of string
    }

    if c == 27 {
        # `puts` prints text faster than printf but don't supports any formatting
        puts("\r\nYou just pressed ESC\r\n");
        
        return;
    }
    # strcmp is boolean function that compares two string on equality
    # it they equal returns `-1` and zero if not
    if strcmp("oops", &line) {
        puts("\r\nWhat happens?!\r\n");
    }

    # `strstarts` is boolean function that check is line starts with specified string
    printf("%d", strstarts("This long line", "This"));

    # strcpy(dest, src) copies string from `src` to `dst`
    strcpy(&line, "Hello, my little world!");

    # strcat appends second string to first and stores in buffer of first string
    strcat(&line, "\r\n");    

    # strstr(src, substr) finds the first occurrence of `substr` in `str` and
    # returns pointer to start of first occurrance
    printf("%s", strstr(&line, "my"));
    
    cls();
    # positions cursor on screen
    gotoxy(10, 10);

    # puts single character
    putc('*');

    # Switches cursor visibility
    set_cursor_mode(0);

    # You can switch what plane you want use for putting text
    use_graphics_cursor();
    use_text_cursor();
    
    set_cursor_mode(1);
    # Makes noise
    beep();
}

# File operations
files() {
    var fp, c, bytes_read;

    # File operations looks mostly like in any C-like language
    
    # fopen syntax is the same as for C compilers
    fp = fopen("mynewfile.txt", "w");

    # it returns file handle(and zero if it had no success in opening files)
    if fp == 0 {
        puts("\r\nIssue during creating file\r\n");

        return ;
    }

    # fprintf works almost the same as printf but stores data 
    # in file instead printing on screen
    fprintf(fp, "Hello, world!%c%c", 13, 10);

    # you can write in your files per symbol
    fputc(fp, '!');
    # or output entire string into file
    fputs(fp, "WOW!\r\n");
    
    # Move current pointer in file to 100 bytes from start of file
    flseek(fp, 100);

    # If we need move more than on 16Mb - you can use flseek with extension
    flseek_ext(fp, 100, 1);
    
    fputs(fp, "100 bytes after start file");
    
    # All opened files should be closed explicitly
    fclose(fp);

    # You can rename file 
    frename("mynewfile.txt", "file.tmp");
    # Create directories
    mkdir("tmp");
    # Copy files into them
    fcopy("file.tmp", "tmp/file.tmp");
    
    # Change working directory
    cwd("tmp");

    # And delete files
    delete("file.tmp");
    
    cwd("..");

    # And empty directories
    delete("tmp");

    # for reading it works almost the same
    fp = fopen("file.tmp", "r");
    
    # fread(file_handle, buffer_pointer, maximum bytes to read) and returns 
    # how actually bytes was read
    # fwrite exists also and works similar but instead of reading 
    # it will write something to file
    bytes_read = fread(fp, &buffer, 512);

    flseek(fp, 100);

    puts(&buffer);

    while feof(fp) == 0 {
        # fgetc(file_handle) allows read file byte by byte
        c = fgetc(fp);

        putc(c);
    }   
    
    puts("\r\n");

    fclose(fp); 
    
    delete("file.tmp");
}

# Entry point for programs usually should be called as main function
# I've let keep this tradition alive
main() {
    # You can make all your own stuff here
    # or call functions
    printf("\r\n%d\r\n", sum(5, 5));
    
    expressions();

    stdlib();

    hello();
    files();
}
```

You can find this program in `examples` directory of compiler repository.