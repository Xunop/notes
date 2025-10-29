# TypeScript 函数定义

写 ts 写得比较少，也不是持续的写，外加上 LLM 的帮助，对于 ts 的语法是有些怠惰了，这里整理下 ts 的函数定义。
> 加上自己对于各种东西都是够用就行，所以...

## 基础函数和常量

**方式一：函数声明**

```TypeScript

function add(a: number, b: number): number {
  return a + b;
}
```

最易懂的方式，函数名是 `add`。

**方式二：函数表达式 / 箭头函数**

```TypeScript

const add = (a: number, b: number): number => {
  return a + b;
};
```

在这里，定义了一个常量 `add`。它的值是一个匿名函数（这里是箭头函数）。函数本身没有名字，是 `add` 这个常量指向了它。这里稍微看一下也没有阅读障碍。

**方式三：对象方法**

```TypeScript
const calculator = {
  add(x: number, y: number): number {
    return x + y;
  },
  subtract(x: number, y: number): number {
    return x - y;
  }
};
```

省略了方式一的 `function` 关键字，也没有阅读障碍。

**方法四：函数类型**

```TypeScript
// 定义一个函数类型
type GreetFunc = (name: string) => string;

// 应用这个类型
const greet: GreetFunc = (name) => {
  return `Hello, ${name}`;
};
```

## 给四种函数加上泛型

现在，给这四种函数加上泛型 `<T>`。

**方式一：函数声明 + 泛型**

对于函数声明，泛型 `<T>` 紧跟在函数名后面。

```TypeScript

function createArray<T>(item: T): T[] {
  return [item];
}
```

这个语法很直观，`createArray` 是一个泛型函数。

**方式二：箭头函数 + 泛型**

对于一个被赋值给常量的箭头函数，它的“函数”部分其实是从 `=` 号后面才开始的。

```TypeScript

// 分解来看
const createEntity =      // 这是在定义一个常量
  <T extends ...>(...) => { ... } // 这才是一个完整的、匿名的、带有泛型的箭头函数
```

所以，泛型 `<T extends ...>` 必须作为这个箭头函数定义的一部分，放在参数列表 `(...)` 的前面。

正确的语法：

```TypeScript

// const [变量名] = [泛型定义][参数列表] => [函数体]
export const createEntity = <T extends Record<string, any>>(
  data: Omit<T, 'id' | 'createdAt' | 'updatedAt'>
): T & { id: string; createdAt: Date; updatedAt: Date } => {
  // ...
};
```
> 对我来说，这种写法已经开始让我迷糊了。

如果试图把泛型放在常量名后面，就会出现语法错误：

```TypeScript

// ❌ 错误的语法
export const createEntity<T extends ...> = (data: ...) => { ... };
// SyntaxError: '=' expected.
// 因为 TypeScript 会认为 createEntity<...> 是一个类型或特殊语法，而不是变量名。
```

**方式三：对象方法 + 泛型**

泛型语法：泛型 `<T>` 放在方法名之后，参数列表之前。

```TypeScript

const collection = {
  items: [],
  add<T>(item: T): T[] {
    this.items.push(item);
    return this.items;
  }
```

**方法四：函数类型 + 泛型**

```TypeScript
// 定义一个泛型函数类型
type IdentityFunc<T> = (arg: T) => T;

// 应用这个类型
const identity: IdentityFunc<number> = (arg) => {
  return arg;
};
```

泛型的位置都是在参数列表前。

其实 TypeScript 的文档肯定很清晰且详细的解释并说明了这些，但是真的够用就行了，遇到不会的再看吧。

> https://www.typescriptlang.org/docs/handbook/2/functions.html
