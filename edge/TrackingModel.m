//
//  TrackingModel.m
//  edge
//
//  Created by Ryan G Walton on 8/28/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "TrackingModel.h"
#import "AppDelegate.h"
#import "Tracking.h"
#import "RegistrationModel.h"
#import "MyProfile.h"
#import "AFNetworking.h"

#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]

@interface TrackingModel ()
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, assign) NSManagedObjectContext *managedObjectContext;

@end

@implementation TrackingModel

+ (TrackingModel*) sharedInstance
{
    static TrackingModel *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[TrackingModel alloc] init];
        // Do any other initialisation stuff here
        [instance initModel];
        
    });
    
    return instance;
    
}
- (void) initModel
{
    // init
    _appDelegate = [UIApplication sharedApplication].delegate;
    _managedObjectContext = _appDelegate.managedObjectContext;
    
}

- (void) callTracking
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:[[RegistrationModel sharedInstance] uuid] forKey:@"uuid"];
    
    NSMutableArray *trackingArray = [NSMutableArray array];
    
    for (Tracking* trackingInfo in [[self trackingFRC] fetchedObjects])
    {
        NSMutableDictionary *trackingInfoDict = [[NSMutableDictionary alloc]init];
        [trackingInfoDict setObject:trackingInfo.activityCode forKey:@"activityCode"];
        [trackingInfoDict setObject:trackingInfo.resources forKey:@"resource"];
        [trackingInfoDict setObject:trackingInfo.timestamp forKey:@"acessDt"];
        [trackingArray addObject:trackingInfoDict];
    }
    [params setObject:trackingArray forKey:@"trackingInfo"];
    
    [self trackingWithParams:params];
}


- (void) createTrackingDataWithUserName:(NSString *)name resource:(NSString *)resource activityCode:(NSString *)activityCode timestamp:(NSString *)timestamp
{
    // Create a new instance of the entity
    Tracking *track = [NSEntityDescription insertNewObjectForEntityForName:@"Tracking"
                                                    inManagedObjectContext:_appDelegate.managedObjectContext];
    
    track.userName = [self userFullName];
    track.resources = resource;
    track.activityCode = activityCode;
    track.timestamp = [self trackingTimestamp];
    
    [_appDelegate saveContext];
    
}

- (void) createTrackingDataWithResource:(NSString *)resource activityCode:(NSString *)activityCode
{
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tracking" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    //NSError *error;
    
    // Create a new instance of the entity
    Tracking *track = [NSEntityDescription insertNewObjectForEntityForName:@"Tracking"
                                                    inManagedObjectContext:_appDelegate.managedObjectContext];
    
    //track.userName = [self userFullName];
    track.userName = [self userEmailString];
    
    track.resources = resource;
    track.activityCode = activityCode;
    track.timestamp = [self trackingTimestamp];
    
    //NSLog(@"Resource = %@ ActivityCode = %@",resource, activityCode);

    [_appDelegate saveContext];

    /*
    int countForFetch;
    countForFetch = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    
    
    if (countForFetch < MAX_TRACKING_ITEMS)
    {
        
    }
    else
    {
        // Remove oldest tracking object
        
        [fetchRequest setFetchLimit:1];
        NSError *error;
        NSArray *results = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
        Tracking *track = nil;
        track = [results objectAtIndex:0];
        [self deleteOldestTrackingItem:track];
        
        // Now create new
        // instance of the entity
        
        track = [NSEntityDescription insertNewObjectForEntityForName:@"Tracking"
                                              inManagedObjectContext:_appDelegate.managedObjectContext];
        
        //track.userName = [self userFullName];
        track.userName = [self userEmailString];
        
        track.resources = resource;
        track.activityCode = activityCode;
        track.timestamp = [self trackingTimestamp];
        
    }
     */
}

- (void) deleteOldestTrackingItem:(Tracking *)track
{
    [_appDelegate.managedObjectContext deleteObject:track];
    
    [_appDelegate saveContext];
}


#pragma mark -
#pragma Private Methods

- (NSFetchRequest*)trackingFetchRequest
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tracking" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    return fetchRequest;
}

