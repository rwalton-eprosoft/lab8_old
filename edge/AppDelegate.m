    //
//  AppDelegate.m
//  edge
//
//  Created by iPhone Developer on 5/11/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "AppDelegate.h"
#import "RegistrationModel.h"
#import "FilterModel.h"
#import "DashboardModel.h"
#import "ContentModel.h"
#import "ProcedureModel.h"
#import "ContentSyncVerifier.h"
#include "PresentationModel.h"
#import "HTTPClient.h"
#import "InteractiveViewerModel.h"
#import <AdSupport/AdSupport.h>
#import "MyEntitlement.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize SignatureImage,DeviceToken,IsFromResource,IsupdatedClicked;

- (void) initApp
{
    
    //_settingsServerURL = [self serverURLFromSettings:@"Server"];
    // customize the standard iOS controls using API
    [self customizeAppearance];
    
    _userDefaults = [[NSUserDefaults alloc] init];    
    NSMutableDictionary * syncSchedule = [_userDefaults objectForKey:@"syncSchedule"];
    NSDate* date = [syncSchedule objectForKey:@"datePicker"];
    
    if (!date) {
        [self setDefaultSchedule:date];
    }
    _isScheduleMisfired = YES;
    NSDate* date1 = [syncSchedule objectForKey:@"datePicker"];
    [self checkMisFiredSchedules:date1];

    [RegistrationModel sharedInstance];

    [FilterModel sharedInstance];
    
    [DashboardModel sharedInstance];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    self.tabBarController = [sb instantiateViewControllerWithIdentifier:@"TabBarController"];
    self.productNavController = [sb instantiateViewControllerWithIdentifier:@"ProductNavController"];
}

- (void) setDefaultSchedule:(NSDate *)date_p
{
    date_p = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: date_p];
    [components setHour: 06];
    [components setMinute: 00];
    [components setSecond: 00];
    
    NSDate *newDate = [gregorian dateFromComponents: components];
    [self scheduleNotificationForDate: newDate];
    NSMutableDictionary * syncSchedule = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          newDate, @"datePicker" , nil];
    [_userDefaults setObject:syncSchedule forKey:@"syncSchedule"];
}

- (void) cancelTimer {
    if (_misFiredScheduleTimer) {
        [_misFiredScheduleTimer invalidate];
        _misFiredScheduleTimer = nil;
    }
    _isScheduleMisfired = YES;
    _scheduleAttempts = 0;
}

- (void)checkMisFiredSchedules:(NSDate *)date
{
    if([[NSDate date] compare: date] == NSOrderedDescending) {
        if (_isScheduleMisfired) {
            _scheduleAttempts++;
            if ([[HTTPClient sharedClient1] hasWifi]) { //one attempt
                [[ContentSyncVerifier sharedInstance] checkSpecialityStatus];
                [self cancelTimer];
            } else {
                //Try in 4 hours for 2 attemps.
                if (!_misFiredScheduleTimer) {
                    _misFiredScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:NOTIFY_UPDATE_INTERVAL
                                                                              target:self
                                                                            selector:@selector(fireNotifyUpdateService)
                                                                            userInfo:nil
                                                                             repeats:YES];
                }
            }
        }
    }
}

- (void) fireNotifyUpdateService {
    
    if (_scheduleAttempts++ == 3) {
        [self cancelTimer];
    }
    
    if ([[HTTPClient sharedClient1] hasWifi]) {
        [[ContentSyncVerifier sharedInstance] checkSpecialityStatus];
        [self cancelTimer];
    }
}

- (void) deinitApp
{
}

