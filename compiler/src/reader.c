#include <stdio.h>

#include "reader.h"
#include "errors.h"

int line_number = 1;

FILE *fp;

char poked = 0;
char eof = 0;

char buffer[1025];

unsigned int buf_ptr;
char is_buffered;


void init_reader(char *filename) {
    printf("Processing file: %s\r\n", filename);

    is_buffered = 0;
    line_number = 1;
    poked = 0;
    eof = 0;

    fp = fopen(filename, "r");

    if (!fp) 
        error(OPEN_FILE_ISSUE);
}

void buff_left()
{
    buf_ptr--;
    buf_ptr %= 1024;
}

char rewind_buffer()
{
    char is_last;
    is_last = 0;
    buff_left();
    while (1) {
        buff_left();
        if (buffer[buf_ptr] == '"') {
            buff_left();
            while (1) {
                buff_left();


                if (buffer[buf_ptr] == '"') {

                    if (buffer[(buf_ptr - 1) % 1024] == '\\') {
                        buff_left();
                        buff_left();
                    }
                }

                if (buffer[buf_ptr] == '"')
                    break;

            }
            buff_left();
        }

        if (buffer[buf_ptr] == '(') {
            is_last = 1;
            break;
        }
        if (buffer[buf_ptr] == ',')
            break;
    }
    buf_ptr++;
    buf_ptr %= 1024;

    is_buffered = 1;
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
        buffer[buf_ptr++] = c;
    } else {
        c = buffer[buf_ptr++];
    }

    buf_ptr %= 1024;
    if (feof(fp)) eof = 1;

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
