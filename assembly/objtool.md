```sh
gcc -Og -S test.c -o a.s
```

```sh
as a.s -o a.o
```

```sh
objdump -d a.o
```

```sh
objtool --orc a.o
```

```sh
objtool --dump a.o
```
