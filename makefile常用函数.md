# Makefile函数

## 一、Makefile函数的调用语法

函数调用，很像变量的使用，也是以`“$”`来标识的，其语法如下：

`$(<function> <arguments>)` 或 `${<function> <arguments>}`

这里,

- function 就是函数名，make支持的函数不多。
- arguments 是参数,参数间以逗号 `,` 分隔; 而函数名和参数之间以`空格`分隔。

函数调用以“$”开头，以圆括号或花括号把函数名和参数括起。

## 二、字符串处理函数

### 2.1 `$(subst <from>,<to>,<text>)`

```BASH
#名称: subst
    字符串替换函数。
#功能:
    把字串<text>中的<from>字符串替换成<to>。
#返回:
    函数返回被替换过后的字符串。
#示例:
    $(subst ee,EE,feet on the street) 
    # 把feet on the street中的“ee”替换成“EE”，返回结果是“fEEt on the strEEt”
```

### 2.2 `$(patsubst <pattern>,<replacement>,<text>)`

```BASH
#名称:
    模式字符串替换函数——patsubst。
#功能:
    查找<text>中的单词（单词以“空格”、“Tab”或“回车”“换行”分隔）是否符合模式<pattern>，如果匹配的话，则以<replacement>替换。
    这里，<pattern>可以包括通配符“%”，表示任意长度的字串。如果 <replacement>中也包含“%”，那么，<replacement>中的这个“%”将是<pattern>中的那个“%”所代表的字串。（可以用“\”来转义，以“\%”来表示真实含义的“%”字符）
#返回:
    函数返回被替换过后的字符串。
#示例：
    $(patsubst %.c,%.o,x.c.c bar.c)
    把字串“x.c.c bar.c”符合模式[%.c]的单词替换成[%.o]，返回结果是“x.c.o bar.o”

#额外说明：
    这和我们前面“变量章节”说过的相关知识有点相似。如：

    “$(var:<pattern>=<replacement>)”
     相当于
    “$(patsubst <pattern>,<replacement>,$(var))”，

     而“$(var: <suffix>=<replacement>)”
     则相当于
     “$(patsubst %<suffix>,%<replacement>,$(var))”。

     例如有：objects = foo.o bar.o baz.o，
     那么，“$(objects:.o=.c)”和“$(patsubst %.o,%.c,$(objects))”是一样的。
```

### 2.3 `$(strip <string>)`

```BASH
#名称：
    去空格函数——strip。
#功能：
    去掉<string>字串中开头和结尾的空字符。
#返回：
    返回被去掉空格的字符串值。
#示例：
    $(strip a b c )
    把字串“a b c ”去到开头和结尾的空格，结果是“a b c”。
```

### 2.4 `$(findstring <find>,<in>)`

```BASH
#名称：
    查找字符串函数——findstring。
#功能：
    在字串<in>中查找<find>字串。
#返回：
    如果找到，那么返回<find>，否则返回空字符串。
#示例：
    $(findstring a,a b c)
    $(findstring a,b c)
    第一个函数返回“a”字符串，第二个返回“”字符串（空字符串）
```

### 2.5 `$(filter <pattern...>,<text>)`

```BASH
#名称：
    过滤函数——filter。
#功能：
    以<pattern>模式过滤<text>字符串中的单词,保留符合模式<pattern>的单词.可有多个模式.
#返回：
    返回符合模式<pattern>的字串。
#示例：
    sources := foo.c bar.c baz.s ugh.h
    foo: $(sources)
    cc $(filter %.c %.s,$(sources)) -o foo

    $(filter %.c %.s,$(sources))返回的值是“foo.c bar.c baz.s”。
```

### 2.6 `$(filter-out <pattern...>,<text>)`

```BASH
#名称：
    反过滤函数——filter-out。
#功能：
    以<pattern>模式过滤<text>字符串中的单词，去除符合模式<pattern>的单词。可以有多个模式。
#返回：
    返回不符合模式<pattern>的字串。
#示例：
    objects=main1.o foo.o main2.o bar.o
    mains=main1.o main2.o

    $(filter-out $(mains),$(objects)) 返回值是“foo.o bar.o”。
```

### 2.7 `$(sort <list>)`

```BASH
#名称：
    排序函数——sort。
#功能：
    给字符串<list>中的单词排序（升序）。
#返回：
    返回排序后的字符串。
#示例：
    $(sort foo bar lose)返回“bar foo lose” 。
#备注：
    sort函数会去掉<list>中相同的单词。
```

### 2.8 `$(word <n>,<text>)`

```BASH
#名称：
    取单词函数——word。
#功能：
    取字符串<text>中第<n>个单词。（从一开始）
#返回：
    返回字符串<text>中第<n>个单词。如果<n>比<text>中的单词数要大，那么返回空字符串。
#示例：
    $(word 2, foo bar baz)返回值是“bar”。
```

### 2.9 `$(wordlist <s>,<e>,<text>)`

