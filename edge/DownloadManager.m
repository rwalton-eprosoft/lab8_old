//
//  DownloadManager.m
//  edgesync
//
//  Created by Vijaykumar on 6/7/13.
//  Copyright (c) 2013 eprosoft. All rights reserved.
//

#import "DownloadManager.h"
#import "ContentDownloadModel.h"
#import "AppDelegate.h"
#include "Constants.h"
#import "DataSyncService.h"
#import "HTTPClient.h"
#import "MyEntitlement.h"
#import "RegistrationModel.h"
#import "MyProfile.h"
#import "ContentSyncModel.h"
#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]

@interface DownloadManager()

@property (nonatomic, retain) NSRecursiveLock *lock;
@property (nonatomic, retain) NSMutableArray *pausedRequests;

@end

@implementation DownloadManager

static DownloadManager *sharedDownloadManager = nil;
int tempSpltId;

#pragma mark Singleton Methods
+ (id)sharedManager {
    @synchronized(self) {
        if(sharedDownloadManager == nil)
            sharedDownloadManager = [[DownloadManager alloc] init];
    }
    return sharedDownloadManager;
}

- (id)init {
	if (self = [super init])
    {
        _managedObjectContext = [APP_DELEGATE managedObjectContext];
    }
    _pausedRequests = [[NSMutableArray alloc] init];
    
	return self;
}

- (void) initDownloads {
    [self loadFromDatabase];
    [self initializeDownloads];
    [self initNotifications];
}

- (void) startDownloads {
    if (_data == nil || _data.count < 1) {
        DownloadManager *downloadMan = [DownloadManager sharedManager];
        @autoreleasepool {
            [downloadMan loadFromDatabase];
        }
        [downloadMan initializeDownloads];
    }
}

/**
 */
-(void)initNotifications
{
    [[NSNotificationCenter defaultCenter]  addObserver:self
											  selector:@selector(handleDownloadComplete:)
												  name:DOWNLOAD_COMPLETE_EVENT
												object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self
											  selector:@selector(handleDownloadFailed:)
												  name:DOWNLOAD_FAILED_EVENT
												object:nil];
}

- (void) initializeDownloads {
    
    NSArray* tempData = [_data copy];
    for (ContentDownloadModel* cm in tempData) {
        if ([cm.m valueForKey:@"status"] == [NSNumber numberWithInt:3]) { //Delete files with deleteflag as 3
            //nslog(@"Deleting a file....%@", [cm.m valueForKey:ATTR_PATH]);
            [self removeDownload :cm];
        }
    }
}

/**
 */
-(void)removeDownload:(ContentDownloadModel*) cm
{
    if( [_data containsObject:cm])
    {
        [cm cancelDownload];
        [cm removeFile];
        cm.downloadRequest = nil;
        cm = nil;

        [_data removeObject:cm];
        //        [_managedObjectContext deleteObject:cm.m];
        //        NSError *error;
        //        if(![_managedObjectContext save:&error])
        //        {
        //        }
        //[[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_REMOVED_EVENT object: cm];
    }
}

- (void)updateWithFetchStatus:(ContentDownloadModel *)cm error:(NSError *)error
{
    [cm.m setValue:VALUE_FETCHED forKey:ATTR_DOWNLOADSTATUS];
}

-(BOOL) areDownloadsCompleted {
    
    NSMutableArray* items = [self fetchFileContent];
    _isInitialSyncStillPending = NO;
    int count = 0;
    int intialSyncFilesCount = 0;
    int countCheck = 1;
    if (items != nil && items.count > 0) {
        for (NSManagedObject* mo in items) {
            NSString* filePath = [mo valueForKey:ATTR_PATH];
            NSString* downloadStatus = [mo valueForKey:ATTR_DOWNLOADSTATUS];
            BOOL initialSync = NO;
            if ([mo valueForKey:ATTR_INITIALSYNC]) {
                initialSync = [[mo valueForKey:ATTR_INITIALSYNC] boolValue];
            }
            
            if (filePath != nil && filePath.length > 0) {
                if (![self checkIfContentAlreadyDownloaded :downloadStatus forPath:filePath]) {
                    
                    if (initialSync) {
                        if (++intialSyncFilesCount >= 1)  {//if there are files left during initial sync....
                            _isInitialSyncStillPending = YES;
                            countCheck = 1;
                        }
                    }

                    if (++count >= countCheck)
                        return NO;
                }
            }
        }
    }
    return YES;
}

