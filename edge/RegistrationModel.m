//
//  User.m
//  edge
//
//  Created by iPhone Developer on 5/17/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "RegistrationModel.h"
#import "AppDelegate.h"
#import "MyProfile.h"
#import "MyEntitlement.h"
#import "Speciality.h"
#import "ContentModel.h"
#import <AdSupport/AdSupport.h>

@interface RegistrationModel ()
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, strong) NSString *uuid;
@end

@implementation RegistrationModel

- (id) init
{
    if (self = [super init])
    {
        _appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        
        [self initUUID];
        
        _downloadState = [_appDelegate.userDefaults objectForKey:USER_DEFAULT_KEY_DOWNLOAD_STATUS];
    }
    return self;
}

+ (RegistrationModel*) sharedInstance
{
    static RegistrationModel *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[RegistrationModel alloc] init];
        // Do any other initialisation stuff here
        if (instance.isRegistered)
        {
            [instance loadMyProfile];
        }
    });
    
    return instance;
    
}

#pragma mark -
#pragma mark public methods

#pragma mark -
#pragma mark login
- (BOOL) isAuthorized
{
    BOOL req = [_appDelegate.userDefaults boolForKey:USER_DEFAULT_KEY_AUTHORIZED];
    //nslog(@"isAuthorized: %@", req ? @"YES" : @"NO");
    return req;
}

- (void) loginWithEmail:(NSString*)email password:(NSString*)password initialLogin:(BOOL)initialLogin
{
    BOOL valid = YES;
    
    if (!initialLogin)
    {
        // check that email/password matches last saved values
        NSString *savedEmail = [_appDelegate.userDefaults objectForKey:USER_DEFAULT_KEY_EMAIL];
        NSString *savedPassword = [_appDelegate.userDefaults objectForKey:USER_DEFAULT_KEY_PASSWORD];

        valid = [email isEqualToString:savedEmail] && [password isEqualToString:savedPassword];
        
    }
    
    if (valid)
    {
        [_appDelegate.userDefaults setBool:YES forKey:USER_DEFAULT_KEY_AUTHORIZED];
        [_appDelegate.userDefaults setObject:email forKey:USER_DEFAULT_KEY_EMAIL];
        [_appDelegate.userDefaults setObject:password forKey:USER_DEFAULT_KEY_PASSWORD];
        [_appDelegate.userDefaults synchronize];
        
        if (![self loadMyProfile])
        {
            [[[UIAlertView alloc] initWithTitle:@"Profile Load Error" message:@"Error loading profile from local storage." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
        }

    }
    
    [_appDelegate postApplicationEvent:valid ? APP_EVENT_LOGIN_SUCCESS : APP_EVENT_LOGIN_FAILURE];
    
}

- (void) logout
{
    [_appDelegate.userDefaults setBool:NO forKey:USER_DEFAULT_KEY_AUTHORIZED];
    [_appDelegate.userDefaults removeObjectForKey:USER_DEFAULT_KEY_EMAIL];
    [_appDelegate.userDefaults synchronize];
    
}

#pragma mark -
#pragma mark registration
- (BOOL) isRegistered
{
    BOOL reg = [_appDelegate.userDefaults boolForKey:USER_DEFAULT_KEY_REGISTERED];
    //nslog(@"isRegistered: %@", reg ? @"YES" : @"NO");
    return reg;
}

- (void) callUpdateRegistration:(NSDictionary*)dict
{
    [self performSelectorOnMainThread:@selector(updateRegistration:) withObject:dict waitUntilDone:NO];
}

- (void) updateRegistration:(NSDictionary*)dict
{
    NSString *email = [dict objectForKey:@"email"];
    [_appDelegate.userDefaults setObject:email forKey:USER_DEFAULT_KEY_EMAIL];
    //[_appDelegate.userDefaults setBool:YES forKey:USER_DEFAULT_KEY_REGISTERED];
    [_appDelegate.userDefaults synchronize];
    
    [self addOrUpdateProfileWithDict:dict];

    // re-load the user profile, since entitlements might have changed
    [self performSelectorOnMainThread:@selector(loadMyProfile) withObject:nil waitUntilDone:YES];
}

- (void) deregistration
{
    [_appDelegate.userDefaults setBool:NO forKey:USER_DEFAULT_KEY_REGISTERED];
    [_appDelegate.userDefaults synchronize];

}

- (void) setRegistrationComplete
{
    // create the relationships between MyEntitlements and Speciality objects.
    [self relateEntitlementsToSpecialities];
    
    [_appDelegate.userDefaults setBool:YES forKey:USER_DEFAULT_KEY_REGISTERED];
    [_appDelegate.userDefaults synchronize];
    
    _profile.contentUpdDt = [NSDate date];
    [_appDelegate saveContext];

}

#pragma mark -

// the user's default MyEntitlement (Speciality)
// @returns - nil or the user's default MyEntitlement
- (MyEntitlement*)defaultEntitlement
{
    MyEntitlement *myEnt;
    
    [self loadMyProfile];
    
    if (_profile)
    {
        for (MyEntitlement *entitlement in [_profile.myProfileToMyEntitlement allObjects])
        {
            if (entitlement.isDefault)
            {
                //nslog(@"RegistrationModel defaultEntitlement: %@", entitlement.name);
                myEnt = entitlement;
                break;
            }
        }
    }
    
    return myEnt;
}

- (BOOL)isMyEntitlementEnabled:(MyEntitlement*)myEntitlement
{
    return [myEntitlement.status intValue] == kEntitlementStatusEnabled;
}

- (BOOL) atLeastOneEnablement
{
    BOOL atLeastOne = NO;
    
    if (_profile)
    {
        for (MyEntitlement *entitlement in [_profile.myProfileToMyEntitlement allObjects])
        {
            if ([entitlement.status intValue] == kEntitlementStatusEnabled)
            {
                atLeastOne = YES;
                break;
            }
        }
    }
    
    return atLeastOne;
    
}

#pragma mark -
#pragma mark private stuff


- (NSFetchRequest*)profileFetchRequestWithEmail:(NSString*)email
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyProfile" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"email = %@", email];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;    
}

- (NSFetchRequest*)specialityFetchRequestWithSplId:(NSNumber*)splId
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Speciality" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"splId = %d", [splId intValue]];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

- (Speciality*) specialityWithSplId:(NSNumber*)splId
{
    Speciality *speciality;
    
    NSFetchRequest *fetchRequest = [self specialityFetchRequestWithSplId:splId];
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            speciality = [items objectAtIndex:0];
        }
    }

    return speciality;
    
}

