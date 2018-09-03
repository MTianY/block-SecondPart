//
//  TYPerson.m
//  block-2Part-1
//
//  Created by 马天野 on 2018/9/3.
//  Copyright © 2018年 Maty. All rights reserved.
//

#import "TYPerson.h"

@implementation TYPerson

- (void)dealloc {
    // MRC 环境下执行 super
//    [super dealloc];
    NSLog(@"%s",__func__);
}

@end