- (NSMutableArray *)fetchFileContent
{
    NSError *error;
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENT_FILECONTENT inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:ATTR_SPLID ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [req setSortDescriptors:sortDescriptors];
    
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:req error:&error] mutableCopy];
    return mutableFetchResults;
}

-(void) loadFromDatabase
{
    if(!_data) _data = [[NSMutableArray alloc] init];
    [self clearAll];
    
    if(!_completedDownloads) _completedDownloads = [[NSMutableArray alloc] init];
    [_completedDownloads removeAllObjects];
    
    if(!_failedData) _failedData = [[NSMutableArray alloc] init];
    [_failedData removeAllObjects];
    
    if (!_splts) _splts = [[NSMutableArray alloc] init];
    [_splts removeAllObjects];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    NSMutableArray *mutableFetchResults;
    NSError* error;
    mutableFetchResults = [self fetchFileContent];
    ContentDownloadModel* cm;
    int appContent = 0;
    if (mutableFetchResults) {
        
        NSArray* myEntitlements = [[RegistrationModel sharedInstance].profile myProfileToMyEntitlement].allObjects;
        for (int i = 0; i < [myEntitlements count]; i++)
        {
            MyEntitlement* entitlement =  [myEntitlements objectAtIndex:i];
            if ([[entitlement status] isEqualToNumber:[NSNumber numberWithInt:kEntitlementStatusEnabled]]) {
                [_splts addObject: [entitlement.splId stringValue]];
            }
        }
        NSMutableArray* tempSpls = [[NSMutableArray alloc] init];
        for (NSManagedObject* mo in mutableFetchResults) {
            
            NSString* filePath = [mo valueForKey:ATTR_PATH];
            NSString* downloadStatus = [mo valueForKey:ATTR_DOWNLOADSTATUS];
            if (filePath != nil && filePath.length > 0 /*&&
                ![downloadStatus isEqualToString:VALUE_FAILED]*/) {
                if (![self checkIfContentAlreadyDownloaded :downloadStatus forPath:filePath] /*&&
                        [[cm.m valueForKey:@"Status"] intValue] != 2*/) {
                    
                    cm = [[ContentDownloadModel alloc] init];
                    cm.m = mo;
                    cm.downloadFile = [cm.m valueForKey:ATTR_PATH];
                    [_data addObject:cm];
                    
                    //These are application level files, so ignore and remove it from count.
                    //TODO: Provide a section in Registration Screen along with other speclialities
                    if ([[cm.m valueForKey:@"splId"] intValue] == 0)
                        appContent++;
                    
                    _totalFileSize += [[cm.m valueForKey:ATTR_SIZE] integerValue];
                    ////nslog(@"File Size - %lld, Data Count - %d", _totalFileSize, _data.count);
                    NSString* splId = [[cm.m valueForKey:ATTR_SPLID] stringValue];
                    if (![tempSpls containsObject:splId]) {
                        [tempSpls addObject:splId];
                    }
                    _isDownloading = YES;
                }
            }
        }

        // for the specialities which are in progress, update sync date to nil,
        // because this will be updated with all download complete logic
        for (NSString* splid in tempSpls) {
            [self removeSyncDateFromSplt:splid];
        }
        
        for (ContentDownloadModel* cm in _data) {
            [self updateWithFetchStatus:cm error:error];
        }
        
        if(![_managedObjectContext save:&error])
        {
            //nslog(@"Error while saving.... %@", error);
        }
        _totalFiles = _data.count - appContent;
    }
}

- (BOOL) checkIfContentAlreadyDownloaded : (NSString*)downloadStatus  forPath:(NSString*)path {
    
    if ([downloadStatus isEqualToString:VALUE_FETCHED] ||
        [downloadStatus isEqualToString:VALUE_FAILED]) {
        NSString* targetPath = [DocumentsDirectory stringByAppendingPathComponent:[[NSURL URLWithString:path] path]];
        return [[NSFileManager defaultManager] fileExistsAtPath:targetPath];
    }
    return false;
}

-(void)clearAll
{
    int cnt = [_data count];
    ContentDownloadModel *cm;
    for(int i=cnt-1; i>=0; i--)
    {
        cm = (ContentDownloadModel*)[_data objectAtIndex:i];
        NSLog(@"Clear All : %@", cm.downloadFile);
        [self removeDownload:cm];
    }
    [_data removeAllObjects];
}

-(void)handleConnectionStatusChanged:(NSNotification*)pNotifcation {
    
    //[self checkDownloads];
}

/**
 */
