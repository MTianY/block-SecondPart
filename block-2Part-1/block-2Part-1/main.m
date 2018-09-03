//
//  main.m
//  block-2Part-1
//
//  Created by 马天野 on 2018/9/2.
//  Copyright © 2018年 Maty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYPerson.h"

void test1() {
    void(^testBlock1)(void) = ^{
        NSLog(@"Hello World!");
    };
    
    testBlock1();
    
    NSLog(@"%@",[testBlock1 class]);
    NSLog(@"%@",[[testBlock1 class] superclass]);
    NSLog(@"%@",[[[testBlock1 class] superclass] superclass]);
    NSLog(@"%@",[[[[testBlock1 class] superclass] superclass] superclass]);
}

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

int b = 20;

void test3() {
    static int a = 10;
    int c = 20;
    void(^test3Block)(void) = ^{
        NSLog(@"%d",c);
    };
    NSLog(@"%@",[test3Block class]);
}

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

void(^test5Block)(void);
void test5() {
    int a = 10;
    test5Block = ^{
        NSLog(@"a = %d",a);
    };
}

typedef void(^testBlock)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
//        test1();
//        test2();
//        test3();
        
//        test4();
//
//        test5();
//
//        test5Block();
        
        testBlock block;
        
        {
            TYPerson *person = [[TYPerson alloc] init];
            person.age = 30;
            
            __weak TYPerson *weakPerson = person;
            block = ^{
                NSLog(@"%d",weakPerson.age);
            };
            
            // MRC 环境下 release
//            [person release];
            
        }
        
        
    
        NSLog(@"-");
        
    }
    return 0;
}
