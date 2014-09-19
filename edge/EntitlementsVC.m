//
//  EntitlementsVC.m
//  edge
//
//  Created by iPhone Developer on 6/10/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "EntitlementsVC.h"
#import "AppDelegate.h"
#import "FilterCell.h"
#import "DownloadFilterCell.h"
#import "RegistrationModel.h"
#import "MyProfile.h"
#import "MyEntitlement.h"
#import "Speciality.h"
#import "DownloadManager.h"
#import "BytesConversionHelper.h"
#import "MBProgressHUD.h"
#import "ContentModel.h"
#import "PrivacyPolicyVC.h"
#import "sizeValidation.h"

@interface EntitlementsVC ()
{
    CGFloat availableSpace;
    CGFloat checkedEntitlementSize;
    IBOutlet UILabel *diskSpaceText;
    
    IBOutlet UIImageView *dataImage;
    UIActivityIndicatorView *indicator;
    UIView *cmpleteView;
    UIView *cmpleteView1;

}
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, strong) NSArray *myEntitlements;

@end

@implementation EntitlementsVC

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
	// Do any additional setup after loading the view.
    _appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [[RegistrationModel sharedInstance] loadMyProfile];
    _myEntitlements = [[RegistrationModel sharedInstance].profile.myProfileToMyEntitlement allObjects];

    // sort entitlements by name
    _myEntitlements = [_myEntitlements sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        //return [[(MyEntitlement*)obj1 name] caseInsensitiveCompare:[(MyEntitlement*)obj2 name]];
        return [[obj1 name] caseInsensitiveCompare:[obj2 name]];
    }];
    
    CGFloat freeSpace = [self totalFreeStorageSpace];
    _totalFreeStorageSpaceLbl.text = [BytesConversionHelper convertBytesToDisplayString:freeSpace];
    
    cmpleteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    cmpleteView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:cmpleteView];
    
    cmpleteView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    cmpleteView1.backgroundColor = [UIColor blackColor];
    cmpleteView1.alpha = 0.5;
    
    [cmpleteView addSubview:cmpleteView1];
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator setCenter:CGPointMake(cmpleteView1.frame.size.width/2.0,cmpleteView1.frame.size.height/2.0)];
    [cmpleteView1 addSubview:indicator];
    cmpleteView.hidden = YES;

}