- (BOOL) loadMyProfile
{
    BOOL loaded = NO;
    
    NSString *email = [_appDelegate.userDefaults objectForKey:USER_DEFAULT_KEY_EMAIL];
    
    if (email)
    {
        // Create the fetch request for MyProfile
        NSFetchRequest *fetchRequest = [self profileFetchRequestWithEmail:email];
        
        NSError *error;
        NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error) {
            if (items && items.count > 0)
            {
                _profile = [items objectAtIndex:0];
                loaded = YES;
            }
        }
    }
    
    return loaded;
}

- (void) deleteAllEntitlements
{
    for (MyEntitlement *entitlement in _profile.myProfileToMyEntitlement.allObjects)
    {
        [_appDelegate.managedObjectContext deleteObject:entitlement];
    }
    [_appDelegate saveContext];
}

// return an array of MyEntitlements for the given array of speciality ids
- (NSArray*) createMyEntitlements:(NSArray*)entitlements
{
    // delete current entitlements
    [self deleteAllEntitlements];
    
    NSMutableArray *myEntitlements = [NSMutableArray array];
    for (NSDictionary *dict in entitlements)
    {
        [myEntitlements addObject:[self addOrUpdateMyEntitlementWithDict:dict]];
    }
    
    return myEntitlements;
}

// after Specialties are downloaded, they need to be "related" to MyEntitlements
- (void) relateEntitlementsToSpecialities
{
    BOOL updated = NO;
 
    //nslog(@"_profile.myProfileToMyEntitlement.count: %d", _profile.myProfileToMyEntitlement.count);
    
    [self loadMyProfile];
    
    //nslog(@"_profile.myProfileToMyEntitlement.count: %d", _profile.myProfileToMyEntitlement.count);

    if (_profile)
    {
        for (MyEntitlement *myEntitlement in _profile.myProfileToMyEntitlement.allObjects)
        {
            //nslog(@"myEntitlement.splId: %d", [myEntitlement.splId intValue]);
            Speciality *speciality = [self specialityWithSplId:myEntitlement.splId];
            if (speciality)
            {
                speciality.specialityToMyEntitlement = myEntitlement;
                myEntitlement.myEntitlementToSpeciality = speciality;
                updated = YES;
            }
        }
    }
    
    if (updated)
    {
        [_appDelegate saveContext];
    }
    
}

