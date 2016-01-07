//
//  NWWrappedView.m
//  gossip
//
//  Created by Nicholas White on 1/4/16.
//  Copyright © 2016 Nicholas White. All rights reserved.
//

#import "NWWrappedView.h"

@implementation NWWrappedView {
    CGFloat _spacing;
    BOOL _centered;
}

- (void)setSpacing:(NSString*)spacing {
    _spacing = [spacing floatValue];
}

- (void)setCentered:(NSString*)centered {
    _centered = [centered boolValue];
}

- (void)positionViews:(NSArray*)views x:(CGFloat)x y:(CGFloat)y {
    CGFloat xOffset = 0;
    if (_centered) {
        CGFloat totalWidth = 0;
        
        for (UIView *view in views) {
            totalWidth += view.frame.size.width;
        }
        totalWidth += (views.count - 1) * _spacing;
        xOffset = (self.frame.size.width - totalWidth) / 2;
    }
    for (UIView *view in views) {
        CGRect frame = view.frame;
        frame.origin.x = x + xOffset;
        frame.origin.y = y;
        view.frame = frame;
        x += frame.size.width + _spacing;
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat maxHeight = 0;
    NSMutableArray *row = [NSMutableArray array];
    for (UIView *subview in self.subviews) {
        CGRect frame = subview.frame;
        maxHeight = fmax(frame.size.height, maxHeight);
        if (x + frame.size.width > width && row.count > 0) {
            [self positionViews:row x:0 y:y];
            y += maxHeight + _spacing;
            x = 0;
            [row removeAllObjects];
        }
        [row addObject:subview];
        x += frame.size.width + _spacing;
    }
    if (row.count > 0) [self positionViews:row x:0 y:y];
}

@end
