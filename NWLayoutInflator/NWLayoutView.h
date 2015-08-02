//
//  NWLayoutView.h
//  NWLayoutInflator
//
//  Created by Nicholas White on 7/31/15.
//  Copyright (c) 2015 Nicholas White. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NWLayoutView : UIView

@property (strong, nonatomic) NSString* layoutName;

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithLayout:(NSString*)layoutName;

- (void)parseLayout;
- (UIView*)findViewById:(NSString*)name;

+ (void)setXML:(NSString*)xml forName:(NSString*)name;
+ (UIColor*)namedColor:(NSString*)name;
+ (void)setColor:(UIColor*)color forName:(NSString*)name;

@end
