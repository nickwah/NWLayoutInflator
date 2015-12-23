//
//  ViewController.m
//  NWLayoutInflator
//
//  Created by Nicholas White on 7/31/15.
//  Copyright (c) 2015 Nicholas White. All rights reserved.
//

#import "ViewController.h"
#import <NWLayoutInflator/NWLayoutInflator.h>

@interface ViewController ()

@end

@implementation ViewController {
    NWLayoutView *_layoutView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NWLayoutView addColorsFromDictionary:
        @{@"orange": @"#FABA43"}];

    _layoutView = [[NWLayoutView alloc] initWithLayout:@"testLayout" andFrame:self.view.bounds andDelegate:self];
    [_layoutView setDictValue:@"right side key" forKey:@"right_side"];
    [_layoutView setFrame:self.view.bounds];
    [self.view addSubview:_layoutView];
}

- (void)moveFrame {
    _layoutView.frame = CGRectMake(120, 20, 200, 200);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
