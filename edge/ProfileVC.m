//
//  ProfileVC.m
//  edge
//
//  Created by iPhone Developer on 5/13/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ProfileVC.h"
#import "AppDelegate.h"
#import "MyEntitlement.h"
#import "RegistrationModel.h"
#import "MyProfile.h"
#import "TrackingModel.h"
#import "DownloadManager.h"
#import "BytesConversionHelper.h"
#import "ContentSyncReportViewController.h"
#import "DataValidator.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "DashboardModel.h"
#import "Speciality.h"
#import "MBProgressHUD.h"
#import "UpdateNotify.h"
#import "ContentSyncModel.h"
#import "TabBarViewController.h"
#import "UpdateNotify.h"
#import "sizeValidation.h"
#import "HTTPClient.h"

#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface ProfileVC ()


@property (nonatomic,strong) IBOutlet UIImageView * userimageIMGVIEW;
@property (nonatomic, strong) AppDelegate * appdelegate;
@property (nonatomic, strong) UIPopoverController *popOver;
@property (nonatomic, retain) IBOutlet UIView * profileView;
@property (nonatomic, retain) IBOutlet UIView * generalView;
@property (nonatomic, retain) IBOutlet UIView * SpecialtyView;
@property (nonatomic, retain) IBOutlet UITableView * specialitytableview;

@end

@implementation ProfileVC
@synthesize Viewname;
NSArray *myEntitlements;



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
    
   // self.title = @"Profile";
    currentTextField.delegate = self;
    
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont fontWithName:@"Arial" size:18];
    //titleView.font = [UIFont boldSystemFontOfSize:22.0];
    titleView.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    titleView.shadowOffset = CGSizeMake(0.0f, 1.0f);
    titleView.textColor = [UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f];
    _serverURL.text = WEB_SERVICE_BASE_SERVER;
    
    self.appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    
