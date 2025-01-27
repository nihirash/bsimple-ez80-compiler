#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "scanner.h"

#include "errors.h"
#include "token.h"
#include "generator.h"
#include "config.h"
#include "reader.h"
#include "symbols.h"
#include "writer.h"

char current_function[MAX_TOKEN_SIZE];
char l_value[MAX_TOKEN_SIZE];

char local_label_counter = 0;

void process_fun_call(char *fun_to_call);

void global_var()
{
    char size = 1;
    char name[MAX_TOKEN_SIZE];
    char tok;

    if (get_token() != Id) {
        error(UNEXPECTED_SYMBOL);
    }

    if (lookup_symbol(current_token) != 0) {
        error(CANT_REDEFINE);
    }

    strcpy(name, current_token);
    register_glob(name);

    printf("var %s\n", name);

    tok = get_token();
    if (tok == LS) {
        if (get_token() == Number) {
            size = atoi(current_token);

            if (get_token() != RS)
                error(UNEXPECTED_SYMBOL);

            tok = get_token();
        } else {
            error(UNEXPECTED_SYMBOL);
        }
    }

    if (tok == EOS) {
        write_global_var(name, WORD_SIZE * size);

        return;
    }

    error(UNEXPECTED_SYMBOL);
}

void process_local_vars()
{
    char offset = 0;
    char token;
    char size = 1;
    char name[MAX_TOKEN_SIZE];

    token = get_token();
    while (token != EOS) {
        size = 1;

        if (token != Id)
            error(EXPECTED_IDENTIFIER);

        if (is_keyword(current_token))
            error(CANT_REDEFINE);

        strcpy(name, current_token);

        token = get_token();

        if (token == LS) {
            token = get_token();

            if (token != Number)
                error(NUMBER_EXPECTED);

            size = atoi(current_token);

            token = get_token();

            if (token != RS)
                error(UNEXPECTED_SYMBOL);

            token = get_token();
        }

        offset += size * WORD_SIZE;
        register_var(name, -offset);

        if (token == Comma) {
            token = get_token();
        }
    }
    allocate_vars(offset);
}

void calc_indexed_address()
{
    char token;
    Symbol *s;
    int num;

    token = get_token();

    switch (token) {
    case Id:
        s = lookup_symbol(current_token);

        if (is_keyword(current_token))
            error(NOT_VALID_IDENTIFIER);

        // Global array
        if (!s || s->type == Glob) {
            set_accumulator_to_ptr(current_token);
        } else if (s && (s->type == Auto || s->type == Parameter)) {
            set_accumulator_to_stack_ptr(s->offset);
        }
        break;

    case Number:
        num = atoi(current_token);
        set_accumulator(num);
        break;

    case Mul:
        token = get_token();
        if (token != Id || is_keyword(current_token))
            error(UNEXPECTED_SYMBOL);
        s = lookup_symbol(current_token);

        if (!s || s->type == Glob) {
            load_global_variable(current_token);
        } else if (s && (s->type == Auto || s->type == Parameter)) {
            load_local_variable(s->offset);
        }
        break;
    default:
        error(UNEXPECTED_SYMBOL);
        break;
    }

    if (get_token() != Index)
        error(UNEXPECTED_SYMBOL);

    token = get_token();
    if (token == Number) {
        num = atoi(current_token);

        set_additional(num * WORD_SIZE);
    } else if (token == Id) {
        s = lookup_symbol(current_token);
        swap_regs();
        if (!s || s->type == Glob) {
            load_global_variable(current_token);
            mul_ptr();
        } else if (s && (s->type == Auto || s->type == Parameter)) {
            load_local_variable(s->offset);
            mul_ptr();
        }

    }

    sum_regs();
    if (get_token() != RS)
        error(UNEXPECTED_SYMBOL);
}