- (void) customizeAppearance
{
    /****************************************************************
     *
     * navigation bar
     *
     ****************************************************************/
    // Create resizable images
    UIImage *navBkg = [[UIImage imageNamed:@"nav_bar_bkg"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    // Set the background image for *all* UINavigationBars
    [[UINavigationBar appearance] setBackgroundImage:navBkg
                                       forBarMetrics:UIBarMetricsDefault];

    /*
    // Customize the title text for *all* UINavigationBars
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
      UITextAttributeTextColor,
      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"Arial-Bold" size:0.0],
      UITextAttributeFont,
      nil]];
      */
    
    /****************************************************************
     *
     * tool bar
     *
     ****************************************************************/
    // Create resizable images
    UIImage *toolbarBkg = [[UIImage imageNamed:@"tool_bar_bkg.png"]
                       resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    // Set the background image for *all* UINavigationBars
    [[UIToolbar appearance] setBackgroundImage:toolbarBkg
                            forToolbarPosition:UIToolbarPositionAny
                                       barMetrics:UIBarMetricsDefault];
    
    /****************************************************************
     *
     * tab bar
     *
     ****************************************************************/
    UIImage *tabBkg = [[UIImage imageNamed:@"tab_bar_bkg.png"]
                              resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UITabBar appearance] setBackgroundImage:tabBkg];
    //[[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tab_select_indicator"]];
    
//    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                       [UIColor whiteColor], UITextAttributeTextColor,
//                                                       nil] forState:UIControlStateNormal];
//    UIColor *titleHighlightedColor = BRANDING_RED_COLOR;
//    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                       titleHighlightedColor, UITextAttributeTextColor,
//                                                       nil] forState:UIControlStateHighlighted];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    ////nslog(@"%@\n\n\n",[[ProcedureModel sharedInstance] arcStepsForProcedure:7 andForSpeciality: 2]);
    ////nslog(@"%@\n\n\n",[[ProcedureModel sharedInstance] arcStepsForProcedure:7 andForSpeciality: 2]);
    ////nslog(@"%@\n\n\n",[[ProcedureModel sharedInstance] productsForProcedure:13 andForSpeciality: 6 andForArcStepName: @"A"]);
    ////nslog(@"%@\n\n\n",[[ProcedureModel sharedInstance] productsForProcedure:13 andForSpeciality: 6 andForArcStepName: @"A" andForProcStepID: 49]);
    ////nslog(@"%@\n\n\n",[[ProcedureModel sharedInstance] productsForProcedure:13 andForSpeciality: 6 andForArcStepName: @"A" andForConcernId: 65]);
    ////nslog(@"%@", [[PresentationModel sharedInstance] pathsForPresentations]);
    ////nslog(@"%@", [[ProcedureModel sharedInstance] metadataForContentId:390 andForKey : @"RELEVANTPROCEDURES"]);
    ////nslog(@"%@", [[ProcedureModel sharedInstance] metadataForContentId:304 andForKey : @"TARGETAUDIENCE"]);
    ////nslog(@"%@", [[InteractiveViewerModel sharedInstance] fetchSpecialtyIV:[NSNumber numberWithInt:1] withTarget: [NSNumber numberWithInt:1]]);
    ////nslog(@"%@", [[InteractiveViewerModel sharedInstance] fetchProcedureIV:[NSNumber numberWithInt:4] withTarget: [NSNumber numberWithInt:1]]);
    ////nslog(@"%@", [[InteractiveViewerModel sharedInstance] fetchProductIV:[NSNumber numberWithInt:21] withTarget: [NSNumber numberWithInt:2] :[NSNumber numberWithInt:2]]);
    
//    NSMutableArray* array = [[NSMutableArray alloc] init];
//    NSMutableArray* array1 = [[NSMutableArray alloc] init];
//    NSMutableArray* array2 = [[NSMutableArray alloc] init];
//
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//    NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] init];
//    NSMutableDictionary *dict2 = [[NSMutableDictionary alloc] init];
//   
//    [array2 addObject:@"22"];
//    //[dict3 setObject:array2 forKey:@"procStepId"];
//    [dict2 setObject:array2 forKey:@"procStepId"];
//    [dict2 setObject:@"59" forKey:@"concernId"];
//    
//    [array1 addObject:dict2];
//    
//    [dict1 setObject:array1 forKey:@"ConcernToProcedureStep"];
//    
//    [array addObject:dict1];
//    
//    [dict setObject:array forKey:@"Relations"];
//    
//    
//    NSLog(@"%@", dict);
    
    [[HTTPClient sharedClient1] initializeReachability];

    self.IsupdatedClicked = NO;
    int cacheSizeMemory = 4*1024*1024; // 4MB
    int cacheSizeDisk = 32*1024*1024; // 32MB
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
    IsFromResource = NO;
    // Override point for customization after application launch.
    self.DeviceToken = @"";
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:4]];
    [self initApp];
   
    //Local Notifications -- Start
    application.applicationIconBadgeNumber = 0;
    //[[ContentSyncVerifier sharedInstance] checkSpecialityStatus];
    
    // Need to refactor
    //NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    //NSMutableDictionary * syncSchedule = [defaults objectForKey:@"syncSchedule"];
    //BOOL autoUpdate = [[syncSchedule objectForKey:@"autoUpdates"] boolValue];
//    if (autoUpdate) {
//        [self invokeContentSync];
//    } else
    {
        [[ContentSyncVerifier sharedInstance] checkSpecialityStatus];
    }

    // Handle launching from a notification
    UILocalNotification *localNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        //nslog(@"Recieved Notification %@",localNotif);
        //[[ContentSyncVerifier sharedInstance] checkSpecialityStatus];
//        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
//        NSMutableDictionary * syncSchedule = [defaults objectForKey:@"syncSchedule"];
//        BOOL autoUpdate = [[syncSchedule objectForKey:@"autoUpdates"] boolValue];
//        if (autoUpdate) {
//            [self invokeContentSync];
//        } else
        {
            [[ContentSyncVerifier sharedInstance] checkSpecialityStatus];
        }

    }
    //Local Notifications -- End
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
    
    [application setMinimumBackgroundFetchInterval: UIApplicationBackgroundFetchIntervalMinimum];
    _isproductClicked = NO;
    
    [_window makeKeyWindow];
    [_window makeKeyAndVisible];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//    UIBackgroundTaskIdentifier backgroundIdentifier = [application beginBackgroundTaskWithExpirationHandler:^(void) { [[[HTTPClient sharedClient] operationQueue] waitUntilAllOperationsAreFinished];}]; [application endBackgroundTask:backgroundIdentifier];
 
