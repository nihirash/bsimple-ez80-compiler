changequote(`{{', `}}')# Learn BSimple in Y minutes

BSimple is the compiled language for eZ80 CPU(mostly for Agon computers) that can be executed on Agon Light/Console8 or your PC/Mac.

BSimple is mid-level programming language and compiles to assembly. All identifiers are case-sensitive - so `ID`, `Id` and `iD` are different identifiers.

All numbers are 24 bit long(and treated as signed numbers usually). 

Values placed in range −8,388,608 to 8,388,607(in decimal).

You can use also heximal values as long as decial prefix for hex values is `$`(for example `a = $7ffd;` is just the same as `a = 32765`).

```perl
sinclude({{examples/learn.bs}})
```

You can find this program in `examples` directory of compiler repository.