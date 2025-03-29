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
    init_symtable();
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

int main(int argc, char **argv)
{
    char filename[MAX_TOKEN_SIZE];
    char *pos;
    char *base, *tmp;

    printf
        ("B Simple compiler v%s\n(c) 2025 Aleksandr Sharikhin\n\n",
         VERSION);


    if (argc < 2) {
        printf("\n Usage:\n %s <input-file>\n", argv[0]);

        return 0;
    }

    pos = strstr(argv[1], ".bs");

    if (pos != 0) {
        *pos = 0;
    }

    base = argv[1];

    sprintf(filename, "%s.bs", argv[1]);

    while (strstr(base, "/") || strstr(base, "\\")) {
        tmp = strstr(base, "/");

        if (tmp) {
            base = tmp + 1;
        } else {
            tmp = strstr(base, "\\");
            if (tmp)
                base = tmp + 1;
        }
    }

    sprintf(l_prefix, "%s", base);

    init_keyword_table();
    init_reader(filename);
    init_writer(argv[1]);

    process_program();

    shutdown_reader();
    close_writer();

    return 0;
}
