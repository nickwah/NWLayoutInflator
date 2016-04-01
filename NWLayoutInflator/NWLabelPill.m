//
//  NWLabelPill.m
//  gossip
//
//  Created by Nicholas White on 3/2/16.
//  Copyright © 2016 Nicholas White. All rights reserved.
//

#import "NWLabelPill.h"
#import "NWLayoutView.h"

@implementation NWLabelPill {
    NSString *_maxWidthString;
    __weak NWLayoutView *_layout;
}

- (void)setText:(NSString *)text {
    text = [text stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceCharacterSet]];
    if (_padding) {
        NSMutableString *spaces = [NSMutableString stringWithCapacity:3];
        int pad = (int)_padding;
        for (int i = 0; i < pad / 8; i++) [spaces appendString:@"\u2000"];
        int remainder = pad % 8;
        switch (remainder) {
            case 1:
                [spaces appendString:@"\u200A"];
                break;
            case 2:
                [spaces appendString:@"\u2006"];
                break;
            case 3:
            case 4:
                [spaces appendString:@"\u2005"];
                break;
            case 5:
            case 6:
                [spaces appendString:@"\u2004"];
                break;
            case 7:
                [spaces appendString:@"\u2000"];
                break;
            default:
                break;
        }
        text = [NSString stringWithFormat:@"%@%@%@", spaces, text, spaces];
    }
    [super setText:text];
}

- (void)apply_maxWidth:(NSString*)value layoutView:(NWLayoutView*)layoutView {
    _maxWidthString = value;
    _layout = layoutView;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize fits = [super sizeThatFits:size];
    if (_maxWidthString && _layout) {
        _maxWidth = [_layout sizeValue:_maxWidthString forView:self horizontal:YES];
        if (fits.width > _maxWidth) fits.width = _maxWidth;
    }
    return fits;
}

@end
