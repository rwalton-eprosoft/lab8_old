//
//  ContentDownloadVC.h
//  edge
//
//  Created by iPhone Developer on 6/7/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentDownloadModel.h"
#import "ContentSyncModel.h"
#import "JEProgressView.h"

#define SMOOTHING_FACTOR 0.005

@interface ContentDownloadVC : UIViewController <ContentDownloadModelDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *spectrumImageView;

@property (nonatomic, strong) IBOutlet UIButton *startBtn;
@property (nonatomic, strong) IBOutlet UIButton *pauseBtn;
@property (nonatomic, strong) IBOutlet UIButton *resumeBtn;
@property (nonatomic, strong) IBOutlet UIButton *doneBtn;
@property (nonatomic, strong) IBOutlet UILabel  *downloadFileLbl;
@property (nonatomic, strong) IBOutlet UILabel  *bytesDownloadedLbl;
@property (nonatomic, strong) IBOutlet UILabel  *promptLbl;

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
@property (strong, nonatomic) IBOutlet UILabel *totalCommonFiles;

@property (strong, nonatomic) IBOutlet JEProgressView *fileProgress;
@property (strong, nonatomic) IBOutlet JEProgressView *totalProgress;
@property (strong, nonatomic) IBOutlet UILabel *percentComplete;
@property (strong, nonatomic) IBOutlet UILabel *fileNameLabel;

@property (retain) IBOutlet UITableView* uiTableView;
@property (retain) IBOutlet UITextField *keyValuePair;

@property (retain) NSTimer* downloadTimer;

@property (retain) IBOutlet ContentSyncModel* contentSync;

@property (strong, nonatomic) IBOutlet UILabel *fileProgressLabel;
@property (assign, nonatomic) float averageSpeed;
@property (assign, nonatomic) float lastSpeed;
@property (assign, nonatomic) float previousDownloadedSize;

@end


