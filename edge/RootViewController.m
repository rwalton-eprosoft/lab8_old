//
//  RootViewController.m
//  edge
//
//  Created by Vijaykumar on 8/22/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "RootViewController.h"
#import "SyncViewController.h"
#import "ContentSyncSchedulerViewController.h"
#import "HTTPClient.h"
#import "RegistrationModel.h"
#import "MyProfile.h"
#import "MyEntitlement.h"
#import "ContentModel.h"
#import "TabBarViewController.h"
#import "ProfileVC.h"
#import "DiagnosticsViewController.h"

@interface RootViewController ()
{
    SyncViewController *syncVC1;
    TabBarViewController* tab;
}
@end

@implementation RootViewController

NSArray *myEntitlements;
NSMutableArray *tempEntitlements;

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
        self.navigationController.navigationBar.translucent = NO;
    }else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    }
    
    self.contentSyncList = [[NSArray alloc] initWithObjects:@"Specialty List",
                            @"Frequency of Updates",@"Diagnostics", @"Sync via WIFI only", nil];
    
    
    
    self.view.layer.borderColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0f].CGColor;
    self.view.layer.cornerRadius = 0;
    self.view.layer.masksToBounds = YES;
    self.view.layer.borderWidth = 1.0f;
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont fontWithName:@"Arial" size:18];
    //titleView.font = [UIFont boldSystemFontOfSize:22.0];
    titleView.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    titleView.shadowOffset = CGSizeMake(0.0f, 1.0f);
    titleView.textColor = [UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f];
    titleView.text = @"Content Update Settings";
    self.navigationItem.titleView = titleView;
    [titleView sizeToFit];
    
    
    
    //    self.contentSyncOption.layer.borderColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f].CGColor;
    //    self.contentSyncOption.layer.cornerRadius = 0;
    //    //self.contentSyncOption.layer.masksToBounds = YES;
    //    self.contentSyncOption.layer.borderWidth = 0.0f;
    
    UIButton *myButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [myButton1 setImage:[UIImage imageNamed:@"close_btn.png"] forState:UIControlStateNormal];
    myButton1.showsTouchWhenHighlighted = YES;
    myButton1.frame = CGRectMake(0.0, 3.0, 50,30);
    
    [myButton1 addTarget:self action:@selector(closeButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:myButton1];
    self.navigationItem.rightBarButtonItem = nil;
    
    //close_btn.png
    
    syncVC1 = [[SyncViewController alloc] init];
    tab = [[TabBarViewController alloc] init];
    
    tempEntitlements = [[NSMutableArray alloc] init];
    myEntitlements = [[RegistrationModel sharedInstance].profile myProfileToMyEntitlement].allObjects;
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    [self setContentSizeForViewInPopover:CGSizeMake(300.0, 275.0f)];
    
}

- (void) viewDidDisappear:(BOOL)animated {
    
    [self setContentSizeForViewInPopover:CGSizeMake(300.0, 300.0f)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)closeButton:(id)sender;
{
    [self.view removeFromSuperview];
    [self.delegate1 syncButtonStatus:NO];
    [self.delegate dismisspopover];
    
    
}

- (IBAction)syncButn:(id)sender
{
    [self closeButton:sender];
    
    [[[UpdateNotify SharedManager] entitlementsArray] removeAllObjects];
    [tempEntitlements removeAllObjects];
    
    
    for (int i =0; i<[myEntitlements count]; i++)
    {
        MyEntitlement* entitlement =  [myEntitlements objectAtIndex:i];
        if ([entitlement.status isEqualToNumber:[NSNumber numberWithInt:kEntitlementStatusEnabled]]) {
            [tempEntitlements addObject:entitlement]; //Add selected Specialites to get deltas
        }
        
    }
    [[UpdateNotify SharedManager]setEntitlementsArray:tempEntitlements];
    syncVC1.syncvalue = 1;
    syncVC1.delegate = self.delegate;
    syncVC1.hudView = syncVC1.delegate.view;
    syncVC1.syncFromScheduler = NO;
    [syncVC1 syncBtnClicked:sender];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contentSyncList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"syncListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([indexPath row] == 2) {
            cell.imageView.image = [UIImage imageNamed:@"diagnostics"];
        }
        if ([indexPath row] == 3) {
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            [switchView setOn:YES animated:NO];
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.imageView.image = [UIImage imageNamed:@"wifi"];
        }
    }
    
    // Configure the cell.
    cell.textLabel.text = [self.contentSyncList objectAtIndex: [indexPath row]];
    
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:15];
    //cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    //cell.textLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
    cell.textLabel.textColor = [UIColor colorWithRed:110.0f/255.0f green:110.0f/255.0f blue:110.0f/255.0f alpha:1];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        cell.backgroundColor = self.view.backgroundColor;
        tableView.backgroundColor = self.view.backgroundColor;
    }
   
    return cell;
}

- (void) switchChanged:(id)sender {
    UISwitch* switchControl = sender;
    [HTTPClient sharedClient1].isWifiOnlyON = switchControl.on;
    if (switchControl.on)
        if ([HTTPClient sharedClient1].isWWANON) [HTTPClient sharedClient1].hasWifi = YES;
    
    //nslog( @"The switch is %d", [HTTPClient sharedClient].isWifiOnlyON );
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)invokeSyncViewController {
    
    SyncViewController *contentSyncController = [[SyncViewController alloc] initWithNibName:@"SyncViewController" bundle:nil];
    contentSyncController.delegate = self.delegate;
    [[self navigationController] pushViewController:contentSyncController animated:YES];
    [contentSyncController setContentSizeForViewInPopover:CGSizeMake(300.0, 300.0)];
}

- (void)invokeDiagnosticsViewController {
    
    DiagnosticsViewController *diagVC = [[DiagnosticsViewController alloc] initWithNibName:@"DiagnosticsViewController" bundle:nil];
    
    diagVC.delegate = self.delegate;
    [[self navigationController] pushViewController:diagVC animated:YES];
    [diagVC setContentSizeForViewInPopover:CGSizeMake(300.0, 275)];   // [self.navigationController pushViewController:vc animated:YES];
}

//- (void) didMoveToParentViewController:(UIViewController *)parent {
//    //nslog(@"Parent %@" , parent.title);
//}

- (void)invokeSchedulerViewController {
    
    ContentSyncSchedulerViewController *contentSyncSchedulerViewController = [[ContentSyncSchedulerViewController alloc] initWithNibName:@"ContentSyncSchedulerViewController" bundle:nil];
    [[self navigationController] pushViewController:contentSyncSchedulerViewController animated:YES];
    [contentSyncSchedulerViewController setContentSizeForViewInPopover:CGSizeMake(300.0, 275)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.row) {
        [self invokeSyncViewController];
    } else if (1 == indexPath.row) {
        [self invokeSchedulerViewController];
    }  else if (2 == indexPath.row) {
        [self invokeDiagnosticsViewController];
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.row) {
        [self invokeSyncViewController];
    } else if (1 == indexPath.row) {
        [self invokeSchedulerViewController];
    } else if (2 == indexPath.row) {
        [self invokeDiagnosticsViewController];
    }
}

@end
