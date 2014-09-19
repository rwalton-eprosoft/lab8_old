//
//  CustomLineLayout.m
//  edge
//
//  Created by iPhone Developer on 7/7/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "CustomListLayout.h"

@implementation CustomListLayout

- (id) init
{
    if (self = [super init])
    {
        [self setScrollDirection:UICollectionViewScrollDirectionVertical];
        [self setMinimumInteritemSpacing:10.f];
        [self setMinimumLineSpacing:10.f];
        [self setItemSize:CGSizeMake(657, 165)];
        //[self setSectionInset:UIEdgeInsetsMake(20.f, 20.f, 20.f, 20.f)];
        [self setHeaderReferenceSize:CGSizeMake(657.f, 50.f)];
    }
    return self;
}

@end
