//
//  UIColor+hexString.m
//  NWLayoutInflator
//
//  Created by Nicholas White on 8/1/15.
//  Copyright (c) 2015 Nicholas White. All rights reserved.
//

#import "UIColor+hexString.h"

@implementation UIColor (hexString)

static NSMutableDictionary *cachedColors;

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
    if (!cachedColors) cachedColors = [NSMutableDictionary dictionary];
    id cached = cachedColors[hexStr];
    if (cached) return cached;
    if (hexStr.length == 4) {
        // I feel like there should be a faster way than this...
        unichar char1 = [hexStr characterAtIndex:1];
        unichar char2 = [hexStr characterAtIndex:2];
        unichar char3 = [hexStr characterAtIndex:3];
        hexStr = [NSString stringWithFormat:@"#%C%C%C%C%C%C", char1, char1, char2, char2, char3, char3];
    }
    // Convert hex string to an integer
    unsigned int hexint = [UIColor intFromHexString:hexStr];
    
    // Create color object, specifying alpha as well
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:(hexStr.length >= 8) ? (CGFloat)((hexint & 0xFF000000) >> 24)/255.0f : 1.0f];
    cachedColors[hexStr] = color;
    return color;
}

@end
