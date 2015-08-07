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

- (void)apply_font:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    UIFont *font;
    if (![value containsString:@":"]) {
        font = [UIFont systemFontOfSize:[value floatValue]];
    } else {
        NSString *valueFromColon = [value substringFromIndex:[value rangeOfString:@":"].location + 1];
        if ([value hasPrefix:@"fontWithName:'"]) {
            NSString *sizeText = [valueFromColon substringFromIndex:[valueFromColon rangeOfString:@":"].location + 1];
            NSString *nameText = [valueFromColon substringWithRange:NSMakeRange(1, [valueFromColon rangeOfString:@"'" options:0 range:NSMakeRange(1, valueFromColon.length - 1)].location - 1)];
            font = [UIFont fontWithName:nameText size:[sizeText floatValue]];
        } else if ([value hasPrefix:@"bold"]) {
            font = [UIFont boldSystemFontOfSize:[valueFromColon floatValue]];
        } else if ([value hasPrefix:@"italic"]) {
            font = [UIFont italicSystemFontOfSize:[valueFromColon floatValue]];
        } else {
            font = [UIFont systemFontOfSize:[valueFromColon floatValue]];
        }
    }
    if (font) {
        if ([self respondsToSelector:@selector(titleLabel)]) {
            ((UIButton*)self).titleLabel.font = font;
        } else if ([self respondsToSelector:@selector(setFont:)]) {
            ((UILabel*)self).font = font;
        }
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

- (void)apply_imageWithURL:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    if ([self respondsToSelector:@selector(setImageWithURL:)]) {
        if ([value hasPrefix:@"//"]) {
            value = [NSString stringWithFormat:@"http:%@", value];
        }
        [self performSelector:@selector(setImageWithURL:) withObject:[NSURL URLWithString:value]];
    }
}

- (void)apply_numberOfLines:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    if ([self respondsToSelector:@selector(setNumberOfLines:)]) {
        [((UILabel*)self) setNumberOfLines:[value intValue]];
    }
}

- (void)apply_tintColor:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    if ([self respondsToSelector:@selector(setTintColor:)]) {
        [((UIImageView*)self) setTintColor:[self colorNamed:value]];
    }
}

- (void)apply_onclick:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    if (layoutView.delegate && ![layoutView.delegate respondsToSelector:NSSelectorFromString(value)]) {
        NSLog(@"ERROR: delegate does not respond to %@ -- %@", value, layoutView.delegate);
        return;
    }
    if ([self respondsToSelector:@selector(addTarget:action:forControlEvents:)]) {
        [((UIButton*)self) addTarget:layoutView.delegate action:NSSelectorFromString(value) forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:layoutView.delegate action:NSSelectorFromString(value)];
        [self addGestureRecognizer:tapRecognizer];
    }
}

- (void)apply_activityIndicatorViewStyle:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    if ([self respondsToSelector:@selector(setActivityIndicatorViewStyle:)]) {
        UIActivityIndicatorViewStyle style;
        if ([value isEqualToString:@"white"]) style = UIActivityIndicatorViewStyleWhite;
        else if ([value isEqualToString:@"whitelarge"]) style = UIActivityIndicatorViewStyleWhiteLarge;
        else if ([value isEqualToString:@"gray"]) style = UIActivityIndicatorViewStyleGray;
        ((UIActivityIndicatorView*)self).activityIndicatorViewStyle = style;
    }
}

- (void)apply_tag:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    self.tag = [value intValue];
}

- (void)apply_scrollEnabled:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    if ([self respondsToSelector:@selector(setScrollEnabled:)]) {
        ((UIScrollView*)self).scrollEnabled = [value intValue] ? YES : NO;
    }
}

- (void) apply_segments:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    if (![self isKindOfClass:[UISegmentedControl class]]) return;
    UISegmentedControl *control = (UISegmentedControl*)self;
    NSArray *items = [value componentsSeparatedByString:@"|"];
    [control removeAllSegments];
    for (NSString *segment in items) {
        [control insertSegmentWithTitle:segment atIndex:control.numberOfSegments animated:NO];
    }
    [control addTarget:layoutView action:@selector(chooseSegment:) forControlEvents:UIControlEventValueChanged];
    control.selectedSegmentIndex = 0;
}

@end
