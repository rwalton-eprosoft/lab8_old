//
//  ContentSyncViewController.h
//  edge
//
//  Created by Vijaykumar on 7/21/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentSyncModel.h"
#import "TabBarViewController.h"
#define SMOOTHING_FACTOR 0.005
#import "AppDelegate.h"
#import "JEProgressView.h"
@interface ContentSyncViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *contentSyncView;
@property (strong, nonatomic) IBOutlet UIView *contentSyncProgress;

@property (nonatomic, strong) IBOutlet UIButton *startBtn;
@property (nonatomic, strong) IBOutlet UIButton *pauseBtn;
@property (nonatomic, strong) IBOutlet UIButton *resumeBtn;
@property (nonatomic, strong) IBOutlet UIButton *doneBtn;
@property (nonatomic, strong) IBOutlet UILabel  *downloadFileLbl;
@property (nonatomic, strong) IBOutlet UILabel  *bytesDownloadedLbl;
@property (nonatomic, strong) IBOutlet UILabel  *promptLbl;
@property (nonatomic, strong) IBOutlet UITextView  *errorsLog;
@property (nonatomic, assign) float previousSizeComplete;
@property (nonatomic, assign) NSTimeInterval start;
@property (nonatomic, assign) AppDelegate * appDelegate;

- (IBAction) handleStartBtnTouched;
- (IBAction) handlePauseBtnTouched;
- (IBAction) handleResumeBtnTouched;
- (IBAction) handleDoneBtnTouched;

@property (strong, nonatomic) IBOutlet UILabel *filesCompleted;
@property (strong, nonatomic) IBOutlet UILabel *totalFiles;
@property (strong, nonatomic) IBOutlet UILabel *sizeCompleted;
@property (strong, nonatomic) IBOutlet UILabel *totalSize;
@property (strong, nonatomic) IBOutlet UILabel *timeRemainingToComplete;
@property (strong, nonatomic) IBOutlet UILabel *downloadSpeed;

@property (strong, nonatomic) IBOutlet JEProgressView *fileProgress;
@property (strong, nonatomic) IBOutlet JEProgressView *totalProgress;
@property (strong, nonatomic) IBOutlet UILabel *percentComplete;
@property (strong, nonatomic) IBOutlet UILabel *fileNameLabel;

@property (strong, nonatomic) IBOutlet TabBarViewController *delegate;

@property (retain) IBOutlet UITableView* uiTableView;
@property (retain) IBOutlet UITextField *keyValuePair;

@property (retain) NSTimer* downloadTimer;

@property (retain) IBOutlet ContentSyncModel* contentSync;

- (void) startDownloads;

@property (assign, nonatomic) float averageSpeed;
@property (assign, nonatomic) float lastSpeed;
@property (assign, nonatomic) float previousDownloadedSize;
@property (assign, nonatomic) BOOL isDownloading;
@property (assign, nonatomic) BOOL syncFromScheduler;

- (void) reset;
@property (strong, nonatomic) IBOutlet UILabel *resyncLabel;
@property (strong, nonatomic) IBOutlet UIButton *continueDownloadsInBackgroundBtn;

@end
