//
//  UITouchDownGestureRecognizer.m
//  FriendLife
//
//  Created by Nicholas White on 11/10/15.
//  Copyright © 2015 MyLikes. All rights reserved.
//

#import "UITouchDownGestureRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation UITouchDownGestureRecognizer

static CGPoint touchDownLastTouchPoint;

-(void)touchesBegan:(NSSet<UITouch*> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if (touches.count > 1) return;
    touchDownLastTouchPoint = [touches.anyObject locationInView:self.view];
    if (self.state == UIGestureRecognizerStatePossible) {
        self.state = UIGestureRecognizerStateBegan;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    CGPoint loc = [touches.anyObject locationInView:self.view];
    if (fabs(loc.y - touchDownLastTouchPoint.y) + fabs(loc.x - touchDownLastTouchPoint.x) > 18) {
        self.state = UIGestureRecognizerStateCancelled;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    self.state = UIGestureRecognizerStateEnded;
    touchDownLastTouchPoint = CGPointZero;
}

@end
