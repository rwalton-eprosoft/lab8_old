//
//  AppDelegate.h
//  edge
//
//  Created by iPhone Developer on 5/11/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Content;
@class DashboardModel;
@class FilterModel;
@class Product;
@class RegistrationModel;

#define BRANDING_RED_COLOR                      [UIColor colorWithRed:255/255 green:58/255 blue:67/255 alpha:1.0];
#define BRANDING_GRAY_COLOR                     [UIColor colorWithRed:126/255 green:128/255 blue:131/255 alpha:1.0];

#define JJBRANDING_RED_COLOR                    [UIColor colorWithRed:192/255 green:4/255 blue:0 alpha:1.0];
#define JJBRANDING_DARK_GRAY_COLOR              [UIColor colorWithRed:68/255 green:61/255 blue:61/255 alpha:1.0];
#define JJBRANDING_MED_GRAY_COLOR               [UIColor colorWithRed:153/255 green:146/255 blue:146/255 alpha:1.0];
#define JJBRANDING_LIGHT_GRAY_COLOR             [UIColor colorWithRed:211/255 green:205/255 blue:205/255 alpha:1.0];
#define JJBRANDING_WHITE_COLOR                  [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1.0];
#define JJBRANDING_YELLOW_COLOR                 [UIColor colorWithRed:241/255 green:183/255 blue:28/255 alpha:1.0];

#define APP_EVENT_LOGIN_SUCCESS                 @"APP_EVENT_LOGIN_SUCCESS"
#define APP_EVENT_LOGIN_FAILURE                 @"APP_EVENT_LOGIN_FAILURE"

#define APP_EVENT_REGISTRATION_SUCCESS          @"APP_EVENT_REGISTRATION_SUCCESS"
#define APP_EVENT_REGISTRATION_FAILURE          @"APP_EVENT_REGISTRATION_FAILURE"
#define APP_EVENT_REGISTRATION_ERROR_RESPONSE   @"APP_EVENT_REGISTRATION_ERROR_RESPONSE"

#define APP_EVENT_SYNC_PRODUCT_SUCCESS          @"APP_EVENT_SYNC_PRODUCT_SUCCESS"
#define APP_EVENT_SYNC_PRODUCT_FAILURE          @"APP_EVENT_SYNC_PRODUCT_FAILURE"

#define APP_EVENT_SYNC_CONTENT_SUCCESS          @"APP_EVENT_SYNC_CONTENT_SUCCESS"
#define APP_EVENT_SYNC_CONTENT_FAILURE          @"APP_EVENT_SYNC_CONTENT_FAILURE"

#define APP_EVENT_SYNC_MASTER_DATA_SUCCESS      @"APP_EVENT_SYNC_MASTER_DATA_SUCCESS"
#define APP_EVENT_SYNC_MASTER_DATA_FAILURE      @"APP_EVENT_SYNC_MASTER_DATA_FAILURE"

#define APP_REQUEST_FAILURE                     @"APP_REQUEST_FAILURE"

#define SIZE_VALIDATION_SUCESS                     @"SIZE_VALIDATION_SUCESS"
#define SIZE_VALIDATION_FAILURE                     @"SIZE_VALIDATION_FAILURE"


#define APP_EVENT_NO_WIFI                       @"APP_EVENT_NO_WIFI"

#define APP_EVENT_VERIFY_SYNC_DATA_SUCCESS      @"APP_EVENT_VERIFY_SYNC_DATA_SUCCESS"
#define APP_EVENT_VERIFY_SYNC_DATA_FAILURE      @"APP_EVENT_VERIFY_SYNC_DATA_FAILURE"

#define APP_EVENT_ALL_DOWNLOAD_COMPLETE         @"APP_EVENT_ALL_DOWNLOAD_COMPLETE"
#define APP_EVENT_DOWNLOAD_COMPLETE_SUCCESS     @"APP_EVENT_DOWNLOAD_COMPLETE_SUCCESS"
#define APP_EVENT_DOWNLOAD_COMPLETE_FAILURE     @"APP_EVENT_DOWNLOAD_COMPLETE_FAILURE"

