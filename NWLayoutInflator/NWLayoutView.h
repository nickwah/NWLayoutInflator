//
//  NWLayoutView.h
//  NWLayoutInflator
//
//  Created by Nicholas White on 7/31/15.
//  Copyright (c) 2015 Nicholas White. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NWLayoutView : UIView

@property (strong, nonatomic) NSDictionary *dictValues;
@property (strong, nonatomic) NSString* layoutName;
@property (weak, nonatomic) id delegate;

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithLayout:(NSString*)layoutName;
- (instancetype)initWithLayout:(NSString*)layoutName andFrame:(CGRect)frame;
- (instancetype)initWithLayout:(NSString*)layoutName andFrame:(CGRect)frame andDelegate:(id)delegate;

- (void)parseLayout;
- (UIView*)findViewById:(NSString*)name;
- (void)addSubview:(UIView *)view withId:(NSString*)name;
- (void)chooseSegment:(UISegmentedControl*)control;
- (void)fixContentSize:(UIScrollView*)scrollView;
- (NSMutableDictionary*)getFormValues;
- (NSString*)getDictValue:(NSString*)varExpr;
- (NSString*)getDictValue:(NSString*)varExpr forNode:(UIView*)node property:(NSString*)property;
// Note that you should re-layout (view.frame = view.frame will do this) after changing any text or size properties
- (void)setDictValue:(NSString*)value forKey:(NSString*)key;

+ (void)setXML:(NSString*)xml forName:(NSString*)name;
+ (void)revertXMLforName:(NSString*)name;
+ (void)setCSS:(NSString*)css forName:(NSString*)name;
+ (void)revertCSSforName:(NSString*)name;
+ (UIColor*)namedColor:(NSString*)name;
+ (void)setColor:(UIColor*)color forName:(NSString*)name;
+ (void)addColorsFromDictionary:(NSDictionary*)colors; // NSString -> NSString of hex color
+ (void)precacheLayout:(NSString*)layoutName;

@end
