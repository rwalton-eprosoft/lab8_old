//
//  ContentSyncProcess.m
//  edge
//
//  Created by Vijaykumar on 7/29/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ContentSyncModel.h"
#import "DownloadManager.h"
#import "Constants.h"
#import "RegistrationModel.h"
#import "MyProfile.h"
#import "MyEntitlement.h"
#import "SpecialityDownloadCell.h"
#import "KeyValue.h"
#import "ContentDownloadModel.h"
#import "BytesConversionHelper.h"
#import "HTTPClient.h"
#import "AFURLConnectionOperation+AFURLConnectionByteSpeedMeasure.h"

@implementation ContentSyncModel
NSMutableArray *avgSpeed;
NSMutableArray *averagSpeed;

NSMutableArray *keyvalueList;
NSDateFormatter *dateFormatter;
unsigned long long previousDownloadedBytes;

static ContentSyncModel *sharedContentSync = nil;

#pragma mark Singleton Methods
+ (id)sharedContentSync {
    @synchronized(self) {
        if(sharedContentSync == nil)
            sharedContentSync = [[ContentSyncModel alloc] init];
    }
    return sharedContentSync;
}

- (NSString*) calculateSpeed : (unsigned long long) downloaded {
    
    return _humanReadableSpeed;
}

- (NSString*) calculateRemainingTime : (unsigned long long) total :
(unsigned long long) downloaded :
(NSTimeInterval) timespent {
    
    ////nslog(@"avgSpeed....%@", avgSpeed);
    float speed = [[avgSpeed valueForKeyPath:@"@avg.floatValue"] floatValue];//_speedInBytesPerSecond;
    //nslog(@"Speed array %d", avgSpeed.count);
    [avgSpeed removeAllObjects];
    
    _averageSpeed = SMOOTHING_FACTOR * speed + (1.0f - SMOOTHING_FACTOR) * _averageSpeed;
    [averagSpeed addObject:[NSNumber numberWithFloat:_averageSpeed]];
    if (averagSpeed.count >= 20) [averagSpeed removeObjectAtIndex:0];
    speed = [[averagSpeed valueForKeyPath:@"@avg.floatValue"] floatValue];
    
    _humanReadableSpeed = [NSByteCountFormatter stringFromByteCount:speed countStyle: NSByteCountFormatterCountStyleFile];

    unsigned long long remaining = total - downloaded;
    if (remaining <= 0) return [[NSString alloc] initWithFormat:@"%02d:%02d:%02d\n \n", 0, 0, 0];
    
    ////nslog(@"Remaining...%lld.....",remaining);
    int remainingTime = (int)(remaining / speed);
    int hours = remainingTime / 3600;
    int minutes = (remainingTime - hours * 3600) / 60;
    int seconds = remainingTime - hours * 3600 - minutes * 60;
    
    float downloadedSize, totalSize;
    char prefix;
    if (total >= 1024 * 1024 * 1024) {
        downloadedSize = (float) downloaded / (1024 * 1024 * 1024);
        totalSize = (float)total / (1024 * 1024 * 1024);
        prefix = 'G';
    } else if (total >= 1024 * 1024) {
        downloadedSize = (float) downloaded / (1024 * 1024);
        totalSize = (float)total / (1024 * 1024);
        prefix = 'M';
    } else if (total >= 1024) {
        downloadedSize = (float) downloaded / 1024;
        totalSize = (float)total / 1024;
        prefix = 'k';
    } else {
        downloadedSize = (float) downloaded;
        totalSize = (float)total;
        prefix = '\0';
    }
    
    NSString *remainingTimeFormat = [[NSString alloc] initWithFormat:@"%02d:%02d:%02d\n \n", hours, minutes, seconds];
    if (hours < 0 || minutes < 0 || seconds < 0) {
        remainingTimeFormat = [[NSString alloc] initWithFormat:@"00:00:00\n \n"];
    }
    
    return remainingTimeFormat;
}