-(void)handleDownloadComplete:(NSNotification*)pNotifcation
{
    if ([[HTTPClient sharedClient1] hasWifi]) {
        ContentDownloadModel *cm = (ContentDownloadModel*)[pNotifcation object];
        if([_data containsObject:cm])
        {
            _completedFileFileSize = [[cm.m valueForKey:ATTR_SIZE] longValue];
            _totalFileSizeCompleted += _completedFileFileSize;
            _totalFilesCount ++;
                        [_completedDownloads addObject:cm];
            
            //These are application level files, so ignore and remove it from count. TODO: Provide a section in Registration Screen along with other speclialities
            if (!([[cm.m valueForKey:@"splId"] intValue] == 0)) {
                _totalFilesCompleted++;// = _completedDownloads.count;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:BROADCAST_DOWNLOAD_COMPLETE_EVENT object:self];
            [_data removeObject:cm];
            if (_data.count % 50 == 0) {
                [self updateDatabaseWithProcessedRecord];
                [self updateDatabaseWithFailedRecord];
            }
            if ((_totalFilesCount%  50 == 0))
            {
                
                ContentSyncModel* contentSyncModel = [ContentSyncModel sharedContentSync];
                contentSyncModel.pageSize += 49;
                [contentSyncModel refreshDownloads:contentSyncModel.pageSize];
            }
        }
        

        if([_data count] == 0)
        {
            [self updateDatabaseWithProcessedRecord];
            [self updateDatabaseWithFailedRecord];
            
            for (NSString* splid in _splts)
                [self updateSpecialitiesWithSyncDate :splid];
            _isDownloading = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_ALL_COMPLETE_EVENT object:self];
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            [self resetData];
        }
    }
//    //nslog(@"DownloadManager handleDownloadComplete: leaving");
}

/**
 */
-(void)handleDownloadFailed:(NSNotification*)pNotifcation
{
    
    if ([[HTTPClient sharedClient1] hasWifi]) {

        ContentDownloadModel *cm = (ContentDownloadModel*)[pNotifcation object];
        if([_data containsObject:cm])
        {
            [_failedData addObject:cm];
            [_data removeObject:cm];
        }
        _totalFilesCount ++;
        
        if([_data count] == 0)
        {
            [self updateDatabaseWithProcessedRecord];
            [self updateDatabaseWithFailedRecord];
            
            for (NSString* splid in _splts)
                [self updateSpecialitiesWithSyncDate :splid];
            
            _isDownloading = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_ALL_COMPLETE_EVENT object:self];
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            [self resetData];
        }
        if ((_totalFilesCount%  50 == 0))
        {
            
            ContentSyncModel* contentSyncModel = [ContentSyncModel sharedContentSync];
            contentSyncModel.pageSize += 49;
            [contentSyncModel refreshDownloads:contentSyncModel.pageSize];
        }
    }
}

- (void) updateDatabaseWithProcessedRecord {
    NSError *error;
    for (ContentDownloadModel* cm in _completedDownloads) {
        [_managedObjectContext deleteObject:cm.m];
        if(![_managedObjectContext save:&error])
        {
            //nslog(@"Error while saving.... %@", error);
        }
    }
    [_completedDownloads removeAllObjects];
}

- (void) updateDatabaseWithFailedRecord {
    NSError *error;
    for (ContentDownloadModel* cm in _failedData) {
        if(!cm.downloadFile) {
            [cm.m setValue:VALUE_FAILED forKey:ATTR_DOWNLOADSTATUS];
            NSLog(@"Failed record : %@",cm?cm.downloadFile:@"");
            if(![_managedObjectContext save:&error])
            {
                //nslog(@"Error while saving.... %@", error);
            }
        }
    }
    [_failedData removeAllObjects];
    _failedData = nil;
}

- (void)pauseAllDownloads
{
	[self.lock lock];
	_isDownloadPaused = YES;
	[_pausedRequests addObjectsFromArray:_data];
	[_data removeAllObjects];
	[[HTTPClient sharedClient].operationQueue cancelAllOperations];
    
	[self.lock unlock];
}

- (void)resumeAllDownloads
{
    if (_isDownloadPaused) {
        [self.lock lock];
        
        _isDownloadPaused = NO;
        for (ContentDownloadModel *cm in _pausedRequests) {
            //[cm downloadContentFile:cm.downloadFile];
            [_data addObject:cm];
        }
        [_pausedRequests removeAllObjects];
        
        [self.lock unlock];
    }
}

