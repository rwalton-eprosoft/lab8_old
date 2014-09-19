//
//  ContentSyncViewController.m
//  edge
//
//  Created by Vijaykumar on 7/21/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ContentSyncViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DownloadManager.h"
#import "Constants.h"
#import "ContentSyncModel.h"
#import "MyProfile.h"
#import "MyEntitlement.h"
#import "SpecialityDownloadCell.h"
#import "ContentModel.h"
#include "Constants.h"
#include "BytesConversionHelper.h"
#include "KeyValue.h"
#import "DataValidator.h"
#import "ContentSyncReportViewController.h"
#import "ContentSyncVerifier.h"
#import "DashboardModel.h"
#import "HTTPClient.h"


@interface ContentSyncViewController ()

@end

@implementation ContentSyncViewController
NSTimeInterval start;
NSMutableArray *ma;
NSMutableArray *keyvalueList;
unsigned long long previousDownloadedBytes;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.contentSyncView.layer.cornerRadius = 10;
    self.contentSyncView.layer.masksToBounds = YES;
    self.contentSyncView.layer.borderColor = [UIColor grayColor].CGColor;
    self.contentSyncView.layer.borderWidth = 1.0f;
    
    self.contentSyncProgress.layer.masksToBounds = YES;
    self.contentSyncProgress.layer.borderColor = [UIColor grayColor].CGColor;
    self.contentSyncProgress.layer.borderWidth = 1.0f;
    
    self.errorsLog.layer.cornerRadius = 10;
    self.errorsLog.layer.masksToBounds = YES;
    self.errorsLog.layer.borderColor = [UIColor grayColor].CGColor;
    self.errorsLog.layer.borderWidth = 1.0f;
    
    [[NSNotificationCenter defaultCenter]  addObserver:self
											  selector:@selector(handleAllDownloadComplete:)
												  name:DOWNLOAD_ALL_COMPLETE_EVENT
												object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self
											  selector:@selector(notifyDownloadComplete:)
												  name:BROADCAST_DOWNLOAD_COMPLETE_EVENT
												object:nil];
    
    _isDownloading = NO;
    
    UIImage *progress = [UIImage imageNamed:@"progressbar_lightgrey_bg.png"];
//    progress = [progress resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    [_fileProgress setProgressImage:progress];
    
    UIImage *track = [UIImage imageNamed:@"progressbar_darkgrey_bg.png"];
//    track = [track resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];

    //Single File Progress
    [_fileProgress setTrackImage:track];
    [_fileProgress setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    _fileProgress.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _fileProgress.layer.cornerRadius = 10;
//    _fileProgress.layer.masksToBounds = YES;
   // _fileProgress.layer.borderWidth = 1.0f;
    
    //Total File Progress
    [_totalProgress setProgressImage:progress];
    [_totalProgress setTrackImage:track];
    [_totalProgress setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    _totalProgress.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _totalProgress.layer.cornerRadius = 10;
//    _totalProgress.layer.masksToBounds = YES;
   // _totalProgress.layer.borderWidth = 1.0f;
    
    _contentSync = [ContentSyncModel sharedContentSync];
    if (_contentSync.syncFromDashboard) {
        _resyncLabel.text =  @"Resuming downloads from previous attempt";
        if ([[DownloadManager sharedManager] isInitialSyncStillPending]) {
            _resyncLabel.text =  @"Wait for initial download to complete before using Total Access.";
            _continueDownloadsInBackgroundBtn.hidden = YES;
        }
    }  else if ([[ContentModel sharedInstance] isResetAll]) {
        _resyncLabel.text =  @"Resetting the app, please wait until download is complete";
        _continueDownloadsInBackgroundBtn.hidden = YES;
    }
    
    _errorsLog.text =   [[[DownloadManager sharedManager] loadFailedData] componentsJoinedByString:@"\n\t"];
    [self startDownloads];
}

- (void)viewDidAppear:(BOOL)animated {
    //nslog(@"View Appeared....");
}

- (void) registerForWifiEvents
{
    [self unregisterForWifiEvents];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNoWifi) name:APP_EVENT_NO_WIFI object:nil];
}