#define APP_EVENT_TRACKING_SUCCESS              @"APP_EVENT_TRACKING_SUCCESS"
#define APP_EVENT_TRACKING_FAILURE              @"APP_EVENT_TRACKING_FAILURE"
#define APP_EVENT_TRACKING_ERROR_RESPONSE       @"APP_EVENT_TRACKING_ERROR_RESPONSE"
#define APP_EVENT_DASHBOARD_REFRESHED           @"APP_EVENT_DASHBOARD_REFRESHED"
#define NOTIFY_UPDATE_INTERVAL                  14400 //4 hours

#define PROCEDURE_TAB_INDEX                     1
#define PRODUCT_TAB_INDEX                       2

#define PRODUCT_MISSING_IMAGE                   @"product_missing_image.png"
#define CONTENT_MISSING_IMAGE                   @"content_missing_image.png"

#define IMAGE_VIEW_GRID_ICON                    @"grid"
#define IMAGE_VIEW_LIST_ICON                    @"listview"
#define IMAGE_VIDEOS_ICON                       @"videos.png"
#define IMAGE_ARTICLES_ICON                     @"form.png"
#define IMAGE_SPECIFICATIONS_ICON               @"specifications.png"
#define IMAGE_COMPETITIVE_ICON                  @"competetive.png"
#define IMAGE_CLINICAL_ICON                     @"clinical.png"
#define IMAGE_ECONOMICAL_ICON                   @"economical.png"
#define IMAGE_VACPAC_ICON                       @"vacpac.png"
#define IMAGE_RESOURCES_ICON                    @"resources.png"

#define MINIMUM_SEARCH_STRING_LENGTH            3

#define MAX_RECENTLY_VIEWED                     10

//@class Reachability;  //Added to check reachability in Downloads
@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    //Start -- Added to check reachability in Downloads
//    Reachability* hostReach;       
//    Reachability* internetReach;
//    Reachability* wifiReach;
    //End --   Added to check reachability in Downloads
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readwrite) BOOL IsupdatedClicked;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) UITabBarController *tabBarController;
@property (nonatomic, strong) UINavigationController *productNavController;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, readwrite) BOOL IsFromResource;

#warning candidate for removal appears to not be used -- exists in dashboard model
//@property (nonatomic, strong) Product *currentProduct;
//@property (nonatomic, strong) Content *currentContent;

@property (nonatomic, strong) UIImage * SignatureImage;
@property(nonatomic, strong)NSString *DeviceToken;
@property (nonatomic, readwrite) BOOL  isproductClicked;
@property (readwrite, nonatomic) BOOL isScheduleMisfired;
@property (readwrite, nonatomic) int scheduleAttempts;
@property (nonatomic, strong) NSTimer* misFiredScheduleTimer;

//@property(nonatomic, strong) NSString *settingsServerURL;


// core data
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

// oper que
- (NSOperationQueue *)backgroundQueue;

//Start -- Added to check reachability in Downloads
-(BOOL) hasWifi;
-(BOOL) hasInternet;
//End -- Added to check reachability in Downloads

// app info
- (NSString*) appVersionString;

// app support
- (void) postApplicationEvent:(NSString *)event;
- (BOOL) validateEmail:(NSString*) string;
- (UIImage*)loadImage:(NSString*)imageName;
- (void) openAssetWithPath:(NSString*)path;
- (NSString*) prefixDocumentsPathToPath:(NSString*)path;
- (void) navigateToProductDetailWithProduct:(Product*)product;
- (void) presentContentViewerWithContent:(Content*)content;

- (NSString*)deviceUUID;
- (NSString*) referencepath;
- (NSString*) getMirformPdf;
- (NSString*) getAppContentPath:(NSString *)pdftype;
- (void) invokeContentSync;

@end

/*
 Phase I
 ===================
 
 Specialty	Procedure
 
 General Surgery (Hernia Repair)	Laparoscopic Ventral
 Open Ventral
 Bariatric Surgery	Gastric Bypass
 Sleeve Gastrectomy
 Colorectal Surgery	Colectomy
 Orthopedic Surgery	Knee Arthroplasty
 Total Hip Arthroplasty
 Gynecologic Surgery	Cesarean Section
 Hysterectomy - Laparoscopic Supracervical
 Hysterectomy - Total Abdominal
 Hysterectomy - Total Vaginal
 Hysterectomy - Total Laparoscopic
 */
