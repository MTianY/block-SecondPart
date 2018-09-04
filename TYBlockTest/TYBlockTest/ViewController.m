//
//  ViewController.m
//  TYBlockTest
//
//  Created by 马天野 on 2018/9/4.
//  Copyright © 2018年 Maty. All rights reserved.
//

#import "ViewController.h"
#import "TYPerson.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    TYPerson *person = [[TYPerson alloc] init];
    person.age = 10;
    NSLog(@"age1 = %d",person.age);
    
    
    __weak TYPerson *weakPerson = person;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"age2 = %d",weakPerson.age);
    });
    
}


@end
