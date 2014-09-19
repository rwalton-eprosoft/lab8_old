//
//  DiagnosticsViewController.m
//  edge
//
//  Created by Dheeraj Raju on 10/03/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import "DiagnosticsViewController.h"
#import "RootViewController.h"
#import "HTTPClient.h"
#import "AppDelegate.h"
#import "DataValidator.h"
#import "AFHTTPClient.h"
#import "MBProgressHUD.h"
#import "UpdateNotify.h"
#import "RegistrationModel.h"
#import "AFJSONRequestOperation.h"
#import "MyProfile.h"
#import "ContentModel.h"
#import "MyEntitlement.h"
#import "DataSyncService.h"
@interface DiagnosticsViewController ()

@end
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
@implementation DiagnosticsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setImageForNavigationBackButton];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
        self.navigationController.navigationBar.translucent = NO;
    }else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    }
    
    self.view.layer.borderColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0f].CGColor;
    self.view.layer.cornerRadius = 7;
    self.view.layer.masksToBounds = YES;
    self.view.layer.borderWidth = 1.0f;
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont fontWithName:@"Arial" size:18];
    //titleView.font = [UIFont boldSystemFontOfSize:22.0];
    titleView.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    titleView.shadowOffset = CGSizeMake(0.0f, 1.0f);
    titleView.textColor = [UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f];
    titleView.text = @"Diagnostics";
    self.navigationItem.titleView = titleView;
    [titleView sizeToFit];
	// Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated {
    [self setContentSizeForViewInPopover:CGSizeMake(300.0, 275.0f)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popCurrentViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) setImageForNavigationBackButton
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 41)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back_btn.png"] forState:UIControlStateNormal];
    UIBarButtonItem *barBackButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [backButton addTarget:self action:@selector(popCurrentViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = barBackButtonItem;
    self.navigationItem.hidesBackButton = YES;
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
     if (alertView.tag == 10) {
        
        if (buttonIndex == 1){
            _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:[[RegistrationModel sharedInstance] uuid] forKey:@"uuid"];
            [params setObject:[userDefaults objectForKey:@"email"] forKey:@"email"];
            [params setObject:[userDefaults objectForKey:@"firstName"] forKey:@"firstName"];
            [params setObject:[userDefaults objectForKey:@"lastName"] forKey:@"lastName"];
            [ContentModel sharedInstance].isResetAll = YES;
            [[ContentModel sharedInstance] registrationWithParams:params];
        }
    }
}

- (IBAction)resetAllClicked:(id)sender {
    
    if ([[HTTPClient sharedClient1] hasWifi]) {
        [self registerForEvents];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Reset Data" message:@"Are you sure you want to reset? This will delete all Content and re-download." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        
        alert.tag = 10;
        [alert show];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"WiFi connection is unavailable.  Try reset at a later time." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void) handleRegistrationSuccess
{
    //nslog(@"RegistrationVC handleRegistrationSuccess.");
    [_hud hide:YES];
    [self unregisterForEvents];
    // [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"FileContent"];
    
    [[ContentModel sharedInstance]  deleteAllFromEntityWithName:@"MedicalCategory"];
    
    //nslog(@"Removing data from ArcCategory");
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"ArcCategory"];
    
    //nslog(@"Removing data from ProcedureStep");
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"ProcedureStep"];
    
    //nslog(@"Removing data from SpecialityCategory");
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"SpecialityCategory"];
    
    //nslog(@"Removing data from Content");
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"Content"];
    
    //nslog(@"Removing data from ContentCategory");
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"ContentCategory"];
    
    //nslog(@"Removing data from ContentMapping");
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"ContentMapping"];
    
    //nslog(@"Removing data from Speciality");
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"Speciality"];
    
    //nslog(@"Removing data from Procedure");
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"Procedure"];
    
    //nslog(@"Removing data from Market");
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"Market"];
    
    //nslog(@"Removing data from ProductCategory");
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"ProductCategory"];
    
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"MyRecentlyViewed"];
    
    //nslog(@"Removing data from Product");
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"Product"];
    
    //nslog(@"Removing data from CompProduct");
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"CompProduct"];
    
    //nslog(@"Removing data from FileContent");
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"FileContent"];
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"Applications"];
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"ExtendedMetadata"];
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"Concern"];
    [[ContentModel sharedInstance] deleteAllFromEntityWithName:@"ProcedureStepToProductNew"];
    
    [self invokeContentSync];
    
    //    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //    NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/assets", DOCUMENTS_FOLDER] error:nil];
    //    for (NSString *filename in fileArray)  {
    //        [fileMgr removeItemAtPath:[directory stringByAppendingPathComponent:filename] error:NULL];
    //    }
    NSString *folderPath = [NSString stringWithFormat:@"%@/assets", DOCUMENTS_FOLDER]; //[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSError *error = nil;
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error]) {
        [[NSFileManager defaultManager] removeItemAtPath:[folderPath stringByAppendingPathComponent:file] error:&error];
        NSLog(@"%@", error);
    }
}