```BASH
#名称：
    取单词串函数——wordlist。
#功能：
    从字符串<text>中取从<s>开始到<e>的单词串。<s>和<e>是一个数字。
#返回：
    返回字符串<text>中从<s>到<e>的单词字串。如果<s>比<text>中的单词数要大，那么返回空字符串。
    如果<e>大于<text>的单词数，那么返回从<s>开始，到<text>结束的单词串。
#示例：
    $(wordlist 2, 3, foo bar baz)返回值是“bar baz”。
```

### 2.10 `$(words <text>)`

```BASH
#名称：
    单词个数统计函数——words。
#功能：
    统计<text>中字符串中的单词个数。
#返回：
    返回<text>中的单词数。
#示例：
    $(words, foo bar baz)返回值是“3”。
#备注：
    如果我们要取<text>中最后的一个单词，我们可以这样：$(word $(words <text>),<text>)。
```

### 2.11 `$(firstword <text>)`

```BASH
#名称：
    首单词函数——firstword。
#功能：
    取字符串<text>中的第一个单词。
#返回：
    返回字符串<text>的第一个单词。
#示例：
    $(firstword foo bar)返回值是“foo”。
#备注：
    这个函数可以用word函数来实现：$(word 1,<text>)。
```

以上，是所有的字符串操作函数，如果搭配混合使用，可以完成比较复杂的功能。这里，举一个现实中应用的例子。
我们知道，make使用“VPATH”变量来指定“依赖文件”的搜索路径。于是，我们可以利用这个搜索路径来指定编译器对头文件的搜索路径参数CFLAGS，如：
`override CFLAGS += (patsubst (subst :, ,(VPATH)))`
如果我们的“(VPATH)”值是“src:../headers”，那么“`(patsubst(subst :, ,$(VPATH)))`”将返回“`-Isrc -I../headers`”，这正是cc或gcc搜索头文件路径的参数。

## 三、文件名操作函数

下面我们要介绍的函数主要是处理文件名的。每个函数的参数字符串都会被当做一个或是一系列的文件名来对待。

### 3.1 `$(dir <names...>)`

```bash
#名称：
    取目录函数——dir。
#功能：
    从文件名序列<names>中取出目录部分。目录部分是指最后一个反斜杠（“/”）之前的部分。
    如果没有反斜杠，那么返回“./”。
#返回：
    返回文件名序列<names>的目录部分。
#示例：
    $(dir src/foo.c hacks)返回值是“src/ ./”。
```

### 3.2 `$(notdir <names...>)`

```bash
#名称：
    取文件函数——notdir。
#功能：
    从文件名序列<names>中取出非目录部分。
    非目录部分是指最后一个反斜杠（“/”）之后的部分。
#返回：
    返回文件名序列<names>的非目录部分。
#示例：
    $(notdir src/foo.c hacks)返回值是“foo.c hacks”。
```

### 3.3 `$(suffix <names...>)`

```bash
#名称：
    取后缀函数——suffix。
#功能：
    从文件名序列<names>中取出各个文件名的后缀。
#返回：
    返回文件名序列<names>的后缀序列，如果文件没有后缀，则返回空字串。
#示例：
    $(suffix src/foo.c src-1.0/bar.c hacks)返回值是“.c .c”。
```

### 3.4 `$(basename <names...>)`

```bash
#名称：
    取前缀函数——basename。
#功能：
    从文件名序列<names>中取出各个文件名的前缀部分。
#返回：
    返回文件名序列<names>的前缀序列，如果文件没有前缀，则返回空字串。
#示例：
    $(basename src/foo.c src-1.0/bar.c hacks)返回值是“src/foo src-1.0/bar hacks”。
```

### 3.5 `$(addsuffix <suffix>,<names...>)`

```bash
#名称：
    加后缀函数——addsuffix。
#功能：
    把后缀<suffix>加到<names>中的每个单词后面。
#返回：
    返回加过后缀的文件名序列。
#示例：
    $(addsuffix .c,foo bar)返回值是“foo.c bar.c”。
```

### 3.6 `$(addprefix <prefix>,<names...>)`

```bash
#名称：
    加前缀函数——addprefix。
#功能：
    把前缀<prefix>加到<names>中的每个单词后面。
#返回：
    返回加过前缀的文件名序列。
#示例：
    $(addprefix src/,foo bar)返回值是“src/foo src/bar”。
```

### 3.7 `$(join <list1>,<list2>)`

```bash
#名称：
    连接函数——join。
#功能：
    把<list2>中的单词对应地加到<list1>的单词后面。
    如果<list1>的单词个数要比< list2>的多，那么，<list1>中的多出来的单词将保持原样。
    如果<list2>的单词个数要比< list1>多，那么，<list2>多出来的单词将被复制到<list2>中。
#返回：
    返回连接过后的字符串。
#示例：
    $(join aaa bbb , 111 222 333)返回值是“aaa111 bbb222 333”。
```

## 四、foreach 函数

foreach函数和别的函数非常的不一样。因为这个函数是用来做循环用的。它的语法是：

`$(foreach ,,)`

