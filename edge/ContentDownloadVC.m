//
//  ContentDownloadVC.m
//  edge
//
//  Created by iPhone Developer on 6/7/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ContentDownloadVC.h"
#import "DownloadManager.h"
#import "ContentDownloadModel.h"
#import "MBProgressHUD.h"
#import "RegistrationModel.h"
#import "DataValidator.h"
#import "VideoPlayerViewController.h"
#import "MyProfile.h"
#import "MyEntitlement.h"
#import "SpecialityDownloadCell.h"
#import "DashboardModel.h"
#import "PrivacyPolicyVC.h"
#import "ContentSyncVerifier.h"
#include "Constants.h"
#include "BytesConversionHelper.h"
#include "KeyValue.h"

@interface ContentDownloadVC ()
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSArray *myEntitlements;
@end

@implementation ContentDownloadVC

NSMutableArray *keyvalueList;
unsigned long long previousDownloadedBytes;

- (void) registerForWifiEvents
{
    [self unregisterForWifiEvents];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNoWifi) name:APP_EVENT_NO_WIFI object:nil];
}

- (void) handleNoWifi {
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Your initial content download was unsuccessful. To use the platform, it’s MANDATORY to complete the Content Download.  Please ensure to stay connected to internet via WiFi to complete the process." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    alert.tag = 10;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10) {
        if (buttonIndex == alertView.cancelButtonIndex){
            exit(0);
        }
    }
}

- (void) unregisterForWifiEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_NO_WIFI object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)registerDownloadNotification
{
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]  addObserver:self
											  selector:@selector(handleAllDownloadComplete:)
												  name:DOWNLOAD_ALL_COMPLETE_EVENT
												object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self
											  selector:@selector(notifyDownloadComplete:)
												  name:BROADCAST_DOWNLOAD_COMPLETE_EVENT
												object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerDownloadNotification];
    
    _startBtn.hidden = YES;
    _fileProgress.hidden = YES;
    _pauseBtn.hidden = YES;
    _resumeBtn.hidden = YES;
    _doneBtn.frame = _pauseBtn.frame;
    CGRect frame2 = _sizeCompleted.frame;
    frame2.origin.x = frame2.origin.x - 10;
    _sizeCompleted.frame = frame2;
    
    UIImage *progress = [UIImage imageNamed:@"progressbar_lightgrey_bg.png"];
    UIImage *track = [UIImage imageNamed:@"progressbar_darkgrey_bg.png"];
    
    //Total File Progress
    [_totalProgress setProgressImage:progress];
    [_totalProgress setTrackImage:track];
    
    _contentSync = [ContentSyncModel sharedContentSync];
    [self startDownloads];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        _uiTableView.userInteractionEnabled = NO;
    }

    [self unregisterForWifiEvents];
    [self registerForWifiEvents];
}

- (void)rotateImageView
{
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.spectrumImageView setTransform:CGAffineTransformRotate(self.spectrumImageView.transform, M_PI_2)];
    }completion:^(BOOL finished){
        if (finished) {
            [self rotateImageView];
        }
    }];
    
}

- (void) calculateSpeed
{
    
    if (_downloadTimer.timeInterval == START_INTERVAL) { //Only for the firt time, process speed in START_INTERVAL seconds and continue with DOWNLOAD_TIMER_INTERVAL seconds
        [_downloadTimer invalidate];
        _downloadTimer = nil;
        _downloadTimer = [NSTimer scheduledTimerWithTimeInterval:DOWNLOAD_TIMER_INTERVAL
                                                          target:self
                                                        selector:@selector(calculateSpeed)
                                                        userInfo:nil
                                                         repeats:YES];
    }
    
    DownloadManager *downloadMan = [DownloadManager sharedManager];
    
    unsigned long long downloaded = (downloadMan.totalFileSizeCompleted);
    unsigned long long total = downloadMan.totalFileSize * 1024.0f;
    _timeRemainingToComplete.text = [_contentSync calculateRemainingTime: total :downloaded :0.0];
    _downloadSpeed.text = [_contentSync calculateSpeed :0];
}