- (void) handleRegistrationErrorResponse
{
    //nslog(@"RegistrationVC handleRegistrationErrorResponse.");
    [_hud hide:YES];
    
    NSDictionary *responseDict = [ContentModel sharedInstance].registrationResponseHeader;
    NSString *err = [responseDict objectForKey:@"message"];
    [[[UIAlertView alloc] initWithTitle:@"Reset Failure" message:[NSString stringWithFormat:@"Reset failed. %@. Please try again.", err] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    [self unregisterForEvents];
}

- (void) handleRegistrationFailure
{
    //nslog(@"RegistrationVC handleRegistrationFailure.");
    [_hud hide:YES];
    
    [[[UIAlertView alloc] initWithTitle:@"Reset Failure" message:@"Service may be unavailable. Check your network connection. Please try again." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    [ContentModel sharedInstance].isResetAll = NO;
    [self unregisterForEvents];
}

- (void) registerForEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRegistrationSuccess) name:APP_EVENT_REGISTRATION_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRegistrationFailure) name:APP_EVENT_REGISTRATION_FAILURE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRegistrationErrorResponse) name:APP_EVENT_REGISTRATION_ERROR_RESPONSE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSyncMasterDataSuccess) name:APP_EVENT_SYNC_MASTER_DATA_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSyncMasterDataFailure:) name:APP_EVENT_SYNC_MASTER_DATA_FAILURE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRequestDataFailure:) name:APP_REQUEST_FAILURE object:nil];

    
}

- (void) unregisterForEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_REGISTRATION_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_REGISTRATION_FAILURE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_REGISTRATION_ERROR_RESPONSE object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_SYNC_MASTER_DATA_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_SYNC_MASTER_DATA_FAILURE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_REQUEST_FAILURE object:nil];

    
}

- (void)invokeContentSync
{
    NSMutableArray* tempEntitlements = [[NSMutableArray alloc] init];
    NSArray* myEntitlements = [[RegistrationModel sharedInstance].profile myProfileToMyEntitlement].allObjects;
    _sync = [[SyncViewController alloc] init];
    [[[UpdateNotify SharedManager] syncArray]removeAllObjects];
    [tempEntitlements removeAllObjects];
    
    for (int i = 0; i < [myEntitlements count]; i++)
    {
        MyEntitlement* entitlement =  [myEntitlements objectAtIndex:i];
        if ([[entitlement status] isEqualToNumber:[NSNumber numberWithInt:kEntitlementStatusEnabled]]) {
            [tempEntitlements addObject:entitlement]; //Add selected Specialites to get deltas
        }
    }
    
    [[UpdateNotify SharedManager] setSyncArray:tempEntitlements];
    _sync.syncvalue1 = 1;
    ContentSyncModel* contentSyncModel = [ContentSyncModel sharedContentSync];
    contentSyncModel.syncFromDashboard = 0;
    
    TabBarViewController* tab = contentSyncModel.customTabBarViewController;
    _sync.delegate = tab;
    
    _sync.hudView = tab.view;
    _sync.syncFromScheduler = NO;
    
    [_sync syncBtnClicked:nil];
    
    tempEntitlements = nil;
    myEntitlements = nil;
}

- (IBAction)sendContentDataToServer:(id)sender {
    [self.diagnosticsBtn setEnabled:NO];
    [self.reset_all_btn setEnabled:NO];
     [self registerForEvents];
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self performSelector:@selector(loadFilesFromPaths) withObject:nil afterDelay:0.2];
    }

- (void) loadFilesFromPaths
{
    DataValidator* dq = [[DataValidator alloc] init];
    NSMutableDictionary * dict = (NSMutableDictionary *)[dq fetchCoreData];
    [dict setObject:[[UpdateNotify SharedManager] Filecontentdict] forKey:@"FileContent"];
    [dq getContentByContentCategory];
    
    //    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    //    NSString* jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    //    NSLog(@"ContentDataJson String: %@", jsonString);
    
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:dict forKey:@"debugInfo"];
    
    NSString* serverBaseURL = WEB_SERVICE_BASE_SERVER;
#define LOG_API_REPORT             @"/logapi/sendlog"
    
    ContentSyncModel* contentSyncModel = [ContentSyncModel sharedContentSync];
    [_hud hide:YES];
    _hud = [MBProgressHUD showHUDAddedTo:contentSyncModel.customTabBarViewController.view animated:YES];
    
    DataSyncService *dataSyncService = [[DataSyncService alloc] init];
    
    NSString *email = [[RegistrationModel sharedInstance].profile email];
    NSString *password = nil;
    NSString* newString = [NSString stringWithFormat:@"%@%@", serverBaseURL, LOG_API_REPORT];
    [dataSyncService syncData:newString withRequestData:params usingHttpMethod:@"POST" withEmailId:email withPassword:password];
    

}

- (void) handleSyncMasterDataSuccess
{
    [_hud hide:YES];
    [_delegate invokeContentSync];
    [self.diagnosticsBtn setEnabled:YES];
    [self.reset_all_btn setEnabled:YES];
    [self unregisterForEvents];
}

- (void) handleSyncMasterDataFailure : (NSNotification *)notification
{
    [_hud hide:YES];
    [ContentModel sharedInstance].isResetAll = NO;
    //    NSNumber* statusCode = [[notification userInfo] valueForKey:@"statusCode"];
    //    NSString* responseMessage = [[notification userInfo] valueForKey:@"message"];
    //    if ([statusCode intValue] == [[NSNumber numberWithInt:kNoContent] intValue]) {
    //        responseMessage = @"No new content on Server \nBut Check for partially downloaded content and complete them.";
    //    }
    ////    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Information" message:responseMessage delegate:self
    ////                                           cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    //    responseMessage = @"Are you sure you want to sync the content";
    //    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Information" message:responseMessage delegate:self
    //                                           cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    //    alert.tag = 1;
    //    [alert show];
    [_delegate invokeContentSync];

    [self unregisterForEvents];
}

- (void) handleRequestDataFailure : (NSNotification *)notification
{
    [_hud hide:YES];
    UIAlertView *showInfo = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Request Failed Please Try Later" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [showInfo show];
    
    [self unregisterForEvents];
}

@end