- (void) handleNoWifi {
    
    if ([[ContentModel sharedInstance] isResetAll]) {
        NSString* noWiFiAlert = @"Your initial content download was unsuccessful. To use the platform, it’s MANDATORY to complete the Content Download.  Please ensure to stay connected to internet via WiFi to complete the process.";
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Message" message:noWiFiAlert delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        alert.tag = 12;
        [alert show];
    } else {
        NSString* noWiFiAlert = @"WiFi connection is unavailable.  Try content update at a later time.";
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Message" message:noWiFiAlert delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        alert.tag = 10;
        [alert show];
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

- (void) calculateSpeed
{
    
    if (_downloadTimer.timeInterval == START_INTERVAL) { //Only for the firt time, process speed in START_INTERVAL seconds and continue with DOWNLOAD_TIMER_INTERVAL seconds
        [_downloadTimer invalidate];
        _downloadTimer = [NSTimer scheduledTimerWithTimeInterval:DOWNLOAD_TIMER_INTERVAL
                                                          target:self
                                                        selector:@selector(calculateSpeed)
                                                        userInfo:nil
                                                         repeats:YES];
    }
    
    DownloadManager *downloadMan = [DownloadManager sharedManager];
    
    unsigned long long downloaded = (downloadMan.totalFileSizeCompleted);
    unsigned long long total = downloadMan.totalFileSize * 1024.0f;
    
    _downloadSpeed.text = [_contentSync calculateSpeed :0.0f];
    _timeRemainingToComplete.text = [_contentSync calculateRemainingTime: total :downloaded :0.0];
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
    if (!keyvalueList) [keyvalueList removeAllObjects];
    
    [_contentSync initiateDownloads:_fileProgress withFileNameProgress:_fileNameLabel];
    keyvalueList = [_contentSync specialityDownloadList];
    
    if (_contentSync.downloadInProgress) {
        _downloadTimer = [NSTimer scheduledTimerWithTimeInterval:START_INTERVAL
                                                          target:self
                                                        selector:@selector(calculateSpeed)
                                                        userInfo:nil
                                                         repeats:YES];
        
        _isDownloading = YES;
        //[_delegate showActivityIndicator];
        if (![[HTTPClient sharedClient1] hasWifi]) {
            if (![[DownloadManager sharedManager] isInitialSyncStillPending]) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"WiFi connection is unavailable.  Try content update at a later time." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                alert.tag = 10;
                [alert show];
            }
        } else {
            if (![[DownloadManager sharedManager] isInitialSyncStillPending])
                [self registerForWifiEvents];
        }

    } else {
        
        _isDownloading = NO;
        if (![[HTTPClient sharedClient1] hasWifi]) {
            if (![[DownloadManager sharedManager] isInitialSyncStillPending]) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"WiFi connection is unavailable.  Try content update at a later time." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                alert.tag = 10;
                [alert show];
            }
        } else {
            if (!_syncFromScheduler) {
                [[[UIAlertView alloc] initWithTitle:@"Content Download Status" message:@"All content is up to date" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshProducts" object:nil];

            }
        }
        
        [self reset];
        return;
    }
    
    //move this to contentSync
    DownloadManager* downloadMan = [DownloadManager sharedManager];
    _totalFiles.text = [NSString stringWithFormat:@"%d", downloadMan.totalFiles];
    _totalSize.text =  [BytesConversionHelper convertBytesToString:[BytesConversionHelper convertKiloBytesToBytes:downloadMan.totalFileSize]];
}

#pragma mark -

-(void)handleAllDownloadComplete:(NSNotification*)pNotifcation
{
    _downloadFileLbl.text = @"Download has Completed";
    _bytesDownloadedLbl.text = @"";
    _timeRemainingToComplete.text = @"00:00:00";
    _isDownloading = NO;
    NSDateFormatter *dateFormatter;
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    if (keyvalueList) {
        NSMutableArray* tempArray = [keyvalueList copy];
        [keyvalueList removeAllObjects];
        for (KeyValue* keyvalue in tempArray) {
            keyvalue.downloadState = @"checkbox-checked_16.png";
            if ([keyvalue.downloadStatus isEqualToString:@"Updating"]) {
                keyvalue.downloadStatus = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate: [NSDate date]]];
            }
            [keyvalueList addObject:keyvalue];
        }
        
        for (KeyValue* keyvalue in tempArray) {
            NSLog(@"Status : %@ ", keyvalue.downloadStatus);
        }
        [self refreshTableView];
    }
    
    [[DashboardModel sharedInstance] refreshDashboard]; //refresh dashboard
    [self allDownloadsComplete];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_NO_WIFI object:nil];
}

