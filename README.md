
## 一. block 最终继承自 NSObject

随便写一个 block, 看其父类.

```objc
void(^testBlock1)(void) = ^{
     NSLog(@"Hello World!");
};
```

打印之后,看其父类:

```lldb
// 打印结果: __NSGlobalBlock__
NSLog(@"%@",[testBlock1 class]);

// 打印结果: __NSGlobalBlock
NSLog(@"%@",[[testBlock1 class] superclass]);

// 打印结果: NSBlock
NSLog(@"%@",[[[testBlock1 class] superclass] superclass]);

// 打印结果: NSObject
NSLog(@"%@",[[[[testBlock1 class] superclass] superclass] superclass]);
```

## 二. block 的类型

> 总结:
> 1. 没有访问`auto`变量的block, 其类型为`__NSGlobalBlock__`
> 2. 访问了 `auto` 变量的 block, 其类型为`__NSStackBlock__`
> 3. `__NSStackBlock__`类型的 block 调用`copy`,就会变为`__NSMallocBlock__`类型
> 4.`__NSGlobalBlock__`类型的 block 调用`copy`,还是`__NSGlobalBlock__`类型,什么也不做.
> 5.`__NSMallocBlock__`类型的 block 调用 copy, 引用计数加1.还是`__NSMallocBlock__`类型.

block 有`3种` 类型,我们可以通过调用其`class方法`或者`isa指针`去查看具体类型.其最终都是继承自 NSBlock 的

- 类型1: `__NSGlobalBlock__`
- 类型2: `__NSStackBlock__`
- 类型3: `__NSMallocBlock__`

写三个 block, 调用其 class 方法,查看其类型:

```objc
void test2() {
    
    void(^testBlock1)(void) = ^{
        NSLog(@"testBlock1");
    };
    
    int a = 10;
    void(^testBlock2)(void) = ^{
        NSLog(@"testBlock2---a = %d",a);
    };
    
    NSLog(@"\ntestBlock1Class = %@\ntest2BlockClass = %@\nlastBlockClass = %@\n",[testBlock1 class], [testBlock2 class], [^{
        NSLog(@"%d",a);
    } class]);
    
}

// 打印结果分别为:
testBlock1Class = __NSGlobalBlock__
test2BlockClass = __NSMallocBlock__
lastBlockClass = __NSStackBlock__
```

上面的代码编译成`c++`代码后,我们可能会看到每个 block 的 isa 指针指向的可能都是`_NSConcreteStackBlock`这个类型,但是我们最终结果要以 runtime 打印的为准.

### 2.1 block 的3种类型在内存中的分配