//    UIButton *myButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
//    [myButton1 setImage:[UIImage imageNamed:@"save_btn@2x.png"] forState:UIControlStateNormal];
//    myButton1.showsTouchWhenHighlighted = YES;
//    myButton1.frame = CGRectMake(0.0, 5.0, 85,30);
//    //
//    [myButton1 addTarget:self action:@selector(saveBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [myButton1 setImage:[UIImage imageNamed:@"saveselect_btn.png"] forState:UIControlStateHighlighted];
//    //
//    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:myButton1];
//    self.navigationItem.rightBarButtonItem = rightButton;
    
    
    
    UIButton *myButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [myButton2 setImage:[UIImage imageNamed:@"back_btn.png"] forState:UIControlStateNormal];
    myButton2.showsTouchWhenHighlighted = YES;
    myButton2.frame = CGRectMake(0.0, 5.0, 70,41);
    //
    [myButton2 addTarget:self action:@selector(BackBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    //
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:myButton2];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    if ([self.Viewname isEqualToString:@"1"])
    {
        titleView.text = @"Profile";
        self.profileView.hidden = NO;
        self.generalView.hidden = YES;
        self.SpecialtyView.hidden = YES;
    }
    else if ([self.Viewname isEqualToString:@"2"])
    {
        
        titleView.text = @"About";
        self.navigationItem.titleView = titleView;
        [titleView sizeToFit];
        self.profileView.hidden = YES;
        self.generalView.hidden = NO;
        self.SpecialtyView.hidden = YES;
        self.navigationItem.rightBarButtonItem = nil;
        //nslog(@"version string--%@",[self.appDelegate appVersionString]);
        self.appversion.text = [self.appDelegate appVersionString];
        [self totalDiskSpaceInBytes];
       

        ////nslog(@"self.contentsize.text %@",self.contentsize.text);

    }
    else if ([self.Viewname isEqualToString:@"3"])
    {//speciality
        selectedSpecialitylist = [[NSMutableArray alloc] init];
       
        titleView.text = @"Default Specialty";
       
        self.profileView.hidden = YES;
        self.generalView.hidden = YES;
        self.SpecialtyView.hidden = NO;
        self.navigationItem.rightBarButtonItem = nil;
        myEntitlements = [[RegistrationModel sharedInstance].profile myProfileToMyEntitlement].allObjects;
        [self getSelectedSpecailtyList];
    }
    self.navigationItem.titleView = titleView;
    [titleView sizeToFit];
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    if (([userDefaults objectForKey:@"imagepath"] == nil) || ([[userDefaults objectForKey:@"imagepath"] isEqualToString:@""])|| ([[userDefaults objectForKey:@"imagepath"] isKindOfClass:[NSNull class]]))
    {
        self.userimageIMGVIEW.image = [UIImage imageNamed:@"thumb@2x.png"];
        
    }
    else
    {
        
        NSData * imagedata = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[userDefaults objectForKey:@"imagepath"]]];
        
        self.userimageIMGVIEW.image = [UIImage imageWithData:imagedata];
    }
    
    
    
	// Do any additional setup after loading the view.
}
- (void)totalDiskSpaceInBytes {
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults floatForKey:@"totalSize"] == 0)
    {
        
        NSArray *ourEntitlements = [[RegistrationModel sharedInstance].profile myProfileToMyEntitlement].allObjects;
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (MyEntitlement *entitlement in ourEntitlements)
        {
            if (entitlement.status == [NSNumber numberWithInt:kEntitlementStatusEnabled])
            {
                [array addObject:entitlement.splId];
            }
        }
     if ([[HTTPClient sharedClient1] hasWifi]) {
      [self sizeValidationRegisterEvents];
      [[sizeValidation SharedManager] callServer:array isIncrSize:0];
      }
    }
    CGFloat downloadSize = [BytesConversionHelper convertKiloBytesToBytes:[defaults floatForKey:@"totalSize"]];
    self.contentsize.text = [NSString stringWithFormat:@"Content size: %@",[BytesConversionHelper convertBytesToString:downloadSize]];
   
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
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    CGFloat downloadSize = [BytesConversionHelper convertKiloBytesToBytes:[defaults floatForKey:@"totalSize"]];
    self.contentsize.text = [NSString stringWithFormat:@"Content size: %@",[BytesConversionHelper convertBytesToString:downloadSize]];
    [self sizeValidationUnregisterEvents];

}
- (void) sizeValidationFailure
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    CGFloat downloadSize = [BytesConversionHelper convertKiloBytesToBytes:[defaults floatForKey:@"totalSize"]];
    self.contentsize.text = [NSString stringWithFormat:@"Content size: %@",[BytesConversionHelper convertBytesToString:downloadSize]];
    [self sizeValidationUnregisterEvents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - Textfield methods

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    [theTextField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    currentTextField = textField;
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    if (textField.tag == 10)
    {
        [userDefaults setValue:textField.text forKey:@"firstName"];
    }
    else if(textField.tag == 11)
    {
        [userDefaults setValue:textField.text forKey:@"lastName"];
    }
    else if(textField.tag == 12)
    {
        [userDefaults setValue:textField.text forKey:@"phone"];
    }
    [userDefaults synchronize];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField.tag ==12)
    {
           NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789-"] invertedSet];
        
        
        if ([string length] == 0){
            return YES;
        }else{
            if (textField.tag == 12)
            {
                
                int length = [textField.text length];
                if(length == 15)
                {
                    if(range.length == 0)
                        return NO;
                }
            }
        }
        
        
                return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0);
            
    }
    
    if ([string length] == 0){
        return YES;
    }else{
        if (textField.tag == 10 || textField.tag == 11)
        {
            
            int length = [textField.text length];
            if(length == 20)
            {
                if(range.length == 0)
                    return NO;
            }
        }
//        if (textField.tag == 12)
//        {
//            
//            int length = [textField.text length];
//            if(length == 15)
//            {
//                if(range.length == 0)
//                    return NO;
//            }
//        }
        
        
    }
    
    return YES;
}