- (void) viewDidAppear:(BOOL)animated
{
    [self registerForEvents];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [self unregisterForEvents];
    cmpleteView = nil;
    cmpleteView1 = nil;
    indicator = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int nRows = 0;
    
    switch (tableView.tag) {
        case TAG_SPECIALITY_DEFAULT_TABLE_VIEW:
            nRows = _myEntitlements.count;
            break;
            
        case TAG_SPECIALITY_ENABLEMENTS_TABLE_VIEW:
            nRows = _myEntitlements.count;
            break;

        default:
            break;
    }
    
    return nRows;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    FilterCell *filterCell;
    DownloadFilterCell *downloadFilterCell;
    MyEntitlement *myEntitlement;
    
    myEntitlement = [_myEntitlements objectAtIndex:indexPath.row];

    BOOL isDefault;
    BOOL checked;
    switch (tableView.tag)
    {
        case TAG_SPECIALITY_DEFAULT_TABLE_VIEW:
        {
            isDefault = [myEntitlement.isDefault boolValue];
            
            filterCell = [tableView dequeueReusableCellWithIdentifier:@"FilterCell"];
            filterCell.titleLbl.text = myEntitlement.name;
            filterCell.toggleBtn.indexPath = indexPath;
            filterCell.toggleBtn.tag = TAG_FILTER_CELL_DEFAULT;
            filterCell.toggleBtn.checked = isDefault;
            [self setImageForFilterBtn:filterCell.toggleBtn];
            cell = filterCell;
        }
            break;
            
        case TAG_SPECIALITY_ENABLEMENTS_TABLE_VIEW:
        {
            checked = ([myEntitlement.status intValue] == kEntitlementStatusEnabled);

            downloadFilterCell = [tableView dequeueReusableCellWithIdentifier:@"DownloadFilterCell"];
            downloadFilterCell.titleLbl.text = myEntitlement.name;
            downloadFilterCell.totalFilesLbl.text = [NSString stringWithFormat:@"%d", [myEntitlement.totalFiles intValue]];
            CGFloat totalSizeKBytes = [myEntitlement.totalSize floatValue];
            //nslog(@"totalSizeKBytes: %f", totalSizeKBytes);
            downloadFilterCell.totalSizeLbl.text = [BytesConversionHelper convertBytesToDisplayString:[BytesConversionHelper convertKiloBytesToBytes:totalSizeKBytes]];
            downloadFilterCell.toggleBtn.indexPath = indexPath;
            downloadFilterCell.toggleBtn.tag = TAG_FILTER_CELL_ENABLEMENT;
            downloadFilterCell.toggleBtn.checked = checked;
            [self setImageForFilterBtn:downloadFilterCell.toggleBtn];
            cell = downloadFilterCell;
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void) setImageForFilterBtn:(FilterBtn*)filterBtn
{
    [filterBtn setImage:filterBtn.checked ? [UIImage imageNamed:@"checkbox-checked_16.png"] : [UIImage imageNamed:@"checkbox-unchecked_16.png"] forState:UIControlStateNormal];
    
}

- (IBAction) toggleFilter:(id)sender
{
    FilterBtn *btn = (FilterBtn*)sender;
    
    btn.checked = !btn.checked;
    [self setImageForFilterBtn:btn];
    
    MyEntitlement *myEntitlement;
    switch (btn.tag) {
        case TAG_FILTER_CELL_DEFAULT:
        {
            // turn down current default
            for (myEntitlement in _myEntitlements)
            {
                myEntitlement.isDefault = [NSNumber numberWithBool:NO];
            }
            [_appDelegate saveContext];
            
            // update entitlement for the selected row
            myEntitlement = [_myEntitlements objectAtIndex:btn.indexPath.row];
            //nslog(@"myEntitlement.name: %@", myEntitlement.name);
            myEntitlement.isDefault = [NSNumber numberWithBool:YES];
            [_appDelegate saveContext];

            [[RegistrationModel sharedInstance] defaultEntitlement];
            
            [self.defaultTableView reloadData];
        }
            break;
        case TAG_FILTER_CELL_ENABLEMENT:
        {
            myEntitlement = [_myEntitlements objectAtIndex:btn.indexPath.row];
            
            myEntitlement.status = [NSNumber numberWithInt:btn.checked ? kEntitlementStatusEnabled : kEntitlementStatusDisabled];
            [_appDelegate saveContext];
            //nslog(@"myEntitlement name: %@ status: %d", myEntitlement.name, [myEntitlement.status intValue]);
               // _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [indicator startAnimating];
            cmpleteView.hidden = NO;
            [self sizeValidationRegisterEvents];
            NSMutableArray *splID = [[NSMutableArray alloc] init];
            [splID removeAllObjects];
            for (MyEntitlement *entitlement in _myEntitlements)
            {
                if ([[RegistrationModel sharedInstance] isMyEntitlementEnabled:entitlement])
                {
                    [splID addObject:entitlement.splId];
                }
            }
            [[sizeValidation SharedManager] callServer:splID isIncrSize:0];
            [self.enablementsTableView reloadData];
        }
            break;
            
        default:
            break;
    }
    
}

- (void) validateForm
{
    BOOL valid = YES;
    NSString *msg;
    
    // make sure user has selected a default speciality
//    BOOL hasDefault = NO;
//    MyEntitlement *defaultMyEntitlement;
//    for (MyEntitlement *myEnt in  _myEntitlements)
//    {
//        if ([myEnt.isDefault boolValue])
//        {
//            defaultMyEntitlement = myEnt;
//            hasDefault = YES;
//            break;
//        }
//    }
//    if (!hasDefault)
//    {
//        valid = NO;
//        msg = @"Please select a default Speciality.";
//    }
//    else
    {
//        // make sure default entitlement is enabled for content download
//        if (![[RegistrationModel sharedInstance] isMyEntitlementEnabled:defaultMyEntitlement])
//        {
//            valid = NO;
//            msg = @"Speciality selected as default, must be enabled for content download.";
//        }
//        else
        {
            // make sure user has at least one enablement
            if (![[RegistrationModel sharedInstance] atLeastOneEnablement])
            {
                valid = NO;
                msg = @"At least one speciality must be enabled for content download.";
            }
            else
            {
                if (checkedEntitlementSize >= availableSpace)
                {
                    valid = NO;
                    msg = @"You do not have suffcient disk space for this install.\nTry to unselect specialities that are not needed.";
                    
                }
            }
            
        }
    }
    
    if (valid)
    {
        //[self confirmContentDownloadSubmit];
        [self callSyncMasterData];
    } else{
        [[[UIAlertView alloc] initWithTitle:@"Validation Error" message:msg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    }
        
}

- (IBAction) downloadContentBtnTouched
{
    [self validateForm];
}

#pragma mark -
#pragma mark app event handling

- (void) registerForEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSyncMasterDataSuccess) name:APP_EVENT_SYNC_MASTER_DATA_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSyncMasterDataFailure) name:APP_EVENT_SYNC_MASTER_DATA_FAILURE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRequestDataFailure) name:APP_REQUEST_FAILURE object:nil];

    
}

- (void) unregisterForEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_SYNC_MASTER_DATA_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_SYNC_MASTER_DATA_FAILURE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_REQUEST_FAILURE object:nil];

    
}
- (void) handleSyncMasterDataSuccess
{
    //nslog(@"EntitlementsVC handleSyncMasterDataSuccess.");
    
    // create the relationships between MyEntitlements and Speciality objects.
//    [[RegistrationModel sharedInstance] relateEntitlementsToSpecialities];
    
    [indicator stopAnimating];
    cmpleteView.hidden = YES;
    
    [RegistrationModel sharedInstance].totalContentDownloadSize = [BytesConversionHelper convertKiloBytesToBytes: [self totalContentDownloadSize]];
    [self performSegueWithIdentifier:@"EntitlementsToContentDownload" sender:nil];
}

