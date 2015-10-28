//
//  NWAlertView.m
//  FriendLife
//
//  Created by Nicholas White on 10/27/15.
//  Copyright © 2015 MyLikes. All rights reserved.
//

#import "NWAlertView.h"

@implementation NWAlertView {
    NWAlertViewCallback _callback;
}

- (void)setCallback:(NWAlertViewCallback)callback {
    _callback = callback;
}

- (instancetype)initWithLayout:(NSString *)layoutName andFrame:(CGRect)frame callback:(NWAlertViewCallback)callback {
    if (self = [super initWithLayout:layoutName andFrame:frame andDelegate:self]) {
        [self setCallback:callback];
    }
    return self;
}

- (void)answer:(NSString*)answer {
    if (_callback) {
        _callback(answer);
        _callback = 0;
    }
    [self removeFromSuperview];
}

@end
