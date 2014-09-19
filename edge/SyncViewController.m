//
//  SyncViewController.m
//  edge
//
//  Created by Vijaykumar on 8/7/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "SyncViewController.h"
#import "MyEntitlement.h"
#import "RegistrationModel.h"
#import "MyProfile.h"
#import "ContentModel.h"
#import "TabBarViewController.h"
#import "Constants.h"
#import "RootViewController.h"
#import "HTTPClient.h"
#import "TrackingModel.h"
#import "ContentSyncVerifier.h"
#import "sizeValidation.h"

@interface SyncViewController ()

@end

@implementation SyncViewController
@synthesize syncvalue,syncvalue1;

NSArray *myEntitlements;
NSMutableArray *tempMyEntitlements;
NSMutableArray *selectedEntitlements;
NSDateFormatter *dateFormatter;
NSMutableArray *tempMyEntitlementsDeleteList;

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
    // Do any additional setup after loading the view from its nib.
    self.specialityListTable.layer.borderColor = [UIColor whiteColor].CGColor;
    self.specialityListTable.layer.cornerRadius = 10;
    self.specialityListTable.layer.masksToBounds = YES;
    self.specialityListTable.layer.borderWidth = 2.0f;
    
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
    titleView.text = @"Specialty List";
    self.navigationItem.titleView = titleView;
    [titleView sizeToFit];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    tempMyEntitlements = [[NSMutableArray alloc] init];
    selectedEntitlements = [[NSMutableArray alloc] init];
    myEntitlements = [[RegistrationModel sharedInstance].profile myProfileToMyEntitlement].allObjects;
    
    //sort array by name
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [myEntitlements sortedArrayUsingDescriptors:sortDescriptors];
    
    myEntitlements = sortedArray;
    
    
    for (MyEntitlement* entitlement in myEntitlements)
    {
        if (entitlement.status == [NSNumber numberWithInt:kEntitlementStatusEnabled] )
        {
            [tempMyEntitlements addObject:entitlement];
        }
        
    }
    
    //NSLog(@"sorted array = %@", sortedArray);
    ////nslog(@"tempMyEntitlements in view did load%d",[tempMyEntitlements count]);
    ////nslog(@"myEntitlements inn view did load %d",[myEntitlements count]);
}

- (void)viewWillDisappear:(BOOL)animated {
    [self unregisterForEvents];
    [tempMyEntitlements removeAllObjects];
}

- (void) viewDidAppear:(BOOL)animated {
    [self setContentSizeForViewInPopover:CGSizeMake(300.0f, 300.0f)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return myEntitlements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *specialityCell = @"specialityCell";
    
    UITableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:specialityCell];
    
    if(aCell == nil)
    {
        aCell = ([[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:specialityCell]);
    }
    
    MyEntitlement *entitlement = [myEntitlements objectAtIndex:[indexPath row]];

    DownloadManager *downloadMan = [DownloadManager sharedManager];
    NSDate* date;
    
    NSArray *specialities = downloadMan.fetchAllSpecialities;
    
    for (NSManagedObject* speciality in specialities)
    {
        NSNumber* spltId = [speciality valueForKey:@"splId"];
        
        if ([spltId intValue] == [entitlement.splId intValue])
        {
            date = [speciality valueForKey:@"lastSyncDt"];
            break;
        }
    }

    aCell.textLabel.text = entitlement.name;
    aCell.textLabel.font = [UIFont fontWithName:@"Arial" size:15];
    aCell.textLabel.textColor = [UIColor colorWithRed:110.0f/255.0f green:110.0f/255.0f blue:110.0f/255.0f alpha:1];
    aCell.selectionStyle = UITableViewCellSelectionStyleGray;
    aCell.accessoryType = UITableViewCellAccessoryNone;
    aCell.imageView.image = [UIImage imageNamed:@"download_Cell"];
    
    if ([entitlement.status isEqualToNumber:[NSNumber numberWithInt:kEntitlementStatusEnabled]]) {
        [tableView selectRowAtIndexPath:indexPath
                               animated:YES
                         scrollPosition:UITableViewScrollPositionNone];
        aCell.imageView.image = nil;
    }
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 14)];
    dateLabel.text = [dateFormatter stringFromDate:date];
    dateLabel.font = [UIFont fontWithName:@"Arial" size:15];
    dateLabel.textColor = [UIColor darkGrayColor];
    dateLabel.tag = 1;
    UIView* view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 14)];
    [view addSubview:dateLabel];
    aCell.accessoryView = view;
    
    return aCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MyEntitlement* entitlement =  [myEntitlements objectAtIndex:[indexPath row]];
    if (![tempMyEntitlements containsObject:entitlement]) {
        [tempMyEntitlements addObject:entitlement];
        
        //** Start **
        //    This logic is to deselect a speciality, but due to lot of dependencies of specialites on email, favorites, physical files..etc
        //    we are dropping this feature in this phase.
        //        if (tempMyEntitlementsDeleteList != nil &&
        //            [tempMyEntitlementsDeleteList containsObject:entitlement]) {
        //            [tempMyEntitlementsDeleteList removeObject:entitlement];
        //        }
        //** End **
        
    }
    //NSLog(@"didselect entitlement = %@", entitlement.name);

}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    MyEntitlement* entitlement =  [myEntitlements objectAtIndex:[indexPath row]];
    
    // Setting the status to disabled is causing issues, which makes product portfolio to skip this speciality
    // entitlement.status = [NSNumber numberWithInt:kEntitlementStatusDisabled];
    // [tempMyEntitlements removeObject:entitlement];
    // //nslog(@"tempMyEntitlements %d",[tempMyEntitlements count]);
    
    if ([entitlement.status isEqualToNumber:[NSNumber numberWithInt:kEntitlementStatusEnabled]]) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        
        //** Start **
        //    This logic is to deselect a speciality, but due to lot of dependencies of specialites on email, favorites, physical files..etc
        //    we are dropping this feature in this phase.
        //    if (tempMyEntitlementsDeleteList == nil) tempMyEntitlementsDeleteList = [[NSMutableArray alloc] init];
        //          [tempMyEntitlementsDeleteList addObject:entitlement];
        //** End **
        
    } else {
        [tempMyEntitlements removeObject:entitlement];
    }
}

