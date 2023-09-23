```
.text+2f1d03: sp:sp+80 bp:prevsp-48 type:call end:0
```

```
PREV_RSP = RSP + 80
         = 0xffffa764404a3bb8 + 80 = 0xffffa764404a3c08
```

PREV_RIP = PREV_RSP - 8

```
PREV_RIP = *(PREV_RSP - 8)
         = *(0xffffa764404a3c08 - 8)
         = *(0xffffa764404a3c00) = 0xffffffffae2e07d2
```

PREV_RBP = PREV_RSP - 48

```
PREV_RBP = *(PREV_RSP - 48)
         = *(0xffffa764404a3c08 - 48)
         = *(0xffffa764404a3c08 - 48)
         = *(0xffffa764404a3bd8) = 0x0000000000000000
```
