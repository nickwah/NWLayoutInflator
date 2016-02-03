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
    NWCollectionView *_collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NWLayoutView addColorsFromDictionary:
        @{@"orange": @"#FABA43"}];

    _layoutView = [[NWLayoutView alloc] initWithLayout:@"testLayout" andFrame:self.view.bounds andDelegate:self];
    [_layoutView setDictValue:@"right side key" forKey:@"right_side"];
    [_layoutView setFrame:self.view.bounds];
    [self.view addSubview:_layoutView];
    [_layoutView sizeToFit];
    
    _collectionView = [[NWCollectionView alloc] initWithFrame:CGRectMake(0, _layoutView.frame.size.height, self.view.frame.size.width, 300)];
    [self.view addSubview:_collectionView];
    _collectionView.layoutName = @"collection_test";
    _collectionView.collectionItems = @[@{@"caption": @"testing 1 2 3 doctor watson can you hear me over here?"}, @{@"caption": @"number 2"}, @{@"caption": @"i'm third"}, @{@"caption": @"fourth is the best. fourth is the best"}, @{@"caption": @"fifth"}, @{@"caption": @"i'm sixth"}, @{@"caption": @"number seven goes here"}, @{@"caption": @"did you know we have at least eight items in this list?"}, @{@"caption" : @"no repeats"}, @{@"caption": @"tenth"}];
    _collectionView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
}

- (void)moveFrame {
    _layoutView.frame = CGRectMake(120, 20, 200, 200);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