- (void)syncContent {
    UIView* hview = (_hudView != nil)?_hudView: self.view;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array removeAllObjects];
    [selectedEntitlements removeAllObjects];
    if (syncvalue == 1)
    {
        if ([[UpdateNotify SharedManager] entitlementsArray] != nil && [[UpdateNotify SharedManager] entitlementsArray].count > 0) {
            _hud = [MBProgressHUD showHUDAddedTo:hview animated:YES];
            [self sizeValidationRegisterEvents];
            for (MyEntitlement* entitlement in [[UpdateNotify SharedManager] entitlementsArray])
            {
                [array addObject:entitlement.splId];
            }
            [[sizeValidation SharedManager] callServer:array isIncrSize:1];
        }
    }
    else if (syncvalue1 == 1) {
        if ([[UpdateNotify SharedManager] syncArray] != nil && [[UpdateNotify SharedManager] syncArray].count > 0) {
            _hud = [MBProgressHUD showHUDAddedTo:hview animated:YES];
            [self sizeValidationRegisterEvents];
            for (MyEntitlement* entitlement in [[UpdateNotify SharedManager] syncArray])
            {
                [array addObject:entitlement.splId];
            }
            [[sizeValidation SharedManager] callServer:array isIncrSize:1];
        }
    }
    else if (tempMyEntitlements != nil && tempMyEntitlements.count > 0) {
        for (MyEntitlement* entitlement in tempMyEntitlements)
        {
            if (entitlement.status == [NSNumber numberWithInt:kEntitlementStatusDisabled] )
            {
                entitlement.status = [NSNumber numberWithInt:kEntitlementStatusEnabled];
                [array addObject:entitlement.splId];
                [selectedEntitlements addObject:entitlement];
            }

        }
        if ([selectedEntitlements count]>0) {
            _hud = [MBProgressHUD showHUDAddedTo:hview animated:YES];
            [self sizeValidationRegisterEvents];
            [[sizeValidation SharedManager] callServer:array isIncrSize:0];
        }
        else{
             [[[UIAlertView alloc] initWithTitle:@"Download" message:@"No new speciality selected" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
    array = nil;
}

- (void) sizeValidationRegisterEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeValidationSucess) name:SIZE_VALIDATION_SUCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeValidationFailure) name:SIZE_VALIDATION_FAILURE object:nil];
}
- (void) sizeValidationUnregisterEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SIZE_VALIDATION_SUCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SIZE_VALIDATION_FAILURE object:nil];
}
- (void) sizeValidationSucess
{
    [self sizeValidationUnregisterEvents];
    if ([[sizeValidation SharedManager] totalContentDownloadSize]>=[[sizeValidation SharedManager] totalFreeStorageSpace])
    {
        [_hud hide:YES];
        [[[UIAlertView alloc] initWithTitle:@"Alert" message:@"You have insufficient disk space to continue download." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    }
    else
    {
        if (syncvalue == 1)
        {
                [[ContentModel sharedInstance] syncDataInBackgroundWithEntitlements:[[UpdateNotify SharedManager] entitlementsArray]];
            [[UpdateNotify SharedManager] setEntitlementsArray:nil];
        }
        else if (syncvalue1 == 1) {
                [[ContentModel sharedInstance] syncDataInBackgroundWithEntitlements:[[UpdateNotify SharedManager] syncArray]];
            [[UpdateNotify SharedManager] setSyncArray:nil];
        }
        else {
            [[ContentModel sharedInstance] syncDataInBackgroundWithEntitlements:selectedEntitlements];
            selectedEntitlements = nil;
        }
    }
}
- (void) sizeValidationFailure
{
    [self sizeValidationUnregisterEvents];
    [_hud hide:YES];
}


- (IBAction)syncBtnClicked:(id)sender {
    
    //** Start **
    //    This logic is to deselect a speciality, but due to lot of dependencies of specialites on email, favorites, physical files..etc
    //    we are dropping this feature in this phase.
    //
    //    if (tempMyEntitlementsDeleteList != nil && tempMyEntitlementsDeleteList.count > 0) {
    //
    //        NSString* message = @"";
    //        for (MyEntitlement* entitlement in tempMyEntitlementsDeleteList) {
    //            message = [message stringByAppendingString:[NSString stringWithFormat:@",%@",[entitlement name]]];
    //        }
    //        message = [message substringWithRange: NSMakeRange(1, [message length] - 1)];
    //        message = [NSString stringWithFormat:@"Are you sure you want to delete Speciality [%@]", message];
    //
    //        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Information" message:message delegate:self
    //                                               cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    //        alert.tag = 2;
    //        [alert show];
    //
    //        return;
    //    }
    //** End **
    
    // Alert not required....
    //    NSString* responseMessage = @"Are you sure you want to sync the Content";
    //    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Information" message:responseMessage delegate:self
    //                                           cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    //    alert.tag = 1;
    //    [alert show];
    //.......................
    
    if (!_syncFromScheduler) {
        if (![[HTTPClient sharedClient1] hasWifi]) {
            if (![[DownloadManager sharedManager] isInitialSyncStillPending]) {
                [[[UIAlertView alloc] initWithTitle:@"Info" message:@"You are not connected to WIFI. Try content download again after connecting to WIFI" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                return;
            }
        }
    } else {
        _delegate.syncFromScheduler = YES;
    }
    
    [[TrackingModel sharedInstance] callTracking];
    [self registerForEvents];
    [self syncContent];
    _syncFromScheduler = NO;
}

- (void) registerForEvents
{
    [self unregisterForEvents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSyncMasterDataSuccess) name:APP_EVENT_SYNC_MASTER_DATA_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSyncMasterDataFailure:) name:APP_EVENT_SYNC_MASTER_DATA_FAILURE object:nil];

}

- (void) unregisterForEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_SYNC_MASTER_DATA_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_SYNC_MASTER_DATA_FAILURE object:nil];

    
}

