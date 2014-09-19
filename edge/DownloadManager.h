//
//  DownloadManager.h
//  edgesync
//
//  Created by Vijaykumar on 6/7/13.
//  Copyright (c) 2013 eprosoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadManager : NSObject

@property (nonatomic, retain) NSMutableArray *data;
@property (nonatomic, retain) NSMutableArray *splts; //Specialities
@property (nonatomic, retain) NSMutableArray *completedDownloads;
@property (nonatomic, retain) NSMutableArray *failedData;
@property (nonatomic, assign) int totalFilesCount;
//** Start **
//This is to list total number of duplicates files across specialities...
//@property (nonatomic, retain) NSNumber* commonFiles;
//** End **

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) int totalFilesCompleted;
@property (nonatomic, assign) int actualCompletedFiles;
@property (nonatomic, assign) long long totalFileSizeCompleted;
@property (nonatomic, assign) float completedFileFileSize;

@property (nonatomic, assign) int totalFiles;
@property (nonatomic, assign) long long totalFileSize;
@property (nonatomic, assign) BOOL isDownloadPaused;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, assign) BOOL isInitialSyncStillPending;

+ (id) sharedManager;

- (void) clearAll;
- (void) loadFromDatabase;
- (float) totalDiskSpaceInBytes;
- (void) initializeDownloads;
- (void) startDownloads;
-(NSArray*) loadFailedData;

- (int) totalFiles;
- (int) downloadedFiles;
- (NSArray*) fetchAllSpecialities;
- (void) updateSpecialitiesWithSyncDate : (NSString*) spltid;

- (void) resetData;
- (void) initDownloads;
- (void) resumeAllDownloads;
- (void) pauseAllDownloads;
- (void) setDownloadedFileSize : (long long) bytesDownloaded;
- (BOOL) specialityDeSelected : (NSNumber*) splId;
- (void) removeFileAtPath : (NSString*) path;
- (BOOL) areDownloadsCompleted;
- (NSMutableArray *)fetchFileContent;

@end