![内存分配](https://lh3.googleusercontent.com/kB3iPEIe_xJhbB2qqHdHaB9v34HSLbphjPgKtS5qVInr4KhWIAaymkw3AuE2JB23qxa-EORw0j-RisnUXlF8U48Yi_vT8M9CX-QvC9bFBd0yWFlbMl83WoOK6o7AClG2X2Z1X5xjLv54IM_qfaEbC5MeYRfJ9aWvqJocsUcJN_hd0ZvQUUVwSUxmh5ifzLmXJ3jnbNsjOI-y6zS7K21g7j4hAI9n3zyd_LIBukhrRdYpGpTQIdKwRTzbBEnkZ8UU-QSD6dF_tHvitIngs6PSPI5dU-s0iEAcmN7scO9nqQoqcomn4b_WiqFjp00BucKbF5U1xm0fr-_jpQ97-on7cPoxDLMl4BE4-8coofCo2tslcxJRHZIoPjdrnJTifdLjepFkaWNps4paaPKja5OrLvEeOT5uDZJ31hST62_7N9KSoY-SMXwt1W4gUqlQY_FnXIN5pKP7WjDdShU7m_mpcYKCLivh_Fdv-l1n94ya1d7_AU6LPppwsDXWBHHNEvmDZljDzJER9JSuuLG_MuokKlQRz48LA2di2aPH9O-xPUL7pbKbm0fQv8li3XdA_Sj6jmYEUdl2iNi-mNVlCJZjwWo5FL_LoiFRbvrhYL7YOGEIzPxTBsIzB0QiuQqkCH8=w1652-h1288-no)

- `.text 区` (内存低地址)
    - 代码段,存放我们编写的代码 
- `.data 区`
    - 数据段,一般放些全局变量
- `堆`
    - 放一些动态分配的内存的,如 alloc 
- `栈` (高地址)
    - 放一些局部变量 

### 2.2. `__NSGlobalBlock__` 类型.

> 没有访问 `auto` 变量的block, 都是`__NSGlobalBlock__` 类型.
> `__NSGlobalBlock__`类型的 block 存在`内存中的-->数据区域`

- 第 1 种,`访问 static 变量的.`

```objc
// 打印结果: __NSGlobalBlock__
void test3() {    
    static int a = 10;
    void(^test3Block)(void) = ^{
        NSLog(@"%d",a);
    };
    NSLog(@"%@",[test3Block class]);
}
```

- 第 2 种,`访问全局变量的`

```objc
// 打印结果: __NSGlobalBlock__
int b = 20;

void test3() {
    static int a = 10;
    void(^test3Block)(void) = ^{
        NSLog(@"%d",b);
    };
    NSLog(@"%@",[test3Block class]);
}
```

### 2.3 `__NSStackBlock__` 类型

> 注意: 这里需要把`ARC`功能关闭掉,否则`ARC`会对这个做些处理,使我们打印出来的类型发生变化.
> `__NSStackBlock__`类型的 block 存在`内存中的栈区域`

当 block 访问`auto`变量的时候, block 的类型是`__NSStackBlock__`类型.如果在 ARC 环境下,打印结果: `__NSMallocBlock__`

```objc
// 打印结果: __NSStackBlock__
void test3() {
    static int a = 10;
    int c = 20;
    void(^test3Block)(void) = ^{
        NSLog(@"%d",c);
    };
    NSLog(@"%@",[test3Block class]);
}
```

- `__NSStackBlock__`类型的 block 保存在`栈`上.那么当作用域结束后,就会自动销毁.
- 当执行如下操作时,block 内捕获的 a 值可能会错乱:
    - 因为是存在栈上的 block. 执行完 test5()之后,自动销毁了.
    - 再次调用 block, 因为之前已经销毁,那么其内部捕获的值可能就会发生错乱.

```objc
// 打印结果 a = -272632440
void(^test5Block)(void);
void test5() {
    int a = 10;
    test5Block = ^{
        NSLog(@"a = %d",a);
    };
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {        
        test5();
        
        test5Block();
    }
    return 0;
}
```

- 所以,如果想让栈上的 block 不自动销毁,那么只要对它执行`copy`操作,将其复制到`堆`上.就可以,同时该 block 的类型就会变为`__NSMallocBlock__`.见下面例子.

### 2.4 `__NSMallocBlock__` 类型

> `__NSMallocBlock__`类型的 block 存在`内存中的堆上`

对`__NSStackBlock__`类型的`block`进行一次`copy`操作,就会将其从`栈`复制到`堆`上, 其copy 方法返回的 block 的类型就是 `__NSMallocBlock__`.

```objc
// MRC 环境下.
// 执行 copy 操作,返回的 block 类型为 __NSMallocBlock__
void(^test4Block)(void);
void test4 () {
    int a = 30;
//    void(^test4Block)(void) = ^{
//        NSLog(@"a = %d",a);
//    };
    test4Block = [^{
        NSLog(@"a = %d", a);
    } copy];
    
    NSLog(@"%@",[test4Block class]);
}
```

## 三. block 的 copy

在 `ARC` 环境下,编译器在如下几种情况下,`会自动将栈上的 block 复制到堆上.`(为 block 保命,防止 block 自动销毁,从而使其内部值发生错乱)

- block 作为函数返回值的时候.
- block 被强指针引用的时候(赋值给__strong 指针)
- block 作为 Cocoa API中方法名含有`usingBlock`的参数时候
- block 作为 GCD 的方法参数时候.

所以在`ARC`下,我们声明属性时,如下两种写法都是可以的,都会讲 block 复制到堆上.

```objc
@property (nonatomic, strong) void(^block)(void);

// 建议这么写,使用 copy, 与 MRC 环境下保持一致
@property (nonatomic, copy) void(^block)(void);
```

但是在`MRC`环境下,要写成`copy`

```objc
@property (nonatomic, copy) void(^block)(void);
```

## 四.对象类型的 auto 变量

### 4.1 block 内部会捕获 TYPerson *person,只要 block 存在, TYPerson 就不会被提前释放掉

```objc
// 1. ARC 环境下,在 `NSLog(@"-");`处打断点, TYPerson 此时还没有被释放,因为 block 还在, block 持有它
// 2. ARC 环境下,栈空间的 block 如果被强引用着,它默认会执行copy 操作.保命
typedef void(^testBlock)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        testBlock block;
        
        {
            TYPerson *person = [[TYPerson alloc] init];
            person.age = 30;
            
            block = ^{
                NSLog(@"%d",person.age);
            };
             
        }
    
        NSLog(@"-");
        
    }
    return 0;
}
```

同样的代码,在`MRC`环境下,情况不同:

```objc
// MRC 环境下
// 在 NSLog(@"-") 处打断点,见到 TYPerson 被释放掉了
typedef void(^testBlock)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        testBlock block;
        
        {
            TYPerson *person = [[TYPerson alloc] init];
            person.age = 30;
            
            block = ^{
                NSLog(@"%d",person.age);
            };
             
        }
    
        NSLog(@"-");
        
    }
    return 0;
}
```

- 上面的代码在 `MRC` 环境下,在 `NSLog(@"-")` 处打断点, TYPerson 会被释放掉.
- 因为在 `MRC` 环境下, 该 `block`因为访问了 `auto 变量`,所以这个 block 的类型是`__NSStackBlock__`,存在于`栈空间`.所以作用域结束后, block 销毁. TYPerson 也随之销毁.

但是在`MRC`环境下,上述代码的 block 执行一次`copy`操作,如下:

```objc
typedef void(^testBlock)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        testBlock block;
        
        {
            TYPerson *person = [[TYPerson alloc] init];
            person.age = 30;
            
            block = [^{
                NSLog(@"%d",person.age);
            } copy];
             
            [person release];
        }
    
        NSLog(@"-");
        
    }
    return 0;
}
```

- 执行`copy`操作,将栈空间的 block 复制一份到堆上,那么 block 类型变为`__NSMallocBlock__`,作用域结束后 block 不会被释放掉.
- 同时它会对 TYPerson 进行一次 retain 操作.使 TYPerson 不会被销毁


### 4.2 __weak 和 __strong 修饰时,栈上 block 和 堆上的 block 的不同.

如下代码:

- 在`NSLog(@"-")` 处打断点的话,此时 TYPerson 已经被释放掉了.

```objc
typedef void(^testBlock)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        testBlock block;
        
        {
            TYPerson *person = [[TYPerson alloc] init];
            person.age = 30;
            
            __weak TYPerson *weakPerson = person;
            block = ^{
                NSLog(@"%d",weakPerson.age);
            };

        }
    
        NSLog(@"-");
        
    }
    return 0;
}
```

上述代码编译成 c++ 文件:

- 如果像之前 `xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m` 这个命令会报错:

```linux
 error: 
      cannot create __weak reference because the current deployment target does
      not support weak references
            __attribute__((objc_ownership(weak))) TYPerson *weakPerson = person;
                           ^
1 error generated.
```

- 上面错误的原因是因为 `weak` 弱引用这种技术是需要运行时 runtime 支持的,像上面那种静态的编译时不行的.需要执行如下命令:

```linux
xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc -fobjc-arc -fobjc-runtime=ios-8.0.0 main.m
```

编译成 c++ 文件后发现,捕获进来的 TYPerson, 类型为`TYPerson *__weak weakPerson;`

```c++
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  TYPerson *__weak weakPerson;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, TYPerson *__weak _weakPerson, int flags=0) : weakPerson(_weakPerson) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```

- 上面的如果将`__weak` 换成 `__strong`. 那么捕获进去的就是`TYPerson *__strong person`.
- 但是无论是`__weak`还是`__strong`,`在 ARC 环境下,只要 block 在栈空间,而且没有被强引用,无论写__ weak 还是__ strong, 那么它都不会对外面的 TYPerson 进行强引用.`
- 因为 block 在栈上,会随时被释放掉,所以它不会对别人进行强引用.
- 如下就是 ARC 环境下, block 没有被强引用,在栈上

```objc
typedef void(^testBlock)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        testBlock block;
        
        {
            TYPerson *person = [[TYPerson alloc] init];
            person.age = 30;
            
            __weak TYPerson *weakPerson = person;
            
            // 没有强引用 block. 无论上面是__weak 还是 __strong, 都不会对 TYPerson 强引用.
            ^{
                NSLog(@"%d",weakPerson.age);
            };

        }
    
        NSLog(@"-");
        
    }
    return 0;
}
```

**如果在 block 在堆上**

```objc
typedef void(^testBlock)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        testBlock block;
        
        {
            TYPerson *person = [[TYPerson alloc] init];
            person.age = 30;
            
            __weak TYPerson *weakPerson = person;
            //  ARC 环境下,block 被强引用着.自动执行 copy 操作,此时 block 在堆上.
            block = ^{
                NSLog(@"%d",weakPerson.age);
            };

        }
    
        NSLog(@"-");
        
    }
    return 0;
}
```

其中`__main_block_desc_0`这个结构当 `block在栈上和 block 在堆上,结果不同`.

```c++
// block 在堆上.
static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  
  // 这个指针指向 `__main_block_copy_0 这个函数`
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  
  // 这个指针指向 `__main_block_dispose_0` 这个函数
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};
```

- 当 block 进行一次 copy 操作的时候,它会自动调用`__main_block_copy_0` 这个函数.

```c++
static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {

// 这句会根据上面捕获进来的 TYPerson 类型,__weak 还是 __strong 来进行弱引用或强引用操作.
_Block_object_assign((void*)&dst->weakPerson, (void*)src->weakPerson, 3/*BLOCK_FIELD_IS_OBJECT*/);

}
```

- 而`__main_block_dispose_0`这个函数,当堆上的 block 被废弃时,会断开对 auto 变量的强引用,类似执行一次 release 操作,如果 auto 变量的引用计数为0,则释放

```c++
static void __main_block_dispose_0(struct __main_block_impl_0*src) {
    _Block_object_dispose((void*)src->weakPerson, 3/*BLOCK_FIELD_IS_OBJECT*/);
}
```

## 五. GCD 的 block

建立一个 iOS 项目,有一个`TYPerson`类.其中有个属性`age`.执行如下操作,看其释放时机.

### 5.1 情况一:

点击控制器的 view,会先打印 `age1 = 10`, 然后`立即`释放掉`TYPerson`.

```objc
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    TYPerson *person = [[TYPerson alloc] init];
    person.age = 10;
    NSLog(@"age1 = %d",person.age);
}
```

### 5.2 情况二:

person 对象被 GCD 的 block 持有.它会自动对 person 执行一次`copy`操作,强引用它,然后当 block 销毁时,断开强引用, person 引用计数为0,释放掉 person 对象.

- 所以下面的操作应该是先打印 `age1 = 10`.
- 然后过3秒之后,打印`age2 = 10`.与此同时, block 释放掉,从而 person 释放掉.

```objc
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    TYPerson *person = [[TYPerson alloc] init];
    person.age = 10;
    NSLog(@"age1 = %d",person.age);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"age2 = %d",person.age);
    });
    
}
```

### 5.3 情况三:

如下,使用`__weak` 弱引用 TYPerson 对象,那么 block 就不会对 person 对象产生强引用.所以在打印完`age1 = 10;`之后,立即释放掉 person 对象,然后过3秒中, block 释放掉,此时打印 age2 = 0; 因为之前 person 对象已经被释放掉了.

```objc
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    TYPerson *person = [[TYPerson alloc] init];
    person.age = 10;
    NSLog(@"age1 = %d",person.age);
    
    
    __weak TYPerson *weakPerson = person;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"age2 = %d",weakPerson.age);
    });
    
}
```

