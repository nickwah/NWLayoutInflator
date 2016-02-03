//
//  NWCollectionView.m
//  gossip
//
//  Created by Nicholas White on 2/2/16.
//  Copyright © 2016 Nicholas White. All rights reserved.
//

#import "NWCollectionView.h"
#import "NWLayoutView.h"

@interface NWCollectionView()<UIScrollViewDelegate>

@end

#define BUFFER 30
#define SCROLL_THRESHOLD 10

@implementation NWCollectionView {
    NSMutableArray *_freeViews;
    NSMutableArray *_savedHeights;
    NSMutableArray *_collectionItems;
    NSMutableDictionary<NSNumber*,NWLayoutView*> *_activeViews;
    UIScrollView *_scrollView;
    int _minRow;
    int _maxRow; // the maximum row number is _maxRow - 1
    
    CGFloat _lastScrollEvent;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _freeViews = [NSMutableArray array];
        _activeViews = [NSMutableDictionary dictionary];
        _savedHeights = [NSMutableArray array];
        _collectionItems = [NSMutableArray array];
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.scrollEnabled = YES;
        [self addSubview:_scrollView];
        _scrollView.delegate = self;
        _estimatedHeight = 100;
        _numColumns = 1;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _scrollView.frame = self.bounds;
    [self renderViews];
}

- (void)renderViews {
    CGFloat minY = 0;
    CGFloat maxY = 0;
    if (_maxRow > _minRow) {
        minY = _activeViews[@(_minRow)].frame.origin.y;
        maxY = CGRectGetMaxY(_activeViews[@(_maxRow - 1)].frame);
    }
    CGFloat maxRequiredY = _scrollView.contentOffset.y + _scrollView.frame.size.height;
    while (maxY < maxRequiredY && _collectionItems.count > _maxRow) {
        NWLayoutView *view = [self viewForRow:_maxRow];
        view.frame = CGRectMake(0, maxY, view.frame.size.width, view.frame.size.height);
        maxY += view.frame.size.height;
        if (_savedHeights.count > _maxRow) {
            _savedHeights[_maxRow] = @(view.frame.size.height);
        } else {
            [_savedHeights addObject:@(view.frame.size.height)];
        }
        _maxRow++;
    }
    CGFloat minRequiredY = fmax(_scrollView.contentOffset.y - BUFFER, 0);
    while (minY > minRequiredY && _minRow > 0) {
        _minRow--;
        NWLayoutView *view = [self viewForRow:_minRow];
        minY -= view.frame.size.height;
        view.frame = CGRectMake(0, minY, view.frame.size.width, view.frame.size.height);
    }
    CGFloat totalHeight = 0;
    for (NSNumber *heightNum in _savedHeights) {
        totalHeight += heightNum.floatValue;
    }
    totalHeight += _estimatedHeight * (_collectionItems.count - _savedHeights.count);
    if (_scrollView.contentSize.height != totalHeight) {
        _scrollView.contentSize = CGSizeMake(self.frame.size.width, totalHeight);
    }
}

- (void)recycleViews {
    CGFloat top = _scrollView.contentOffset.y;
    CGFloat bottom = top + _scrollView.frame.size.height;
    NSMutableArray *removeKeys = [NSMutableArray array];
    for (int i = _minRow; i < _maxRow; i++) {
        NSNumber *key = @(i);
        NWLayoutView *view = _activeViews[key];
        CGRect frame = view.frame;
        if (CGRectGetMaxY(frame) < top - BUFFER) {
            [_activeViews removeObjectForKey:key];
            [_freeViews addObject:view];
            _minRow++;
        } else {
            break;
        }
    }
    for (int i = _maxRow - 1; i >= _minRow; i--) {
        NSNumber *key = @(i);
        NWLayoutView *view = _activeViews[key];
        CGRect frame = view.frame;
        if (frame.origin.y > bottom + BUFFER) {
            [_activeViews removeObjectForKey:key];
            [_freeViews addObject:view];
            _maxRow--;
        } else {
            break;
        }
    }
    [_activeViews removeObjectsForKeys:removeKeys];
}


- (NWLayoutView *)viewForRow:(int)row {
    NWLayoutView *layoutView = _activeViews[@(row)];
    if (!layoutView) {
        if (_freeViews.count) {
            NSLog(@"recycling a row");
            layoutView = _freeViews.lastObject;
            [_freeViews removeLastObject];
        } else {
            layoutView = [[NWLayoutView alloc] initWithLayout:_layoutName andFrame:CGRectMake(0, 0, self.frame.size.width / 2, _estimatedHeight) andDelegate:self];
            [_scrollView addSubview:layoutView];
            NSLog(@"created a row");
        }
        _activeViews[@(row)] = layoutView;
    }
    [layoutView setDictValues:_collectionItems[row]];
    [layoutView sizeToFit];
    return layoutView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (fabs(_lastScrollEvent - scrollView.contentOffset.y) > SCROLL_THRESHOLD) {
        [self recycleViews];
        [self renderViews];
        _lastScrollEvent = scrollView.contentOffset.y;
    }
}

- (void)setCollectionItems:(NSArray<NSDictionary *> *)collectionItems {
    _collectionItems = collectionItems.mutableCopy;
    _savedHeights = [NSMutableArray array];
    [self renderViews];
}

- (void)addCollectionItem:(NSDictionary*)item {
    [_collectionItems addObject:item];
    [self renderViews];
}

// So you can include this whole thing in a layout xml and set the data array via collectionItems="{{ items }}"
- (void)apply_collectionItems:(id)items layoutView:(NWLayoutView*)layoutView {
    if ([items isKindOfClass:[NSArray class]]) {
        self.collectionItems = items;
    }
}

@end
