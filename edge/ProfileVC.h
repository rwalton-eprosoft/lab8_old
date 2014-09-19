//
//  ProfileVC.h
//  edge
//
//  Created by iPhone Developer on 5/13/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "BasePopoverVC.h"
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"
#import "SyncViewController.h"
@interface ProfileVC : BasePopoverVC<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UITextFieldDelegate>
{
    NSMutableArray * selectedSpecialitylist;
    UITextField *currentTextField;
}

@property (nonatomic, retain)  NSString * Viewname;
@property (nonatomic, strong) IBOutlet UILabel * appversion;
@property (nonatomic, strong) IBOutlet UILabel * contentsize;
@property (strong, nonatomic) IBOutlet UILabel *serverURL;
@property (nonatomic, strong) SyncViewController *sync;

-(IBAction)BackBtnPressed:(id)sender;
-(IBAction)saveBtnPressed:(id)sender;
-(IBAction)sendVcard:(id)sender;
- (IBAction)sendTrackingButtonPressed:(id)sender;

-(IBAction)addPhoto:(id)sender;
-(UIImage *)fixOrientation:(UIImage*)image;
-(UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)newSize;
@property (nonatomic, strong) MBProgressHUD *hud;


@end
