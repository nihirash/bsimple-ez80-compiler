#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "token.h"
#include "symbols.h"
#include "writer.h"
#include "generator.h"
#include "scanner.h"
#include "reader.h"

/// @brief Prepares keywords initial state
void init_keyword_table()
{
    register_keyword("label", K_Label);
    register_keyword("goto", K_Goto);
    register_keyword("while", K_While);
    register_keyword("if", K_If);
    register_keyword("var", K_Var);
    register_keyword("return", K_Return);
}

int main(int argc, char **argv)
{
    char filename[MAX_TOKEN_SIZE];

    printf
        ("B Simple compiler v%s\r\n(c) 2025 Aleksandr Sharikhin\r\n\r\n",
         VERSION);


    if (argc < 2) {
        printf("\r\n Usage:\r\n %s <input-file>\r\n\r\nPlease don't specify extension for input file\r\n", argv[0]);

        return 0;
    }

    sprintf(filename, "%s.bs", argv[1]);
    sprintf(l_prefix, "%s", argv[1]);

    init_keyword_table();
    init_reader(filename);
    init_writer(argv[1]);

    process_program();

    close_writer();

    return 0;
}