- (void) viewDidDisappear:(BOOL)animated {
    [self unregisterNotifications];
    [[DownloadManager sharedManager] unregisterNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark -

- (void) startDownloads
{
    //_promptLbl.text = @"Please be patient while content is downloaded based on your Speciality enablements.";
    //[_contentSync initiateDownloads: _fileProgress];
    [_contentSync initiateDownloads:_fileProgress withFileNameProgress:_fileNameLabel];
    
    keyvalueList = [_contentSync specialityDownloadList];
    
    if (keyvalueList.count > 0) {
        _downloadTimer = [NSTimer scheduledTimerWithTimeInterval:START_INTERVAL
                                                          target:self
                                                        selector:@selector(calculateSpeed)
                                                        userInfo:nil
                                                         repeats:YES];
        
        [self refreshTableView];
    }
    
    //move this to contentSync
    DownloadManager* downloadMan = [DownloadManager sharedManager];
    _totalFiles.text = [NSString stringWithFormat:@"%d", downloadMan.totalFiles];
    _totalSize.text =  [BytesConversionHelper convertBytesToString:[BytesConversionHelper convertKiloBytesToBytes:downloadMan.totalFileSize]];
}

#pragma mark -

-(void)handleAllDownloadComplete:(NSNotification*)pNotifcation
{
    //[_hud hide:YES];
    _timeRemainingToComplete.text = @"00:00:00";
    
    // indicate successful registration in the model
    [[RegistrationModel sharedInstance] setRegistrationComplete];
    
    // make sure dasboard is up to date
    [[DashboardModel sharedInstance] initModel];
    
    _downloadFileLbl.text = [NSString stringWithFormat:@"%@ download has completed.", _percentComplete.text];
    _bytesDownloadedLbl.text = @"";
    NSMutableArray* tempArray = [[NSMutableArray alloc] init];
    for (KeyValue* keyvalue in keyvalueList) {
        keyvalue.downloadState = @"checkbox-checked_16.png";
        keyvalue.downloadStatus = @"Completed";
        [tempArray addObject:keyvalue];
    }
    
    [keyvalueList removeAllObjects];
    [keyvalueList addObjectsFromArray:tempArray];
    
    DownloadManager* downloadMan = [DownloadManager sharedManager];
    downloadMan.isInitialSyncStillPending = NO;
    
    [self refreshTableView];
    [self allDownloadsComplete];
    [self unregisterForWifiEvents];
}

- (void) allDownloadsComplete
{
    //_startBtn.hidden = _pauseBtn.hidden = _resumeBtn.hidden = YES;
    _doneBtn.hidden = NO;
    
    [[[UIAlertView alloc] initWithTitle:@"Information" message:[NSString stringWithFormat:@"%@ download has completed.", _percentComplete.text] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
    if (_downloadTimer) [_downloadTimer invalidate];
    _downloadTimer = nil;
    [_contentSync resetData];
    _totalProgress.tintColor = [UIColor lightGrayColor];
    [self.spectrumImageView.layer removeAllAnimations];
    [[ContentSyncVerifier sharedInstance] disableBulbIcon];
    [self unregisterNotifications];
    
}

#pragma mark -
#pragma mark handle actions

- (IBAction) handleDataValidatorTouched {
    //    DataValidator* dq = [[DataValidator alloc] init];
    //    [dq getContentByContentCategory];
}

- (IBAction) handleVideoPlayerTouched {
}

- (IBAction) handleStartBtnTouched
{
    //_pauseBtn.hidden = NO;
    //_resumeBtn.hidden = NO;
    _startBtn.hidden = YES;
    [self startDownloads];
}

- (IBAction) handlePauseBtnTouched
{
    //_pauseBtn.hidden = YES;
    //_resumeBtn.hidden = NO;
}

- (IBAction) handleResumeBtnTouched
{
    //_resumeBtn.hidden = YES;
    //_pauseBtn.hidden = NO;
}

- (IBAction) handleDoneBtnTouched
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil ];
}

#pragma mark -

-(void) notifyDownloadComplete:(NSNotification*)pNotifcation
{
    DownloadManager *downloadMan = [DownloadManager sharedManager];
    
    if (downloadMan.downloadedFiles >= downloadMan.totalFiles)
        downloadMan.totalFilesCompleted = downloadMan.totalFiles;
    
    _filesCompleted.text = [NSString stringWithFormat:@"%d", downloadMan.downloadedFiles];
    
    float downloaded = (downloadMan.totalFileSizeCompleted);
    downloaded = downloaded * 1024.0f;
    float total = downloadMan.totalFileSize * 1024.0f;
    
    if (downloaded >= total)
        downloaded = total;
    
    _sizeCompleted.text  = [BytesConversionHelper convertBytesToString:downloaded];
    _totalProgress.progress = downloaded/total; //(float)downloadMan.downloadedFiles/(float)downloadMan.totalFiles;
    
    float X = downloaded;//(float)downloadMan.downloadedFiles;
    float Y = total;//(float)downloadMan.totalFiles;
    ////nslog(@"X = %f, Y = %f", X, Y);
    _percentComplete.text = [NSString stringWithFormat:@"%d%%", (int)(X/Y * 100)];
    
}

-(void) downloadStarted {
    
}

-(void) downloadFailed {
    
}

- (void) unregisterNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DOWNLOAD_ALL_COMPLETE_EVENT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BROADCAST_DOWNLOAD_COMPLETE_EVENT object:nil];
}

