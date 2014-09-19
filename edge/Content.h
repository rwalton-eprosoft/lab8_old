//
//  Content.h
//  edge
//
//  Created by Ryan G Walton on 9/12/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MyFavorite, MyRecentlyViewed, SharedLink;

@interface Content : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * bitrate;
@property (nonatomic, retain) NSNumber * cntId;
@property (nonatomic, retain) NSNumber * contentCatId;
@property (nonatomic, retain) NSString * approvalStatus;
@property (nonatomic, retain) NSNumber * crtBy;
@property (nonatomic, retain) NSDate * crtDt;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * expDt;
@property (nonatomic, retain) NSString * externalLink;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * isSharable;
@property (nonatomic, retain) NSString * keywords;
@property (nonatomic, retain) NSString * md5hash;
@property (nonatomic, retain) NSString * mime;
@property (nonatomic, retain) NSNumber * owner;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSString * quality;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * thumbnailImgPath;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * uptBy;
@property (nonatomic, retain) NSDate * uptDt;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) MyFavorite *contentToMyFavorite;
@property (nonatomic, retain) MyRecentlyViewed *contentToMyRecentlyViewed;
@property (nonatomic, retain) SharedLink *contentToSharedLink;

@end
