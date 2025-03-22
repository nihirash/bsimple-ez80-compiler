#include "config.h"

/// @brief              Initialize source code reading
/// @param filename     File from source code should be read
void init_reader(char *filename);

/// @brief              Shutdown source code reading
void shutdown_reader();

/// @brief              Include source code from another file
/// @param filename     Filename(can contain path)
void include_file(char *filename);

/// @brief              Character that will be returned on next get_chr() instead of reading file 
extern char poked;

/// @brief              Flag that input stream was finished
extern char eof;

/// @brief              Reads character from some stream
/// @return             Single character(from file or poked if stored)
char get_chr();

/// @brief              Gets current line number
/// @return 
int get_current_line();

/**
 * Buffered read.
 * 
 * This part makes a bit strange thing, but it allows implement our compiler with CDELC-frame without forming AST
 * This is reduces memory usage and allows compile any size of programs - keeping compiler streaming.
 */

/// @brief              Enables read buffer and rewind to start of last function call argument
/// @param rewind_ptr   Buffer index where function call was opened - mark of last(in processing, first in list) function argument 
/// @return             Was first argument found
char rewind_buffer(unsigned int rewind_ptr);

/// @brief              Stores current pointer in output buffer
extern int buf_ptr;
/// @brief              Flag that indicates is buffered mode enabled or we should continue processing file
extern char is_buffered;
/// @brief              Should we populate arguments buffer?
extern char is_buffer_writable;

/// @brief              Buffer - size can be configured in config.h
extern char buffer[];

/// @brief              Additional information if error messages
extern char linebuffer[LINE_BUFFER_SIZE];

/// @brief              Prepares buffer for argument parsing
void prepare_buffer();
