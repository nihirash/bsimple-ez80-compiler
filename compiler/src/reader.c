#include <stdio.h>

#include "reader.h"
#include "errors.h"
#include "config.h"

int line_number = 1;

FILE *fp;

char poked = 0;
char eof = 0;

char buffer[ARGS_BUFFER_SIZE];

int buf_ptr;
char is_buffered;


void init_reader(char *filename)
{
    printf("Processing file: %s\r\n", filename);

    is_buffered = 0;
    line_number = 1;
    poked = 0;
    eof = 0;

    fp = fopen(filename, "r");

    if (!fp)
        error(OPEN_FILE_ISSUE);
}

void clean_buffer()
{
    for (int i = 0; i < ARGS_BUFFER_SIZE; i++)
        buffer[i] = 0;
}

void buff_left()
{
    buf_ptr--;

    if (buf_ptr < 0) {
        buf_ptr = ARGS_BUFFER_SIZE - 1;
    }
}

void buff_right()
{
    buf_ptr++;

    if (buf_ptr == ARGS_BUFFER_SIZE) {
        buf_ptr = 0;
    }
}

char rewind_buffer(unsigned int rewind_ptr)
{
    char is_last;
    int par;
    par = 0;
    is_last = 0;
    buff_left();
    while (1) {
        buff_left();
        if (buffer[buf_ptr] == ')') {
            par++;
            buff_left();
            while (1) {
                if (buffer[buf_ptr] == '(') {
                    par--;
                    buff_left();

                    if (!par)
                        break;
                }

                if (buffer[buf_ptr] == ')') {
                    par++;
                    buff_left();
                }
                buff_left();
            }
            buff_left();
        }

        if (buffer[buf_ptr] == '"') {
            buff_left();
            while (1) {
                buff_left();

                if (buffer[buf_ptr] == '"') {

                    if (buffer[(buf_ptr - 1) % ARGS_BUFFER_SIZE] == '\\') {
                        buff_left();
                        buff_left();
                    }
                }

                if (buffer[buf_ptr] == '"')
                    break;

            }
            buff_left();
        }


        if (buf_ptr == rewind_ptr) {
            is_last = 1;
            break;
        }
        if (buffer[buf_ptr] == ',')
            break;
    }

    buff_right();

    return is_last;
}


char get_chr()
{
    char c;

    if (poked) {
        c = poked;
        poked = 0;

        return c;
    }


    if (!is_buffered) {
        if (!fread(&c, 1, 1, fp)) {
            eof = 1;
        }
        buffer[buf_ptr] = c;
    } else {
        c = buffer[buf_ptr];
    }

    buff_right();

    if (feof(fp))
        eof = 1;

    if (eof) {
        return 0;
    }


    if (c == 10) {
        line_number++;
    }

    return c;
}

int get_current_line()
{
    return line_number;
}
