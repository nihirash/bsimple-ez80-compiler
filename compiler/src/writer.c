#include <stdio.h>

#include "writer.h"
#include "errors.h"

FILE *code_fp;
FILE *data_fp;

char filename[80];


void epilogue() 
{
    char buf[512];
    int c;
    printf("Storing data segment!\n");
    if (data_fp && code_fp) {
        fflush(data_fp);
        fclose(data_fp);

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
    
	remove(filename);
    }
}

void init_writer(char *basefile)
{
    sprintf(filename, "%s.s", basefile);

    code_fp = fopen(filename, "w");

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
    for (int i=0;s[i] != 0 ; i++)
	fputc(s[i], code_fp);
}

void write_data(char *s)
{
    for (int i=0;s[i] != 0 ; i++)
	fputc(s[i], data_fp);
}

void write_data_char(char c)
{
    fputc(c, data_fp);
}
