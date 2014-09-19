//
//  ContentSyncProcess.h
//  edge
//
//  Created by Vijaykumar on 7/29/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadManager.h"
#import "TabBarViewController.h"
#import "JEProgressView.h"
#define SMOOTHING_FACTOR 0.005

@interface ContentSyncModel : NSObject

@property (nonatomic, strong) NSArray *myEntitlements;
@property (nonatomic, strong) JEProgressView* fileProgress;
@property (nonatomic, strong) UILabel* fileNameLabel;

- (NSString*) calculateSpeed : (unsigned long long) downloaded;

- (NSString*) calculateRemainingTime : (unsigned long long) total :
    (unsigned long long) downloaded :
        (NSTimeInterval) timespent;

- (void)initiateDownloads : (JEProgressView*) fileProgressView withFileNameProgress: (UILabel*) fileNameLabel;

- (NSMutableArray*)specialityDownloadList;

@property (assign) BOOL downloadInProgress;

+ (id)sharedContentSync;

- (void) resetData;

@property (nonatomic, strong) NSString *humanReadableSpeed;
@property (nonatomic, strong) TabBarViewController *customTabBarViewController;
@property (nonatomic, strong) NSString *humanReadableRemaingTime;
@property (nonatomic, assign) double speedInBytesPerSecond;
- (void) resumeDownloads;

@property (assign, nonatomic) float averageSpeedProgress;
@property (assign, nonatomic) float averageSpeed;
@property (assign, nonatomic) float lastSpeed;
@property (assign, nonatomic) float previousDownloadedSize;
@property (nonatomic, assign) int syncFromDashboard;

@property (nonatomic, assign) int pageSize;
- (void) refreshDownloads : (int) page;

@end
