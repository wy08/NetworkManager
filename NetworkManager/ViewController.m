//
//  ViewController.m
//  NetworkManager
//
//  Created by mac on 2018/1/8.
//  Copyright © 2018年 baby. All rights reserved.
//

#import "ViewController.h"
#import "NetworkManager.h"
#import "NetworkMacro.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self testURL];
}

- (void)testURL {
    [[NetworkManager shareNetworkManager]GETUrl:@"http://haoma.p10155.cn/phone_number_segment//" parameters:nil success:^(id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        NSLog(@"error%ld",judgeCode);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