- (NSFetchedResultsController *) trackingFRC
{
    NSFetchRequest *fetchRequest = [self trackingFetchRequest];
    
    NSString *sectionNameKeyPath;
    sectionNameKeyPath = @"timestamp";
    //nslog(@"sectionNKP %@", sectionNameKeyPath);
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:sectionNameKeyPath ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:
                                sortDescriptor1,
                                nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
                                                            initWithFetchRequest:fetchRequest
                                                            managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionNameKeyPath
                                                            cacheName:nil];
    NSError *error = nil;
	if (![fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	     */
	    //nslog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    //nslog(@"Tracking model fetchedObjects.count: %d", fetchedResultsController.fetchedObjects.count);
    return fetchedResultsController;
}

-(NSString *) userFullName
{
    NSString *userString = [NSString stringWithFormat:@"%@, %@", [RegistrationModel sharedInstance].profile.lastName, [RegistrationModel sharedInstance].profile.firstName];
    return userString;
}

-(NSString *) userEmailString
{
    NSString *userString = [NSString stringWithFormat:@"%@", [RegistrationModel sharedInstance].profile.email];
    return userString;
}

-(NSString *) trackingTimestamp
{
    NSString *dateString = [NSString stringWithFormat:@"%@", [NSDate date]];
    return dateString;
}


#pragma mark -
#pragma Web Service Methods

- (void) trackingWithParams:(NSDictionary*)params
{
    
    NSString* serverBaseURL = WEB_SERVICE_BASE_SERVER;
//    NSString* defaultServerURL = [APP_DELEGATE settingsServerURL];
//    if (defaultServerURL != nil && defaultServerURL.length > 0)
//        serverBaseURL = defaultServerURL;
    
    //NSString *wsUrlStr = [NSString stringWithFormat:@"%@%@", serverBaseURL, POST_TRACKING_SERVICE];

    ////nslog(@"tracking url: %@", wsUrlStr);
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:serverBaseURL]];
    
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:POST_TRACKING_SERVICE parameters:params];
    //NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:POST_TRACKING_SERVICE parameters:nil];
    //nslog(@"Params: %@", params);
    //nslog(@"Sending %lu tracking parameters", (unsigned long)[[params objectForKey:@"trackingInfo"] count]);

    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:[[RegistrationModel sharedInstance].profile email] forHTTPHeaderField:@"USERNAME"];
    //[request setValue:@"failcase" forHTTPHeaderField:@"USERNAME"];

    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"application/json"]];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/json"]];
    
    AFJSONRequestOperation *op = [AFJSONRequestOperation
                                  JSONRequestOperationWithRequest:request
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                  {
                                      //nslog(@"%@ success response at: %@", wsUrlStr, [NSDate date]);
                                      //nslog(@"response status code: %ld", (long)response.statusCode);
                                     // NSLog(@"JSON payload %@", params);

                                      if (response.statusCode == 200)
                                      {
                                          //nslog(@"trackingWithParams success.");
                                          // success call, can now delete sent tracking item from core data
                                          if ([self parseTrackingWithResponseDict:JSON])
                                          {
                                              //nslog(@"Successfull response 200.");
                                              [self clearTrackingData];
                                          }
                                      
                                      } else
                                      {
                                          // some kind of failure
                                          //nslog(@"parseTrackingWithResponseDict error response.");
                                      }
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                      //nslog(@"failure response %@  \n error %@ \n JSON %@", response, error, JSON);
                                  }];
    
    
    [httpClient enqueueHTTPRequestOperation:op];
}


-(NSDictionary *)createTrackingDictionary
{
    NSDictionary *trackingDictionary;
    
    return trackingDictionary;
}

#pragma mark -
//
// web service response related
//
- (BOOL) parseTrackingWithResponseDict:(NSDictionary*)json
{
    BOOL validTrack = NO;

    if ([json isKindOfClass:[NSDictionary class]])
    {
        //nslog(@"JSON is dictionary");
        
        NSDictionary *header = [json objectForKey:@"header"];
        NSNumber *statusCode = [header objectForKey:@"statusCode"];

        switch ([statusCode intValue])
        {
            case 200:
            {
                validTrack = YES;
                break;
            }
            case 401:
            case 4:
            case 2:
            case 507:
            case 506:
            default:
            {
                validTrack = NO;
                break;
            }

        }
    }
    
    return validTrack;
}

- (void)clearTrackingData
{
    [self deleteAllFromEntityWithName:@"Tracking"];
    
}
- (void) deleteAllFromEntityWithName:(NSString*)entityName
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            for (NSManagedObject *item in items)
            {
                [self.managedObjectContext deleteObject:item];
            }
            
            [self.appDelegate saveContext];
        }
    }
    
}

@end
