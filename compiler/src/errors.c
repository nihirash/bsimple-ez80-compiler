#include <stdio.h>
#include <stdlib.h>

#include "errors.h"
#include "reader.h"
#include "writer.h"
#include "token.h"

void error(char code)
{
    printf("\r\nERROR!!! ");

    switch (code) {
    case UNIMPLEMENTED:
        printf("Unimplemented! ");
        break;
    case UNEXPECTED_EOF:
        printf("Unexpected end of file! ");
        break;
    case UNEXPECTED_SYMBOL:
        printf("Unexpected symbol!");
        break;
    case OPEN_FILE_ISSUE:
        printf("Cannot open file! ");
        break;
    case CREATE_FILE_ISSUE:
        printf("Cannot create file! ");
        break;
    case SYMBOLS_TABLE_OVERLOAD:
        printf("Symbols table overload! ");
        break;
    case CANT_REDEFINE:
        printf("Can't redefine symbol! ");
        break;
    case EXPECTED_BLOCK:
        printf("Expected code block { ... } ! ");
        break;
    case EXPECTED_IDENTIFIER:
        printf("Expected identifier! ");
        break;
    case NUMBER_EXPECTED:
        printf("Expected number! ");
        break;
    case NOT_VALID_IDENTIFIER:
        printf("Not valid identifier! ");
        break;
    case BINARY_OPERATION:
        printf("Binary operation! ");
        break;
    case TOO_FAR_ON_STACK:
        printf("Trying allocate too far on stack! ");
        break;
    case BUFFER_OVERRUN:
        printf
            ("Buffer overrun! Increase ARGS_BUFFER_SIZE in compiler's config or reduce arguments list lenght!");
        break;
    case FILESTACK_OVERRUN:
        printf
            ("File stack overrun! Increase FILESTACK_DEPTH in compiler's config or reduce depth of including sources!");
        break;
    default:
        printf("Unknown error happens ");
        break;
    }

    printf("@ line %u \r\n", get_current_line());
    printf("> %s\r\n", linebuffer);

    shutdown_reader();
    close_writer();

    exit(1);
}
