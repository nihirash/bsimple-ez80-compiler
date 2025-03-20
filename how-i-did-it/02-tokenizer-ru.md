# BSimple. Записки сумасшедшего, или как я решил написать компилятор.

## Первые шаги

Решать большую задачу можно либо прорабатывая её до деталей изначально и выполняя набор маленьких задач, либо, скажем так, "от пятна" — по ходу реализации дополняя картину деталями, начиная с чего-то максимально высокоуровневого и добавляя нюансы в процессе погружения в проект.

BSimple развивался именно методом "от пятна", за исключением двух маленьких участков кода — таблицы символов и минимального токенайзера. Они нам понадобятся на любом этапе разработки.

Сегодня начнём с токенайзера.

### Чтение программы

Прежде чем разбирать программу на токены или даже компилировать её, нам нужно сначала иметь, что читать.

В реальности нам не так важно, читаем ли мы данные из файла или получаем их байт за байтом из массива, главное — чтобы у нас была функция, возвращающая один байт. В некоторых случаях полезно иметь возможность "возвращать" символ назад, чтобы следующее чтение снова получило его. Для этого будем сохранять его в переменную poked. Если в ней уже есть значение, то при чтении сначала извлечём его оттуда, а затем будем читать из источника.

Условно, функция для чтения из строки будет выглядеть так:

```c
char str_to_tokenize[] = " x=10 >= 5 <= 6 == 1+2+3>10<100*10/455+(a+b+c) && x+y || x-y ^ z;";

int position = 0;
char poked = 0;

char get_char() {
    char c;

    if (poked) {
        c = poked;
        poked = 0;

        return c;
    }
    
    if (str_to_tokenize[position] == 0) {
        return 0;
    }

    return str_to_tokenize[position++];
}
```

Теперь мы можем вычитывать всю строку через get_char(), а где нужно — вернуть символ назад, просто записав его в переменную poked.

### Токенайзер

С точки зрения внешнего наблюдателя токенайзер будет представлять собой три вещи: enum с видами токенов, функцию get_token(), возвращающую тип токена, и переменную, хранящую текущий токен в виде строки (для идентификаторов и строк).

Для работы компилятора нам совершенно не интересны символы-разделители (пробелы, табуляции, переводы строк) и комментарии, поэтому их сразу будем отбрасывать:

```c
char is_space(char c) {
    return c == ' ' || c == '\t' || c == 13 || c == 10;
}

void skip_spaces() {
    char c;

    while(1) {
        c = get_char();
        if (!is_space(c)) {
            poked = c;
            return;
        } 
    }
}
```

Здесь нам пригодится возможность вернуть символ назад: если мы вычитали не разделитель, мы просто записываем его в poked, и остальной код этого не заметит.

К счастью, язык BSimple не использует декораторы через комментарии или что-то подобное, поэтому комментарии можно пропускать ещё на этапе токенизации. Для обозначения комментариев используется символ `#`. Как только мы его встречаем, вычитываем все символы до ближайшего перевода строки, игнорируя их. После этого снова пропускаем пробелы и проверяем, не начинается ли следующий комментарий, ведь их может быть сколько угодно перед первым значимым токеном.

Разбор токена представляет собой развилку, которую определяет его первый символ:

* Если первый символ — число, пробуем считать числовую константу.
* Если первый символ — буква, пробуем считать идентификатор.
* Если первый символ — специальный символ, разбираем кейсы, связанные с ним.

#### Разбор числа

Самый простой вариант: читаем байты, пока они являются цифрами. Как только встречаем нецифровой символ, завершаем строку `current_token` нулем, а последний считанный байт сохраняем в poked, чтобы следующее получение токена обработало этот символ.

#### Разбор идентификатора

Чуть более сложный случай. Первый символ мы уже сохранили в `current_token`, дальше проверяем следующие символы: они могут быть либо буквами, либо цифрами.

#### Разбор специальных символов

Этот случай устроен ещё проще. Чаще всего токены из специальных символов состоят из одного (+, -, *) или двух символов (>=, <=, ==). В случае несовпадения второго символа мы просто возвращаем его назад через poked.

### Пример токенайзера

В результате должен получиться небольшой токенайзер, который умеет разбирать минимально необходимые выражения на токены.

Демонстрационный вариант приведён ниже:

```c
#include <stdio.h>
#include <stdlib.h>

#define MAX_TOKEN_SIZE  32

char str_to_tokenize[] = " x=10 >= 5 <= 6 == 1+2+3>10<100*10/455+(a+b+c)";

char current_token[MAX_TOKEN_SIZE];

int position = 0;
char poked = 0;

enum  {
    Unknown,
    Id,
    Number,
    
    EOS, // ;

    Comma, // ,

    LP, // (
    RP, // )

    Begin, // {
    End,   // }

    LS,    // [
    RS,    // ]

    Sum,
    Dec,
    Mul,
    Div,
    Mod,
    And,
    Or,
    Xor,
    Greater,
    Less,
    Eq,
    GE,
    LE,
    Assign
};

char get_char() {
    char c;

    if (poked) {
        c = poked;
        poked = 0;

        return c;
    }
    
    if (str_to_tokenize[position] == 0) {
        return 0;
    }

    return str_to_tokenize[position++];
}

char is_alpha(char c) {
    return c >= 'a' && c <='z' || c >='A' && c <='Z';
}

char is_digit(char c) {
    return c >= '0' && c <= '9';
}

char is_space(char c) {
    return c == ' ' || c == '\t' || c == 13 || c == 10;
}

char is_symbol(char c) {
    return c == '+' || c == '-' || c == '*' || c == '&' || 
           c == '|' || c == '>' || c == '<' || c == '=' || 
           c == '%' || c == '/' || c == '(' || c == ')' ||
           c == '{' || c == '}' || c == '[' || c == ']' ||
           c == ',' || c == ';' || c == ':'
           ;
}

void skip_spaces() {
    char c;

    while(1) {
        c = get_char();
        if (!is_space(c)) {
            poked = c;
            return;
        } 
    }
}

void get_id() {
    int pos = 0;
    char c;

    while(1) {
        c = get_char();
        if (is_alpha(c) || is_digit(c)) {
            current_token[pos++] = c;
        } else {
            current_token[pos] = 0;
            poked = c;
            return;
        }
    }
}

void get_num() {
    int pos = 0;
    char c;

    while(1) {
        c = get_char();
        if (is_digit(c)) {
            current_token[pos++] = c;
        } else {
            current_token[pos] = 0;
            poked = c;
            return;
        }
    }
}

char process_symbols() {
    char c, tmp;

    c = get_char();
    switch (c)
    {
    case '/': return Div;
    case '*': return Mul;
    case '+': return Sum;
    case '-': return Dec;
    case '%': return Mod;
    case '(': return LP;
    case ')': return RP;
    case ',': return Comma;
    case ';': return EOS;
    case '>': 
        poked = get_char();
        if (poked == '=') {
            poked = 0;
            return GE;
        }
        return Greater;

    case '<': 
        poked = get_char();
        if (poked == '=') {
            poked = 0;
            return LE;
        }
        return Less;
    
    case '=':
        poked = get_char();
        if (poked == '=') {
            poked = 0;
            return Eq;
        }
        return Assign;

    default:
        return Unknown;
    }
}

char get_token() {
    char c;
    
    current_token[0] = 0;
checks:
    skip_spaces();
    c = get_char();

    if (c == '#') {
        while (c != 13 && c != 10) {
            c = get_char();
        }
        goto checks;
    }

    // Starting from symbols - special cases
    if (is_symbol(c)) {
        poked = c;

        return process_symbols();
    }

    // Starting from Alpha - identity
    if (is_alpha(c)) {
        poked = c;

        get_id();
        return Id;
    } 
    
    // Starting from digit - numberic
    if (is_digit(c)) {
        poked = c;

        get_num();
        return Number;
    }

    return Unknown;
}

void debug_token(char type) {
    switch (type)
    {
    case Id:
        printf("Id");
        break;
    
    case Number:
        printf("Num");
        break;
    
    case EOS:
        printf(";");
        return;

    case Comma:     printf("Comma"); return;
    case LP:        printf("("); return; 
    case RP:        printf(")"); return; 
    case Begin:     printf(" Begin of block "); return; 
    case End:       printf(" End of block "); return;
    case LS:        printf("[ "); return;
    case RS:        printf("] "); return;
    case Sum:       printf("add "); return;
    case Dec:       printf("sub "); return;
    case Mul:       printf("mul "); return;
    case Div:       printf("div "); return;
    case Mod:       printf(" mod "); return;
    case And:       printf("Logical And "); return;
    case Or:        printf("Logical Or "); return;
    case Xor:       printf("Logical Xor "); return;
    case Greater:   printf("Greater "); return;
    case Less:      printf("Less "); return;
    case Eq:        printf("Equals "); return;
    case GE:        printf("Greater Or Equal "); return;
    case LE:        printf("Less Or Equal "); return;
    case Assign:    printf("Assign "); return;
    
    default:
        printf("Unknown type: ");
        break;
    }

    printf("(%s) ", current_token);
}

int main() {
    char t;
    t = get_token(); 
    while (t != Unknown) {
        debug_token(t);
        t = get_token();
    }

    return 0;
}
```

Этот код обеспечивает базовую разметку исходной строки на токены.