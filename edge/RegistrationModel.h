//
//  User.h
//  edge
//
//  Created by iPhone Developer on 5/17/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MyProfile;
@class MyEntitlement;
@class Speciality;

enum DownloadState {
    kDownloadStateStarted = 0,
    kDownloadStateStopped,
    kDownloadStateComplete
    };

enum EntitlementStatus {
    kEntitlementStatusDisabled = 0,
    kEntitlementStatusEnabled
    };

#define USER_DEFAULT_KEY_EMAIL              @"email"
#define USER_DEFAULT_KEY_PASSWORD           @"password"
#define USER_DEFAULT_KEY_AUTHORIZED         @"authorized"
#define USER_DEFAULT_KEY_REGISTERED         @"registered"
#define USER_DEFAULT_KEY_DOWNLOAD_STATUS    @"downloadStatus"
#define USER_DEFAULT_KEY_KEEP_ME_LOGGED_IN  @"keepmeloggedin"

#define USER_DEFAULT_VALUE_UUID             @"1234567890"
// define or undefine to enable/disable using device uuid
#define DEVICE_UUID_ENABLED             1
//#undef DEVICE_UUID_ENABLED

@interface RegistrationModel : NSObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;

@property (nonatomic, strong) MyProfile *profile;

+ (RegistrationModel*) sharedInstance;

// login (authorization)
- (BOOL) isAuthorized;
- (void) loginWithEmail:(NSString*)email password:(NSString*)password initialLogin:(BOOL)initialLogin;
- (void) logout;

// registration
- (BOOL) isRegistered;
- (void) updateRegistration:(NSDictionary*)dict;
- (void) deregistration;
- (void) setRegistrationComplete;

- (BOOL) loadMyProfile;

- (NSString*) uuid;

// entitlements and enablements
- (MyEntitlement*)defaultEntitlement;           // the user's default MyEntitlement (Speciality)
- (BOOL)isMyEntitlementEnabled:(MyEntitlement*)myEntitlement;
- (BOOL) atLeastOneEnablement;
- (void) relateEntitlementsToSpecialities;
- (Speciality*) specialityWithSplId:(NSNumber*)splId;

// download state
@property (nonatomic, strong) NSNumber* downloadState;
@property (nonatomic, assign) unsigned long long totalContentDownloadSize;

@end


/*
 // Get UUID value
 NSUUID  *uuid = [NSUUID UUID];
 
 // Convert UUID to string and output result
 //nslog(@"UUID: %@", [uuid UUIDString]);
 
 Read more at http://icodetoplay.com/tips/ios-6-sdk-create-universally-unique-identifier/#jlsKW5O2UCiRWUuT.99
 */
