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
#define TOTAL_ROW_LIMIT 10000
#define MAX_COLUMNS 10

@implementation NWCollectionView {
    NSMutableArray *_freeViews;
    NSMutableArray<NSNumber*> *_savedHeights;
    NSMutableArray *_collectionItems;
    NSMutableDictionary<NSNumber*,NWLayoutView*> *_activeViews;
    Byte _columnMap[TOTAL_ROW_LIMIT];
    CGPoint _originMap[TOTAL_ROW_LIMIT];
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
        memset(_columnMap, -1, TOTAL_ROW_LIMIT);
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _scrollView.frame = self.bounds;
    [self renderViews];
}

- (void)renderViews {
    CGFloat minY = 0, maxY = 0;
    CGFloat minColY[_numColumns];
    CGFloat maxColY[_numColumns];
    memset(minColY, -999, sizeof(minColY));
    memset(maxColY, 0, sizeof(maxColY));
    if (_maxRow > _minRow) {
        minY = _activeViews[@(_minRow)].frame.origin.y;
        minColY[_columnMap[_minRow]] = minY;
        maxY = CGRectGetMaxY(_activeViews[@(_maxRow - 1)].frame);
        maxColY[_columnMap[_maxRow - 1]] = maxY;
    }
    for (int i = _minRow; i < _maxRow; i++) {
        int col = _columnMap[i];
        if (minColY[col] == -999) {
            minColY[col] = _activeViews[@(i)].frame.origin.y;
        }
        maxColY[col] = fmax(CGRectGetMaxY(_activeViews[@(i)].frame), maxColY[col]);
    }
    CGFloat maxRequiredY = _scrollView.contentOffset.y + _scrollView.frame.size.height;
    int nextCol = 0;
    CGFloat nextColMaxY = maxColY[nextCol];
    while (maxY < maxRequiredY && _collectionItems.count > _maxRow) {
        for (int i = _numColumns - 1; i >= 0; i--) {
            if (maxColY[i] <= nextColMaxY) {
                nextColMaxY = maxColY[i];
                nextCol = i;
            }
        }
        NWLayoutView *view = [self viewForRow:_maxRow];
        _columnMap[_maxRow] = nextCol;
        view.frame = CGRectMake(nextCol * view.frame.size.width, nextColMaxY, view.frame.size.width, view.frame.size.height);
        _originMap[_maxRow] = view.frame.origin;
        nextColMaxY += view.frame.size.height;
        maxY = nextColMaxY;
        maxColY[nextCol] = nextColMaxY;
        if (_savedHeights.count > _maxRow) {
            _savedHeights[_maxRow] = @(view.frame.size.height);
        } else {
            [_savedHeights addObject:@(view.frame.size.height)];
        }
        for (int i = 0; i < _numColumns; i++) {
            maxY = fmin(maxY, maxColY[i]);
        }
        _maxRow++;
    }
    CGFloat minRequiredY = fmax(_scrollView.contentOffset.y - BUFFER, 0);
    while (minY > minRequiredY && _minRow > 0) {
        _minRow--;
        NWLayoutView *view = [self viewForRow:_minRow];
        int col = _columnMap[_minRow];
        CGRect frame = view.frame;
        frame.origin = _originMap[_minRow];
        minY = minColY[col] = frame.origin.y;
        for (int i = 0; i < _numColumns; i++) {
            minY = fmax(minY, minColY[i]);
        }
        frame.size.height = _savedHeights[_minRow].floatValue;
        view.frame = frame;
    }
    CGFloat totalHeight = 0;
    for (int i = _maxRow; i < _savedHeights.count; i++) maxColY[_columnMap[i]] += _savedHeights[i].floatValue;
    for (int i = 0; i < _numColumns; i++) totalHeight = fmax(totalHeight, maxColY[i]);
    totalHeight += _estimatedHeight * (_collectionItems.count - _savedHeights.count) / _numColumns;
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
            layoutView = _freeViews.lastObject;
            [_freeViews removeLastObject];
        } else {
            layoutView = [[NWLayoutView alloc] initWithLayout:_layoutName andFrame:CGRectMake(0, 0, self.frame.size.width / _numColumns, _estimatedHeight) andDelegate:self.delegate];
            [_scrollView addSubview:layoutView];
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
    _scrollView.contentOffset = CGPointMake(0, -self.contentInset.top);
    _collectionItems = collectionItems.mutableCopy;
    _savedHeights = [NSMutableArray array];
    _minRow = 0;
    _maxRow = 0;
    [_freeViews addObjectsFromArray:_activeViews.allValues];
    [_activeViews removeAllObjects];
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

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _scrollView.contentInset = contentInset;
}

- (UIEdgeInsets)contentInset {
    return _scrollView.contentInset;
}

@end
