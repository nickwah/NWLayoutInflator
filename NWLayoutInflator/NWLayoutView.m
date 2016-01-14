//
//  NWLayoutView.m
//  NWLayoutInflator
//
//  Created by Nicholas White on 7/31/15.
//  Copyright (c) 2015 Nicholas White. All rights reserved.
//

#import "NWLayoutView.h"
#import "NWXMLDictionary.h"
#import "UIView+applyProperty.h"
#import "UIColor+hexString.h"

static NSMutableDictionary *_cachedXML;
static NSMutableDictionary *_parsedCache;
static NSSet *_layoutKeys;
static NSMutableDictionary *_namedColors;
static NSMutableDictionary *_parsedStyles;

@implementation NWLayoutView {
    NSMutableDictionary *_childrenById; // NSString -> UIView
    NSMutableDictionary *_attributesById; // NSString -> NSDictionary
    NSMutableArray *_segmentedControls;
    NSMutableArray *_allNodes; // array of nsdictionaries, each dict has attributes and @"node"
    NSMutableDictionary *_dataMappedNodes;
    __weak NSDictionary *_lastDictValues;
    NSMutableDictionary *_dictValues;
    NSMutableDictionary *_formValuesById;
    NSMutableDictionary *_styleSheet;
}

@synthesize layoutName = _layoutName;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    if (!_cachedXML) {
        _cachedXML = [NSMutableDictionary dictionary];
    }
    if (!_parsedCache) {
        _parsedCache = [NSMutableDictionary dictionary];
    }
    if (!_layoutKeys) {
        _layoutKeys = [NSSet setWithObjects:@"id", @"width", @"height", @"x", @"y", @"alignLeft", @"alignTop", @"margin", @"marginLeft", @"marginTop", @"marginRight", @"marginBottom", @"above", @"below", @"bottom", @"right", @"toLeftOf", @"toRightOf", @"alignRight", @"alignBottom", nil];
    }
    if (!_parsedStyles) _parsedStyles = [NSMutableDictionary dictionary];
    if (!_namedColors[@"white"]) [NWLayoutView setColor:[UIColor whiteColor] forName:@"white"];
    if (!_namedColors[@"black"]) [NWLayoutView setColor:[UIColor blackColor] forName:@"black"];
    _dataMappedNodes = [NSMutableDictionary dictionary];
    _dictValues = [NSMutableDictionary dictionary];
}

- (instancetype)initWithLayout:(NSString*)layoutName {
    if (self = [self init]) {
        _layoutName = layoutName;
        [self parseLayout];
    }
    return self;
}

- (instancetype)initWithLayout:(NSString*)layoutName andFrame:(CGRect)frame {
    return [self initWithLayout:layoutName andFrame:frame andDelegate:nil];
}

- (instancetype)initWithLayout:(NSString*)layoutName andFrame:(CGRect)frame andDelegate:(id)delegate {
    if (self = [self initWithFrame:frame]) {
        _layoutName = layoutName;
        self.delegate = delegate;
        [self parseLayout];
    }
    return self;
}


- (UIView*)findViewById:(NSString*)name {
    return _childrenById[name];
}

+ (void)setXML:(NSString*)xml forName:(NSString*)name {
    [self setContents:xml forFile:name ofType:@"xml"];
}
+ (void)revertXMLforName:(NSString*)name {
    [self revertFileforName:name ofType:@"xml"];
}
+ (void)setCSS:(NSString*)css forName:(NSString*)name {
    [self setContents:css forFile:name ofType:@"css"];
}
+ (void)revertCSSforName:(NSString*)name {
    [self revertFileforName:name ofType:@"css"];
}
+ (void)setContents:(NSString*)xml forFile:(NSString*)name ofType:(NSString*)type {
    _cachedXML[name] = xml;
    
    // Build the path, and create if needed.
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = [NSString stringWithFormat:@"%@.%@", name, type];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    
    [[xml dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
}

+ (void)revertFileforName:(NSString*)name ofType:(NSString*)type {
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = [NSString stringWithFormat:@"%@.%@", name, type];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:fileAtPath error:&error];
    }
}

+ (NSString*)getXMLforName:(NSString *)name {
    if ([name hasPrefix:@"<"]) return name;
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

+ (NSString*)getCSSforName:(NSString*)name {
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = [NSString stringWithFormat:@"%@.css", name];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        fileAtPath = [[NSBundle mainBundle] pathForResource:name ofType:@"css"];
    }
    return [NSString stringWithContentsOfFile:fileAtPath
                                     encoding:NSUTF8StringEncoding
                                        error:NULL];
}

