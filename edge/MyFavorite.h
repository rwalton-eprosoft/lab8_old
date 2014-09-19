//
//  MyFavorite.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content;

@interface MyFavorite : NSManagedObject

@property (nonatomic, retain) NSNumber * cntId;
@property (nonatomic, retain) NSNumber * contentCatId;
@property (nonatomic, retain) NSDate * crtDt;
@property (nonatomic, retain) NSNumber * favId;
@property (nonatomic, retain) NSNumber * isOnDashboard;
@property (nonatomic, retain) NSNumber * isProduct;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * uptDt;
@property (nonatomic, retain) Content *favoriteToContent;

@end