//    UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
//        
//        // Wait until the pending operations finish
//        [[[HTTPClient sharedClient] operationQueue] waitUntilAllOperationsAreFinished];
//        
//        [application endBackgroundTask: bgTask];
//       // bgTask = UIBackgroundTaskInvalid;
//    }];
    
    //nslog(@"applicationWillResignActive Invoked");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //nslog(@"applicationDidEnterBackground");
    UIApplication* app = [UIApplication sharedApplication];
    
    UIBackgroundTaskIdentifier __block bgTask = [app beginBackgroundTaskWithExpirationHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [app endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        });
    }];
    
//    [[DownloadManager sharedManager] pauseAllDownloads]; //pause downloads and continue in performFetchWithCompletionHandler when iOS gives time.
//    UIBackgroundTaskIdentifier backgroundIdentifier = [application beginBackgroundTaskWithExpirationHandler:^(void) { [[[HTTPClient sharedClient] operationQueue] waitUntilAllOperationsAreFinished];}]; [application endBackgroundTask:backgroundIdentifier];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //nslog(@"applicationWillEnterForeground");
//    DownloadManager* downloadManager = [DownloadManager sharedManager];
//    if ([downloadManager isDownloadPaused]) {
//        [downloadManager resumeAllDownloads];
//        [[ContentSyncModel sharedContentSync] resumeDownloads];
//    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    _isScheduleMisfired = YES;
    NSMutableDictionary * syncSchedule = [_userDefaults objectForKey:@"syncSchedule"];
    NSDate* date = [syncSchedule objectForKey:@"datePicker"];
    [self checkMisFiredSchedules:date];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    
    [self deinitApp];
}
-(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    NSString *dt = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    dt = [dt stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    self.DeviceToken= dt;
    //nslog(@"toekn --%@",DeviceToken);
    
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    
    
    NSString *status = [ NSString stringWithFormat: @"\nRegistration failed.\n\nError: %@",[err localizedDescription] ];
    //nslog(@"notification--%@",status);
    
      //UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:status  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [alert show];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            //nslog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"edge" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
/*
// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"edge.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        ///
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
        //*/
        //nslog(@"Unresolved error %@, %@", error, [error userInfo]);
    //    abort();
  //  }
    
  //  return _persistentStoreCoordinator;
//}*/

//trial for core data versioning
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"edge.sqlite"];
    
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
    						 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
    						 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Handle error
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark -
#pragma mark backgroundQueue

- (NSOperationQueue *)backgroundQueue
{
    static dispatch_once_t once;
    static id _backgroundQueue;
    
    dispatch_once(&once, ^{
        _backgroundQueue = [[NSOperationQueue alloc] init];
        [_backgroundQueue setMaxConcurrentOperationCount:4];
    });
    
    return _backgroundQueue;
}

#pragma mark Application event handling

-(void)postApplicationEvent:(NSString *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:event object:nil];
}

//returns YES if checked string is email formatted, or NO
- (BOOL) validateEmail:(NSString*) string
{
    NSString* emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:string];
}