+ (NSMutableDictionary*)parseCSS:(NSString*)css {
    NSError *error;
    if (!css) return nil;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"[/][*].*?[*][/]" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
    css = [regex stringByReplacingMatchesInString:css options:0 range:NSMakeRange(0, css.length) withTemplate:@""];
    regex = [NSRegularExpression
             regularExpressionWithPattern:@"[/][/].*?\n" options:0 error:&error];
    css = [regex stringByReplacingMatchesInString:css options:0 range:NSMakeRange(0, css.length) withTemplate:@""];
    css = [css stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    NSUInteger pos = 0;
    NSMutableDictionary *classes = [NSMutableDictionary dictionary];
    NSMutableDictionary *ids = [NSMutableDictionary dictionary];
    while (pos < css.length) {
        unichar ch = [css characterAtIndex:pos];
        if (ch == '\n' || ch == ' ' || ch == '\t') {
            pos++;
            continue;
        }
        NSString *name = nil;
        BOOL isId = NO;
        if (ch == '.' || ch == '#') {
            isId = (ch == '#');
            pos++;
            NSRange curly = [css rangeOfString:@"{" options:0 range:NSMakeRange(pos, css.length - pos)];
            if (curly.location == NSNotFound) break;
            name = [css substringWithRange:NSMakeRange(pos, curly.location - pos)];
            name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            pos = curly.location + 1;
            curly = [css rangeOfString:@"}" options:0 range:NSMakeRange(pos, css.length - pos)];
            if (curly.location == NSNotFound) break;
            NSString *contents = [css substringWithRange:NSMakeRange(pos, curly.location - pos)];
            NSMutableDictionary *styles = [NSMutableDictionary dictionary];
            NSArray *chunks = [contents componentsSeparatedByString:@";"];
            for (NSString *chunk in chunks) {
                NSRange colon = [chunk rangeOfString:@":"];
                if (colon.location == NSNotFound) continue;
                NSString *key = [chunk substringToIndex:colon.location];
                NSString *value = [chunk substringFromIndex:colon.location + 1];
                styles[[key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]] = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            if (isId) {
                ids[name] = styles;
            } else {
                classes[name] = styles;
            }
            pos = curly.location + 1;
        } else {
            pos++;
        }
    }
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:classes, @"classes", ids, @"ids", nil];
}

- (void)loadStylesheet:(NSString*)nameList {
    NSArray *names = [nameList componentsSeparatedByString:@" "];
    _styleSheet = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableDictionary dictionary], @"classes", [NSMutableDictionary dictionary], @"ids", nil];
    for (NSString *name in names) {
        if (!_parsedStyles[name]) {
            NSString *css = [NWLayoutView getCSSforName:name];
            NSMutableDictionary *styleSheet = [NWLayoutView parseCSS:css];
            _parsedStyles[name] = styleSheet;
        }
        [_styleSheet[@"classes"] addEntriesFromDictionary:_parsedStyles[name][@"classes"]];
        [_styleSheet[@"ids"] addEntriesFromDictionary:_parsedStyles[name][@"ids"]];
    }
}

- (NSMutableDictionary*)getStyleForClass:(NSString*)class {
    return _styleSheet[@"classes"][class];
}

- (NSMutableDictionary*)getStyleForId:(NSString*)class {
    return _styleSheet[@"ids"][class];
}

- (NSDictionary*)getFinalLayout {
    id cached = _parsedCache[_layoutName];
    NSDictionary *root;
    if (!cached) {
        NSString *xmlLayout = [NWLayoutView getXMLforName:_layoutName];
        if (!xmlLayout) {
            NSLog(@"ERROR: unable to locate %@", _layoutName);
            return nil;
        }
        root = [NSDictionary NWdictionaryWithXMLString:xmlLayout];
        _parsedCache[_layoutName] = root;
    }
    return root;
}

+ (void)precacheLayout:(NSString*)layoutName {
    NWLayoutView *lv = [[NWLayoutView alloc] init];
    lv.layoutName = layoutName;
    [lv getFinalLayout];
}