# pragma mark - Textviews methods


-(void)getSelectedSpecailtyList
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
   
    
    if (([userDefaults objectForKey:@"speciality"] == nil) || ([[userDefaults objectForKey:@"speciality"] isEqualToString:@""])|| ([[userDefaults objectForKey:@"speciality"] isKindOfClass:[NSNull class]]))
    {
        
    }
    else
    {
       NSMutableArray * beforesorting = [[NSMutableArray alloc] init];
        beforesorting = (NSMutableArray *)[[userDefaults objectForKey:@"speciality"] componentsSeparatedByString:@","];
        selectedSpecialitylist = (NSMutableArray *)[beforesorting sortedArrayUsingSelector:
                                                    @selector(localizedCaseInsensitiveCompare:)];
        [userDefaults setValue:[selectedSpecialitylist objectAtIndex:0] forKey:@"speciality"];
        
    }
    
    
    
    [self.specialitytableview reloadData];
}


#pragma mark -UITableViewDataSource


// Default is 1 if not implemented
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.specialitytableview)
    {
        //return [myEntitlements count];
        //NSLog(@"specialties count = %lu", (unsigned long)[[[DashboardModel sharedInstance] specialities]count]);
      return  [[[DashboardModel sharedInstance] specialities]count];
    }
    else
        return 4;
}


// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (tableView == self.specialitytableview)
    {
        //MyEntitlement* entitlement =  [myEntitlements objectAtIndex:[indexPath row]];
        static NSString *cellIdentifier=@"cell";
        
        NSArray *specialties = [[DashboardModel sharedInstance] specialities];
        
        Speciality *specialty = [specialties objectAtIndex:indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:cellIdentifier] ;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = specialty.name;
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:15];
        cell.textLabel.textColor = [UIColor colorWithRed:110.0f/255.0f green:110.0f/255.0f blue:110.0f/255.0f alpha:1];
        cell.backgroundColor = [UIColor clearColor];
        // cell.backgroundView = nil;
         NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        if ([[userDefaults objectForKey:@"speciality"] isEqualToString:specialty.name])
        {
            cell.textLabel.textColor = [UIColor whiteColor];
            
            cell.backgroundColor = [UIColor lightGrayColor];
        }
