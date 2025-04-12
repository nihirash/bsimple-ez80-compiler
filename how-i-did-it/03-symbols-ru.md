# BSimple. Записки сумасшедшего, или как я решил написать компилятор.

## Таблица символов

Вместе с задачей токенизации задача хранения текущей таблицы символов — одна из первоочередных задач при построении компилятора.

Таблица символов решает задачу определения ключевых слов, глобальных переменных, функций, аргументов функции и локальных переменных.

Тут и дальше описание некоторых участков кода может идти или в упрощенном, или в сокрашенном виде, но основная суть будет сохранена. 

Для каждого символа нам необходимо знать его тип (ключевое слово, глобальный идентификатор, переменная на стеке и т.д.), смещение (либо относительно стека, либо в перечислении типа ключевых слов; может быть опущено для глобальных идентификаторов, так как компиляция идёт в ассемблер), а также строку с именем идентификатора.

Полученная структура выходит очень простой. Если язык программирования не поддерживает структуры, её легко сэмулировать даже на обычном массиве.

```c
typedef struct {
    char type;
    int offset;
    char name[MAX_TOKEN_SIZE];
} Symbol;
```

Первое, что необходимо сделать с таблицей символов, — это наполнить её ключевыми словами языка программирования (которые не должны быть переопределены ничем).

Для упрощения реализации сделаем общий инструмент регистрации символа вне зависимости от его типа — функция будет принимать имя символа, его тип, а также смещение в таблице символов:

```c
enum {
    Keyword,
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
    K_Import,
    K_Bin,
    K_For,
    K_Repeat,
    K_Until,
    K_Include,
};

Symbol symbols[SYM_TABLE_SIZE];

/// @brief Register symbol in table
/// @param s    string with keywords
/// @param k    keyword_id/offset
/// @param t    type
void register_symbol(char *s, int k, char t)
{
    if (symbol_table_pos + 1 >= SYM_TABLE_SIZE) {
        error(SYMBOLS_TABLE_OVERLOAD);
    }

    strcpy(symbols[symbol_table_pos].name, s);
    symbols[symbol_table_pos].type = t;
    symbols[symbol_table_pos].offset = k;

    symbol_table_pos++;
}

void init_keyword_table()
{
    register_keyword("while", K_While);
    register_keyword("if", K_If);
    register_keyword("var", K_Var);
    register_keyword("return", K_Return);
    register_keyword("for", K_For);
}
```

Для отладки можно добавить функцию вывода текущей таблицы символов — при дальнейшей разработке она может сильно помочь:

```c
void dump_symbols()
{
    printf("\r\nSymbols table (size %i): \r\n", symbol_table_pos);

    for (int i = symbol_table_pos - 1; i != -1; i--) {
        switch (symbols[i].type) {
        case Keyword:
            printf("Keyword: ");
            break;
        case Glob:
            printf("Global identifier: ");
            break;
        case Parameter:
            printf("Argument (offset %i): ", symbols[i].offset);
            break;
        case Auto:
            printf("Stack variable (offset %i): ", symbols[i].offset);
            break;
        default:
            printf("Unknown symbol: ");
            break;
        }
        puts(symbols[i].name);
    }
}
```

Таким образом, на момент запуска компилятора мы уже будем иметь некую таблицу символов, которая будет выглядеть примерно так:

```
Symbols table (size 5):
Keyword: for
Keyword: return
Keyword: var
Keyword: if
Keyword: while
```

Для упрощения разработки критически важно иметь возможность получать символ по его имени, а также проверять, является ли символ ключевым словом (чтобы запретить их переопределение).

Здесь кроется один маленький нюанс: при поиске ключевых слов мы будем идти не с начала списка, а с конца. Таким образом, мы реализуем перекрытие локальным пространством имён глобального (например, мы сможем назвать локальную переменную так же, как глобальную переменную или даже как глобальную функцию).

Функция поиска символа в таблице будет выглядеть следующим образом (а проверку на ключевое слово можно реализовать, используя результат этой функции):

```c
Symbol *lookup_symbol(char *s)
{
    for (int i = symbol_table_pos - 1; i != -1; i--)
        if (!strcmp(s, symbols[i].name))
            return &symbols[i];

    return NULL;
}
```

Итак, мы можем считать из файла или строки токен, проверить его в таблице символов или зарегистрировать его в ней — можно приступать к разбору текста программы.