- (void) handleSyncMasterDataSuccess
{
    [_hud hide:YES];
    [_delegate invokeContentSync];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            //Server may not have delta content, but continue the previously inprogress/paused content
            //[_delegate invokeContentSync];
            [self syncContent];
        }
    } else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            // Start : For Speciality delete...
            // [_delegate deleteSpecialities:tempMyEntitlementsDeleteList];
            // [tempMyEntitlementsDeleteList removeAllObjects];
            // End
        }
    }
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

- (void)popCurrentViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)getNewSplsBtnTouched:(id)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeHudFromView:)
                                                 name:@"RemoveHudInSyncVCSCreen" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlertForNoSpecs:)
                                                 name:@"NoNewSpecialities" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewSpecialtyFailure:) name:APP_REQUEST_FAILURE object:nil];

    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSString *uuid = [[RegistrationModel sharedInstance] uuid];
    [[ContentSyncVerifier sharedInstance] callDataSyncServiceWithUUID:uuid entitlements:nil];
}

- (void) removeHudFromView:(NSNotification *)notify
{
    [_hud hide:YES];
    [self removerFromView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RemoveHudInSyncVCSCreen" object:nil];
}

- (void) showAlertForNoSpecs:(NSNotification *)notify
{
    [_hud hide:YES];
    [self removerFromView];
    UIAlertView *showInfo = [[UIAlertView alloc] initWithTitle:@"Content Update" message:@"Your Specialty List is up to date." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [showInfo show];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NoNewSpecialities" object:nil];
}

- (void) handleNewSpecialtyFailure : (NSNotification *)notification
{
    [_hud hide:YES];
    [self removerFromView];
    UIAlertView *showInfo = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Request Failed Please Try Later" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [showInfo show];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_REQUEST_FAILURE object:nil];
}

- (void) removerFromView
{
    for (UIViewController *child in self.navigationController.childViewControllers)
    {
        if ([child isKindOfClass: [RootViewController class]])
        {
            [(RootViewController*) child closeButton:nil];
        }
    }
}


@end