//        for (int k =0; k<[selectedSpecialitylist count]; k++)
//        {
//            if ([entitlement.name isEqualToString:[selectedSpecialitylist objectAtIndex:k]])
//            {
//                cell.textLabel.textColor = [UIColor whiteColor];
//               
//                cell.backgroundColor = [UIColor grayColor];
//                break;
//            }
//        }
       
        //NSLog(@"specialty should be %@", specialty.name);
    }
    
    
    else
    {
         NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
         cell = [tableView dequeueReusableCellWithIdentifier:@"LeftDetailCell"];
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(125, 5, 150, 20)];
        textField.clearsOnBeginEditing = NO;
        textField.textAlignment = NSTextAlignmentRight;
        textField.delegate = self;
        textField.font = [UIFont fontWithName:@"Arial" size:15];
        textField.textColor = [UIColor colorWithRed:110.0f/255.0f green:110.0f/255.0f blue:110.0f/255.0f alpha:1];;
       // textField.backgroundColor = [UIColor redColor];
        cell.detailTextLabel.text = @"";
        [cell.contentView addSubview:textField];
         UIImageView * lockimage = [[UIImageView alloc] initWithFrame:CGRectMake(112, 9, 10, 12)];
        lockimage.image = [UIImage imageNamed:@"lock@2x.png"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        switch (indexPath.row) {
            case 0:
               
                cell.textLabel.text = @"First Name";
              textField.text = [userDefaults objectForKey:@"firstName"];
                textField.tag = 10;
                //cell.detailTextLabel.text = [userDefaults objectForKey:@"firstName"];
                
                break;
            case 1:
                //cell = [tableView dequeueReusableCellWithIdentifier:@"LeftDetailCell"];
                cell.textLabel.text = @"Last Name";
                textField.text = [userDefaults objectForKey:@"lastName"];
                textField.tag = 11;
                break;
            case 2:
               // cell = [tableView dequeueReusableCellWithIdentifier:@"LeftDetailCell"];
                cell.textLabel.text = @"Email address";
                textField.text = [userDefaults objectForKey:@"email"];
               [cell.contentView addSubview:lockimage];
                textField.userInteractionEnabled = NO;
                break;
            case 3:
              //  cell = [tableView dequeueReusableCellWithIdentifier:@"LeftDetailCell"];
                cell.textLabel.text = @"Phone";
                
               textField.text =[userDefaults objectForKey:@"phone"];
                textField.keyboardType = UIKeyboardTypeNumberPad;
                if ([textField.text isEqualToString:@""] || [textField.text isKindOfClass:[NSNull class]])
                {
                    textField.placeholder = @"Phone Number";
                }
                textField.tag = 12;
                break;
                
            default:
                break;
        }
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.specialitytableview)
    {
        UITableViewCell *theSelectedCell = [tableView cellForRowAtIndexPath:indexPath];
       // BOOL isthere = NO;
        //int k;
        
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
         [userDefaults setValue:theSelectedCell.textLabel.text forKey:@"speciality"];
         [self.specialitytableview reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
//        for (k=0; k<[selectedSpecialitylist count]; k++)
//        {
//            if ([theSelectedCell.textLabel.text isEqualToString:[selectedSpecialitylist objectAtIndex:k]])
//            {
//                isthere = YES;
//                break;
//            }
//        }
//        
//        if (isthere == YES)
//        {
//            [selectedSpecialitylist removeObjectAtIndex:k];
//            [userDefaults setValue:@"" forKey:@"speciality"];
//            for (int l =0; l<[selectedSpecialitylist count]; l++)
//            {
//                if (l == 0)
//                {
//                    [userDefaults setValue:[selectedSpecialitylist objectAtIndex:l] forKey:@"speciality"];
//                }
//                else
//                {
//                    [userDefaults setValue:[NSString stringWithFormat:@"%@,%@",[userDefaults objectForKey:@"speciality"],[selectedSpecialitylist objectAtIndex:l]] forKey:@"speciality"];
//                }
//            }
//            
//            
//            [self.specialitytableview reloadData];
//        }
//        else
//        {
//            
//            [userDefaults setValue:[NSString stringWithFormat:@"%@,%@",[userDefaults objectForKey:@"speciality"],theSelectedCell.textLabel.text] forKey:@"speciality"];
//            [self getSelectedSpecailtyList];
//        }
        
    }
    
}

#pragma mark -navigation buttons

-(IBAction)BackBtnPressed:(id)sender
{
    if ([self.Viewname isEqualToString:@"1"])
    {
        [self saveBtnPressed:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)saveBtnPressed:(id)sender
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (([userDefaults objectForKey:@"imagepath"] == nil) || ([[userDefaults objectForKey:@"imagepath"] isEqualToString:@""])|| ([[userDefaults objectForKey:@"imagepath"] isKindOfClass:[NSNull class]]))
    {
        
        
        //        NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
        //        NSString *caldate = [now description];
        //
        //        NSString *filePath= [NSString stringWithFormat:@"%@/%@.jpg", DOCUMENTS_FOLDER,caldate];
        //
        //        NSURL * imageurl = [NSURL fileURLWithPath:filePath];
        //        NSData * dataImage = UIImagePNGRepresentation(self.userimageIMGVIEW.image);
        //
        //        [dataImage writeToFile:filePath atomically:YES];
        //
        //        NSString * urlstring = [NSString stringWithFormat:@"%@",imageurl];
        //        [userDefaults setValue:urlstring forKey:@"imagepath"];
        
    }
    else
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:[userDefaults objectForKey:@"imagepath"] error:NULL];
        
        //        NSData * dataImage = UIImagePNGRepresentation(self.userimageIMGVIEW.image);
        //
        //        [dataImage writeToFile:[userDefaults objectForKey:@"imagepath"] atomically:YES];
        //
        //        [userDefaults setValue:[userDefaults objectForKey:@"imagepath"] forKey:@"imagepath"];
        
    }
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [now description];
    
    NSString *filePath= [NSString stringWithFormat:@"%@/%@.jpg", DOCUMENTS_FOLDER,caldate];
    
    NSURL * imageurl = [NSURL fileURLWithPath:filePath];
    NSData * dataImage = UIImagePNGRepresentation(self.userimageIMGVIEW.image);
    
    [dataImage writeToFile:filePath atomically:YES];
    
    NSString * urlstring = [NSString stringWithFormat:@"%@",imageurl];
    [userDefaults setValue:urlstring forKey:@"imagepath"];
    
    
}