- (void) allDownloadsComplete
{

    _startBtn.hidden = _pauseBtn.hidden = _resumeBtn.hidden = YES;
    _doneBtn.hidden = NO;
    
    if (!_syncFromScheduler) {
        //        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Download has completed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:[NSString stringWithFormat:@"%@ download has completed.", _percentComplete.text] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertView.tag = 1;
        [alertView show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshProducts" object:nil];
    }
    _appDelegate.IsupdatedClicked = YES;
    //[_delegate hideActivityIndicator];
    _syncFromScheduler = NO;
    [_downloadTimer invalidate];
    [self unregisterForWifiEvents ];
    [ContentModel sharedInstance].isResetAll = NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            [self reset];
        }
    } else if (alertView.tag == 10) {
        if (buttonIndex == alertView.cancelButtonIndex){
            [self unregisterForWifiEvents];
            [self reset];
        }
    } else if (alertView.tag == 12) {
        if (buttonIndex == alertView.cancelButtonIndex){
            [self unregisterForWifiEvents];
            [self reset];
            exit(0);
        }
    }
}

- (IBAction)startDownloadBtnClicked:(id)sender {
    //[self startDownloads];
}

- (IBAction)stopBtnClicked:(id)sender {
}

- (IBAction) handleVideoPlayerTouched {
}

- (IBAction) handleStartBtnTouched
{
    [self startDownloads];
}

- (IBAction) handlePauseBtnTouched
{
    _pauseBtn.hidden = YES;
    _resumeBtn.hidden = NO;
}