char process_value(char is_acc)
{
    char token, c;
    int value, is_minus;
    Symbol *s;

    is_minus = 0;
    token = get_token();

    if (token == Dec) {
        is_minus = 1;
        token = get_token();
    }

    switch (token) {
    case BAnd:
        token = get_token();
        if (token != Id)
            error(UNEXPECTED_SYMBOL);

        s = lookup_symbol(current_token);

        if (is_keyword(current_token))
            error(UNEXPECTED_SYMBOL);

        if (!s || s->type == Glob) {
            if (is_acc) {
                set_accumulator_dir_ptr(current_token);
            } else {
                set_additional_dir_ptr(current_token);
            }
        }

        if (s && (s->type == Auto || s->type == Parameter)) {
            if (is_acc) {
                set_accumulator_to_stack_ptr(s->offset);
            } else {
                set_additional_to_stack_ptr(s->offset);
            }
        }

        break;
    case DoubleQuote:
        if (is_acc) {
            set_accumulator_dir_ptr(string_literal());
        } else {
            set_additional_dir_ptr(string_literal());
        }
        c = get_chr();
        while (c != '"') {
            if (c == '\\') {
                write_data_char('\\');
                c = get_chr();
            }
            write_data_char(c);
            c = get_chr();
        }

        finish_string_literal();
        break;
    case Number:
        value = atoi(current_token);
        if (is_minus) {
            value = -value;
        }
        if (is_acc)
            set_accumulator(value);
        else
            set_additional(value);
        break;
    case Id:
        if (is_minus)
            error(BINARY_OPERATION);

        s = lookup_symbol(current_token);
        if (s->type == Auto || s->type == Parameter) {
            if (is_acc) {
                load_local_variable(s->offset);
            } else {
                load_local_variable_to_add(s->offset);
            }
        } else if (!s || s->type == Glob) {
            poked = get_chr();

            if (poked == '(') {
                poked = 0;
                if (is_acc) {
                    push_additional();
                    process_fun_call(current_token);
                    pop_additional();
                } else {
                    push_accumulator();
                    process_fun_call(current_token);
                    swap_regs();
                    pop_accumulator();
                }

            } else if (is_acc) {
                load_global_variable(current_token);
            } else {
                load_global_variable_to_add(current_token);
            }
        }
        break;
    case LS:
        if (is_minus)
            error(BINARY_OPERATION);

        if (is_acc)
            push_additional();
        else
            push_accumulator();

        calc_indexed_address();
        load_from_acc_ptr();

        if (is_acc)
            pop_additional();
        else {
            swap_regs();
            pop_accumulator();
        }
        break;
    }

    return token;
}

char process_expression()
{
    char token;
    int value;
    char is_first = 1;
    Symbol *s;

    if (process_value(1) == EOS)
        return EOS;

    while (1) {
        token = get_token();
        switch (token) {
        case Sum:
            value = process_value(0);
            sum_regs();
            if (value == EOS)
                return EOS;
            break;
        case Dec:
            value = process_value(0);
            sub_regs();
            if (value == EOS)
                return EOS;
            break;
        case Eq:
            value = process_value(0);
            equals_check();
            if (value == EOS)
                return EOS;
            break;
        case NEq:
            value = process_value(0);
            notequals_check();
            if (value == EOS)
                return EOS;
            break;
        case Greater:
            value = process_value(0);
            swap_regs();
            greater_check();
            if (value == EOS)
                return EOS;
            break;
        case GE:
            value = process_value(0);
            greater_or_eq_check();
            if (value == EOS)
                return EOS;
            break;
        case LE:
            value = process_value(0);
            swap_regs();
            greater_or_eq_check();
            if (value == EOS)
                return EOS;
            break;
        case Less:
            value = process_value(0);
            greater_check();
            if (value == EOS)
                return EOS;
            break;
        case BAnd:
            value = process_value(0);
            bit_and();
            if (value == EOS)
                return EOS;
            break;
        case BOr:
            value = process_value(0);
            bit_or();
            if (value == EOS)
                return EOS;
            break;
        case BXor:
            value = process_value(0);
            bit_xor();
            if (value == EOS)
                return EOS;
            break;
        case Mul:
            value = process_value(0);
            e_mul();
            if (value == EOS)
                return EOS;
            break;
        case Div:
            value = process_value(0);
            e_div();
            if (value == EOS)
                return EOS;
            break;
        case Mod:
            value = process_value(0);
            e_mod();
            if (value == EOS)
                return EOS;
            break;
        default:
            return token;
        }
    }
}

void process_assing()
{
    char to[MAX_TOKEN_SIZE];
    char token;
    Symbol *s;

    strcpy(to, l_value);
    s = lookup_symbol(to);

    if (process_expression() != EOS) {
        error(UNEXPECTED_SYMBOL);
    }

    if (s && (s->type == Auto || s->type == Parameter)) {
        store_to_stack_var(s->offset);

        return;
    }

    if (!s || s->type == Glob) {
        store_to_global_var(to);

        return;
    }

    error(NOT_VALID_IDENTIFIER);
}

void indexed_assignation()
{
    char token;
    int num;
    Symbol *s;

    calc_indexed_address();
    push_accumulator();

    if (get_token() != Assign)
        error(UNEXPECTED_SYMBOL);

    if (process_expression() != EOS)
        error(UNEXPECTED_SYMBOL);

    store_accum_to_stack_ptr();

}

