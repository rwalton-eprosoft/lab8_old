//
//  PresentationMaster.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PresentationDetail;

@interface PresentationMaster : NSManagedObject

@property (nonatomic, retain) NSDate * crtDt;
@property (nonatomic, retain) NSString * footer;
@property (nonatomic, retain) NSString * header;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * presMasId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * subTitle1;
@property (nonatomic, retain) NSString * subTitle2;
@property (nonatomic, retain) NSString * subTitle3;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * uptDt;
@property (nonatomic, retain) NSSet *PresentationMasterToPresentationDetail;
@end

@interface PresentationMaster (CoreDataGeneratedAccessors)

- (void)addPresentationMasterToPresentationDetailObject:(PresentationDetail *)value;
- (void)removePresentationMasterToPresentationDetailObject:(PresentationDetail *)value;
- (void)addPresentationMasterToPresentationDetail:(NSSet *)values;
- (void)removePresentationMasterToPresentationDetail:(NSSet *)values;

@end
