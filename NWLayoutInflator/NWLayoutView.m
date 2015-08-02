//
//  NWLayoutView.m
//  NWLayoutInflator
//
//  Created by Nicholas White on 7/31/15.
//  Copyright (c) 2015 Nicholas White. All rights reserved.
//

#import "NWLayoutView.h"
#import "XMLDictionary.h"
#import "UIView+applyProperty.h"
#import "UIColor+hexString.h"

static NSMutableDictionary *_cachedXML;
static NSMutableDictionary *_parsedCache;
static NSSet *_layoutKeys;
static NSMutableDictionary *_namedColors;

@implementation NWLayoutView {
    NSMutableDictionary *_childrenById;
}

@synthesize layoutName = _layoutName;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _childrenById = [NSMutableDictionary dictionary];
    if (!_cachedXML) {
        _cachedXML = [NSMutableDictionary dictionary];
    }
    if (!_parsedCache) {
        _parsedCache = [NSMutableDictionary dictionary];
    }
    if (!_layoutKeys) {
        _layoutKeys = [NSSet setWithObjects:@"id", @"width", @"height", @"x", @"y", @"alignLeft", @"alignTop", @"margin", @"marginLeft", @"marginTop", @"marginRight", @"marginBottom", nil];
    }
    if (!_namedColors) {
        _namedColors = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], @"white", [UIColor blackColor], @"black", nil];
    }
}

- (instancetype)initWithLayout:(NSString*)layoutName {
    if (self = [self init]) {
        _layoutName = layoutName;
        [self parseLayout];
    }
    return self;
}

- (UIView*)findViewById:(NSString*)name {
    return _childrenById[name];
}

