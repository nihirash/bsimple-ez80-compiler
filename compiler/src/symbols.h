#include "config.h"

#define SYM_TABLE_SIZE 50

enum {
    Keyword,
    Constant,
    Glob,
    Auto,
    Parameter,
    Label,

    K_Return,
    K_While,
    K_If,
    K_Label,
    K_Goto,
    K_Var,
};

typedef struct {
    char type;
    char offset;
    char name[MAX_TOKEN_SIZE];
} Symbol;


extern int symbol_table_back;
extern int symbol_table_pos;
extern int local_vars_count;

/// @brief Register symbol in table
/// @param s    string with keywords
/// @param k    keyword_id/offset
/// @param t    type
void register_symbol(char *s, char k, char t);

/// @brief Register keyword in table
/// @param s    string with keyword
/// @param k    keyword id
void register_keyword(char *s, char k);

/// @brief Register function parameter
/// @param s        name
/// @param offset   offset in stack
void register_arg(char *s, int offset);

/// @brief Register local label
/// @param s        name
void register_label(char *s);

/// @brief Register global var/function
/// @param s        name
void register_glob(char *s);

/// @brief Registers local variable
/// @param s        name
/// @param offset   offset in stack
void register_var(char *s, int offset);

/// @brief Find symbol in table
/// @param s string for symbol
/// @return pointer
Symbol *lookup_symbol(char *s);

/// @brief      Check is current ID is keyword
/// @param s    pointer to string
/// @return 
char is_keyword(char *s);

/// @brief      Just for debug - print symbols table 
void dump_symbols();

/// @brief      Remove from symbols table all local definitions
void locals_end();
