//
//  ContentModel.m
//  edgesync
//
//  Created by Vijaykumar on 6/12/13.
//  Copyright (c) 2013 eprosoft. All rights reserved.
//

#import "ContentDownloadModel.h"
#include "Constants.h"
#include "AFDownloadRequestOperation.h"
#import "HTTPClient.h"
#import "AFURLConnectionOperation+AFURLConnectionByteSpeedMeasure.h"
#import "BackgroundTaskManager.h"
#import "ContentModel.h"






#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]

@implementation ContentDownloadModel

- (void) downloadContentFile:(NSString*)urlString
{
    NSURLCache * dataCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:dataCache];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *path = [NSString stringWithFormat:@"%@", [self getTargetFilePath :[NSURL URLWithString:urlString]]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:360];
    [request setHTTPMethod:@"GET"];
    [request setValue:WEB_SERVICE_BASE_SERVER forHTTPHeaderField:@"Referer"];
    [request addValue:@"device" forHTTPHeaderField:@"env"];

    __weak id weakself = self;
    _downloadRequest = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:path shouldResume:NO];
    
    _downloadRequest.downloadSpeedMeasure.active = YES;
    
    _downloadRequest.shouldOverwrite = YES;
    //    [_downloadRequest setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
    //        //nslog(@"Download background time expired");
    //    }];
    //[_downloadRequest setShouldExecuteAsBackgroundTaskWithExpirationHandler:nil];
    
    
    [_downloadRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakself cancelDownload];
        [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_COMPLETE_EVENT object:weakself];
         [dataCache removeAllCachedResponses];
        //[[UIApplication sharedApplication] endBackgroundTask:[weakself backgroundTaskID]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakself cancelDownload];
         [dataCache removeAllCachedResponses];
        //nslog(@"Request Failed with error %@", error);
        if (error )
        [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_FAILED_EVENT object:weakself];
    }];
    
    [[BackgroundTaskManager sharedBackgroundTaskManager] beginNewBackgroundTask];
    
    [[HTTPClient sharedClient] enqueueHTTPRequestOperation:_downloadRequest];
    [HTTPClient sharedClient].operationQueue.maxConcurrentOperationCount = 4;
   
    urlString = nil;
}
-(BOOL)isFileDownloaded
{
    NSString *path = [NSString stringWithFormat:@"%@", [_m valueForKey:ATTR_PATH]];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path])
    {
        return YES;
    }
    return NO;
}

/**
 */
- (NSString *)getTargetFilePath:(NSURL *)url {
    NSString* targetPath = [DocumentsDirectory stringByAppendingPathComponent:[url path]];
    NSError* error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:[targetPath stringByDeletingLastPathComponent]
                                             withIntermediateDirectories:YES
                                                              attributes:nil
                                                                   error:&error];
    if (!success || error) {
        //nslog(@"Error! %@", error);
    } else {
        //nslog(@"Loading ... %@", targetPath);
    }
    return targetPath;
}

-(void)cancelDownload
{
    [_downloadRequest cancel];
    _downloadRequest = nil;
    _isDownloading = NO;
    _fileProgress = nil;
    _downloadFile = nil;
    _delegate = nil;
   // [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTaskID];
}

-(void)suspendDownload
{
    _isDownloading = NO;
    [_downloadRequest cancel];
    if(self.delegate) [self.delegate downloadSuspended];
    //[[UIApplication sharedApplication] endBackgroundTask: self.backgroundTaskID];
    //self.backgroundTaskID = UIBackgroundTaskInvalid;
}

/**
 */
-(void) removeFile
{
    NSURL* url = [NSURL URLWithString:[_m valueForKey:ATTR_PATH]];
    NSString *dlpath = [DocumentsDirectory stringByAppendingPathComponent:[url path]];
    NSString *tmppath = [DocumentsDirectory stringByAppendingPathComponent:[url path]];
    [[NSFileManager defaultManager] removeItemAtPath:dlpath error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:tmppath error:NULL];
}

-(void) removeFileAtPath : (NSString*) path
{
    NSURL* url = [NSURL URLWithString:path];
    NSString *dlpath = [DocumentsDirectory stringByAppendingPathComponent:[url path]];
    [[NSFileManager defaultManager] removeItemAtPath:dlpath error:NULL];
}

@end
