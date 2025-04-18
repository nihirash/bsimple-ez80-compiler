#include <stdio.h>

#include "reader.h"
#include "errors.h"
#include "config.h"

int line_number = 1;

FILE *fp;

char filestack_position;
FILE *filestack[FILESTACK_DEPTH];

char poked = 0;
char eof = 0;

char buffer[ARGS_BUFFER_SIZE];

char linepos;
char linebuffer[LINE_BUFFER_SIZE];

int buf_ptr;
char is_buffered;
char is_buffer_writable;


void init_reader(char *filename)
{
    printf("Processing file: %s\r\n", filename);

    is_buffered = 0;
    is_buffer_writable = 0;
    line_number = 1;
    poked = 0;
    eof = 0;
    filestack_position = 0;

    fp = fopen(filename, "r");
    filestack[filestack_position] = fp;

    linepos = 0;
    linebuffer[linepos] = 0;

    if (!fp)
        error(OPEN_FILE_ISSUE);
}

void shutdown_reader()
{
    for (int i = 0; i <= filestack_position; i++) {
        if (filestack[i]) {
            fclose(filestack[i]);
        }
    }
}

void include_file(char *filename)
{
    filestack_position++;

    if (filestack_position >= FILESTACK_DEPTH) {
        error(FILESTACK_OVERRUN);
    }

    fp = fopen(filename, "r");

    if (!fp)
        error(OPEN_FILE_ISSUE);

    filestack[filestack_position] = fp;
}

void filestack_pop()
{
    printf("File done!\r\n");
    fclose(fp);
    filestack_position--;

    fp = filestack[filestack_position];
}

void prepare_buffer()
{
    for (int i = 0; i < ARGS_BUFFER_SIZE; i++)
        buffer[i] = 0;

    buffer[0] = '(';
    buf_ptr = 1;
}

void buff_left()
{
    buf_ptr--;

    if (buf_ptr < 0) {
        buf_ptr = ARGS_BUFFER_SIZE - 1;
    }
}

char peek_left()
{
    int tmp_ptr = buf_ptr;
    tmp_ptr--;
    if (tmp_ptr < 0) {
        tmp_ptr = ARGS_BUFFER_SIZE - 1;
    }
    return buffer[tmp_ptr];
}

void buff_right()
{
    buf_ptr++;

    if (buf_ptr >= ARGS_BUFFER_SIZE) {
        printf("Buffer state: %s\r\n", buffer);

        error(BUFFER_OVERRUN);
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

                    if (peek_left() == '\\') {
                        buff_left();
                        buff_left();
                    }
                }

                if (buffer[buf_ptr] == '"')
                    break;

            }
            buff_left();
        }


        if (buf_ptr == rewind_ptr || buf_ptr == 0) {
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
      retry:
        if (!fread(&c, 1, 1, fp)) {
            if (filestack_position == 0) {
                eof = 1;
            } else {
                filestack_pop();
                goto retry;
            }
        }

        if (is_buffer_writable) {
            buffer[buf_ptr] = c;
            buff_right();
        }

        if (linepos < LINE_BUFFER_SIZE - 1) {
            linebuffer[linepos++] = c;
            linebuffer[linepos] = 0;
        }
    } else {
        c = buffer[buf_ptr];
        buff_right();
    }


    if (feof(fp))
        eof = 1;

    if (eof) {
        return 0;
    }


    if (c == 10) {
        linebuffer[0] = 0;
        linepos = 0;
        line_number++;
    }

    return c;
}

int get_current_line()
{
    return line_number;
}
