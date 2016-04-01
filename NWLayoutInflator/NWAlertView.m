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

+ (instancetype)alertViewWithLayout:(NSString *)layoutName callback:(NWAlertViewCallback)callback {
    NWAlertView *alertView = [[self alloc] init];
    alertView.layoutName = layoutName;
    alertView.delegate = alertView;
    [alertView setCallback:callback];
    [alertView parseLayout];
    return alertView;
}

- (void)answer:(NSString*)answer {
    if (_callback) {
        _callback(answer);
        _callback = 0;
    }
    [self dismiss];
}

- (void)dismiss {
    if (_animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    } else {
        [self removeFromSuperview];
    }
}

- (void)presentIn:(UIView*)parent animated:(BOOL)animated {
    self.frame = parent.bounds;
    [parent addSubview:self];
    _animated = animated;
    if (animated) {
        self.alpha = 0;
        [UIView animateWithDuration:0.4 animations:^{
            self.alpha = 1;
        }];
    }
}

- (void)present {
    [self presentIn:[self topmostWindow] animated:YES];
}

- (UIWindow *)topmostWindow
{
    UIWindow *topWindow = [[[UIApplication sharedApplication].windows sortedArrayUsingComparator:^NSComparisonResult(UIWindow *win1, UIWindow *win2) {
        return win1.windowLevel - win2.windowLevel;
    }] lastObject];
    return topWindow;
}

@end