+ (void)setXML:(NSString*)xml forName:(NSString*)name {
    _cachedXML[name] = xml;
    
    // Build the path, and create if needed.
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = [NSString stringWithFormat:@"%@.xml", name];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    
    [[xml dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
}

+ (NSString*)getXMLforName:(NSString *)name {
    NSString *xmlLayout = _cachedXML[name];
    if (!xmlLayout) {
        //NSLog(@"Loading xml for %@ from disk", name);
        NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* fileName = [NSString stringWithFormat:@"%@.xml", name];
        NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
            fileAtPath = [[NSBundle mainBundle] pathForResource:name ofType:@"xml"];
        }
        xmlLayout = [NSString stringWithContentsOfFile:fileAtPath
                                              encoding:NSUTF8StringEncoding
                                                 error:NULL];
        _cachedXML[name] = xmlLayout;
    }
    return xmlLayout;
}

- (void)parseLayout {
    if (!_layoutName) {
        // TODO: raise an exception
        [NSException raise:@"Layout not found" format:@"%@ is null", _layoutName];
    }
    NSDictionary *root = _parsedCache[_layoutName];
    if (!root) {
        NSString *xmlLayout = [NWLayoutView getXMLforName:_layoutName];
        if (!xmlLayout) {
            NSLog(@"ERROR: unable to locate %@", _layoutName);
            return;
        }
        root = [NSDictionary dictionaryWithXMLString:xmlLayout];
        _parsedCache[_layoutName] = root;
    }
    [self createAndAddChildNodes:[root childNodes] To:self];
    CGRect frame = self.frame;
    [self applyAttributes:[root attributes] To:self];
    self.frame = frame;
}

- (void) createAndAddChildNodes:(NSArray*)nodes To:(UIView*)view {
    if (!nodes) return;
    for (NSDictionary* node in nodes) {
        //NSLog(@"Adding child node with name %@", node.nodeName);
        UIView *child = [self createViewWithClass:[node nodeName]];
        [view addSubview:child];
        [self applyAttributes:[node attributes] To:child];
    }
}
- (void)applyAttributes:(NSDictionary*)attributes To:(UIView*)view {
    //NSLog(@"Applying %lu attributes to view", (unsigned long)attributes.count);
    CGRect frame = CGRectMake(0,0,0,0);
    UIEdgeInsets margin = UIEdgeInsetsMake(0, 0, 0, 0);
    for (NSString* key in attributes) {
        NSString* value = attributes[key];
        if ([_layoutKeys containsObject:key]) {
            if ([key isEqualToString:@"id"]) {
                _childrenById[value] = view;
            } else if ([key isEqualToString:@"width"]) {
                frame.size.width = [value floatValue];
            } else if ([key isEqualToString:@"height"]) {
                frame.size.height = [value floatValue];
            } else if ([key isEqualToString:@"x"]) {
                frame.origin.x = [value floatValue];
            } else if ([key isEqualToString:@"y"]) {
                frame.origin.y = [value floatValue];
            } else if ([key isEqualToString:@"alignLeft"]) {
                UIView *other = _childrenById[value];
                frame.origin.x = other.frame.origin.x;
            } else if ([key isEqualToString:@"alignTop"]) {
                UIView *other = _childrenById[value];
                frame.origin.y = other.frame.origin.y;
            } else if ([key isEqualToString:@"marginTop"]) {
                margin.top = [value floatValue];
            } else if ([key isEqualToString:@"marginLeft"]) {
                margin.left = [value floatValue];
            } else if ([key isEqualToString:@"marginBottom"]) {
                margin.bottom = [value floatValue];
            } else if ([key isEqualToString:@"marginRight"]) {
                margin.right = [value floatValue];
            } else if ([key isEqualToString:@"margin"]) {
                CGFloat floatVal = [value floatValue];
                margin = UIEdgeInsetsMake(floatVal, floatVal, floatVal, floatVal);
            }
        } else {
            [view applyProperty:key value:value layoutView:self];
        }
    }
    view.frame = frame;
    if (attributes[@"sizeToFit"]) {
        [view sizeToFit];
        frame = view.frame;
        if (attributes[@"width"] || attributes[@"height"]) {
            if (attributes[@"width"]) frame.size.width = [attributes[@"width"] floatValue];
            if (attributes[@"height"]) frame.size.height = [attributes[@"height"] floatValue];
        }
    }
    if (attributes[@"above"]) {
        UIView *other = _childrenById[attributes[@"above"]];
        frame.origin.y = other.frame.origin.y - frame.size.height;
        if (margin.bottom) frame.origin.y -= margin.bottom;
    } else if (attributes[@"below"]) {
        UIView *other = _childrenById[attributes[@"below"]];
        frame.origin.y = other.frame.origin.y + other.frame.size.height;
    } else if (attributes[@"bottom"]) {
        frame.origin.y = [view superview].bounds.size.height - frame.size.height;
        if (margin.bottom) frame.origin.y -= margin.bottom;
    } else if (attributes[@"centerVertical"]) {
        frame.origin.y = ([view superview].bounds.size.height - frame.size.height) / 2;
    }
    if (attributes[@"toLeftOf"]) {
        UIView *other = _childrenById[attributes[@"toLeftOf"]];
        frame.origin.x = other.frame.origin.x - frame.size.width;
        if (margin.right) frame.origin.x -= margin.right;
    } else if (attributes[@"toRightOf"]) {
        UIView *other = _childrenById[attributes[@"toRightOf"]];
        frame.origin.x = other.frame.origin.x + other.frame.size.width;
    } else if (attributes[@"right"]) {
        frame.origin.x = [view superview].bounds.size.width - frame.size.width;
        if (margin.right) frame.origin.x -= margin.right;
    } else if (attributes[@"centerHorizontal"]) {
        frame.origin.x = ([view superview].bounds.size.width - frame.size.width) / 2;
    }
    if (margin.top)  frame.origin.y += margin.top;
    if (margin.left) frame.origin.x += margin.left;
    view.frame = frame;
    //NSLog(@"View.width =%f height=%f", view.frame.size.width, view.frame.size.height);
}

- (UIView*)createViewWithClass:(NSString*)className {
    if ([className isEqualToString:@"UIButton"]) {
        return [UIButton buttonWithType:UIButtonTypeRoundedRect];
    }
    id view = [[NSClassFromString(className) alloc] init];
    // TODO: for any special cases, handle them here
    return view;
}

+ (UIColor*)namedColor:(NSString*)name {
    return _namedColors[name];
}

+ (void)setColor:(UIColor*)color forName:(NSString*)name {
    _namedColors[name] = color;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
