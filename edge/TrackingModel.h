//
//  TrackingModel.h
//  edge
//
//  Created by Ryan G Walton on 8/28/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "ContentModel.h"

@class Tracking;

#define MAX_TRACKING_ITEMS  100

// web services urls defined here
#define TRACKING_WEB_SERVICE_URL  WEB_SERVICE_BASE_SERVER //@"http://eprodevbox.com"

//#define TRACKING_WEB_SERVICE_URL    @"http://192.168.1.108"

#define POST_TRACKING_SERVICE       @"/activitytrackingapi/trackactivity"

#define TRACKING_ACTIVITY_VIEWED_PAGE                                           @"viewedPage"
#define TRACKING_ACTIVITY_VIEWED_PRODUCT                                        @"viewedProduct"
#define TRACKING_ACTIVITY_VIEWED_PRODUCT_ASSET                                  @"viewedProductAsset"
#define TRACKING_ACTIVITY_VIEWED_PRODUCT_INTERACTIVE_VIEWER_ASSET               @"viewedProductInteractiveViewerAsset"
#define TRACKING_ACTIVITY_VIEWED_PROCEDURE                                      @"viewedProcedure"
#define TRACKING_ACTIVITY_VIEWED_PROCEDURE_SPECIALTY                            @"viewedProcedureSpecialty"
#define TRACKING_ACTIVITY_VIEWED_PROCEDURE_ASSET                                @"viewedProcedureAsset"
#define TRACKING_ACTIVITY_VIEWED_PROCEDURE_INTERACTIVE_VIEWER_ASSET             @"viewedProcedureInteractiveViewerAsset"
#define TRACKING_ACTIVITY_VIEWED_SPECIALTY_INTERACTIVE_VIEWER_ASSET             @"viewedSpecialtyInteractiveViewerAsset"
#define TRACKING_ACTIVITY_VIEWED_PROCEDURE_ARC                                  @"viewedProcedureARC"
#define TRACKING_ACTIVITY_VIEWED_PROCEDURE_ARC_PRODUCT                          @"viewedProcedureARCProduct"
#define TRACKING_ACTIVITY_SUBMITTED_MIR_FORM                                    @"submittedMIRForm"
#define TRACKING_ACTIVITY_SUBMITTED_FEEDBACK_FORM                               @"submittedFeedbackForm"
#define TRACKING_ACTIVITY_ADDED_FAVORITE                                        @"addedContentToFavorite"
#define TRACKING_ACTIVITY_ADDED_FAVORITE_ON_PRODUCT                             @"addedProductToFavorite"
#define TRACKING_ACTIVITY_ADDED_FAV_TO_DASH                                     @"addedFavoriteToDashboard"
#define TRACKING_ACTIVITY_ADDED_SURGEON                                         @"addedSurgeon"
#define TRACKING_ACTIVITY_SENT_EMAIL                                            @"sentEmail"
#define TRACKING_ACTIVITY_USED_SEARCH                                           @"usedSearch"

@interface TrackingModel : NSObject

@property (nonatomic, strong) NSDictionary *trackingResponseHeader;

+ (TrackingModel*) sharedInstance;

- (void) createTrackingDataWithUserName:(NSString *)name resource:(NSString *)resource activityCode:(NSString *)activityCode timestamp:(NSString *)timestamp;
- (void) createTrackingDataWithResource:(NSString *)resource activityCode:(NSString *)activityCode;
- (void) trackingWithParams:(NSDictionary*)params;
- (void) callTracking;

- (NSFetchedResultsController *) trackingFRC;

@end
