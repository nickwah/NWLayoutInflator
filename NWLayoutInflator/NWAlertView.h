//
//  NWAlertView.h
//  FriendLife
//
//  Created by Nicholas White on 10/27/15.
//  Copyright © 2015 MyLikes. All rights reserved.
//

#import "NWLayoutView.h"

typedef void(^NWAlertViewCallback)(NSString*answer);

@interface NWAlertView : NWLayoutView {
    BOOL _animated;    
}

+ (instancetype)alertViewWithLayout:(NSString*)layoutName callback:(NWAlertViewCallback)callback;

- (instancetype)initWithLayout:(NSString *)layoutName andFrame:(CGRect)frame callback:(NWAlertViewCallback)callback;
- (void)setCallback:(NWAlertViewCallback)callback;

- (void)present;
- (void)presentIn:(UIView*)parent animated:(BOOL)animated;
- (UIWindow *)topmostWindow;
- (void)answer:(NSString*)answer;
- (void)dismiss;

@end
