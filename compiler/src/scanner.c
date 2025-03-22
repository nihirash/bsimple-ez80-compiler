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
void process_statement(char token);
void process_block(char is_fun);
char process_expression();

void process_for_loop()
{
    char token;
    char label_increment[MAX_TOKEN_SIZE],
        label_for_condition[MAX_TOKEN_SIZE],
        label_for_body[MAX_TOKEN_SIZE], label_done[MAX_TOKEN_SIZE];

    if (get_token() != LP)
        error(UNEXPECTED_SYMBOL);

    strcpy(label_increment, build_label());
    strcpy(label_for_condition, build_label());
    strcpy(label_for_body, build_label());

    token = get_token();
    if (token != EOS)
        process_statement(token);

    write_label(label_for_condition);
    process_expression();

    strcpy(label_done, check_condition());

    jump(label_for_body);

    write_label(label_increment);
    token = get_token();
    if (token != EOS)
        process_statement(token);
    jump(label_for_condition);

    write_label(label_for_body);
    process_block(0);
    jump(label_increment);

    write_label(label_done);
}

void process_repeat_until()
{
    char label1[MAX_TOKEN_SIZE];
    Symbol *s;

    strcpy(label1, make_label());
    process_block(0);

    if (get_token() != Id)
        error(UNEXPECTED_SYMBOL);

    s = lookup_symbol(current_token);

    if (s->offset != K_Until)
        error(UNEXPECTED_SYMBOL);

    process_expression();
    jump_if_false(label1);
}


void global_var()
{
    int size = 1;
    char name[MAX_TOKEN_SIZE];
    char tok;

    while (1) {
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

        if (tok == Comma) {
            write_global_var(name, WORD_SIZE * size);

            size = 1;
            continue;
        }

        error(UNEXPECTED_SYMBOL);
    }
}

