//
//  ViewController.m
//  NWLayoutInflator
//
//  Created by Nicholas White on 7/31/15.
//  Copyright (c) 2015 Nicholas White. All rights reserved.
//

#import "ViewController.h"
#import "NWLayoutView.h"

@interface ViewController ()

@end

@implementation ViewController {
    NWLayoutView *_layoutView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _layoutView = [[NWLayoutView alloc] initWithLayout:@"testLayout" andFrame:self.view.bounds andDelegate:self];
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
