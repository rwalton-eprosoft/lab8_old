//
//  MyRecentlyViewed.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content, Product;

@interface MyRecentlyViewed : NSManagedObject

@property (nonatomic, retain) NSDate * crtDt;
@property (nonatomic, retain) NSNumber * isProduct;
@property (nonatomic, retain) Content *myRecentlyViewedToContent;
@property (nonatomic, retain) Product *myRecentlyViewedToProduct;

@end
