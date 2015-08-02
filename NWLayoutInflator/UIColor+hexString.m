//
//  UIColor+hexString.m
//  NWLayoutInflator
//
//  Created by Nicholas White on 8/1/15.
//  Copyright (c) 2015 Nicholas White. All rights reserved.
//

#import "UIColor+hexString.h"

@implementation UIColor (hexString)

+ (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexInt];
    return hexInt;
}

+ (UIColor *)colorFromHex:(NSString *)hexStr
{
    // Convert hex string to an integer
    unsigned int hexint = [UIColor intFromHexString:hexStr];
    
    // Create color object, specifying alpha as well
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:(hexStr.length >= 8) ? (CGFloat)((hexint & 0xFF000000) >> 24)/255.0f : 1.0f];
    
    NSLog(@"Made color with alpha %f", (hexStr.length >= 8) ? (CGFloat)((hexint & 0xFF000000) >> 24)/255.0f : 1.0f);
    return color;
}

@end