这个函数的意思是，把参数中的单词逐一取出放到参数所指定的变量中，然后再执行所包含的表达式。
每一次会返回一个字符串，循环过程中，的所返回的每个字符串会以空格分隔，
最后当整个循环结束时，由返回的每个字符串所组成的整个字符串（以空格分隔）将会是foreach函数的返回值。

所以，最好是一个变量名，可以是一个表达式，而中一般会使用这个参数来依次枚举中的单词。举个例子：

```bash
names := a b c d
files := $(foreach n,$(names),$(n).o)
```

上面的例子中，(name)中的单词会被挨个取出，并存到变量“n”中，“
(n).o”每次根据“(n)”计算出一个值，这些值以空格分隔，最后作为foreach函数的返回，所以，
(files)的值是“a.o b.o c.o d.o”。

*注意*，foreach中的参数是一个临时的局部变量，foreach函数执行完后，参数的变量将不在作用，其作用域只在foreach函数当中。

## 五、call函数

call函数是唯一一个可以用来创建新的参数化的函数。你可以写一个非常复杂的表达式，这个表达式中，你可以定义许多参数，然后你可以用call函数来向这个表达式传递参数。其语法是：

```TEXT
$(call ,,,...)
```

当make执行这个函数时，参数中的变量，如 `$(1)`，`$(2)`，`$(3)` 等，会被参数依次取代。而的返回值就是call函数的返回值。例如：

```TEXT
reverse =  $(1) $(2)
foo = $(call reverse,a,b)
```

那么，foo的值就是“a b”。当然，参数的次序是可以自定义的，不一定是顺序的，如：

```TEXT
reverse =  $(2) $(1)
foo = $(call reverse,a,b)
```

此时的foo的值就是“b a”。

## 六、Makefile中的wildcard用法

> 在Makefile规则中，通配符会被自动展开。但在变量的定义和函数引用时，通配符将失效。

这种情况下如果需要通配符有效，就需要使用函数“wildcard”，它的用法是：

`(wildcardPATTERN…)`

在Makefile中，它被展开为已经存在的、使用空格分开的、匹配此模式的所有文件列表。如果不存在任何符合此模式的文件，函数会忽略模式字符并返回空。

需要注意的是：这种情况下规则中通配符的展开和上一小节匹配通配符的区别。一般我们可以使用“(wildcard *.c)”来获取工作目录下的所有的.c文件列表。

复杂一些用法；可以使用“(patsubst (wildcard *.c))”，首先使用“wildcard”函数获取工作目录下的.c文件列表；之后将列表中所有文件名的后缀.c替换为.o。这样我们就可以得到在当前目录可生成的.o文件列表。因此在一个目录下可以使用如下内容的Makefile来将工作目录下的所有的.c文件进行编译并最后连接成为一个可执行文件：

```bash
#sample Makefile

objects := (patsubst(wildcard *.c))
foo : (objects)cc−ofoo
(objects)
```

这里我们使用了make的隐含规则来编译.c的源文件。对变量的赋值也用到了一个特殊的符号（:=）。

1、wildcard : 扩展通配符
2、notdir ： 去除路径
3、patsubst ：替换通配符

### eval 函数功能

函数“eval”是一个比较特殊的函数。使用它我们可以在我们的Makefile中构造一个可变的规则结构关系（依赖关系链），其中可以使用其它变量和函数。函数“eval”对它的参数进行展开，展开的结果作为Makefile的一部分，make可以对展开内容进行语法解析。展开的结果可以包含一个新变量、目标、隐含规则或者是明确规则等。也就是说此函数的功能主要是：根据其参数的关系、结构，对它们进行替换展开。
返回值：函数“eval”的返回值时空，也可以说没有返回值。
函数说明：“eval”函数执行时会对它的参数进行两次展开。
第一次展开过程是由函数本身完成的，
第二次是函数展开后的结果被作为Makefile内容时由make解析时展开的。
明确这一点对于使用“eval”函数非常重要。
在理解了函数“eval”二次展开的过程后。
实际使用时，当函数的展开结果中存在引用（格式为：(x)）时，那么在函数的参数中应该使用“
”来代替“

”。
因为这一点，所以通常它的参数中会使用函数“value”来取一个变量的文本值。

“It’s important to realize that the eval argument is expanded twice; first by the eval function, then the results of that expansion are expanded again when they are parsed as makefile syntax.”
Take the example from GNU Make for example:

PROGRAMS    = server client

server_OBJS = server.o server_priv.o server_access.o
server_LIBS = priv protocol

client_OBJS = client.o client_api.o client_mem.o
client_LIBS = protocol

# Everything after this is generic

.PHONY: all
all: $(PROGRAMS)

define PROGRAM_template =
$(1): $$($(1)_OBJS) $$($(1)_LIBS:%=-l%)
    ALL_OBJS   += $$($(1)_OBJS)
endef

$(foreach prog,$(PROGRAMS),$(eval $(call PROGRAM_template,$(prog))))

$(PROGRAMS):
    $(LINK.o) $^ $(LDLIBS) -o $@

clean:
    rm -f $(ALL_OBJS) $(PROGRAMS)
