//
//  NWLinearLayoutView.m
//  gossip
//
//  Created by Nicholas White on 1/20/16.
//  Copyright © 2016 Nicholas White. All rights reserved.
//

#import "NWLinearLayoutView.h"
#import "NWLayoutView.h"

@implementation NWLinearLayoutView {
    CGFloat _width;
    CGFloat _height;
    BOOL _vertical;
}

- (void)setOrientation:(NSString*)orientation {
    _vertical = [orientation isEqualToString:@"vertical"];
}

- (CGSize)sizeThatFits:(CGSize)size {
    [self layoutSubviews];
    return CGSizeMake(_width, _height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat pos = 0;
    for (UIView *view in self.subviews) {
        CGRect frame = view.frame;
        if (_vertical) {
            frame.origin.y = pos;
        } else {
            frame.origin.x = pos;
        }
        view.frame = frame;
        pos += _spacing + (_vertical ? frame.size.height : frame.size.width);
        _width = fmax(_width, CGRectGetMaxX(frame));
        _height = fmax(_height, CGRectGetMaxY(frame));
    }
}

- (void)apply_spacing:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    self.spacing = [value floatValue];
}

@end