- (NSString*) appVersionString
{
    return [NSString stringWithFormat:@"Version %@ Build %@",
            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
}

//
// image handling support
//

//loading an image
- (UIImage*)loadImage:(NSString*)imageName
{
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@%@", NSHomeDirectory(), @"Documents", imageName];
    ////nslog(@"fullPath: %@", fullPath);
    UIImage *img = [UIImage imageWithContentsOfFile:fullPath];
    
    return img; 
}

//saving an image
- (void)saveImage:(UIImage*)image imageName:(NSString*)imageName
{
    NSData *imageData = UIImagePNGRepresentation(image); //convert image into .png format.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
    [fileManager createFileAtPath:fullPath contents:imageData attributes:nil];
    //nslog(@"image saved");
}

//removing an image
- (void)removeImage:(NSString*)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", fileName]];
    [fileManager removeItemAtPath: fullPath error:NULL];
    //nslog(@"image removed");
    
}

- (void) openAssetWithPath:(NSString*)path
{
    NSString *fullPath = [self prefixDocumentsPathToPath:path];
    
    NSURL *url = [[NSURL alloc] initFileURLWithPath:fullPath];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL: url];
    } else {
        //nslog(@"Not supported application to open the file %@", fullPath);
    }
}

- (NSString*) prefixDocumentsPathToPath:(NSString*)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", path]];
    //return [fullPath stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    return fullPath;
}


- (NSFetchRequest*)fetchRequestWithEntity:(NSString*)entityName
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    return fetchRequest;
}

- (NSString*) referencepath
{
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Content"];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"keywords == %@ && contentCatId == %d", @"references",kApplications];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error)
    {
        if (items && items.count > 0)//[mo valueForKey:@"fieldValue"]
        {
            for (NSManagedObject* mo in items) {
             
                NSString* pathstring = [mo valueForKey:@"path"];
                return pathstring;
            }
        }
    }
    
    return nil;
}

- (NSString*) getMirformPdf
{
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Content"];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"keywords == %@ && contentCatId == %d", @"blank_mir_form",kApplications];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error)
    {
        if (items && items.count > 0)//[mo valueForKey:@"fieldValue"]
        {
            for (NSManagedObject* mo in items) {
                
                NSString* pathstring = [mo valueForKey:@"path"];
                return pathstring;
            }
        }
    }
    
    return nil;
}
- (NSString*) getAppContentPath:(NSString *)pdftype
{
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"Content"];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"keywords == %@ && contentCatId == %d", pdftype,kApplications];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error)
    {
        if (items && items.count > 0)//[mo valueForKey:@"fieldValue"]
        {
            for (NSManagedObject* mo in items) {
                
                NSString* pathstring = [mo valueForKey:@"path"];
                return pathstring;
            }
        }
    }
    
    return nil;
}


- (void) navigateToProductDetail
{
    _isproductClicked = YES;
    [_tabBarController setSelectedIndex:PRODUCT_TAB_INDEX];
}

- (void) backgroundDelayedNavigateToProductDetail
{
    [self performSelectorOnMainThread:@selector(navigateToProductDetail) withObject:nil waitUntilDone:NO];
}

