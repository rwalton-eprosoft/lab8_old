//
//  PresentationDetail.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PresentationMaster;

@interface PresentationDetail : NSManagedObject

@property (nonatomic, retain) NSDate * crtDt;
@property (nonatomic, retain) NSNumber * presDetId;
@property (nonatomic, retain) NSNumber * presMasId;
@property (nonatomic, retain) NSNumber * slideOrder;
@property (nonatomic, retain) NSString * slideTitle;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSDate * uptDt;
@property (nonatomic, retain) PresentationMaster *PresentationDetailToPresentationMaster;

@end