void process_local_vars()
{
    int offset = 0;
    char token;
    int size = 1;
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

        if (offset > 127)
            error(TOO_FAR_ON_STACK);

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
    int num = 0;

    token = get_token();

    switch (token) {
    case Id:
        s = lookup_symbol(current_token);

        if (is_keyword(current_token))
            error(NOT_VALID_IDENTIFIER);

        if (!s || s->type == Glob) {
            set_accumulator_to_ptr(current_token);
        } else if (s && (s->type == Auto || s->type == Parameter)) {
            set_accumulator_to_stack_ptr(s->offset);
        } else {
            error(UNEXPECTED_SYMBOL);
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
    case Mul:
        token = get_token();
        if (token == Number) {
            if (is_acc) {
                load_absoulte_addr(current_token);
            } else {
                load_absoulte_addr_to_add(current_token);
            }
        } else {
            if (token != Id)
                error(UNEXPECTED_SYMBOL);

            if (is_keyword(current_token))
                error(UNEXPECTED_SYMBOL);

            s = lookup_symbol(current_token);

            if (!is_acc) {
                push_accumulator();
            }

            if (!s || s->type == Glob) {
                set_accumulator_to_ptr(current_token);
            } else if (s && (s->type == Auto || s->type == Parameter)) {
                set_accumulator_to_stack_ptr(s->offset);
            } else {
                error(UNEXPECTED_SYMBOL);
            }

            load_from_acc_ptr();
            load_from_acc_ptr();

            if (!is_acc) {
                swap_regs();
                pop_accumulator();
            }

        }
        break;
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
        if (s && (s->type == Auto || s->type == Parameter)) {
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
    char res;
    Symbol *s;

    strcpy(to, l_value);
    s = lookup_symbol(to);

    res = process_expression();
    if (res != EOS && res != RP) {
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
    char token, args = 0, c;
    char is_last = 0;
    int pointer = 0;
    unsigned int rewind_ptr, exit_ptr = 0;
    int p_balance;

    args = 0;
    strcpy(fun_to_call, fun);

    rewind_ptr = buf_ptr - 1;
    p_balance = 1;
    for (token = get_token(); p_balance != 0; token = get_token()) {
        if (token == LP) {
            p_balance++;

            continue;
        }

        if (token == RP) {
            p_balance--;

            if (!p_balance)
                break;

            continue;
        }


        if (token == DoubleQuote) {
            c = get_chr();
            while (c != '"') {
                if (c == '\\')
                    get_chr();

                c = get_chr();
            }

            continue;
        }

        if (token == Unknown) {
            error(UNEXPECTED_SYMBOL);
        }
    }
    exit_ptr = buf_ptr;
    is_buffered++;
    is_last = 0;
    while (!is_last) {
        is_last = rewind_buffer(rewind_ptr);

        pointer = buf_ptr;
        token = process_expression();
        buf_ptr = pointer;

        if (token != EOS) {
            push_accumulator();

            args++;
        }
    }

    is_buffered--;
    buf_ptr = exit_ptr;
    call_proc(fun_to_call, args * WORD_SIZE);
}

void process_assign_to_ptr()
{
    char token;
    Symbol *s;

    token = get_token();
    if (token != Id || is_keyword(current_token))
        error(UNEXPECTED_SYMBOL);
    s = lookup_symbol(current_token);

    if (!s || s->type == Glob) {
        load_global_variable(current_token);
    } else if (s && (s->type == Auto || s->type == Parameter)) {
        load_local_variable(s->offset);
    }
    push_accumulator();

    if (get_token() != Assign)
        error(UNEXPECTED_SYMBOL);

    token = process_expression();

    if (token != EOS && token != RP)
        error(UNEXPECTED_SYMBOL);

    store_accum_to_stack_ptr();

}

void process_statement(char token)
{
    char label[MAX_TOKEN_SIZE], label2[MAX_TOKEN_SIZE];

    Symbol *s;

    is_buffered = 0;

    if (token == Mul) {
        process_assign_to_ptr();
    }

    if (token == Id) {
        if (!is_keyword(current_token)) {
            strcpy(l_value, current_token);
            token = get_token();
            switch (token) {
            case Assign:
                process_assing();

                break;
            case LP:
                enable_buffer();
                process_fun_call(l_value);
                disable_buffer();
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
            switch (lookup_symbol(current_token)->offset) {
            case K_For:
                process_for_loop();
                break;
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
                if (get_token() != Id || is_keyword(current_token))
                    error(UNEXPECTED_SYMBOL);

                sprintf(label, "_%s_%s", current_function, current_token);
                write_label(label);
                break;
            case K_Goto:
                if (get_token() != Id || is_keyword(current_token))
                    error(UNEXPECTED_SYMBOL);
                sprintf(label, "_%s_%s", current_function, current_token);
                jump(label);
                break;
            case K_Repeat:
                process_repeat_until();

                break;
            default:
                break;
            }

        }
    }

    if (token == LS) {
        indexed_assignation();
    }

    return;
}

void process_block(char is_fun)
{

    char token;
    Symbol *s;

    token = get_token();

    if (is_fun) {
        if (token == Id) {
            s = lookup_symbol(current_token);
            while (s && s->type == Keyword && s->offset == K_Var) {
                process_local_vars();

                token = get_token();
                s = lookup_symbol(current_token);
            }
        }
    }

    while (token != End) {
        process_statement(token);
        token = get_token();
    }

}

void process_function()
{
    int token, arg_offset;
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

void process_import()
{
    char c;

    if (get_token() != DoubleQuote)
        error(UNEXPECTED_SYMBOL);

    write_code("\tinclude \"");

    while (!eof) {
        c = get_chr();

        if (c == 13 || c == 10)
            error(UNEXPECTED_SYMBOL);

        write_code_char(c);

        if (c == '"')
            break;
    }

    write_code("\n");
}

void process_binary()
{
    char c;
    char label[MAX_TOKEN_SIZE + 1];

    if (get_token() != Id)
        error(UNEXPECTED_SYMBOL);

    if (is_keyword(current_token))
        error(CANT_REDEFINE);

    printf("binary %s\r\n", current_token);

    sprintf(label, "_%s", current_token);
    write_label(label);

    if (get_token() != Comma || get_token() != DoubleQuote)
        error(UNEXPECTED_SYMBOL);

    write_code("\tincbin \"");
    while (!eof) {
        c = get_chr();

        if (c == 13 || c == 10)
            error(UNEXPECTED_SYMBOL);

        write_code_char(c);

        if (c == '"')
            break;
    }

    write_code("\n");
}

void process_program()
{
    Symbol *s;
    char token;

    while (!eof) {
        is_buffered = 0;

        token = get_token();
        if (eof)
            break;

        if (token != Id) {
            error(UNEXPECTED_SYMBOL);
        }

        s = lookup_symbol(current_token);

        if (s && s->type == Keyword) {
            switch (s->offset) {
            case K_Import:
                process_import();
                break;
            case K_Var:
                global_var();
                break;
            case K_Bin:
                process_binary();
                break;
            default:
                error(UNEXPECTED_SYMBOL);
                break;
            }

            continue;
        }

        if (s) {
            error(CANT_REDEFINE);
        }

        process_function();
    }
}
