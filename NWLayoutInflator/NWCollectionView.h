//
//  NWCollectionView.h
//  gossip
//
//  Created by Nicholas White on 2/2/16.
//  Copyright © 2016 Nicholas White. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NWCollectionView;

@protocol NWCollectionDelegate <NSObject>

- (void)collectionViewDidScroll:(NWCollectionView*)collectionView;

@end

@interface NWCollectionView : UIView

@property (nonatomic) NSString* layoutName;
@property (nonatomic) NSMutableArray<NSDictionary*>* collectionItems;
@property (nonatomic) CGFloat estimatedHeight;
@property (nonatomic) int numColumns;
@property (nonatomic) UIEdgeInsets contentInset;
@property (nonatomic) CGPoint contentOffset;
@property (nonatomic, readonly) CGSize contentSize;

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) id<NWCollectionDelegate>collectionDelegate;

- (void)addCollectionItem:(NSDictionary*)item;
- (void)prependCollectionItem:(NSDictionary*)item;
- (void)insertCollectionItem:(NSDictionary*)item atIndex:(int)index;
- (void)reloadItemAtIndex:(int)index;
- (void)removeCollectionItemAtIndex:(int)index;

@end
