#include "config.h"

extern char current_token[MAX_TOKEN_SIZE];

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
