# BSimple. Diary of a Madman, or How I Decided to Write a Compiler.

## Symbol Table

Along with tokenization, managing the symbol table is one of the primary tasks when building a compiler.

The symbol table is responsible for identifying keywords, global variables, functions, function arguments, and local variables.

Here and further, the description of some sections of code may be either simplified, but the main essence will be preserved.

For each symbol, we need to know its type (keyword, global identifier, stack variable, etc.), its offset (either relative to the stack, as an enumeration for keywords, or omitted for global identifiers since the compilation targets assembly), as well as a string containing the identifier’s name.

The resulting structure is very simple. If the programming language does not support structures, it can easily be emulated using a regular array.

```c
typedef struct {
    char type;
    int offset;
    char name[MAX_TOKEN_SIZE];
} Symbol;
```

The first step with the symbol table is to populate it with the language's keywords (which should not be overridden by anything else).

To simplify implementation, we will create a generic function for registering symbols, regardless of their type. The function will take the symbol's name, type, and offset in the symbol table:

```c
enum {
    Keyword,
    Glob,
    Auto,
    Parameter,
    Label,

    K_Return,
    K_While,
    K_If,
    K_Label,
    K_Goto,
    K_Var,
    K_Import,
    K_Bin,
    K_For,
    K_Repeat,
    K_Until,
    K_Include,
};

Symbol symbols[SYM_TABLE_SIZE];

/// @brief Register symbol in table
/// @param s    string with keywords
/// @param k    keyword_id/offset
/// @param t    type
void register_symbol(char *s, int k, char t)
{
    if (symbol_table_pos + 1 >= SYM_TABLE_SIZE) {
        error(SYMBOLS_TABLE_OVERLOAD);
    }

    strcpy(symbols[symbol_table_pos].name, s);
    symbols[symbol_table_pos].type = t;
    symbols[symbol_table_pos].offset = k;

    symbol_table_pos++;
}

void init_keyword_table()
{
    register_keyword("label", K_Label);
    register_keyword("goto", K_Goto);
    register_keyword("incbin", K_Bin);
    register_keyword("import", K_Import);
    register_keyword("repeat", K_Repeat);
    register_keyword("until", K_Until);
    register_keyword("while", K_While);
    register_keyword("include", K_Include);
    register_keyword("if", K_If);
    register_keyword("var", K_Var);
    register_keyword("return", K_Return);
    register_keyword("for", K_For);
}
```

For debugging, we can add a function to print the current symbol table, which will be very helpful during further development:

```c
void dump_symbols()
{
    printf("\r\nSymbols table (size %i): \r\n", symbol_table_pos);

    for (int i = symbol_table_pos - 1; i >= 0; i--) {
        switch (symbols[i].type) {
        case Keyword:
            printf("Keyword: ");
            break;
        case Glob:
            printf("Global identifier: ");
            break;
        case Parameter:
            printf("Argument (offset %i): ", symbols[i].offset);
            break;
        case Auto:
            printf("Stack variable (offset %i): ", symbols[i].offset);
            break;
        default:
            printf("Unknown symbol: ");
            break;
        }
        puts(symbols[i].name);
    }
}
```

Thus, when the compiler starts, we will already have a symbol table that looks something like this:

```
Symbols table (size 12): 
Keyword: for
Keyword: return
Keyword: var
Keyword: if
Keyword: include
Keyword: while
Keyword: until
Keyword: repeat
Keyword: import
Keyword: incbin
Keyword: goto
Keyword: label
```

For easier development, it is crucial to have the ability to retrieve a symbol by its name and to check whether a symbol is a keyword (to prevent redefinition).

Here, a small nuance arises: when searching for keywords, we traverse the list from the end rather than the beginning. This allows local scopes to override global ones (for example, a local variable can have the same name as a global variable or even a global function). The symbol lookup function will thus look like this (and checking for a keyword can be done using its result):

```c
Symbol *lookup_symbol(char *s)
{
    for (int i = symbol_table_pos - 1; i >= 0; i--)
        if (!strcmp(s, symbols[i].name))
            return &symbols[i];

    return NULL;
}
```

So, we can now read a token from a file or string, check it in the symbol table, or register it if needed. It's time to start parsing the program text.

