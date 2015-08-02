//
//  UIView+applyProperty.m
//  NWLayoutInflator
//
//  Created by Nicholas White on 8/1/15.
//  Copyright (c) 2015 Nicholas White. All rights reserved.
//

#import "UIView+applyProperty.h"
#import "UIColor+hexString.h"
#import "NWLayoutView.h"

@implementation UIView (applyProperty)

- (void)applyProperty:(NSString*)name value:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    SEL s = NSSelectorFromString([NSString stringWithFormat:@"apply_%@:layoutView:", name]);
    if ([self respondsToSelector:s]) {
        [self performSelector:s withObject:value withObject:layoutView];
    }
}

- (UIColor *)colorNamed:(NSString*)name {
    if ([name hasPrefix:@"#"]) {
        return [UIColor colorFromHex:name];
    } else {
        return [NWLayoutView namedColor:name];
    }
}

- (void)apply_text:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    if ([self respondsToSelector:@selector(setText:)]) {
        [(UILabel*)self setText:value];
    } else if ([self respondsToSelector:@selector(setTitle:forState:)]) {
        [(UIButton*)self setTitle:value forState:UIControlStateNormal];
    }
}

- (void)apply_textColor:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    UIColor *color = [self colorNamed:value];
    if ([self respondsToSelector:@selector(setTextColor:)]) {
        [(UILabel*)self setTextColor:color];
    } else if ([self respondsToSelector:@selector(setTitleColor:forState:)]) {
        [(UIButton*)self setTitleColor:color forState:UIControlStateNormal];
        [(UIButton*)self setTitleColor:color forState:UIControlStateHighlighted];
    }
}

- (void)apply_textAlignment:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    if ([self respondsToSelector:@selector(setTextAlignment:)]) {
        NSTextAlignment alignment;
        if ([value isEqualToString:@"left"]) alignment = NSTextAlignmentLeft;
        else if ([value isEqualToString:@"center"]) alignment = NSTextAlignmentCenter;
        else if ([value isEqualToString:@"right"]) alignment = NSTextAlignmentRight;
        ((UILabel*)self).textAlignment = alignment;
    } else if ([self respondsToSelector:@selector(setContentHorizontalAlignment:)]) {
        UIControlContentHorizontalAlignment alignment;
        if ([value isEqualToString:@"left"]) alignment = UIControlContentHorizontalAlignmentLeft;
        else if ([value isEqualToString:@"center"]) alignment = UIControlContentHorizontalAlignmentCenter;
        else if ([value isEqualToString:@"right"]) alignment = UIControlContentHorizontalAlignmentRight;
        ((UIButton*)self).contentHorizontalAlignment = alignment;
    }
}

- (void)apply_cornerRadius:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = [value floatValue];
}

-(void)apply_backgroundColor:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    self.backgroundColor = [self colorNamed:value];
}
- (void)apply_borderColor:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    self.layer.borderColor = [[self colorNamed:value] CGColor];
}
- (void)apply_borderWidth:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    self.layer.borderWidth = [value floatValue];
}

- (void)apply_imageNamed:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    if ([self respondsToSelector:@selector(setImage:)]) {
        [((UIImageView*)self) setImage:[UIImage imageNamed:value]];
    }
}

@end