- (void)downloadFile:(NSArray *)contentModels
{
    
    DownloadManager* downloadManager = [DownloadManager sharedManager];
    avgSpeed = [NSMutableArray array];
    averagSpeed = [NSMutableArray array];

    for (ContentDownloadModel* cm in contentModels) {
        @autoreleasepool {
        NSString* filePath = [cm.m valueForKey:ATTR_PATH];
        [cm downloadContentFile : filePath];
        
        [cm.downloadRequest setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _speedInBytesPerSecond = operation.downloadSpeedMeasure.speed;
                _averageSpeed = SMOOTHING_FACTOR * _speedInBytesPerSecond + (1.0f - SMOOTHING_FACTOR) * _averageSpeed;
                [avgSpeed addObject:[NSNumber numberWithFloat:_averageSpeed]];
                //if (avgSpeed.count >= 20) [avgSpeed removeObjectAtIndex:0];
                
                [downloadManager setDownloadedFileSize: bytesRead];
                
                HTTPClient* client = [HTTPClient sharedClient];
                for (NSOperation* oq in client.operationQueue.operations) {
                    if ([oq isExecuting]) {
                        AFDownloadRequestOperation* afDownload = (AFDownloadRequestOperation*)oq;
                        _fileNameLabel.text = [[afDownload targetPath] lastPathComponent];
                    }
                }
            });
        }];
    }
    }
    HTTPClient* client = [HTTPClient sharedClient];
    for (NSOperation* oq in client.operationQueue.operations) {
        @autoreleasepool {
        if ([oq isExecuting]) {
            AFDownloadRequestOperation* afDownload = (AFDownloadRequestOperation*)oq;
            _fileNameLabel.text = [[afDownload targetPath] lastPathComponent];
        }
        }
    }
    
//    backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//        //nslog(@"Entered background processing.......");
//    }];
}

- (void)initiateDownloads : (JEProgressView*) fileProgressView withFileNameProgress: (UILabel*) fileNameLabel
{
    DownloadManager *downloadMan = [DownloadManager sharedManager];
    [downloadMan initDownloads];
    _fileProgress = fileProgressView;
    _fileNameLabel = fileNameLabel;
    [self refreshDownloads : 0];
}

- (void) refreshDownloads : (int) page {
    
    // get a fresh copy of ContentModels
    DownloadManager *downloadMan = [DownloadManager sharedManager];
    NSArray *contentModels = [self partialList :[downloadMan data] :page];
    [self downloadFile:contentModels];
    if (contentModels.count <= 0)
        _downloadInProgress = false;
    else
        _downloadInProgress = true;
}

- (NSArray*) partialList : (NSArray*) data : (int) page {

    @autoreleasepool {
        NSMutableArray* temp = [[NSMutableArray alloc] init];
        for (int cnt = 0; cnt < 50; cnt++) {
            if (data.count > cnt)
                [temp addObject:[data objectAtIndex:cnt]];
        }
        return temp;

    }
}

- (void) resumeDownloads
{
    DownloadManager *downloadMan = [DownloadManager sharedManager];
    NSArray *contentModels = [downloadMan data];
    [self downloadFile:contentModels];
}

- (NSMutableArray*)specialityDownloadList
{
    DownloadManager *downloadMan = [DownloadManager sharedManager];
    keyvalueList = [[NSMutableArray alloc] init];
    NSArray* specialities = downloadMan.fetchAllSpecialities;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    for (NSManagedObject* speciality in specialities) {
        KeyValue *keyvalue = [[KeyValue alloc] init];
        NSString* name = [speciality valueForKey:@"name"];
        NSDate* date = [speciality valueForKey:@"lastSyncDt"];
        NSString* spltId = [[speciality valueForKey:@"splId"] stringValue];
        if ([[downloadMan splts] containsObject:spltId]) {
            keyvalue.specialityName = name;
            if (!date) {
                keyvalue.downloadState   = @"updating.png";
                keyvalue.downloadStatus = [NSString stringWithFormat:@"Updating"];
            } else {
                keyvalue.downloadState   = @"checkbox-checked_16.png";
                keyvalue.downloadStatus = [dateFormatter stringFromDate: date];
            }
            [keyvalueList addObject:keyvalue];
        }
    }
    for (KeyValue* kv in keyvalueList) {
        NSLog(@"downloadStatus .... %@", kv.downloadStatus);
    }
    return keyvalueList;
}

- (void) resetData
{
    DownloadManager *downloadMan = [DownloadManager sharedManager];
    [downloadMan resetData];
    if (avgSpeed) [avgSpeed removeAllObjects];
    if (averagSpeed) [averagSpeed removeAllObjects];
    if (keyvalueList) [keyvalueList removeAllObjects];
}

@end