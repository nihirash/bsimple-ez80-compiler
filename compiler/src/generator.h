/// @brief          Generate global variable code
/// @param name     name of it
/// @param size     Size(in words)
void write_global_var(char *name, int size);

/// @brief          Function header
/// @param name     Name of function
void fun_head(char *name);

/// @brief          End of function block
void fun_tail(char *name);

/// @brief          Local label inside function
void local_label(char *name);

/// @brief          Allocate stack for local variables
/// @param size     Size in bytes
void allocate_vars(int size);

/// @brief          Store constant to accumulator
/// @param value 
void set_accumulator(int value);

/// @brief          Store value to stack variable
/// @param offset 
void store_to_stack_var(int offset);

/// @brief          Store value to global variable
/// @param label 
void store_to_global_var(char *label);

/// @brief          Load variable from stack
/// @param offset 
void load_local_variable(int offset);

/// @brief          Load variable from stack to additional register
/// @param offset 
void load_local_variable_to_add(int offset);

/// @brief          Load global variable
/// @param ptr 
void load_global_variable(char *ptr);

/// @brief          Load global variable to additional register
/// @param ptr 
void load_global_variable_to_add(char *ptr);

void load_absoulte_addr(char *ptr);

void load_absoulte_addr_to_add(char *ptr);

/// @brief          Store global var pointer to accumulator
/// @param ptr 
void set_accumulator_to_ptr(char *ptr);

/// @brief          Store local var pointer to accumulator
/// @param offset 
void set_accumulator_to_stack_ptr(int offset);

/// @brief          Store constant to additional register
/// @param value 
void set_additional(int value);

/// @brief          Calculate sum between additional and accumulator registers
void sum_regs();

/// @brief          Store current calculation value to stack
void push_accumulator();

/// @brief          Store additional register to stack
void push_additional();

/// @brief          Restores accumulator from stack
void pop_accumulator();

/// @brief          Restores additional register from stack
void pop_additional();

/// @brief          Swaping additional and accumulator registers
void swap_regs();

/// @brief          Store to local variable
void store_accum_to_stack_ptr();

/// @brief          Load value from pointer
void load_from_acc_ptr();

/// @brief          Math: Substraction
void sub_regs();

/// @brief          Logic: Equality
void equals_check();

/// @brief          Logic: NotEquality
void notequals_check();

/// @brief          Math: Is number greater?
void greater_check();

/// @brief          Math: Is number greater or equals
void greater_or_eq_check();

/// @brief          Bitwise and
void bit_and();

/// @brief          Bitwise or
void bit_or();

/// @brief          Bitwise xor
void bit_xor();

/// @brief          multiply pointer by word size
void mul_ptr();

/// @brief          Store string literal to data segment
/// @return         Label
char *string_literal();

/// @brief          Done storing string literal
void finish_string_literal();

/// @brief          Set accumulator to pointer 
/// @param ptr      Pointer
void set_accumulator_dir_ptr(char *ptr);

/// @brief          Set accumulator to pointer 
/// @param ptr      Pointer
void set_additional_dir_ptr(char *ptr);

/// @brief              Call function/procedure
/// @param name         Name of procedure
/// @param stack_move   Allocated stack size for parameters
void call_proc(char *name, int stack_move);

/// @brief              Return from function
/// @param fun 
void ret(char *fun);

/// @brief              Check condition(check for non-zero)
/// @return             Label on false condition
char *check_condition();

/// @brief              Write label in assembly
/// @param label        Name
void write_label(char *label);

/// @brief              Make dynamic label
/// @return             Label name
char *make_label();

/// @brief              Goto specified label
/// @param label 
void jump(char *label);

/// @brief              Sets pointer to local variable(additional register)
/// @param offset 
void set_additional_to_stack_ptr(int offset);

/// @brief              Multiply regs
void e_mul();

/// @brief              Divide regs
void e_div();

/// @brief              Get number's modulo
void e_mod();

/// @brief              Label prefix that will be used for labels generation
extern char l_prefix[];

/// @brief              Creates new label and returns it 
char *build_label();

/// @brief              Branching on false check
void jump_if_false(char *label);
