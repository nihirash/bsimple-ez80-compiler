#include "config.h"

/// @brief      Reads token to "current_token" buffer and returns type from enum
/// @return     Enum type of token
char get_token();

enum {
    Unknown,

    Id,
    Number,

    EOS,                        // ;

    Comma,                      // ,

    LP,                         // (
    RP,                         // )

    Begin,                      // {
    End,                        // }

    LS,                         // [
    RS,                         // ]

    Sum,
    Dec,
    Mul,
    Div,
    Mod,

    And,
    Or,

    BAnd,
    BOr,
    BXor,

    Greater,
    Less,
    NEq,
    Eq,
    GE,
    LE,
    Assign,
    Index,

    SingleQuote,
    DoubleQuote,
};


extern char current_token[];
