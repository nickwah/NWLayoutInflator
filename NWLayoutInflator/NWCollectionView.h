//
//  NWCollectionView.h
//  gossip
//
//  Created by Nicholas White on 2/2/16.
//  Copyright © 2016 Nicholas White. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NWCollectionView : UIView

@property (nonatomic) NSString* layoutName;
@property (nonatomic) NSArray<NSDictionary*>* collectionItems;
@property (nonatomic) CGFloat estimatedHeight;
@property (nonatomic) int numColumns;
@property (nonatomic) UIEdgeInsets contentInset;

@property (nonatomic, weak) id delegate;

- (void)addCollectionItem:(NSDictionary*)item;

@end
