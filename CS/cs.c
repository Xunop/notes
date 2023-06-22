#include <stdio.h>
[[gnu::noinline]] void qux() {
  void **fp = __builtin_frame_address(0);
  for (;;) {
    printf("%p\n", fp);
    void **next_fp = *fp;
    if (next_fp <= fp)
      break;
    fp = next_fp;
  }
}
[[gnu::noinline]] void bar() { qux(); }
[[gnu::noinline]] void foo() { bar(); }
int main() { foo(); }
