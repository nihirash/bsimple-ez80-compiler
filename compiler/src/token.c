#include <stdio.h>
#include <stdlib.h>

#include "token.h"
#include "reader.h"
#include "errors.h"

char current_token[MAX_TOKEN_SIZE];

char is_alpha(char c)
{
    return c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c == '_';
}

char is_digit(char c)
{
    return c >= '0' && c <= '9';
}

char is_space(char c)
{
    return c == ' ' || c == '\t' || c == 13 || c == 10;
}

char is_symbol(char c)
{
    return c == '+' || c == '-' || c == '*' || c == '&' ||
        c == '|' || c == '>' || c == '<' || c == '=' ||
        c == '%' || c == '/' || c == '(' || c == ')' ||
        c == '{' || c == '}' || c == '[' || c == ']' ||
        c == ',' || c == ';' || c == ':' || c == '\'' ||
        c == '"' || c == '!' || c == '~' || c == '$';
}

char is_hex(char c)
{
    return is_digit(c) || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
}

void skip_spaces()
{
    char c;

    while (1) {

        if (eof)
            return;

        c = get_chr();
        if (!is_space(c)) {
            poked = c;
            return;
        }
    }
}

char read_hex()
{
    int pos = 0, num = 0;
    char c;

    while (1) {
        c = get_chr();
        if (is_hex(c)) {
            current_token[pos++] = c;
        } else {
            current_token[pos++] = 0;
            poked = c;

            num = strtol(current_token, NULL, 16);
            sprintf(current_token, "%i", num);

            return Number;
        }
    }
}

void get_id()
{
    int pos = 0;
    char c;

    while (1) {
        c = get_chr();
        if (is_alpha(c) || is_digit(c)) {
            current_token[pos++] = c;
        } else {
            current_token[pos] = 0;
            poked = c;

            skip_spaces();
            return;
        }
    }
}

void get_num()
{
    int pos = 0;
    char c;

    while (1) {
        c = get_chr();
        if (is_digit(c)) {
            current_token[pos++] = c;
        } else {
            current_token[pos] = 0;
            poked = c;
            return;
        }
    }
}

char process_symbols()
{
    char c, tmp;

    c = get_chr();
    switch (c) {
    case '/':
        return Div;
    case '*':
        return Mul;
    case '+':
        return Sum;
    case '-':{
            poked = get_chr();
            if (poked == '>') {
                poked = 0;

                return Index;
            }

            return Dec;
        }
    case '%':
        return Mod;
    case '(':
        return LP;
    case ')':
        return RP;
    case ',':
        return Comma;
    case ';':
        return EOS;
    case '[':
        return LS;
    case ']':
        return RS;
    case '{':
        return Begin;
    case '}':
        return End;
    case '\'':{
            c = get_chr();
            poked = get_chr();
            if (poked != '\'')
                error(UNEXPECTED_SYMBOL);
            poked = 0;

            sprintf(current_token, "%u", c);

            return Number;
        }

    case '"':
        return DoubleQuote;

    case '>':
        poked = get_chr();
        if (poked == '=') {
            poked = 0;
            return GE;
        }
        return Greater;

    case '<':
        poked = get_chr();
        if (poked == '=') {
            poked = 0;
            return LE;
        }
        return Less;

    case '=':
        poked = get_chr();
        if (poked == '=') {
            poked = 0;
            return Eq;
        }
        return Assign;

    case '!':
        poked = get_chr();
        if (poked == '=') {
            poked = 0;

            return NEq;
        }
        error(UNEXPECTED_SYMBOL);
        return Unknown;
    case '&':
        return BAnd;
    case '|':
        return BOr;
    case '~':
        return BXor;
    case '$':
        return read_hex();
    default:
        return Unknown;
    }
}

char get_token()
{
    char c;

    if (eof)
        return Unknown;

    current_token[0] = 0;

  checks:
    skip_spaces();
    c = get_chr();
    if (c == '#') {
        while (c != 10 && c != 13 && !eof) {
            c = get_chr();
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