- (MyEntitlement*) addOrUpdateMyEntitlementWithDict:(NSDictionary*)dict
{
    MyEntitlement *myEntitlement;
    NSNumber *splId = [dict objectForKey:@"splId"];
    
    // Create the fetch request for MyEntitlement
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyEntitlement" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // add the predicate for searching
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"splId = %d", [splId intValue]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    BOOL found = NO;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            myEntitlement = [items objectAtIndex:0];
            found = YES;
        }
    }
    
    if (!found)
    {
        // Create a new instance of the entity
        myEntitlement = [NSEntityDescription insertNewObjectForEntityForName:@"MyEntitlement"
                                                 inManagedObjectContext:_appDelegate.managedObjectContext];
        myEntitlement.splId = splId;
        myEntitlement.status = [NSNumber numberWithInt:kEntitlementStatusDisabled];
    }

    /*
     @property (nonatomic, retain) NSNumber * splId;
     @property (nonatomic, retain) NSNumber * totalFiles;
     @property (nonatomic, retain) NSString * name;
     @property (nonatomic, retain) NSDecimalNumber * totalSize;
     @property (nonatomic, retain) NSNumber * status;
     @property (nonatomic, retain) NSDate * contentUpdDt;
     @property (nonatomic, retain) MyProfile *myEntitlementToMyProfile;
      */

    myEntitlement.totalFiles = [dict objectForKey:@"totalFiles"];
    myEntitlement.name = [dict objectForKey:@"name"];
    myEntitlement.totalSize = [dict objectForKey:@"totalSize"];

    // relate myEntitlement to MyProfile
    myEntitlement.myEntitlementToMyProfile = _profile;
    
    [_appDelegate saveContext];
    
    return myEntitlement;

}

- (void) addOrUpdateProfileWithDict:(NSDictionary*)dict
{
    NSString *email = [dict objectForKey:@"email"];
    
    // Create the fetch request for MyProfile
    NSFetchRequest *fetchRequest = [self profileFetchRequestWithEmail:email];
    
    NSError *error;
    BOOL found = NO;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            _profile = [items objectAtIndex:0];
            found = YES;
        }
    }
    
    if (!found)
    {
        // Create a new instance of the entity
        _profile = [NSEntityDescription insertNewObjectForEntityForName:@"MyProfile"
                                                inManagedObjectContext:_appDelegate.managedObjectContext];
        _profile.email = email;
        _profile.crtDt = [NSDate date];
    }

    /*
    2013-06-14 12:45:58.229 edge[94968:11603] response: {
        body =     {
            email = "demo@example.com";
            market = USA;
            repType = "";
            role = role1;
            splIds =         (
                              {
                                  name = "Bariatric Surgery";
                                  splId = 1;
                                  totalFiles = 9;
                                  totalSize = 648375;
                              },
                              {
                                  name = "Cardiovascular Surgery";
                                  splId = 2;
                                  totalFiles = 10;
                                  totalSize = 650075;
                              },
                              {
                                  name = "Hernia Repair";
                                  splId = 5;
                                  totalFiles = 5;
                                  totalSize = 134646;
                              },
                              {
                                  name = "Plastic Surgery";
                                  splId = 6;
                                  totalFiles = 0;
                                  totalSize = 0;
                              }
                              );
        };
        header =     {
            message = OK;
            status = success;
            statusCode = 200;
        };
    }
    */
    
    // NOTE: dictionary may not contain values for all attributes,
    // so check before assigning value
    if ([dict objectForKey:@"department"])
        _profile.department = [dict objectForKey:@"department"];
    if ([dict objectForKey:@"division"])
        _profile.division = [dict objectForKey:@"division"];
    _profile.email = [dict objectForKey:@"email"];
    if ([dict objectForKey:@"firstName"])
        _profile.firstName = [dict objectForKey:@"firstName"];
    if ([dict objectForKey:@"lastName"])
        _profile.lastName = [dict objectForKey:@"lastName"];
    if ([dict objectForKey:@"state"])
            _profile.state = [dict objectForKey:@"state"];
    _profile.uptDt = [NSDate date];
    if ([dict objectForKey:@"market"])
        _profile.market = [dict objectForKey:@"market"];
    if ([dict objectForKey:@"repType"])
        _profile.repType = [dict objectForKey:@"repType"];
    if ([dict objectForKey:@"role"])
        _profile.role = [dict objectForKey:@"role"];

    // get the user's "Speciality" entitlements (array of splIds)
    NSArray *entitlements = [dict objectForKey:@"splIds"];
    if (entitlements != (id)[NSNull null])
    {
        if (entitlements && entitlements.count > 0)
        {
            // create MyEntitlements from the returned entitlements
            NSArray *myEntitlements = [self createMyEntitlements:entitlements];
            //nslog(@"myEntitlements.count: %d", myEntitlements.count);
            NSSet *myEntSet = [NSSet setWithArray:myEntitlements];
            [_profile setMyProfileToMyEntitlement:myEntSet];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Info" message:@"You do not have access to Specialities" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    [_appDelegate saveContext];
    
}


- (void) initUUID
{
    NSString *myUUID = [_appDelegate deviceUUID];
    //nslog(@"my device UUID: %@ and %@", myUUID,_appDelegate.DeviceToken);
    NSUUID *uuid = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    myUUID = [uuid UUIDString];

        if ([myUUID isEqualToString:@""])
        {
            _uuid = @"1234567890";
        }
        else
        {
            _uuid = myUUID;
        }
            
        
}

@end
