#include <stdio.h>

#include "writer.h"
#include "errors.h"

FILE *code_fp;
FILE *data_fp;

char source_name[80];
char filename[80];
char was_data;

void epilogue()
{
    char buf[512];
    int c;

    if (data_fp) {
        fflush(data_fp);
        fclose(data_fp);
    }

    if (code_fp && was_data) {
        printf("Storing data segment!\n");

        data_fp = fopen(filename, "r");
        while (1) {
            c = fread(buf, 1, 512, data_fp);
            if (c) {
                fwrite(buf, 1, c, code_fp);
            } else {
                break;
            }
        }
        fclose(data_fp);

        printf("Done!\n");
    }

    remove(filename);
}

void init_writer(char *basefile)
{
    was_data = 0;
    sprintf(source_name, "%s.s", basefile);

    code_fp = fopen(source_name, "w");

    sprintf(filename, "%s.sdat", basefile);
    data_fp = fopen(filename, "w");


    if (!code_fp || !data_fp)
        error(CREATE_FILE_ISSUE);
}

void close_writer()
{
    epilogue();
    fclose(code_fp);
}

void write_code(char *s)
{
    for (int i = 0; s[i] != 0; i++)
        fputc(s[i], code_fp);
}

void write_code_char(char c)
{
    fputc(c, code_fp);
}

void write_data(char *s)
{
    was_data = 1;
    for (int i = 0; s[i] != 0; i++)
        fputc(s[i], data_fp);
}

void write_data_char(char c)
{
    was_data = 1;
    fputc(c, data_fp);
}
