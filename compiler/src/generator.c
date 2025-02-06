#include <stdio.h>
#include "writer.h"
#include "config.h"
#include "errors.h"

int label_cnt = 0;

char l_prefix[MAX_TOKEN_SIZE] = "l";
char new_label[MAX_TOKEN_SIZE];

char buf[OUTPUT_BUFFER_SIZE];

void build_label()
{
    label_cnt++;

    sprintf(new_label, "_%s%03x", l_prefix, label_cnt);
}


void write_global_var(char *name, int size)
{
    sprintf(buf, "_%s:\tds %u\n", name, size);
    write_code(buf);
}

void fun_head(char *name)
{
    sprintf(buf, "\n_%s:\n\tpush ix\n\tld ix, 0\n\tadd ix, sp\n", name);

    write_code(buf);
}

void fun_tail(char *name)
{
    sprintf(buf, "_%s_end:\n\tld sp, ix\n\tpop ix\n\tret\n", name);

    write_code(buf);
}

void allocate_vars(int size)
{
    if (!size)
        return;

    sprintf(buf, "\n\tld hl, -%u\n\tadd hl, sp\n\tld sp, hl\n\n", size);

    write_code(buf);
}

void set_accumulator(int value)
{
    sprintf(buf, "\tld hl, %i\n", value);

    write_code(buf);
}

void store_to_stack_var(int offset)
{
    sprintf(buf, "\tld (ix+%i), hl\n", offset);

    write_code(buf);
}

void store_to_global_var(char *label)
{
    sprintf(buf, "\tld (_%s), hl\n", label);

    write_code(buf);
}

void load_local_variable(int offset)
{
    sprintf(buf, "\tld hl, (ix+%i)\n", offset);

    write_code(buf);
}

void load_local_variable_to_add(int offset)
{
    sprintf(buf, "\tld de, (ix+%i)\n", offset);

    write_code(buf);
}

void load_global_variable(char *ptr)
{
    sprintf(buf, "\tld hl, (_%s)\n", ptr);

    write_code(buf);
}

void load_global_variable_to_add(char *ptr)
{
    sprintf(buf, "\tld de, (_%s)\n", ptr);

    write_code(buf);
}

void load_absoulte_addr(char *ptr)
{
    sprintf(buf, "\tld hl, (%s)\n", ptr);

    write_code(buf);
}

void load_absoulte_addr_to_add(char *ptr)
{
    sprintf(buf, "\tld de, (%s)\n", ptr);

    write_code(buf);
}

void set_accumulator_to_ptr(char *ptr)
{
    sprintf(buf, "\tld hl, _%s\n", ptr);

    write_code(buf);
}

void set_additional(int value)
{
    sprintf(buf, "\tld de, %u\n", value);

    write_code(buf);
}

void sum_regs()
{
    write_code("\tadd hl, de\n");
}

void sub_regs()
{
    write_code("\tor a\n\tsbc hl,de\n");
}

void push_accumulator()
{
    write_code("\tpush hl\n");
}

void push_additional()
{
    write_code("\tpush de\n");
}

void pop_accumulator()
{
    write_code("\tpop hl\n");
}

void pop_additional()
{
    write_code("\tpop de\n");
}

void swap_regs()
{
    write_code("\tex de, hl\n");
}

void store_accum_to_stack_ptr()
{
    write_code("\tpop de\n\tex de, hl\n\tld (hl), de\n");
}

void set_accumulator_to_stack_ptr(int offset)
{
    sprintf(buf, "\tlea hl, ix+%i\n", offset);

    write_code(buf);
}

void set_additional_to_stack_ptr(int offset)
{
    sprintf(buf, "\tlea de, ix+%i\n", offset);

    write_code(buf);
}

void load_from_acc_ptr()
{
    write_code("\tld hl, (hl)\n");
}

void equals_check()
{
    build_label();
    sprintf(buf,
            "\tor a\n\tsbc hl, de\n\tld hl, -1\n\tjr z, %s\n\tld hl,0\n%s:\n",
            new_label, new_label);

    write_code(buf);
}

void notequals_check()
{
    build_label();
    sprintf(buf,
            "\tor a\n\tsbc hl, de\n\tld hl, -1\n\tjr nz, %s\n\tld hl,0\n%s:\n",
            new_label, new_label);

    write_code(buf);
}

void greater_check()
{
    build_label();
    sprintf(buf,
            "\tcall __cmp\n\tld hl, 0\n\tjp p, %s\n\tld hl, -1\n%s:\n",
            new_label, new_label);

    write_code(buf);
}

void greater_or_eq_check()
{
    build_label();
    sprintf(buf,
            "\tcall __cmp\n\tld hl, 0\n\tjp m, %s\n\tld hl,-1\n%s:\n",
            new_label, new_label);

    write_code(buf);
}

void bit_and()
{
    write_code("\tcall __and\n");
}

void bit_or()
{
    write_code("\tcall __or\n");
}

void bit_xor()
{
    write_code("\tcall __xor\n");
}

void mul_ptr()
{
    switch (WORD_SIZE) {
    case 2:
        write_code("\add hl, hl\n");
        return;
    case 3:
        write_code("\tpush hl\n\tpop bc\n\tadd hl, hl\n\tadd hl, bc\n");
        return;
    default:
        error(UNIMPLEMENTED);
    }
}

char *string_literal()
{
    build_label();
    sprintf(buf, "_%s:\tdb \"", new_label);
    write_data(buf);

    return new_label;
}

void finish_string_literal()
{
    write_data("\", 0\n");
}

void set_accumulator_dir_ptr(char *ptr)
{
    sprintf(buf, "\tld hl, _%s\n", ptr);

    write_code(buf);
}

void set_additional_dir_ptr(char *ptr)
{
    sprintf(buf, "\tld de, _%s\n", ptr);

    write_code(buf);
}

void call_proc(char *name, int stack_move)
{
    if (stack_move) {
        sprintf(buf,
                "\tcall _%s\n\tex de,hl\n\tld hl, %u\n\tadd hl, sp\n\tld sp, hl\n\tex de,hl\n",
                name, stack_move);
    } else {
        sprintf(buf, "\tcall _%s\n", name);
    }

    write_code(buf);
}

void ret(char *fun)
{
    sprintf(buf, "\tjp _%s_end\n", fun);

    write_code(buf);
}

char *check_condition()
{
    build_label();

    sprintf(buf, "\tld de, 0\n\tor a\n\tsbc hl, de\n\tjp z, %s\n",
            new_label);

    write_code(buf);

    return new_label;
}

void write_label(char *label)
{
    sprintf(buf, "%s:\n", label);

    write_code(buf);
}

char *make_label()
{
    build_label();

    sprintf(buf, "%s:\n", new_label);

    write_code(buf);
    return new_label;
}

void jump(char *label)
{
    sprintf(buf, "\tjp %s\n", label);

    write_code(buf);
}

void e_mul()
{
    write_code("\tcall __mul\n");
}

void e_div()
{
    write_code("\tcall __div\n");
}

void e_mod()
{
    write_code("\tcall __mod\n");
}
