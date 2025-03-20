/**
 * BSimple preprocessor/builder for crossbuilding
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "../compiler/src/config.h"

FILE *f_output;
int f_stack_pos;
FILE *f_input[10];

char base_name[120];
char main_source[120];
char import_source[120];
char output_name[120];
FILE *cur_file;
char cur_c;
char first_line;

void process(char *filename);

void close_all()
{
    int i;

    if (f_output)
        fclose(f_output);

    for (i = 0; i < 10; i++) {
        if (f_input[i]) {
            fclose(f_input[i]);
        }
    }
}

void error(char *txt)
{
    close_all();

    printf("\r\nERROR! %s\r\n", txt);

    exit(1);
}

char is_new_line()
{
    char result;

    if (first_line) {
        first_line = 0;

        return 1;
    }
    result = 0;

    while (1) {
        if (cur_c == 13) {
            result = 1;
            cur_c = fgetc(cur_file);
            continue;
        }

        if (cur_c == 10) {
            result = 1;
            cur_c = fgetc(cur_file);
            continue;
        }

        return result;
    }


    return result;
}

void skip_spaces()
{
    while (cur_c == 13 || cur_c == 10 || cur_c == 32 || cur_c == 9) {
        if (feof(cur_file)) {
            return;
        }

        cur_c = fgetc(cur_file);
    }
}


void end_line()
{
    while (!feof(cur_file)) {
        cur_c = fgetc(cur_file);

        if (cur_c == 13 || cur_c == 10) {
            return;
        }
    }
}


void include_check()
{
    char *pos;
    pos = import_source;

    if (fgetc(cur_file) != 'i') {
        return end_line();
    }

    if (fgetc(cur_file) != 'n') {
        return end_line();
    }

    if (fgetc(cur_file) != 'c') {
        return end_line();
    }

    if (fgetc(cur_file) != 'l') {
        return end_line();
    }

    if (fgetc(cur_file) != 'u') {
        return end_line();
    }

    if (fgetc(cur_file) != 'd') {
        return end_line();
    }

    if (fgetc(cur_file) != 'e') {
        return end_line();
    }

    cur_c = fgetc(cur_file);

    skip_spaces();

    if (cur_c != '"') {
        printf("\r\nWARN! Looks like broken include!\r\n");

        return end_line();
    }

    cur_c = fgetc(cur_file);
    while (cur_c != '"') {
        if (feof(cur_file)) {
            error("Unexpected end of file!");
        }

        *pos = cur_c;
        pos++;
        cur_c = fgetc(cur_file);
    }
    *pos = 0;
    end_line();

    process(import_source);

}

void process(char *filename)
{
    printf("Processing file: %s\r\n", filename);

    f_stack_pos++;
    f_input[f_stack_pos] = fopen(filename, "r");
    cur_file = f_input[f_stack_pos];

    if (cur_file == 0) {
        close_all();

        error("Cannot open file!");
    }

    fprintf(f_output, "# File `%s`(depth: %d)\r\n", filename, f_stack_pos);
    first_line = 1;

    while (!feof(cur_file)) {
        cur_c = fgetc(cur_file);

        if (is_new_line()) {
            fputs("\r\n", f_output);
            skip_spaces();
            // Include check
            if (cur_c == '#') {
                include_check();

                continue;
            }
        }

        if (cur_c > 0)
            fputc(cur_c, f_output);


    }

    fclose(cur_file);
    fputs("\r\n# File ended\r\n", f_output);
    f_stack_pos--;

    cur_file = f_input[f_stack_pos];
}

void build()
{
    char buffer[150];
    sprintf(buffer, "bsc %s", output_name);

    if (system(buffer)) {
        error("Compilation failed!");
    }

    sprintf(buffer, "ez80asm %s_post.s %s.bin", base_name, base_name);

    if (system(buffer)) {
        error("Assembly failed!");
    }
}

int main(int argc, char **argv)
{
    char *tmp;

    printf
        ("BSimple %s preprocessor and builder\r\n(c) 2025 Aleksandr Sharikhin\r\n",
         VERSION);

    if (argc < 2) {
        printf("\r\nUsage:\r\n %s <filename>\r\n", argv[0]);

        exit(0);
    }
    tmp = strstr(argv[1], ".bs");

    if (tmp) {
        *tmp = 0;
    }

    strcpy(main_source, argv[1]);
    strcpy(base_name, argv[1]);
    strcpy(output_name, argv[1]);

    strcat(output_name, "_post.bs");
    strcat(main_source, ".bs");

    printf
        ("\r\nPost processed file name: %s\r\nResulting binary: %s.bin\r\n\r\n",
         output_name, base_name);

    f_output = fopen(output_name, "w");
    if (f_output == 0) {
        error("Cannot create resulting file!");
    }

    f_stack_pos = -1;
    process(main_source);
    close_all();

    build();

    return 0;
}
