//
//  SharedLink.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Surgeon;

@interface SharedLink : NSManagedObject

@property (nonatomic, retain) NSNumber * cntId;
@property (nonatomic, retain) NSNumber * contentCatId;
@property (nonatomic, retain) NSDate * crtDt;
@property (nonatomic, retain) NSString * externalLink;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * thumbnailImgPath;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Surgeon *sharedLinkToSurgeon;

@end
