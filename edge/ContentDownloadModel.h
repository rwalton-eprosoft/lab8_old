//
//  ContentModel.h
//  edgesync
//
//  Created by Vijaykumar on 6/12/13.
//  Copyright (c) 2013 eprosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFDownloadRequestOperation.h"
#import "JEProgressView.h"
@protocol ContentDownloadModelDelegate <NSObject>

@optional
    -(void) downloadStreamStarted;
    -(void) downloadComplete : (id) cm;
    -(void) downloadFailed;
    -(void) downloadSuspended;
    -(void) downloadStarted;
@end

@interface ContentDownloadModel : NSObject

@property (nonatomic, retain) AFDownloadRequestOperation *downloadRequest;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, strong) NSManagedObject *m;
@property (nonatomic, retain) id <ContentDownloadModelDelegate> delegate;
@property (nonatomic, retain) NSString *downloadFile;
@property (strong, nonatomic) IBOutlet JEProgressView *fileProgress;


-(void) cancelDownload;
-(void) suspendDownload;
-(void) downloadContentFile:(NSString*)urlString;
-(void) removeFile;

@end