-(NSArray*) loadFailedData
{
    NSMutableArray* failedRecords = [[NSMutableArray alloc] init];
    if(!_failedData) _failedData = [[NSMutableArray alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENT_FILECONTENT inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloadStatus = 'Failed'"];
    [req setPredicate:predicate];
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:req error:&error] mutableCopy];
    ContentDownloadModel* cm;
    if (mutableFetchResults) {
        for (NSManagedObject* mo in mutableFetchResults) {
            cm = [[ContentDownloadModel alloc] init];
            cm.m = mo;
            cm.downloadFile = [cm.m valueForKey:ATTR_PATH];
            [_failedData addObject:cm];
        }
        for (ContentDownloadModel* cm in _failedData) {
            //nslog(@"File path on Failed Data....%@", [cm.m valueForKey:ATTR_PATH]);
            [failedRecords addObject:[cm.m valueForKey:ATTR_PATH]];
        }
    }
    return failedRecords;
}

- (int) totalFiles {
    return _totalFiles;
}

- (int) downloadedFiles {
    return _totalFilesCompleted;
}

- (void) setDownloadedFileSize : (long long) bytesDownloaded {
    //_totalFileSizeCompleted += bytesDownloaded;
}

/**
 */
- (float)totalDiskSpaceInBytes {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attributesDict = [fileManager attributesOfFileSystemForPath:NSHomeDirectory() error:NULL];
    return [[attributesDict objectForKey:NSFileSystemFreeSize] longLongValue];
}

- (void) unregisterNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DOWNLOAD_COMPLETE_EVENT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DOWNLOAD_FAILED_EVENT object:nil];
}

- (void) checkSpecialityChange : (int) spltId{
    if (tempSpltId != spltId) {
        tempSpltId = spltId;
    }
}

- (NSArray*) fetchAllSpecialities  {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENT_SPECIALITY inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:ATTR_LAST_SYNC_DT ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSArray* specialities = [[APP_DELEGATE managedObjectContext] executeFetchRequest:fetchRequest error:nil];
    return specialities;
}

- (void) updateSpecialitiesWithSyncDate : (NSString*) spltid  {
    
    NSArray* specialities = [self fetchAllSpecialities];
    NSDate *now = [NSDate date];
    for (NSManagedObject* speciality in specialities) {
        NSNumber* splid = [speciality valueForKey:@"splId"];
        NSDate* date = [speciality valueForKey:@"lastSyncDt"];
        if ([splid intValue] == [spltid intValue] && date == nil) {
            [speciality setValue:now forKey:@"lastSyncDt"];
            NSError* error;
            if (![[APP_DELEGATE managedObjectContext] save:&error])
            {
                
            }
                //nslog(@"Couldn't save: %@", [error localizedDescription]);
        }
    }
}

- (void) removeSyncDateFromSplt : (NSString*) spltid  {
    
    NSArray* specialities = [self fetchAllSpecialities];
    for (NSManagedObject* speciality in specialities) {
        NSNumber* splid = [speciality valueForKey:@"splId"];
        NSDate* date = [speciality valueForKey:@"lastSyncDt"];
        if ([splid intValue] == [spltid intValue] && date != nil) {
            [speciality setValue:nil forKey:@"lastSyncDt"];
            NSError* error;
            if (![[APP_DELEGATE managedObjectContext] save:&error])
            {
                
            }
            //nslog(@"Couldn't save: %@", [error localizedDescription]);
        }
    }
}

/**
 */
- (void) refreshFileContent {
    
    //TODO......
    
}

/**
 */
- (void) resetData {
    
    [self updateDatabaseWithProcessedRecord];
    [self updateDatabaseWithFailedRecord];
    _totalFilesCompleted = 0;
    _totalFileSizeCompleted = 0;
    _completedFileFileSize = 0;
    _actualCompletedFiles = 0;
    _isInitialSyncStillPending = NO;
    _totalFiles = 0;
    _totalFileSize = 0;
    _isDownloading = NO;
    [self unregisterNotifications];
    
    [self refreshFileContent];
    [self clearAll];
    if (_failedData) [_failedData removeAllObjects];
    if (_completedDownloads) [_completedDownloads removeAllObjects];
    if (_data) [_data removeAllObjects];
    if (_splts) [_splts removeAllObjects];
}

- (BOOL) specialityDeSelected : (NSNumber*) splId {
    DataSyncService* dss = [[DataSyncService alloc] init];
    return [dss deleteSpecialityById:splId withManagedObjectContext:[APP_DELEGATE managedObjectContext]];
}

-(void) removeFileAtPath : (NSString*) path 
{
    NSURL* url = [NSURL URLWithString:path];
    NSString *dlpath = [DocumentsDirectory stringByAppendingPathComponent:[url path]];
    [[NSFileManager defaultManager] removeItemAtPath:dlpath error:NULL];
}
@end
