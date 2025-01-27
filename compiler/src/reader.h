/// @brief Character that will be returned on next get_ch() instead of reading file 
extern char poked;

/// @brief Flag that input stream was finished
extern char eof;

/// @brief Reads character from some stream
/// @return 
char get_chr();

/// @brief Gets current line 
/// @return 
int get_current_line();

extern unsigned int buf_ptr;
extern char is_buffered;

char rewind_buffer();

void init_reader(char *filename);