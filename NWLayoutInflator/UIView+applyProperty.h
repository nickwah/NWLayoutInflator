//
//  UIView+applyProperty.h
//  NWLayoutInflator
//
//  Created by Nicholas White on 8/1/15.
//  Copyright (c) 2015 Nicholas White. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NWLayoutView;

@interface UIView (applyProperty)

- (void)applyProperty:(NSString*)name value:(NSString*)value layoutView:(NWLayoutView*)layoutView;

@end