#pragma mark -adding pic

-(IBAction)addPhoto:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Image from..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Image Gallery", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    actionSheet.alpha=1.0;
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==actionSheet.cancelButtonIndex)
    {
        [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:YES];
        
    }
    else if(buttonIndex==0)
    {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.wantsFullScreenLayout = YES;
        
        
        picker.allowsEditing=NO;
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
        [popover presentPopoverFromRect:self.userimageIMGVIEW.bounds inView:self.userimageIMGVIEW permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        self.popOver = popover;
        
      //  [self.navigationController presentViewController:picker animated:YES completion:nil];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

    }
    else if(buttonIndex==1)
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.wantsFullScreenLayout = YES;
        
        picker.allowsEditing=NO;
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
        [popover presentPopoverFromRect:self.userimageIMGVIEW.bounds inView:self.userimageIMGVIEW permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        [self.popOver setDelegate:self];
        self.popOver = popover;
        //[self.navigationController presentViewController:picker animated:YES completion:nil];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        
        
    }
    
    
}

//Needed for uiimagepickercontroller to hide status bar
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    //#warning iOS7 test bed
    
    //Gets an array af all of the subviews of our actionSheet
    NSArray *subviews = [actionSheet subviews];
    
    for (UIView *v in subviews)
    {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *b = (UIButton*)v;
            [b setTitleColor:[UIColor colorWithRed:110.0f/255.0f green:110.0f/255.0f blue:110.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [b setTitleColor:[UIColor colorWithRed:243.0f/255.0f green:6.0f/255.0f blue:23.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
            
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.popOver dismissPopoverAnimated:YES];
    
    
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    
    UIImage *fixedImage = [self fixOrientation:image];
    [self.userimageIMGVIEW setImage:fixedImage];
    
    
    
    
    [self.popOver dismissPopoverAnimated:YES];
    
    
    
    
    
}


-(UIImage *)fixOrientation:(UIImage*)image
{
    
    // No-op if the orientation is already correct
    //    if (self.imageOrientation == UIImageOrientationUp) return nil;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    UIImageOrientation imageOrientation = [image imageOrientation];
    switch (imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
    }
    
    switch (imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
-(UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)newSize
{
    CGFloat targetWidth =sourceImage.size.width;  //newSize.width;
    CGFloat targetHeight = sourceImage.size.height;// newSize.height;
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }
    
    
    
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;
}


- (IBAction)sendTrackingButtonPressed:(id)sender
{
    [[TrackingModel sharedInstance] callTracking];
}

- (IBAction)debugButtonPressed:(id)sender
{
    DataValidator* dq = [[DataValidator alloc] init];
    NSMutableDictionary * dict = (NSMutableDictionary *)[dq fetchCoreData];
    [dict setObject:[[UpdateNotify SharedManager] Filecontentdict] forKey:@"FileContent"];
    [dq getContentByContentCategory];
//    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
//    NSString* jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
//    NSLog(@"Json String: %@", jsonString);

    
    //ContentSyncReportViewController* report = [[ContentSyncReportViewController alloc] initWithNibName:@"ContentSyncReportViewController" bundle:nil];
    
    //[self presentViewController:report animated:YES completion:nil];
    //report.contentSyncReport.text = dq.report;
    //report.contentSyncReport.editable = false;
    //NSLog(@"%@",dq.report);
    //[report.webView loadHTMLString:dq.report baseURL:nil];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    //[params setObject:[[RegistrationModel sharedInstance] uuid] forKey:@"uuid"];
    //[params setObject:[[RegistrationModel sharedInstance].profile email] forKey:@"email"];
    //[params setObject:dq.report forKey:@"debugInfo"];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:dict
                        options:NSJSONWritingPrettyPrinted
                        error:&error];
    
    NSString* jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    NSLog(@"Verify Content %@", jsonString);
    
    [params setObject:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] forKey:@"debugInfo"];

    
    NSString* serverBaseURL = WEB_SERVICE_BASE_SERVER;
    #define LOG_API_REPORT             @"/logapi/sendlog"
    
    //NSString* newString = [NSString stringWithFormat:@"%@%@", serverBaseURL, LOG_API_REPORT];
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:serverBaseURL]];
    
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:LOG_API_REPORT parameters:params];
    
    //[request setTimeoutInterval:DEFAULT_WEB_SERVICE_TIMEOUT];
    
