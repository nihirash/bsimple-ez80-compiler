/// @brief              Creates two files from base filename(one for code, another for data segment)
/// @param basefile 
void init_writer(char *basefile);
/// @brief              Closes files, also this routine merges data segment to code segment file
void close_writer();

/// @brief              Write string to code segment of source
/// @param s 
void write_code(char *s);
/// @brief              Writes single character to code segment of source
/// @param c 
void write_code_char(char c);
/// @brief              Writes string to data segment of code
/// @param s 
void write_data(char *s);
/// @brief              Writes single character to data segment of code
/// @param c 
void write_data_char(char c);

/// @brief              File name of resulting source file
extern char source_name[80];