- (void) navigateToProductDetailWithProduct:(Product*)product
{
    [[DashboardModel sharedInstance] setCurrentProductProductsFlow:product];
    
    [self performSelector:@selector(backgroundDelayedNavigateToProductDetail) withObject:nil afterDelay:0.0f];
    

}
#warning candidate for removal appears to not be used
/*
- (void) presentContentViewerWithContent:(Content*)content
{
    //_currentContent = content;
    
    [[[UIAlertView alloc] initWithTitle:@"debug" message:@"content viewer not implemented!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    
}
*/
- (NSString*)deviceUUID
{
    NSString *uuidStr;
    
    /*
     // recommeded to use
     //
     //http://nshipster.com/uuid-udid-unique-identifier/
     //
     NSString *uuidStr = [[NSUserDefaults standardUserDefaults] objectForKey:kApplicationUUIDKey];
     if (!uuidStr) {
     CFUUIDRef uuid = CFUUIDCreate(NULL);
     uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
     CFRelease(uuid);
     
     [[NSUserDefaults standardUserDefaults] setObject:uuidStr forKey:kApplicationUUIDKey];
     [[NSUserDefaults standardUserDefaults] synchronize];
     }
     */
    
#warning USING DEPRACATED API !!!
    //uuidStr = [[UIDevice currentDevice] uniqueIdentifier];
    //uuidStr = @"01234567890";
    NSUUID *uuid = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    uuidStr = [uuid UUIDString];

    return uuidStr;
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {

    // Handle the notificaton when the app is running
    //nslog(@"Recieved Notification %@", notif);
    
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * syncSchedule = [defaults objectForKey:@"syncSchedule"];
    //BOOL autoUpdate = [[syncSchedule objectForKey:@"autoUpdates"] boolValue];
//    if (autoUpdate) {
//        [self invokeContentSync];
//    } else
    {
        [[ContentSyncVerifier sharedInstance] checkSpecialityStatus];
    }
    _isScheduleMisfired = NO;
    //NSLog(@"Content Sync notification fired (Auto Update = %d)", autoUpdate);
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
//    DownloadManager* downloadManager = [DownloadManager sharedManager];
//    if ([downloadManager isDownloadPaused]) {
//        [downloadManager resumeAllDownloads];
//        [[ContentSyncModel sharedContentSync] resumeDownloads];
//    }

    //nslog(@"performFetchWithCompletionHandler invoked");
    if ([[DownloadManager sharedManager] isDownloading]) {
        completionHandler(UIBackgroundFetchResultNewData);
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (id) serverURLFromSettings:(NSString*) key
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	id val = nil;
    //nslog(@"settingsDictionary %@", standardUserDefaults);
    
	if (standardUserDefaults)
		val = [standardUserDefaults objectForKey:key];
    
	if (val == nil) {
		//nslog(@"user defaults may not have been loaded from Settings.bundle ... doing that now ...");
		//Get the bundle path
		NSString *bPath = [[NSBundle mainBundle] bundlePath];
		NSString *settingsPath = [bPath stringByAppendingPathComponent:@"Settings.bundle"];
		NSString *plistFile = [settingsPath stringByAppendingPathComponent:@"Root.plist"];
        
		//Get the Preferences Array from the dictionary
		NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
		NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
		//Loop through the array
		NSDictionary *item;
		for(item in preferencesArray)
		{
			//Get the key of the item.
			NSString *keyValue = [item objectForKey:@"Key"];
            
			//Get the default value specified in the plist file.
			id defaultValue = [item objectForKey:@"DefaultValue"];
			if (keyValue && defaultValue) {
				[standardUserDefaults setObject:defaultValue forKey:keyValue];
				if ([keyValue compare:key] == NSOrderedSame)
					val = defaultValue;
			}
		}
		[standardUserDefaults synchronize];
	}
	return val;
}

SyncViewController *sync1;
- (void) invokeContentSync {
    
    sync1 = [[SyncViewController alloc] init];
    
    NSMutableArray* tempEntitlements = [[NSMutableArray alloc] init];
    NSArray* myEntitlements = [[RegistrationModel sharedInstance].profile myProfileToMyEntitlement].allObjects;
    
    [[[UpdateNotify SharedManager] syncArray]removeAllObjects];
    [tempEntitlements removeAllObjects];
    
    for (int i =0; i<[myEntitlements count]; i++)
    {
        MyEntitlement* entitlement1 =  [myEntitlements objectAtIndex:i];
        if ([[entitlement1 status] isEqualToNumber:[NSNumber numberWithInt:kEntitlementStatusEnabled]]) {
            [tempEntitlements addObject:entitlement1]; //Add selected Specialites to get deltas
        }
    }
    [[UpdateNotify SharedManager] setSyncArray:tempEntitlements];
    sync1.syncvalue1 = 1;
    ContentSyncModel* contentSyncModel = [ContentSyncModel sharedContentSync];
    contentSyncModel.syncFromDashboard = 1;
    
    TabBarViewController* tab = (TabBarViewController*)self.tabBarController;
    sync1.delegate = tab;
    sync1.syncFromScheduler = YES;
    [sync1 syncBtnClicked:nil];
    
    tempEntitlements = nil;
    myEntitlements = nil;
}

- (void) scheduleNotificationForDate: (NSDate*) date {
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = date;
    NSLog(@"Notification set for : %@", localNotification.fireDate);
    
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //    localNotification.alertBody = [NSString stringWithFormat:@"Content updates Available"];
    localNotification.alertAction = NSLocalizedString(@"Content Sync", nil);
    //    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 0;
    localNotification.repeatInterval = NSDayCalendarUnit;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end