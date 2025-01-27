#include <stdio.h>
#include <string.h>

#include "errors.h"

#include "token.h"
#include "symbols.h"

Symbol symbols[SYM_TABLE_SIZE];

int symbol_table_back = 0;
int symbol_table_pos = 0;
int local_vars_count = 0;

void register_symbol(char *s, char k, char t)
{
    char i;

    if (symbol_table_pos + 1 >= SYM_TABLE_SIZE) {
        error(SYMBOLS_TABLE_OVERLOAD);
    }

    strcpy(symbols[symbol_table_pos].name, s);
    symbols[symbol_table_pos].type = t;
    symbols[symbol_table_pos].offset = k;

    symbol_table_pos++;
}

void register_keyword(char *s, char k)
{
    register_symbol(s, k, Keyword);
}

void register_arg(char *s, int offset)
{
    register_symbol(s, offset, Parameter);
}

void register_label(char *s)
{
    register_symbol(s, 0, Label);
}

void register_glob(char *s)
{
    register_symbol(s, 0, Glob);
}

void register_var(char *s, int offset)
{
    register_symbol(s, offset, Auto);
}

Symbol *lookup_symbol(char *s)
{
    char i;

    for (i = symbol_table_pos - 1; i != -1; i--)
        if (!strcmp(s, symbols[i].name))
            return &symbols[i];

    return 0;
}

char is_keyword(char *s)
{
    char i;

    for (i = symbol_table_pos - 1; i != -1; i--) {
        if (!strcmp(s, symbols[i].name)) {
            return symbols[i].type == Keyword;
        }
    }

    return 0;
}

void dump_symbols()
{
    char i;
    printf("\r\nSymbols table(size %i): \r\n", symbol_table_pos);

    for (i = symbol_table_pos - 1; i != -1; i--) {
        switch (symbols[i].type) {
        case Keyword:
            printf("Keyword: ");
            break;
        case Glob:
            printf("Global identifier: ");
            break;
        case Parameter:
            printf("Argument(offset %i): ", symbols[i].offset);
            break;
        case Auto:
            printf("Stack variable(offset %i): ", symbols[i].offset);
            break;

        default:
            printf("Unknown symbols: ");
            break;
        }
        puts(symbols[i].name);
    }
}

void locals_end()
{
    char i;
    for (i = symbol_table_pos - 1; i != -1; i--) {
        if (symbols[i].type == Keyword || symbols[i].type == Glob) {
            symbol_table_pos = i + 1;
            return;
        }
    }
    // If there no Keywords or Global definitions
    symbol_table_pos = 0;
}