- (void)parseLayout {
    _childrenById = [NSMutableDictionary dictionary];
    _attributesById = [NSMutableDictionary dictionary];
    _segmentedControls = [NSMutableArray array];
    _formValuesById = [NSMutableDictionary dictionary];
    _allNodes = [NSMutableArray array];
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    if (!_layoutName) {
        // TODO: raise an exception
        [NSException raise:@"Layout not found" format:@"%@ is null", _layoutName];
    }
    NSDictionary *root = [self getFinalLayout];
    if (!root) return;
    if (root.safeAttributesNW[@"stylesheet"]) {
        [self loadStylesheet:root.safeAttributesNW[@"stylesheet"]];
    }
    [_allNodes addObject:@{@"view": self, @"nodeName": root.nodeNameNW, @"attributes": [root safeAttributesNW], @"root": @YES}];
    [self createAndAddChildNodes:[root childNodesNW] To:self];
    CGRect frame = self.frame;
    [self applyAttributes:[root attributesNW] To:self layoutOnly:NO];
    [self setFrame:frame];
    for (UISegmentedControl *child in _segmentedControls) {
        [self chooseSegment:(UISegmentedControl*)child];
    }
}

- (void) createAndAddChildNodes:(NSArray*)nodes To:(UIView*)view {
    if (!nodes || !nodes.count) return;
    NSUInteger numNodes = nodes.count;
    for (int i = 0; i < numNodes; ++i) {
        @try {
            NSDictionary* node = nodes[i];
            //NSLog(@"Adding child node with name %@", node.nodeName);
            UIView *child = [self createViewWithClass:[node nodeNameNW]];
            [view addSubview:child];
            NSDictionary *attrs = [node attributesNW];
            if (attrs[@"id"] && attrs[@"formValue"]) {
                _formValuesById[attrs[@"id"]] = attrs[@"formValue"];
            }
            [self applyAttributes:attrs To:child layoutOnly:NO];
            NSArray *childNodes = [node childNodesNW];
            [_allNodes addObject:@{@"nodeName": node.nodeNameNW, @"view": child, @"attributes": attrs ?: @{}, @"children": @(childNodes.count), @"last": @(i == numNodes - 1)}];
            if (childNodes.count) {
                [self createAndAddChildNodes:childNodes To:child];
                if (node.attributesNW[@"sizeToFit"]) {
                    [self sizeViewToFit:child];
                }
            }
            if ([node.nodeNameNW isEqualToString:@"UIScrollView"]) {
                [self fixContentSize:(UIScrollView*)child];
            }
            if ([node.nodeNameNW isEqualToString:@"UISegmentedControl"]) {
                [_segmentedControls addObject:child];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception trying to render view %@ into %@\n%@", nodes[i], view, exception);
        }
    }
}
CGFloat parseValue(NSString* value, UIView* view, BOOL horizontal, NWLayoutView* instance) {
    if ([value hasPrefix:@"{{"] && [value hasSuffix:@"}}"]) {
        value = [instance getDictValue:[value substringWithRange:NSMakeRange(2, value.length - 4)]];
    }
    if ([value hasSuffix:@"%"]) {
        if (horizontal) {
            return [view superview].bounds.size.width * [[value substringToIndex:value.length - 1] floatValue] / 100.0f;
        } else {
            return [view superview].bounds.size.height * [[value substringToIndex:value.length - 1] floatValue] / 100.0f;
        }
    }
    return [value floatValue];
}
- (void)applyAttributes:(NSDictionary*)attributes To:(UIView*)view layoutOnly:(BOOL)layoutOnly {
    if (attributes[@"class"] || attributes[@"id"]) {
        NSMutableDictionary *classDict = [NSMutableDictionary dictionary];
        if (attributes[@"class"]) {
            NSArray *classes = [attributes[@"class"] componentsSeparatedByString:@" "];
            for (NSString *class in classes) {
                [classDict addEntriesFromDictionary:[self getStyleForClass:class]];
            }
        }
        [classDict addEntriesFromDictionary:[self getStyleForId:attributes[@"id"]]];
        if (classDict && classDict.count) {
            [classDict addEntriesFromDictionary:attributes];
            attributes = classDict;
        }
    }
    //NSLog(@"Applying %lu attributes to view", (unsigned long)attributes.count);
    CGRect frame = CGRectZero;
#define UNSET -999
    CGFloat left = UNSET;
    CGFloat top = UNSET;
    CGFloat right = UNSET;
    CGFloat bottom = UNSET;
    UIEdgeInsets margin = UIEdgeInsetsMake(0, 0, 0, 0);
    for (NSString* key in attributes) {
        NSString* value = attributes[key];
        if ([_layoutKeys containsObject:key]) {
            if ([key isEqualToString:@"id"]) {
                _childrenById[value] = view;
                _attributesById[value] = attributes;
            } else if ([key isEqualToString:@"width"]) {
                frame.size.width = parseValue(value, view, YES, self);
            } else if ([key isEqualToString:@"height"]) {
                frame.size.height = parseValue(value, view, NO, self);
            } else if ([key isEqualToString:@"x"]) {
                left = parseValue(value, view, YES, self);
            } else if ([key isEqualToString:@"y"]) {
                top = parseValue(value, view, NO, self);
            } else if ([key isEqualToString:@"alignLeft"]) {
                UIView *other = _childrenById[value];
                left = other.frame.origin.x;
            } else if ([key isEqualToString:@"alignTop"]) {
                UIView *other = _childrenById[value];
                top = other.frame.origin.y;
            } else if ([key isEqualToString:@"below"]) {
                UIView *other = _childrenById[value];
                top = other.frame.origin.y + other.frame.size.height;
            } else if ([key isEqualToString:@"above"]) {
                UIView *other = _childrenById[value];
                bottom = other.frame.origin.y;
            } else if ([key isEqualToString:@"bottom"]) {
                bottom = [view superview].bounds.size.height - parseValue(attributes[@"bottom"], view, NO, self);
            } else if ([key isEqualToString:@"right"]) {
                right = [view superview].bounds.size.width - parseValue(attributes[@"right"], view, YES, self);
            } else if ([key isEqualToString:@"toLeftOf"]) {
                UIView *other = _childrenById[value];
                right = other.frame.origin.x;
            } else if ([key isEqualToString:@"toRightOf"]) {
                UIView *other = _childrenById[value];
                left = other.frame.origin.x + other.frame.size.width;
            } else if ([key isEqualToString:@"alignRight"]) {
                UIView *other = _childrenById[value];
                right = CGRectGetMaxX(other.frame);
            } else if ([key isEqualToString:@"alignBottom"]) {
                UIView *other = _childrenById[value];
                bottom = CGRectGetMaxY(other.frame);
            } else if ([key isEqualToString:@"marginTop"]) {
                margin.top = parseValue(value, view, NO, self);
            } else if ([key isEqualToString:@"marginLeft"]) {
                margin.left = parseValue(value, view, YES, self);
            } else if ([key isEqualToString:@"marginBottom"]) {
                margin.bottom = parseValue(value, view, NO, self);
            } else if ([key isEqualToString:@"marginRight"]) {
                margin.right = parseValue(value, view, YES, self);
            } else if ([key isEqualToString:@"margin"]) {
                CGFloat floatVal = parseValue(value, view, YES, self);
                margin = UIEdgeInsetsMake(floatVal, floatVal, floatVal, floatVal);
            }
        } else if (!layoutOnly) {
            [view applyProperty:key value:value layoutView:self];
        }
    }
    if (margin.top && top != UNSET)  top += margin.top;
    if (margin.left && left != UNSET) left += margin.left;
    if (margin.bottom && bottom != UNSET) bottom -= margin.bottom;
    if (margin.right && right != UNSET) right -= margin.right;
    if (left != UNSET && right != UNSET && !frame.size.width) frame.size.width = right - left;
    if (top != UNSET && bottom != UNSET && !frame.size.height) frame.size.height = bottom - top;
    if (left != UNSET) frame.origin.x = left;
    if (top != UNSET) frame.origin.y = top;
    view.frame = frame;
    if (attributes[@"sizeToFit"]) {
        CGSize origSize = frame.size;
        [self sizeViewToFit:view];
        frame = view.frame;
        if (origSize.width) frame.size.width = origSize.width;
        if (origSize.height) frame.size.height = origSize.height;
    }
    if (right != UNSET && left == UNSET) frame.origin.x = right - frame.size.width;
    if (bottom != UNSET && top == UNSET) frame.origin.y = bottom - frame.size.height;
    if (attributes[@"centerVertical"]) {
        frame.origin.y = ([view superview].bounds.size.height - frame.size.height) / 2 + margin.top;
    }
    if (attributes[@"centerHorizontal"]) {
        frame.origin.x = ([view superview].bounds.size.width - frame.size.width) / 2 + margin.left;
    }
    if (view == self) {
        [super setFrame:frame];
    } else {
        view.frame = frame;
    }
    /* TODO: fix frame if a view gets resized
    if (attributes[@"backgroundGradient"]) {
        for (CALayer *layer in view.layer.sublayers) {
            if ([layer isKindOfClass:[CAGradientLayer class]]) {
                layer.frame = view.bounds;
                NSLog(@"layer frame updated to %@", NSStringFromCGRect(layer.frame));
            }
        }
    }
     */
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    NSMutableArray *nodeStack = [NSMutableArray array];
    for (NSDictionary *node in _allNodes) {
        if (node[@"root"]) continue;
        [self applyAttributes:node[@"attributes"] To:node[@"view"] layoutOnly:YES];
        if ([node[@"last"] boolValue] && nodeStack.count) {
            NSDictionary *parent = nodeStack.lastObject;
            [nodeStack removeObjectAtIndex:nodeStack.count - 1];
            if (parent[@"attributes"][@"sizeToFit"]) {
                // We revisit the layout of the parent
                [self applyAttributes:parent[@"attributes"] To:parent[@"view"] layoutOnly:YES];
            }
            if ([parent[@"nodeName"] isEqualToString:@"UIScrollView"]) {
                [self fixContentSize:(UIScrollView*)parent[@"view"]];
            }
        }
        if ([node[@"children"] intValue]) {
            [nodeStack addObject:node];
        }
    }
}

- (void)sizeViewToFit:(UIView *)view {
    [self sizeViewToFit:view forceHeight:NO];
}
- (void)sizeViewToFit:(UIView *)view forceHeight:(BOOL)forceHeight {
    if ([view isKindOfClass:[UIImageView class]]) {
        CGRect frame = view.frame;
        UIImage *image = ((UIImageView*)view).image;
        if (frame.size.width) {
            frame.size.height = image ? frame.size.width * image.size.height / image.size.width : 0;
        } else if (frame.size.height) {
            frame.size.width = image ? frame.size.height * image.size.width / image.size.height : 0;
        }
        view.frame = frame;
        return;
    }
    if ((!view.subviews.count || [view isKindOfClass:[UIButton class]] || ![NSStringFromClass(view.class) hasPrefix:@"UI"]) && view != self) {
        [view sizeToFit];
        return;
    }
    CGFloat maxX = 0, maxY = 0;
    for (UIView* subview in view.subviews) {
        if (subview.hidden) continue;
        maxX = fmaxf(maxX, CGRectGetMaxX(subview.frame));
        maxY = fmaxf(maxY, CGRectGetMaxY(subview.frame));
    }
    CGRect frame = view.frame;
    if (!frame.size.width) frame.size.width = maxX;
    if (!frame.size.height || forceHeight) frame.size.height = maxY;
    view.frame = frame;
}

- (void)sizeToFit {
    [super sizeToFit];
    [self sizeViewToFit:self forceHeight:YES];
}

- (void)fixContentSize:(UIScrollView*)scrollView {
    CGFloat maxX = 0, maxY = 0;
    for (UIView* subview in scrollView.subviews) {
        maxX = fmaxf(maxX, CGRectGetMaxX(subview.frame));
        maxY = fmaxf(maxY, CGRectGetMaxY(subview.frame));
    }
    scrollView.contentSize = CGSizeMake(maxX, maxY);
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
    return _namedColors[name] ?: [UIColor clearColor];
}

+ (void)setColor:(UIColor*)color forName:(NSString*)name {
    if (!_namedColors) _namedColors = [NSMutableDictionary dictionary];
    _namedColors[name] = color;
}

+ (void)addColorsFromDictionary:(NSDictionary*)colors {
    for (NSString *name in colors) {
        [self setColor:[UIColor colorFromHex:colors[name]] forName:name];
    }
}

-(void)addSubview:(UIView *)view {
    if ([view isKindOfClass:[NWLayoutView class]]) {
        NSDictionary *otherChildren = ((NWLayoutView*)view)->_childrenById;
        for (NSString* name in otherChildren) {
            if (!_childrenById[name]) _childrenById[name] = otherChildren[name];
        }
    }
    [super addSubview:view];
}

- (void)addSubview:(UIView *)view withId:(NSString*)name {
    [self addSubview:view];
    _childrenById[name] = view;
}

- (void)chooseSegment:(UISegmentedControl*)control {
    NSString *controlId;
    for (NSString *name in _childrenById) {
        if (_childrenById[name] == control) {
            controlId = name;
            break;
        }
    }
    if (!controlId) {
        NSLog(@"ERROR: Cannot show/hide nodes for segmentedcontrol without an id");
        return;
    }
    UIView *childContainer = _childrenById[[NSString stringWithFormat:@"%@_views", controlId]];
    if (!childContainer) {
        NSLog(@"ERROR: no child nodes to display for segmentedcontrol with id %@", controlId);
        return;
    }
    CGRect frame = childContainer.frame;
    CGFloat height = frame.size.height;
    for (int i = 0; i < childContainer.subviews.count; i++) {
        ((UIView*)childContainer.subviews[i]).hidden = i != control.selectedSegmentIndex;
    }
    height = CGRectGetMaxY(((UIView*)childContainer.subviews[control.selectedSegmentIndex]).frame);
    frame.size.height = height;
    childContainer.frame = frame;
    
    UIView *parent = [childContainer superview];
    if (parent.subviews.count == 2 && control.superview == parent) {
        CGRect parentRect = parent.frame;
        parentRect.size.height = CGRectGetMaxY(frame);
        parent.frame = parentRect;
    }
    // TODO: make a helper function for fixing layout issues in general, using _attributesById
    while (parent && parent != self) {
        if ([parent isKindOfClass:[UIScrollView class]]) {
            CGFloat maxX = 0, maxY = 0;
            for (UIView* subview in parent.subviews) {
                maxX = fmaxf(maxX, CGRectGetMaxX(subview.frame));
                maxY = fmaxf(maxY, CGRectGetMaxY(subview.frame));
            }
            ((UIScrollView*)parent).contentSize = CGSizeMake(maxX, maxY);
        }
        parent = [parent superview];
    }
}

- (NSMutableDictionary*)getFormValues {
    NSMutableDictionary *values = [_formValuesById mutableCopy];
    for (NSString *name in _childrenById) {
        UIView *child = _childrenById[name];
        if ([child isKindOfClass:[UIDatePicker class]]) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            UIDatePicker *dp = (UIDatePicker*)child;
            if (dp.datePickerMode == UIDatePickerModeDate) {
                [dateFormat setDateFormat:@"yyyy-MM-dd"];
            } else if (dp.datePickerMode == UIDatePickerModeDateAndTime) {
                [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            } else if (dp.datePickerMode == UIDatePickerModeTime) {
                [dateFormat setDateFormat:@"HH:mm:ss"];
            }
            values[name] = [dateFormat stringFromDate:dp.date];
        } else if ([child respondsToSelector:@selector(formValue)]) {
            values[name] = [child performSelector:@selector(formValue)];
        } else if ([child isKindOfClass:[UITextField class]]) {
            values[name] = ((UITextField*)child).text;
        }
    }
    return values;
}

- (NSString*)getDictValue:(NSString *)varExpr forNode:(UIView *)node property:(NSString*)property {
    varExpr = [varExpr stringByTrimmingCharactersInSet:
               [NSCharacterSet whitespaceCharacterSet]];
    // TODO: add basic filter support, eg formatting numbers
    // TODO: support a.b
    if (_dataMappedNodes[varExpr]) {
        if (_dataMappedNodes[varExpr][property]) {
            [_dataMappedNodes[varExpr][property] addObject:node];
        } else {
            _dataMappedNodes[varExpr][property] = [NSMutableArray arrayWithObject:node];
        }
    } else {
        _dataMappedNodes[varExpr] = [NSMutableDictionary dictionaryWithObject:[NSMutableArray arrayWithObject:node] forKey:property];
    }
    return [self getDictValue:varExpr];
}

- (NSString*)getDictValue:(NSString *)varExpr {
    id value = _dictValues[varExpr];
    if (value && ![value isKindOfClass:[NSString class]]) {
        if ([value isKindOfClass:[NSNull class]]) {
            value = @"";
        } else {
            value = [value stringValue];
        }
        _dictValues[varExpr] = value;
    }
    return value ?: @"";
}

- (NSDictionary*)dictValues {
    return _dictValues;
}

- (void)setDictValues:(NSDictionary *)dictValues {
    if (_lastDictValues == dictValues) return;
    _lastDictValues = dictValues;
    _dictValues = [dictValues mutableCopy];
    for (NSString *key in _dataMappedNodes) {
        for (NSString *valueKey in _dataMappedNodes[key]) {
            NSArray *nodes = _dataMappedNodes[key][valueKey];
            for (UIView *node in nodes) {
                [node applyProperty:valueKey value:[self getDictValue:key] layoutView:self];
            }
        }
    }
}

- (void)setDictValue:(NSString*)value forKey:(NSString*)key {
    _dictValues[key] = value;
    for (NSString *valueKey in _dataMappedNodes[key]) {
        NSArray *nodes = _dataMappedNodes[key][valueKey];
        for (UIView *node in nodes) {
            [node applyProperty:valueKey value:value layoutView:self];
        }
    }
}

@end