- (void) handleSyncMasterDataFailure
{
    [indicator stopAnimating];
    cmpleteView.hidden = YES;
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Download Data Failure" message:@"There seems to be an issue downloading the content,\t\ntap cancel button and restart application\t\nContact help desk if problem persists." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    alert.tag = TAG_ALERT_MASTER_SYNC_FAILED;
    [alert show];
}

- (void) handleRequestDataFailure
{
    [indicator stopAnimating];
    cmpleteView.hidden = YES;
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Download Data Failure" message:@"There seems to be an issue downloading the content,\t\ntap cancel button and restart application\t\nContact help desk if problem persists." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    alert.tag = TAG_ALERT_MASTER_SYNC_FAILED;
    [alert show];
}

- (void) callSyncMasterData
{
    //nslog(@"EntitlementsVC calling syncMasterData");
    
    //_hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [indicator startAnimating];
    cmpleteView.hidden = NO;
    
    // wipe out current master data, and then call sync content
    [[ContentModel sharedInstance] syncMasterData];

}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_VIEW_CONFIRM_CONTENT_DOWNLOAD)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            // start by syncing the master data based on user's entitlement enablements.
            [self callSyncMasterData];
        }
    } else if (alertView.tag == TAG_ALERT_MASTER_SYNC_FAILED) {
        exit(0);
    }

}

- (void) confirmContentDownloadSubmit
{
    NSMutableString *msg = [[NSMutableString alloc] init];
    //[msg appendFormat:@"\nDefault Speciality: %@", [[RegistrationModel sharedInstance] defaultEntitlement].name];
    [msg appendString:@"\nDownload enablements:"];
    for (MyEntitlement *entitlement in _myEntitlements)
    {
        if ([entitlement.status intValue] == kEntitlementStatusEnabled)
        {
            [msg appendFormat:@"\n\t%@", entitlement.name];
        }
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation Required" message:[NSString stringWithFormat:@"Please confirm your selections.\n%@\n\nSubmit content download?", msg] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = TAG_ALERT_VIEW_CONFIRM_CONTENT_DOWNLOAD;
    [alert show];
}

// returned value is kilobytes
- (CGFloat) totalContentDownloadSize
{
    CGFloat totalDownloadSize = 0.0f;
    
    for (MyEntitlement *entitlement in _myEntitlements)
    {
        if ([[RegistrationModel sharedInstance] isMyEntitlementEnabled:entitlement])
        {
            totalDownloadSize += [entitlement.totalSize floatValue];
        }
    }
    
    return totalDownloadSize;
}

- (CGFloat) totalFreeStorageSpace
{
    CGFloat freeSpace = [[DownloadManager sharedManager] totalDiskSpaceInBytes];
    return freeSpace;
}

- (void) sizeValidationSucess
{
    [self sizeValidationUnregisterEvents];
    [indicator stopAnimating];
    cmpleteView.hidden = YES;
    [self createAppCopy];
}

- (void) sizeValidationFailure
{
    [self sizeValidationUnregisterEvents];
    [indicator stopAnimating];
    cmpleteView.hidden = YES;
    [self createAppCopy];
}

-(void) createAppCopy
{
    
    availableSpace = [[sizeValidation SharedManager] totalFreeStorageSpace];
    checkedEntitlementSize = [[sizeValidation SharedManager] totalContentDownloadSize];

    CGFloat check = availableSpace - checkedEntitlementSize;
    if (checkedEntitlementSize != 0 && check >= 5.0f )
    {
        diskSpaceText.hidden = NO;
        diskSpaceText.text = @"You have sufficient disk space for this install.";
        dataImage.hidden = NO;
        dataImage.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"database_green" ofType:@"png"]];
    }
    else if (checkedEntitlementSize != 0 && check >= 1.0f && check < 5.0f)
    {
        diskSpaceText.hidden = NO;
        diskSpaceText.text = @"You have moderate disk space for this install.";
        dataImage.hidden = NO;
        dataImage.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"database_yellow" ofType:@"png"]];
    }
    else if (checkedEntitlementSize != 0 && check < 1.0f && check > 0)
    {
        diskSpaceText.hidden = NO;
        diskSpaceText.text = @"You have very low disk space for this install.";
        dataImage.hidden = NO;
        dataImage.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"database_red" ofType:@"png"]];
    }else if (checkedEntitlementSize >= availableSpace )
    {
        diskSpaceText.hidden = NO;
        diskSpaceText.text = @"You do not have suffcient disk space for this install. Try to unselect specialities that are not needed.";
        dataImage.hidden = NO;
        dataImage.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"database_red" ofType:@"png"]];
    }
    else
    {
        diskSpaceText.hidden = YES;
        dataImage.hidden = YES;
    }
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
- (IBAction)privacyPolicyTouched:(id)sender
{
    
    PrivacyPolicyVC *vc = (PrivacyPolicyVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyID"];
    [self presentViewController:vc animated:YES completion:nil];
}


@end
