# BSimple. Diary of a Madman, or How I Decided to Write a Compiler.

## First Steps

A large task can be tackled either by meticulously planning every detail and executing a series of small tasks, or by an approach akin to "painting from a blot"—starting with something high-level and gradually adding details as the project progresses.

BSimple evolved precisely by the "painting from a blot" method, with the exception of two small code segments—the symbol table and a minimal tokenizer—both of which are essential at any stage of development.

Today, we'll start with the tokenizer.

### Reading the Program

Before we can parse the program into tokens or even compile it, we need something to read.

In reality, it doesn't matter whether we're reading data from a file or receiving bytes from an array; what matters is that we have a function that returns one byte at a time. In some cases, it’s useful to "push back" a character so that the next read retrieves it again. To achieve this, we store it in a variable called poked. If it’s non-zero, we return it first before reading from our source.

A function for reading from a string might look something like this:

```c
char str_to_tokenize[] = " x=10 >= 5 <= 6 == 1+2+3>10<100*10/455+(a+b+c) && x+y || x-y ^ z;";

int position = 0;
char poked = 0;

char get_char() {
    char c;

    if (poked) {
        c = poked;
        poked = 0;

        return c;
    }
    
    if (str_to_tokenize[position] == 0) {
        return 0;
    }

    return str_to_tokenize[position++];
}
```

Now we can read the entire string using get_char(), and if needed, push a character back by simply assigning it to poked.

### The Tokenizer

From an external perspective, the tokenizer consists of three components: an enum defining token types, a get_token() function returning the token type, and a variable storing the current token as a string (for identifiers and literals).

For our compiler, whitespace characters (such as spaces, tabs, and newlines) and comments are irrelevant, so we discard them immediately:

```c
char is_space(char c) {
    return c == ' ' || c == '\t' || c == 13 || c == 10;
}

void skip_spaces() {
    char c;

    while(1) {
        c = get_char();
        if (!is_space(c)) {
            poked = c;
            return;
        } 
    }
}
```

Here, the ability to push back a character comes in handy—if we read a non-whitespace character, we push it back without affecting the rest of the code.

Fortunately, BSimple doesn’t use comments for decorators or similar constructs, so we can discard comments during tokenization.

In BSimple, comments are marked with `#`. When encountered, we can safely read until the next newline character, ignoring the content. If a comment is found, we must repeat the previous steps—skipping spaces and checking for additional comments—since multiple comments and whitespace may appear before the first useful token.

Token recognition is based on the first character:

* If the first character is a digit, we attempt to read a numeric constant.
* If the first character is a letter, we attempt to read an identifier.
* If the first character is a special symbol, we handle it accordingly.

#### Parsing Numbers

The simplest case: we read bytes as long as they are digits. When a non-digit is encountered, we terminate `current_token` with a null character and store the last read byte in poked for the next token retrieval.

#### Parsing Identifiers

Slightly more complex, but we already store the first character in `current_token`. We continue reading characters as long as they are either letters or digits.

#### Parsing Special Symbols

This case is even simpler—most special symbol tokens consist of one character (+, -, *, etc.) or two (>=, <=, ==). If a two-character token doesn't match, we push the character back using poked.

### Tokenizer Example

Ultimately, we aim for a small tokenizer capable of breaking down minimally required expressions into tokens.

A demonstration version is provided below:

```c
#include <stdio.h>
#include <stdlib.h>

#define MAX_TOKEN_SIZE  32

char str_to_tokenize[] = " x=10 >= 5 <= 6 == 1+2+3>10<100*10/455+(a+b+c)";

char current_token[MAX_TOKEN_SIZE];

int position = 0;
char poked = 0;

enum  {
    Unknown,
    Id,
    Number,
    
    EOS, // ;

    Comma, // ,

    LP, // (
    RP, // )

    Begin, // {
    End,   // }

    LS,    // [
    RS,    // ]

    Sum,
    Dec,
    Mul,
    Div,
    Mod,
    And,
    Or,
    Xor,
    Greater,
    Less,
    Eq,
    GE,
    LE,
    Assign
};

char get_char() {
    char c;

    if (poked) {
        c = poked;
        poked = 0;

        return c;
    }
    
    if (str_to_tokenize[position] == 0) {
        return 0;
    }

    return str_to_tokenize[position++];
}

char is_alpha(char c) {
    return c >= 'a' && c <='z' || c >='A' && c <='Z';
}

char is_digit(char c) {
    return c >= '0' && c <= '9';
}

char is_space(char c) {
    return c == ' ' || c == '\t' || c == 13 || c == 10;
}

char is_symbol(char c) {
    return c == '+' || c == '-' || c == '*' || c == '&' || 
           c == '|' || c == '>' || c == '<' || c == '=' || 
           c == '%' || c == '/' || c == '(' || c == ')' ||
           c == '{' || c == '}' || c == '[' || c == ']' ||
           c == ',' || c == ';' || c == ':'
           ;
}

void skip_spaces() {
    char c;

    while(1) {
        c = get_char();
        if (!is_space(c)) {
            poked = c;
            return;
        } 
    }
}

void get_id() {
    int pos = 0;
    char c;

    while(1) {
        c = get_char();
        if (is_alpha(c) || is_digit(c)) {
            current_token[pos++] = c;
        } else {
            current_token[pos] = 0;
            poked = c;
            return;
        }
    }
}

void get_num() {
    int pos = 0;
    char c;

    while(1) {
        c = get_char();
        if (is_digit(c)) {
            current_token[pos++] = c;
        } else {
            current_token[pos] = 0;
            poked = c;
            return;
        }
    }
}

char process_symbols() {
    char c, tmp;

    c = get_char();
    switch (c)
    {
    case '/': return Div;
    case '*': return Mul;
    case '+': return Sum;
    case '-': return Dec;
    case '%': return Mod;
    case '(': return LP;
    case ')': return RP;
    case ',': return Comma;
    case ';': return EOS;
    case '>': 
        poked = get_char();
        if (poked == '=') {
            poked = 0;
            return GE;
        }
        return Greater;

    case '<': 
        poked = get_char();
        if (poked == '=') {
            poked = 0;
            return LE;
        }
        return Less;
    
    case '=':
        poked = get_char();
        if (poked == '=') {
            poked = 0;
            return Eq;
        }
        return Assign;

    default:
        return Unknown;
    }
}

char get_token() {
    char c;
    
    current_token[0] = 0;
checks:
    skip_spaces();
    c = get_char();

    if (c == '#') {
        while (c != 13 && c != 10) {
            c = get_char();
        }
        goto checks;
    }

    // Starting from symbols - special cases
    if (is_symbol(c)) {
        poked = c;

        return process_symbols();
    }

    // Starting from Alpha - identity
    if (is_alpha(c)) {
        poked = c;

        get_id();
        return Id;
    } 
    
    // Starting from digit - numberic
    if (is_digit(c)) {
        poked = c;

        get_num();
        return Number;
    }

    return Unknown;
}

void debug_token(char type) {
    switch (type)
    {
    case Id:
        printf("Id");
        break;
    
    case Number:
        printf("Num");
        break;
    
    case EOS:
        printf(";");
        return;

    case Comma:     printf("Comma"); return;
    case LP:        printf("("); return; 
    case RP:        printf(")"); return; 
    case Begin:     printf(" Begin of block "); return; 
    case End:       printf(" End of block "); return;
    case LS:        printf("[ "); return;
    case RS:        printf("] "); return;
    case Sum:       printf("add "); return;
    case Dec:       printf("sub "); return;
    case Mul:       printf("mul "); return;
    case Div:       printf("div "); return;
    case Mod:       printf(" mod "); return;
    case And:       printf("Logical And "); return;
    case Or:        printf("Logical Or "); return;
    case Xor:       printf("Logical Xor "); return;
    case Greater:   printf("Greater "); return;
    case Less:      printf("Less "); return;
    case Eq:        printf("Equals "); return;
    case GE:        printf("Greater Or Equal "); return;
    case LE:        printf("Less Or Equal "); return;
    case Assign:    printf("Assign "); return;
    
    default:
        printf("Unknown type: ");
        break;
    }

    printf("(%s) ", current_token);
}

int main() {
    char t;
    t = get_token(); 
    while (t != Unknown) {
        debug_token(t);
        t = get_token();
    }

    return 0;
}
```