- (void) pauseDownloads
{
    
}

#pragma forTableView

- (void)refreshTableView {
    
    //[keyvalueList removeAllObjects];
    [_uiTableView reloadData];
    for (int i = 0; i < keyvalueList.count; i++) {
        NSIndexPath *cellIndexPath =  [NSIndexPath indexPathForRow:i inSection:0];
        [_uiTableView beginUpdates];
        [_uiTableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects: cellIndexPath , nil] withRowAnimation: UITableViewRowAnimationNone];
        [_uiTableView endUpdates];
    }
    //[keyvalueList removeAllObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return keyvalueList.count;
}

- (void)prepareCellLabel:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell :(CGRect) rect :(NSString*) data
{
    UILabel *label;
    label = [[UILabel alloc] initWithFrame:rect];
    label.text = [NSString stringWithFormat:@"%@", data];
    //label.font = [UIFont systemFontOfSize:14.0];
    label.tag = indexPath.row;
    label.textColor = [UIColor blackColor];
    [cell.contentView addSubview:label];
    [_uiTableView setEstimatedRowHeight:44.0];
    [tableView setEstimatedRowHeight:44.0];
    _uiTableView = tableView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell;
    SpecialityDownloadCell* specialityDownloadCell = [tableView dequeueReusableCellWithIdentifier:@"SpecialityDownloadCell"];
    specialityDownloadCell.speciality.text = [(KeyValue*)[keyvalueList objectAtIndex:indexPath.row] specialityName];
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    if (indexPath.row == 0)
    {
        [userDefaults setValue:specialityDownloadCell.speciality.text forKey:@"speciality"];
    }
    else
    {
        [userDefaults setValue:[NSString stringWithFormat:@"%@,%@",[userDefaults objectForKey:@"speciality"],specialityDownloadCell.speciality.text] forKey:@"speciality"];
    }
    specialityDownloadCell.downloadStatus.image = [UIImage imageNamed:[(KeyValue*)[keyvalueList objectAtIndex:indexPath.row] downloadState]];
    specialityDownloadCell.downloadStatusText.text = [(KeyValue*)[keyvalueList objectAtIndex:indexPath.row] downloadStatus];
    
    specialityDownloadCell.downloadStatus.backgroundColor = [UIColor clearColor];
    _uiTableView = tableView;
    
    cell = specialityDownloadCell;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

// some fun animations
- (void) testAnim
{
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath: @"position"];
    bounceAnimation.removedOnCompletion = YES;
    bounceAnimation.fillMode = kCAFillModeForwards;
    bounceAnimation.duration = 5;
    bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CGMutablePathRef bouncePath = CGPathCreateMutable();
    CGPathMoveToPoint(bouncePath, NULL, 1024, 0);
    CGPathAddArc(bouncePath, NULL, 924, 150, 60, 0.5*M_PI, 0, 0);
    CGPathAddArc(bouncePath, NULL, 824, 250, 60, M_PI, 0, 0);
    CGPathAddArc(bouncePath, NULL, 724, 350, 60, M_PI, 0, 0);
    CGPathAddArc(bouncePath, NULL, 624, 450, 60, M_PI, 0, 0);
    CGPathAddArc(bouncePath, NULL, 524, 550, 60, M_PI, 0, 0);
    [bounceAnimation setPath:bouncePath];
    
    UIView *animatingView = [[UIView alloc] initWithFrame:CGRectMake(0, 90, 48, 60)];
    animatingView.backgroundColor = [UIColor redColor];
    [self.view addSubview:animatingView];
    [animatingView.layer addAnimation:bounceAnimation forKey:nil];
}

- (IBAction)privacyPolicyTouched:(id)sender
{
    
    
    PrivacyPolicyVC *vc = (PrivacyPolicyVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyID"];
    [self presentViewController:vc animated:YES completion:nil];
}


@end