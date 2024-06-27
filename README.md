# Co Language

### 关于
Co Language 是一种轻量级脚本语言，基于 Lua 语言开发。Co Lanaguage 是由 `Cheese` 设计开发的一个脚本语言。Co Language 可以用作程序开发。虽然语法很不友好，但由于偏向底层，所以执行效率极高。

## 快速上手
### 代码注释
以 `//` 开头的语句是注释，被注释的代码在运行时将被忽略。  
在代码中使用注释可以增加代码的可读性。
``` TypeScript
// 定义 text 字符串
string text "Hello, World!"
// 输出 "Hello, World!"
echo text
```

### 变量类型
Co Language 中有 2 个基本类型分别为：`string` 和 `number`。
| **数据类型** | **描述**  | **对应数值**  |
| ------------ | --------- | ------------  |
| `null`       | 空值类型   | 0            |
| `number`     | 文本类型   | 1            |
| `string`     | 数字类型   | 2            |
| `function`   | 函数类型   | 3            |

### 字符串类型（string）
字符串(string)是由数字、字母、下划线组成的一串字符。  
在 Co Language 中，字符串是一种基本的数据类型，用于存储文本数据。  
Co Language 中的字符串可以包含任意字符，包括字母、数字、符号、空格以及其他特殊字符。  
Co Language 中字符串可以使用以下方式来表示：
``` TypeScript
// 创建字符串变量
const  str1 "Hello, World!"
// 或者是
string str2 "Hello, World!"
```
Co Language 支持以下转义字符：

| **转义字符** | **描述** |
| -------------| -------- |
| `\n`         | 换行符   |
| `\t`         | 制表符   |
| `\"`         | 双引号   |

### 数字类型（number）
Co Language 默认只有一种 `number` 类型 ，以下几种写法都被看作是 `number` 类型：
``` TypeScript
// 创建数字变量
const  a1  10
// 或者使用 number 函数定义
number a2  10
number a3 -10
```
### 类型转换
Co Language 支持变量类型之间的转换。例如：
``` TypeScript
// 创建一个数字变量 num，值为 10
number num 10
// 将数字变量 num 赋值给字符串变量 str
string str num
// 输出字符串变量 str
echo   str
```
Co Language 中的 `const、string` 和 `number` 虽然都是用于定义变量，但是它们之间存在一些区别，`const` 是根据值的类型定义变量，而 `string` 和 `number` 则是直接指定了变量的类型，如果值类型和变量类型不一致，会自动进行隐形类型转换。

### 基本语法
Co Language 内置了许多函数  
使用函数的基本语法：[函数名] (参数..)。例如：
``` TypeScript
// 创建一个变量 content，值为 "Hello, World!"
string content "Hello, World!"
// 调用 echo 函数输出 content 变量的内容
echo   content
```
## 内置函数
赋值：const [name] (value)  
值可以为变量、字符串和数字，变量类型会根据值的内容判断

赋值（但是指定类型为string）：string [name] (value)  
值可以为变量、字符串和数字，变量类型为字符串（会自动转换）

赋值（但是指定类型为number）：number [name] (value)  
值可以为变量、字符串和数字，变量类型为数字（会自动转换）

加法：add [name] (value..)  
计算变量加值的结果，然后赋值给变量。若其中有个参数不是数字类型，就会当做字符串拼接处理

减法：sub [name] (value..)  
计算变量逐个减去值的结果，然后赋值给变量。（参数必须为数字）

乘法：mul [name] (value..)  
计算变量逐个乘以值的结果，然后赋值给变量。（参数必须为数字）

除法：div [name] (value..)  
计算变量逐个除以值的结果，然后赋值给变量。（参数必须为数字）

判断：if-eq [name] [name]  
判断变量1与变量2是否相等

判断：if-ne [name] [name]  
判断变量1与变量2是否不相等

判断：if-lt [name] [name]  
判断变量1是否小于变量2

判断：if-le [name] [name]  
判断变量1是否小于等于变量2

判断：if-gt [name] [name]  
判断变量1是否大于变量2

判断：if-ge [name] [name]  
判断变量1是否大于等于变量2

输出：echo (value..)  
逐个输出参数列表的内容

局部函数：local-fun [name] (name..)  
定义局部函数，局部函数仅在当前作用域生效

局部变量：local-const [name] (value)  
定义局部变量，局部变量仅在当前作用域生效

函数：fun [name] (name..)  
定义函数

返回：return (value..)
使函数返回值

调用函数：invoke [name] (value..)  
调用名为 [name] 的函数，参数列表为 [value..]

结束：end  
结束代码块

输出：echo (value..)
逐个输出参数列表的内容

输入：input [name] (value)  
输入变量 [name]，提示输入内容为 (value)

捕捉错误：try  
尝试运行代码块，如果发生错误，会跳转到 catch 块

抛出错误：error (value)  
在当前作用域抛出错误，错误内容为 (value)

捕捉错误：catch [name]  
捕捉错误，错误内容保存在 [name]

标签：label [name]  
在当前作用域创建标签，标签名是 [name]

跳转：goto [name]  
跳转到名为 [name] 的标签

加载文本代码：load (value)  
加载文本代码，文本代码内容是 (value)

加载库：import (value)  
加载库，库名可以是文件名或者是 URL 地址

## Co Language 实现
### 函数的实现
函数实际上是以二维数组形式进行存储的，为了保证运行效率，存储函数的变量实际上存储的只是一个索引，通过索引来获取函数的代码。每一个数组的第一项是函数名，第二项是函数的参数列表，第三项是函数的代码。

### 作用域的实现
CoLanguage默认会有一个计数器来记录当前的作用域层数，初始值为0。  
当获取变量时，会以 `“计数器+变量名”` 来获取变量  
当遇到 `if`、`fun`、`try` 或 `catch` 等语句时，计数器加1  
当遇到 end 结束语句时，会开始回收以 “计数器值” 开头的变量，最后计数器减1  
遇到 return 结束语句时，会先把变量向上层作用域传递，然后再进行回收

### 关于多线程
Co Language 并不打算实现多线程。
