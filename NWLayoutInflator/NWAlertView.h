//
//  NWAlertView.h
//  FriendLife
//
//  Created by Nicholas White on 10/27/15.
//  Copyright © 2015 MyLikes. All rights reserved.
//

#import "NWLayoutView.h"

typedef void(^NWAlertViewCallback)(NSString*answer);

@interface NWAlertView : NWLayoutView

- (instancetype)initWithLayout:(NSString *)layoutName andFrame:(CGRect)frame callback:(NWAlertViewCallback)callback;
- (void)setCallback:(NWAlertViewCallback)callback;

@end
