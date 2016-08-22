//
//  ViewController.m
//  KYLabel
//
//  Created by Young on 16/5/20.
//  Copyright © 2016年 Young. All rights reserved.
//

#import "ViewController.h"
#import "KYLabel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    KYLabel *label = [[KYLabel alloc] initWithFrame:CGRectMake(20, 200, 300, 300)];
    label.backgroundColor = [UIColor whiteColor];
    label.text = @"中文中文中文abcd123中文中文中文中文abcd123中文中文中文中文中文中文中文abcd123中文中文中文中文中文abc123中文中文中文中文中文中文中文abc123中文中文中文中文中文中文中文abc123";
    label.textColor = [UIColor blueColor];
    label.font = [UIFont systemFontOfSize:14];
    label.numberOfLines = 4;
    label.lineSpacing = 9;
    label.lineBreakMode = KYLineBreakByCharWrappingAndTruncatingTail;
    label.verticalAlignment = KYTextVerticalAlignmentTop;
    label.equalLineHeight = YES;
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
