//
//  SearchResultsGridLayout.m
//  edge
//
//  Created by iPhone Developer on 8/23/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "SearchResultsGridLayout.h"

@implementation SearchResultsGridLayout

- (id) init
{
    if (self = [super init])
    {
        //        [self setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [self setMinimumInteritemSpacing:10.f];
        [self setMinimumLineSpacing:10.f];
        [self setItemSize:CGSizeMake(140.f, 200.f)];
        //        [self setSectionInset:UIEdgeInsetsMake(20.f, 20.f, 20.f, 20.f)];
        [self setHeaderReferenceSize:CGSizeMake(677.f, 50.f)];
        
    }
    return self;
}

@end