void process_fun_call(char *fun)
{
    char fun_to_call[MAX_TOKEN_SIZE];
    char token, c, args;
    int pointer;
    strcpy(fun_to_call, fun);

    for (token = get_token(); token != RP; token = get_token()) {

        if (token == DoubleQuote) {
            c = get_chr();
            while (c != '"') {
                if (c == '\\')
                    get_chr();

                c = get_chr();
            }

            continue;
        }

        if (token == Unknown)
            error(UNEXPECTED_SYMBOL);
    }

    while (1) {
        c = rewind_buffer();

        pointer = buf_ptr;

        token = process_expression();

        if (token != EOS) {
            push_accumulator();

            args++;
        }

        buf_ptr = pointer;
        if (c) {
            break;
        }
    }
    is_buffered = 0;
    call_proc(fun_to_call, args * WORD_SIZE);
}

void process_block(char is_fun)
{

    char token;
    char label[MAX_TOKEN_SIZE], label2[MAX_TOKEN_SIZE];

    Symbol *s;

    token = get_token();

    if (is_fun) {
        if (token == Id) {
            s = lookup_symbol(current_token);
            if (s && s->type == Keyword && s->offset == K_Var) {
                process_local_vars();
                token = get_token();
            }
        }
    }

    while (token != End) {
        if (token == Id) {
            if (!is_keyword(current_token)) {
                strcpy(l_value, current_token);
                token = get_token();
                switch (token) {
                case Assign:
                    process_assing();
                    break;
                case LP:
                    process_fun_call(l_value);
                    token = get_token();
                    if (token != EOS) {
                        error(UNEXPECTED_SYMBOL);
                    }
                    break;
                default:
		    printf("\nToken Id: %u\n", token);
                    error(UNEXPECTED_SYMBOL);
                }
            } else {
                switch(lookup_symbol(current_token)->offset) {
                    case K_Return:
                        if (process_expression() != EOS) {
                            printf("\nToken Id: %u\n", token);
			    error(UNEXPECTED_SYMBOL);
			}

                        ret(current_function);
                        break;
                    case K_If:
                        if (process_expression() != Begin)
                        error(UNEXPECTED_SYMBOL);

                        strcpy(label, check_condition());
                        process_block(0);
                        write_label(label);
                        break;
                    case K_While:
                        strcpy(label2, make_label());

                        if (process_expression() != Begin)
                            error(UNEXPECTED_SYMBOL);
                        strcpy(label, check_condition());
                        process_block(0);
                        jump(label2);
                        write_label(label);
                        break;
                    case K_Label:
                        if (get_token() != Id || is_keyword(current_token)) error(UNEXPECTED_SYMBOL);

                        sprintf(label, "_%s_%s", current_function, current_token);
                        write_label(label);
                        break;
                    case K_Goto:
                        if (get_token() != Id || is_keyword(current_token)) error(UNEXPECTED_SYMBOL);
                        sprintf(label, "_%s_%s", current_function, current_token);
                        jump(label);
                        break;
                    default:
                        break;
                }

            }
        }

        if (token == LS) {
            indexed_assignation();
        }

        token = get_token();
    }

}

void process_function()
{
    char token, arg_offset;
    arg_offset = WORD_SIZE * 2;

    strcpy(current_function, current_token);

    printf("function %s()\n", current_function);

    if (get_token() != LP) {
        error(UNEXPECTED_SYMBOL);
    }

    register_glob(current_function);
    fun_head(current_function);

    // Arguments list
    token = get_token();
    while (token != RP) {
        if ((arg_offset == WORD_SIZE * 2) && token != Id) {
            error(UNEXPECTED_SYMBOL);
        }

        if (is_keyword(current_token))
            error(CANT_REDEFINE);
        register_arg(current_token, arg_offset);

        arg_offset += WORD_SIZE;

        token = get_token();

        if (Comma == token) {
            token = get_token();
        } else if (RP != token) {
            error(UNEXPECTED_SYMBOL);
        }
    }

    if (get_token() != Begin)
        error(EXPECTED_BLOCK);

    // Function body!
    process_block(1);

    fun_tail(current_function);
    locals_end();
}

void process_program()
{
    Symbol *s;
    char token;

    while (!eof) {
        token = get_token();
	if (eof)
	    break;

        if (token != Id) {
            error(UNEXPECTED_SYMBOL);
        }

        s = lookup_symbol(current_token);

        if (s && s->type == Keyword && s->offset == K_Var) {
            global_var();

            continue;
        }

        if (s) {
            error(CANT_REDEFINE);
        }

        process_function();
    }
}