#warning user/pwd hard-coded values in HTTP headers
    [request setValue:[[RegistrationModel sharedInstance] uuid] forHTTPHeaderField:@"UUID"];
    [request setValue:[[RegistrationModel sharedInstance].profile email] forHTTPHeaderField:@"USERNAME"];
    //[request setValue:@"demo" forHTTPHeaderField:@"PASSWORD"];
    
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"application/json"]];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/json"]];
    //
    
    AFJSONRequestOperation *op = [AFJSONRequestOperation
                                  JSONRequestOperationWithRequest:request
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                      //nslog(@"%@ success response at: %@", wsUrlStr, [NSDate date]);
                                      NSLog(@"response: %@", (NSString*)JSON);
                                      [hud hide:YES];
                                      UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Info" message:@"Report sent successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                      [alert show];
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                      [hud hide:YES];
                                      UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not send report at this time" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                      [alert show];
                                      //nslog(@"failure response %@  \n error %@ \n JSON %@", response, error, JSON);
                                  }];
    
    //nslog(@"making %@ call at: %@", wsUrlStr, [NSDate date]);
    
    [httpClient enqueueHTTPRequestOperation:op];
    
    
}


#pragma mark generating Vcard----

-(IBAction)sendVcard:(id)sender
{
    [currentTextField resignFirstResponder];
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults objectForKey:@"firstName"];
    [userDefaults objectForKey:@"lastName"];
    [userDefaults objectForKey:@"email"];
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
  

    
    [mutableArray addObject:@"BEGIN:VCARD"];
    [mutableArray addObject:@"VERSION:3.0"];
  
   
    [mutableArray addObject:[NSString stringWithFormat:@"N:%@;%@",[userDefaults objectForKey:@"lastName"],[userDefaults objectForKey:@"firstName"]]];
   //  [mutableArray addObject:[NSString stringWithFormat:@"LN:%@",[userDefaults objectForKey:@"lastName"]]];
    
  //  [mutableArray addObject:[NSString stringWithFormat:@"ADR:;;%@",
   //                          [self addressWithSeparator:@";"]]];
    
    NSLog(@"contanct data path-----%@",[userDefaults objectForKey:@"phone"]);
    if ([userDefaults objectForKey:@"phone"] != nil)
        [mutableArray addObject:[NSString stringWithFormat:@"TEL;type=CELL;type=VOICE;type=pref:%@", [userDefaults objectForKey:@"phone"]]];
    [mutableArray addObject:[NSString stringWithFormat:@"EMAIL:%@", [userDefaults objectForKey:@"email"]]];
  //  [mutableArray addObject:[NSString stringWithFormat:@"FIRST NAME:%@", [userDefaults objectForKey:@"firstName"]]];
  //  [mutableArray addObject:[NSString stringWithFormat:@"LAST NAME:%@", [userDefaults objectForKey:@"lastName"]]];
   // [mutableArray addObject:[NSString stringWithFormat:@"GEO:%g;%g",
     //                        self.latitudeValue, self.longitudeValue]];
    
   // [mutableArray addObject:[NSString stringWithFormat:@"URL:http://%@",
    //                         self.website]];
    
    //NSData *imageData = UIImagePNGRepresentation(self.userimageIMGVIEW.image);//contact.imageData;
   NSData *imageData = UIImageJPEGRepresentation(self.userimageIMGVIEW.image,0.25f);
    if (imageData)
    {
        [mutableArray addObject:[NSString stringWithFormat:@"PHOTO;BASE64:%@\n",[imageData base64Encoding]]];
        //vcard = [vcard stringByAppendingFormat:@"PHOTO;BASE64:%@\n",[imageData base64Encoding]];
    }
    
    
    [mutableArray addObject:@"END:VCARD"];
    
    NSString *string = [mutableArray componentsJoinedByString:@"\n"];
   
    /*
    
    NSString *vcard = @"BEGIN:VCARD\nVERSION:3.0\n";
    
    // Name
    vcard = [vcard stringByAppendingFormat:@"N:%@;%@\n",
             
             ([userDefaults objectForKey:@"lastName"] ? [userDefaults objectForKey:@"lastName"] : @""),([userDefaults objectForKey:@"firstName"] ? [userDefaults objectForKey:@"firstName"] : @"")
            
             ];
    // ([userDefaults objectForKey:@"email"] ? [userDefaults objectForKey:@"email"] : @""),
   // ([userDefaults objectForKey:@"phone"] ? [userDefaults objectForKey:@"phone"] : @"")
    vcard = [vcard stringByAppendingFormat:@"FN%@\n",@""];
    
    if( [userDefaults objectForKey:@"firstName"]) vcard = [vcard stringByAppendingFormat:@"X-PHONETIC-FIRST-NAME:%@\n",[userDefaults objectForKey:@"firstName"]];
   
    if(  [userDefaults objectForKey:@"lastName"] ) vcard = [vcard stringByAppendingFormat:@"X-PHONETIC-LAST-NAME:%@\n",[userDefaults objectForKey:@"lastName"] ];
    
    
    // Work
    // Mail
    vcard = [vcard stringByAppendingFormat:@"X-PHONETIC-EMAIL:%@\n",[userDefaults objectForKey:@"email"] ];
    
    // Tel
    vcard = [vcard stringByAppendingFormat:@"X-PHONETIC-Phone:%@\n",[userDefaults objectForKey:@"phone"]];
    
     //nslog(@"contanct data path-----%@",vcard);
    // Photo
    NSData *imageData = UIImagePNGRepresentation(self.userimageIMGVIEW.image);//contact.imageData;
    if (imageData)
    {
        //vcard = [vcard stringByAppendingFormat:@"PHOTO;BASE64:%@\n",[imageData base64Encoding]];
    }
    
    // end
    vcard = [vcard stringByAppendingString:@"END:VCARD"];
    
    */
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *folderPath = [paths objectAtIndex:0];
    NSString *filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.vcf",[userDefaults objectForKey:@"firstName"]]];
    [string writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    
    if ([MFMailComposeViewController canSendMail])
    {
        
        
        MFMailComposeViewController *mailView= [[MFMailComposeViewController alloc] init];
        mailView.mailComposeDelegate=self;
        [mailView setSubject:[NSString stringWithFormat:@"%@ Vcard",[userDefaults objectForKey:@"firstName"]]];
        
        
        NSData *pdfData = [NSData dataWithContentsOfFile:filePath];
        
        [mailView setToRecipients:[NSArray arrayWithObject:@""]];
        [mailView addAttachmentData:pdfData mimeType:@"text/x-vcard" fileName:[NSString stringWithFormat:@"%@.vcf",[userDefaults objectForKey:@"firstName"]]];
        
        
        
        
        NSString *emailBody = @" <html> <head> <link rel='stylesheet' type='text/css' media='all' href='http://m.eprodevbox.com/assets/email_templates/style.css' /> </head> <body><div class='wrap'> <span class='greeting'>Hello,</span> <br> <p>As requested, please find my contact information listed in the document attached.</p> </div> <div class='hr'></div> <div class='wrap'> <!-- <img src='http://m.eprodevbox.com/assets/email_templates/contact_card.png' /> --> Please find attachment for VCard. </div> <div class='hr'></div> <div class='wrap'> <p>Please feel free to contact me directly if I can answer any questions or provide you with further information.</p> <br> <br> Sincerely, <br> <span class='name'>{{First Name}} {{Last Name}}</span> <br> <br> <img src='http://m.eprodevbox.com/assets/email_templates/logo.png'/> <br> <br> </div> <div class='hr'></div> <footer> <div class='wrap'> <p class='notice'> <span class='name'>Confidentiality Notice:</span> This e-mail transmission may contain confidential or legally privileged information that is intended only for the individual or entity named in the e-mail address. If you are not the intended recipient, you are hereby notified that any disclosure, copying, distribution, or reliance upon the contents of this e-mail is strictly prohibited. If you have received this e-mail transmission in error, please reply to the sender, so that J&J can arrange for proper delivery, and then please delete the message from your inbox. </p> </div> </footer> </body></html>";
        
         emailBody = [emailBody stringByReplacingOccurrencesOfString:@"http://m.eprodevbox.com" withString:WEB_SERVICE_BASE_SERVER];
        emailBody = [emailBody stringByReplacingOccurrencesOfString:@"{{First Name}}" withString:[userDefaults objectForKey:@"firstName"]];
        emailBody = [emailBody stringByReplacingOccurrencesOfString:@"{{Last Name}}" withString:[userDefaults objectForKey:@"lastName"]];
        

        [mailView setMessageBody:emailBody isHTML:YES];
        
        
        //self.navigationController.navigationBarHidden = YES;
        [self presentViewController:mailView animated:YES completion:nil];
    }
    
}
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self becomeFirstResponder];
    if(result==MFMailComposeResultCancelled)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else if (result == MFMailComposeResultSaved)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Your mail has been sent successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        // alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.tag=15;
        alert.delegate=self;
        [alert show];
    }
    else if (result==MFMailComposeResultSent)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Your mail has been sent successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        // alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.tag=15;
        alert.delegate=self;
        [alert show];
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==15)
	{
        if(buttonIndex==alertView.cancelButtonIndex)
		{
            [self dismissViewControllerAnimated:YES completion:nil];
            
            //[self.view removeFromSuperview];
        }
    } else if (alertView.tag == 10) {
        
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
    
    [self registerForEvents];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Reset Data" message:@"Are you sure you want to reset? This will delete all Content and re-download." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    
    alert.tag = 10;
    [alert show];

}

- (void) handleRegistrationSuccess
{
    //nslog(@"RegistrationVC handleRegistrationSuccess.");
    [_hud hide:YES];
    [self invokeContentSync];
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
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSyncMasterDataSuccess) name:APP_EVENT_SYNC_MASTER_DATA_SUCCESS object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSyncMasterDataFailure) name:APP_EVENT_SYNC_MASTER_DATA_FAILURE object:nil];
    
}

- (void) unregisterForEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_REGISTRATION_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_REGISTRATION_FAILURE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_REGISTRATION_ERROR_RESPONSE object:nil];
    
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_SYNC_MASTER_DATA_SUCCESS object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_SYNC_MASTER_DATA_FAILURE object:nil];
    
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

@end
