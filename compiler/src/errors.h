enum {
    UNEXPECTED_EOF,
    UNEXPECTED_SYMBOL,
    OPEN_FILE_ISSUE,
    CREATE_FILE_ISSUE,
    SYMBOLS_TABLE_OVERLOAD,
    CANT_REDEFINE,
    EXPECTED_BLOCK,
    EXPECTED_IDENTIFIER,
    NUMBER_EXPECTED,
    NOT_VALID_IDENTIFIER,
    BINARY_OPERATION,
    TOO_FAR_ON_STACK,
    BUFFER_OVERRUN,
    FILESTACK_OVERRUN,

    UNIMPLEMENTED
};

/// @brief              Stop execution and print error message
/// @param error 
void error(char error);