- (IBAction) handleResumeBtnTouched
{
    _resumeBtn.hidden = YES;
    _pauseBtn.hidden = NO;
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
    _totalProgress.progress = downloaded/total;
    float X = downloaded;
    float Y = total;
    if (X >= Y) X = Y; //Since server is sending the total size in KB and Completed size will be in
    //in bytes, so there might few bytes diff.
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
    
    for (int i = 0; i < keyvalueList.count; i++) {
        NSIndexPath *cellIndexPath =  [NSIndexPath indexPathForRow:i inSection:0];
        [_uiTableView beginUpdates];
        [_uiTableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects: cellIndexPath , nil] withRowAnimation: UITableViewRowAnimationNone];
        [_uiTableView endUpdates];
    }
    [_uiTableView reloadData];
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
    NSString* ext = @"";
    if ([data isKindOfClass:[NSString class]])
        ext = [[data pathExtension] lowercaseString];
    
    if ([ext isEqualToString:@"jpg"] || [ext isEqualToString:@"png"]) {
        UIImageView *imageView;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 12, 16,16)];
        imageView.image = [UIImage imageNamed:data];
        imageView.tag = indexPath.row;
        [cell.contentView addSubview:imageView];
    } else {
        UILabel *label;
        label = [[UILabel alloc] initWithFrame:rect];
        label.text = [NSString stringWithFormat:@"%@", data];
        label.font = [UIFont fontWithName:@"Arial" size:14.0];
        label.tag = indexPath.row;
        label.textColor = [UIColor colorWithRed:130.0f/255 green:130.0f/255 blue:130.0f/255 alpha:1];
        [cell.contentView addSubview:label];
    }
    //NSLog(@"Cell data ...%@ ", data);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell;
    NSString *MyIdentifier = @"SpecialityDownloadCell";
    UITableViewCell* specialityDownloadCell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (specialityDownloadCell == nil)
    {
        specialityDownloadCell = ([[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier]);
        
        [self prepareCellLabel:tableView indexPath:indexPath cell:specialityDownloadCell :CGRectMake(0, 0, 100,tableView.rowHeight) :[[keyvalueList objectAtIndex:indexPath.row] downloadState]];

        if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0)
        {
            //temporarty bc issues w/ cell content view oveloading in iOS 8
            specialityDownloadCell.indentationLevel = 2;
            specialityDownloadCell.textLabel.font = [UIFont fontWithName:@"Arial" size:14.0];
            specialityDownloadCell.textLabel.textColor = [UIColor colorWithRed:130.0f/255 green:130.0f/255 blue:130.0f/255 alpha:1];
            specialityDownloadCell.textLabel.text = [(KeyValue*)[keyvalueList objectAtIndex:indexPath.row] specialityName];
            
            NSString* downloadStatus = [(KeyValue*)[keyvalueList objectAtIndex:indexPath.row] downloadStatus];

            CGRect frame = CGRectMake(0, 0, 500, 50);
            UILabel *label = [[UILabel alloc] initWithFrame:frame];
            
            label.textAlignment = NSTextAlignmentRight;
            label.text = downloadStatus;
            label.font = [UIFont fontWithName:@"Arial" size:14.0];
            label.textColor = [UIColor colorWithRed:130.0f/255 green:130.0f/255 blue:130.0f/255 alpha:1];
            
            [specialityDownloadCell.contentView addSubview:label];

        }
        else
        {
            
            [self prepareCellLabel:tableView indexPath:indexPath cell:specialityDownloadCell :CGRectMake(45, 0, 100,tableView.rowHeight) :[(KeyValue*)[keyvalueList objectAtIndex:indexPath.row] specialityName]];
            
            NSString* downloadStatus = [(KeyValue*)[keyvalueList objectAtIndex:indexPath.row] downloadStatus];
            
            [self prepareCellLabel:tableView indexPath:indexPath cell:specialityDownloadCell :CGRectMake(400, 0, 200,tableView.rowHeight) :downloadStatus];

        }
    }
    
    _uiTableView = tableView;
    cell = specialityDownloadCell;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)backgroundBtnClicked:(id)sender {
    self.view.hidden = YES;
}

- (IBAction)downloadButtonClicked:(id)sender
{
    // [self startDownloads];
}

- (void) removeFromSuperView {
    
    [self unregisterNotifications];
    [[DownloadManager sharedManager] unregisterNotifications];
    [self.view removeFromSuperview];
}

- (IBAction)contentSyncReport:(id)sender {
    
    DataValidator* dq = [[DataValidator alloc] init];
    [dq getContentByContentCategory];
    //nslog(@"%@...", [dq report]);
    
    ContentSyncReportViewController* report = [[ContentSyncReportViewController alloc] initWithNibName:@"ContentSyncReportViewController" bundle:nil];
    
    [self presentViewController:report animated:YES completion:nil];
    report.contentSyncReport.text = dq.report;
}
- (void) reset {
    
    [[DownloadManager sharedManager] resetData];
    [_downloadTimer invalidate];
    [[ContentSyncVerifier sharedInstance] disableBulbIcon];
    _contentSync.syncFromDashboard = 0;
    _resyncLabel.text = @"";
    [self unregisterNotifications];
    self.view.hidden = YES;
    [self removeFromSuperView];
    
    [_delegate removeContentSync];

}

@end
