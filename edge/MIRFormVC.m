//
//  MIRFormVC.m
//  edge
//
//  Created by EAI-WKS-00011 on 8/8/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "MIRFormVC.h"
#import "SignatureViewController.h"
#import "FormsVC.h"
#import "TabBarViewController.h"
#import "AppDelegate.h"
#import "PrivacyPolicyVC.h"
#import "TrackingModel.h"

#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]

@interface MIRFormVC ()

@property (nonatomic,strong) IBOutlet UIButton * SignatureBtn;
@property (nonatomic,strong) SignatureViewController * SignVC;
@property (nonatomic,strong) AppDelegate * appDelegate;


@end

@implementation MIRFormVC
@synthesize FormObj;
@synthesize TitleTxtfiled;
@synthesize InstitutionTxtfiled;
@synthesize NameTxtfiled;
@synthesize OthersTxtfiled;
@synthesize Address1Txtfiled;
@synthesize Address2Txtfiled;
@synthesize StateTxtfiled;
@synthesize PostalcodeTxtfiled;
@synthesize TelePhoneTxtfiled;
@synthesize FaxTxtfiled;
@synthesize EmailTxtfiled;
@synthesize SAlesTxtfiled;
@synthesize FormTitleTxtfiled;
@synthesize CategoryString;
@synthesize ResponseString;
@synthesize InformationTxtView;
@synthesize SignatureImage;
@synthesize categorybuton1,categorybuton2,categorybuton3,categorybuton4,categorybuton5,categorybuton6;
@synthesize responsemethod1,responsemethod2,responsemethod3,responsemethod4,responsemethod5;
@synthesize isNewform,updatetime,formId,formtitle;
@synthesize BackGroundScrView,pdfFilePath;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
UIImageView * bckgroundimage1;
UIImageView * bckgroundimage;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.CategoryString = @"M.D.";
    self.ResponseString = @"US Mail";
    bckgroundimage = [[UIImageView alloc] initWithFrame:CGRectMake(44, 51, 943, 610)];
   // bckgroundimage.image = [UIImage imageNamed:@"Mirform_bg.png"];
    
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"Mirform_bg" ofType:@"png"];
    UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:thePath];
    bckgroundimage.image = prodImg;
    
    [self.view addSubview:bckgroundimage];
    [self.view bringSubviewToFront:BackGroundScrView];
    [self.view bringSubviewToFront:self.deleteBtn];
    
    
    self.BackGroundScrView.frame = CGRectMake(63, 123, 900, 518);
    [self.BackGroundScrView setContentSize:CGSizeMake(900, 900)];
    
    bckgroundimage1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, 900, 825)];
    //bckgroundimage1.image = [UIImage imageNamed:@"mirform_withtext.png"];
    
    thePath = [[NSBundle mainBundle] pathForResource:@"mirform_withtext" ofType:@"jpg"];
    UIImage *prodImg1 = [[UIImage alloc] initWithContentsOfFile:thePath];
    bckgroundimage1.image = prodImg1;

   // InformationTxtView.text = @"Medical Information";
   // InformationTxtView.userInteractionEnabled = YES;
    //InformationTxtView.editable = YES;
    
    [self.BackGroundScrView addSubview:bckgroundimage1];
    [self.BackGroundScrView sendSubviewToBack:bckgroundimage1];
    [self.SignatureBtn setTitle:@"" forState:UIControlStateNormal];
    
    if (isNewform)
    {
        self.deleteBtn.hidden = YES;
        [self.categorybuton1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.responsemethod1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.SignatureBtn setTitle:@"Tap to sign" forState:UIControlStateNormal];
    }
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (isNewform)
    {
        [self.categorybuton1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.responsemethod1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.SignatureImage.image = nil;
    }
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.SignatureBtn addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self.SignatureBtn addGestureRecognizer:singleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    //ßßß [self Showdata];
    // Do any additional setup after loading the view from its nib.
    
    if (!isNewform)
    {
        NSLog(@"Not new form");

        NSLog(@"signature = %@", self.SignatureImage.image);
        NSLog(@"signature = %@", self.appDelegate.SignatureImage);

        //[self.SignatureBtn setTitle:@"Tap to sign" forState:UIControlStateNormal];
        //NSLog(@"signature image DOESNT exist");
    }
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    
    [self removedataFields];
    [self.view removeFromSuperview];
    [super viewDidDisappear:animated];
}


#pragma TextFiled Delegates


# pragma mark - Textfield methods

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    [theTextField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    
    if (textField.tag == 11|| textField.tag==12)
    {
        [UIView beginAnimations:@"anim" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration:0.2];
        CGRect frame=self.view.frame;
        frame.origin.y=-300;
        self.view.frame=frame;
        [UIView commitAnimations];
        
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 11|| textField.tag==12)
    {
        [UIView beginAnimations:@"anim" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration:0.2];
        CGRect frame=self.view.frame;
        frame.origin.y=0;
        self.view.frame=frame;
        [UIView commitAnimations];
        
    }
    if (textField.tag ==121)
    {
        self.formtitle = self.FormTitleTxtfiled.text;
    }
    if (textField.tag == 5)
    {
        NSString *emailString = self.EmailTxtfiled.text;
        NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailReg];
        if ([emailTest evaluateWithObject:emailString] != YES)
        {
            UIAlertView *loginalert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"E-Mail field not in proper format" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            
            [loginalert show];

        }
        [self.BackGroundScrView scrollRectToVisible:self.SAlesTxtfiled.frame animated:YES];

    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ((textField.tag ==20) ||(textField.tag ==21) || (textField.tag ==22) )
    {
        NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789-"] invertedSet];
        
        if ([string length] == 0){
            return YES;
        }else{
            if (textField.tag == 20)
            {
                
                int length = [textField.text length];
                if(length == 5)
                {
                    if(range.length == 0)
                        return NO;
                }
            }
            if ((textField.tag == 21) || (textField.tag ==22))
            {
                
                int length = [textField.text length];
                if(length == 15)
                {
                    if(range.length == 0)
                        return NO;
                }
            }
            
            return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0);
        }
    }
    else if ((textField.tag ==30))
    {
        if ([string length] == 0){
            return YES;
        }else{
            int length = [textField.text length];
            if(length == 2)
            {
                if(range.length == 0)
                    return NO;
            }
        }
    }
    
    return YES;
}
# pragma mark - Textviews methods


-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView.tag==10)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0.3];
        CGRect rect = self.view.bounds;
        rect.origin.y = -300;
        self.view.frame = rect;
        [UIView commitAnimations];
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"])
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0.3];
        CGRect rect = self.view.frame;
        rect.origin.y = 0;
        self.view.frame = rect;
        [UIView commitAnimations];
        
        [textView resignFirstResponder];
         return YES;
        
    }
    
    if ([text length] == 0){
        return YES;
    }else{
        int length = [textView.text length];
        if(length == 2000)
        {
            if(range.length == 0)
                return NO;
        }
    }
    
    return YES;
   
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.tag==10)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0.3];
        CGRect rect = self.view.frame;
        rect.origin.y = 0;
        self.view.frame = rect;
        [UIView commitAnimations];
    }
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    
    
    return YES;
}


-(IBAction)CloseBtnPressed:(id)sender
{
    
    UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to cancel form?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    [alertView1 setTag:1234];
    [alertView1 show];
    
}
-(IBAction)DeleteBtnPressed:(id)sender
{
    UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete form?" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    
    [alertView1 setTag:2222];
    [alertView1 show];
}

//-(IBAction)SignatureBtnPressed:(id)sender
//{
//    // ViewController * SignVC = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
//    //  [self.view addSubview:SignVC.view];
//
//
//
//    self.SignVC = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"SignVC"];
//    self.SignVC.view.frame = CGRectMake(0, 0, 1024, 768);
//
//    [self.view addSubview:self.SignVC.view];
//
//
//
//}


-(IBAction)SendBtnPressed:(id)sender
{
    
    
    if ([self.NameTxtfiled.text isEqualToString:@""])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please enter Name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if (self.NameTxtfiled.text.length > 50)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Name field should have less than 50 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if ([self.TitleTxtfiled.text isEqualToString:@""])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please enter Title" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if (self.TitleTxtfiled.text.length > 30)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"title field should have less than 30 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if ([self.InstitutionTxtfiled.text isEqualToString:@""])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please enter Institution" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
        
    }
    else if (self.InstitutionTxtfiled.text.length > 35)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Institution field should have less than 35 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if (self.OthersTxtfiled.text.length > 15)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Others field should have less than 15 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if ([self.Address1Txtfiled.text isEqualToString:@""])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please enter Address" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
        
    }
    else if ([self.Address2Txtfiled.text isEqualToString:@""])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please enter City" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if (self.Address2Txtfiled.text.length > 30)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"city field should have less than 30 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if ([self.StateTxtfiled.text isEqualToString:@""])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please enter State" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
        
    }
    else if (self.StateTxtfiled.text.length > 2)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"state field should 2 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if ([self.PostalcodeTxtfiled.text isEqualToString:@""])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please enter Zip Code" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
        
    }
    else if (self.PostalcodeTxtfiled.text.length > 5)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Zipcode should be 5 numbers" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if ([self.TelePhoneTxtfiled.text isEqualToString:@""])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please enter Telephone" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if (self.TelePhoneTxtfiled.text.length > 15)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Telephone field should have less than 15 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
//    else if ([self.FaxTxtfiled.text isEqualToString:@""])
//    {
//        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please enter Fax" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
//        alert.delegate=nil;
//        [alert show];
//        return;
//        
//    }
    else if (self.FaxTxtfiled.text.length > 15)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Fax field should have less than 15 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    
    
    else if ([self.EmailTxtfiled.text isEqualToString:@""])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please enter Email" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if (self.SignatureImage.image == nil)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please add Signature" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if ([self.InformationTxtView.text isEqualToString:@""])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please enter Medical Information" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if (self.InformationTxtView.text.length > 2000)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Informaion field should have less than 2000 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if ([self.SAlesTxtfiled.text isEqualToString:@""])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please enter Sales Representative" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if (self.SAlesTxtfiled.text.length > 35)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Sales Representative field should have less than 35 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if ([self.TerritoryTxtfiled.text isEqualToString:@""])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please enter Territory" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if (self.TerritoryTxtfiled.text.length > 25)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Territory field should have less than 25 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if ([self.CategoryString isEqualToString:@""])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please select Category Type" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    else if ([self.ResponseString isEqualToString:@""])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please select Response Type" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
        return;
    }
    
    else
    {
        
        NSString *emailString = self.EmailTxtfiled.text;
        NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailReg];
        if ([emailTest evaluateWithObject:emailString] != YES)
        {
            UIAlertView *loginalert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"E-Mail field not in proper format" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            
            [loginalert show];
            return;
        }
        if ([MFMailComposeViewController canSendMail])
        {
            
            [self generatepdf];
            /*
             MFMailComposeViewController *mailView= [[MFMailComposeViewController alloc] init];
             mailView.mailComposeDelegate=self;
             [mailView setSubject:@"MIRFORM"];
             
             
             //Create a string with HTML formatting for the email body
             NSString * emailBody = [NSString stringWithFormat:@"Name: %@ \n Title: %@  \n Institution: %@  \n Others: %@  \n Address1: %@  \n Address2: %@  \n State: %@  \n Zip Code: %@  \n Telephone: %@  \n Category: %@ \n Response: %@ \n Fax: %@  \n Email: %@  \n Sales: %@  \n Territory: %@  \n Information: %@ ",self.NameTxtfiled.text,self.TitleTxtfiled.text,self.InstitutionTxtfiled.text,self.OthersTxtfiled.text,self.Address1Txtfiled.text,self.Address2Txtfiled.text,self.StateTxtfiled.text,self.PostalcodeTxtfiled.text,self.TelePhoneTxtfiled.text,self.CategoryString,self.ResponseString,self.FaxTxtfiled.text,self.EmailTxtfiled.text,self.SAlesTxtfiled.text,self.TerritoryTxtfiled.text,self.InformationTxtView.text];
             [mailView setMessageBody:emailBody isHTML:NO];
             UIImage *croppedImg = nil;
             CGRect cropRect = CGRectMake(150, 0, 383, 84); //set your rect size.
             croppedImg = [self croppIngimageByImageName:self.SignatureImage.image toRect:cropRect];
             
             NSData * imagedata = UIImageJPEGRepresentation(self.SignatureImage.image, 1.0);
             
             [mailView addAttachmentData:imagedata mimeType:@"image/png" fileName:@"File"];
             
             [mailView setToRecipients:[NSArray arrayWithObject:@""]];
             //  [mailView addAttachmentData:myData mimeType:@"application/pdf" fileName:@"JPOP.pdf"];
             [self presentViewController:mailView animated:YES completion:nil];
             
             */
        }
        
    }
}



- (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    //CGRect CropRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height+15);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
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
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Your mail has been saved successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        // alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.tag=15;
        alert.delegate=self;
        [alert show];
        self.appDelegate.SignatureImage = nil;
        if (![pdfFilePath isEqualToString:@"(null)" ] && ![pdfFilePath isEqualToString:@""])
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:pdfFilePath error:NULL];
            // //nslog(@"pdfFilePath====%@  fileManager ===%@ ",pdfFilePath,fileManager);
        }
    }
    else if (result==MFMailComposeResultSent)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Your mail has been sent successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        // alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.tag=15;
        alert.delegate=self;
        [alert show];
        self.appDelegate.SignatureImage = nil;
        if (![pdfFilePath isEqualToString:@"(null)" ] && ![pdfFilePath isEqualToString:@""])
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:pdfFilePath error:NULL];
            // //nslog(@"pdfFilePath====%@  fileManager ===%@ ",pdfFilePath,fileManager);
        }
        [[TrackingModel sharedInstance] createTrackingDataWithResource:self.NameTxtfiled.text activityCode:TRACKING_ACTIVITY_SUBMITTED_MIR_FORM];
        if (isNewform)
        {
            
        }
        else
        {
            
            NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
            
            NSError *error;
            
            NSEntityDescription *entiDesc=[NSEntityDescription entityForName:@"MyForm" inManagedObjectContext:context];
            
            NSFetchRequest *request=[[NSFetchRequest alloc] init];
            [request setEntity:entiDesc];
            [request setPredicate:[NSPredicate predicateWithFormat:@"formId=%@",formId]];
            NSManagedObject * obj = [[context executeFetchRequest:request error:&error] lastObject];
            if (obj)
            {
                [context deleteObject:obj];
                [context save:nil];
            }
            
        }
        
        
    }
}


-(IBAction)CategoryBtnPressed:(id)sender
{
    if([sender tag]==100)
    {
        [self.categorybuton1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.categorybuton2.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton3.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton4.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton5.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton6.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.CategoryString = self.categorybuton1.titleLabel.text;
        
    }
    else if([sender tag]==101)
    {
        self.categorybuton1.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        [self.categorybuton2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.categorybuton3.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton4.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton5.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton6.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.CategoryString = self.categorybuton2.titleLabel.text;
    }
    else if([sender tag]==102)
    {
        self.categorybuton1.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton2.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        [self.categorybuton3 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.categorybuton4.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton5.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton6.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.CategoryString = self.categorybuton3.titleLabel.text;
    }
    else if([sender tag]==103)
    {
        self.categorybuton1.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton2.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton3.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        [self.categorybuton4 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
        self.categorybuton5.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton6.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.CategoryString = self.categorybuton4.titleLabel.text;
    }
    else if([sender tag]==104)
    {
        self.categorybuton1.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton2.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton3.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton4.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        [self.categorybuton5 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.categorybuton6.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.CategoryString = self.categorybuton5.titleLabel.text;
        
    }
    else
    {
        self.categorybuton1.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton2.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton3.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton4.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.categorybuton5.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        [self.categorybuton6 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.CategoryString = self.categorybuton6.titleLabel.text;
        
    }
    
    
    
    
    
}


-(IBAction)SaveBtnPressed:(id)sender
{
    
    
    if (isNewform)
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        {
            UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"Enter Form Name" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alertView1.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField *myTextField = [alertView1 textFieldAtIndex:0];
            [alertView1 setTag:555];
            myTextField.keyboardType=UIKeyboardTypeAlphabet;
            self.FormTitleTxtfiled=myTextField;
            self.FormTitleTxtfiled.delegate = self;
            [self.FormTitleTxtfiled becomeFirstResponder];
            self.FormTitleTxtfiled.tag=121;
            [alertView1 show];
            
        }
        else
        {
            UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"Enter Form Name" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 40.0, 260.0, 20.0)];
            [myTextField setBackgroundColor:[UIColor whiteColor]];
            
            [alertView1 setTag:555];
            [alertView1 addSubview:myTextField];
            myTextField.keyboardType=UIKeyboardTypeAlphabet;
            self.FormTitleTxtfiled=myTextField;
            self.FormTitleTxtfiled.delegate = self;
            [self.FormTitleTxtfiled becomeFirstResponder];
            self.FormTitleTxtfiled.tag=121;
            [alertView1 show];
            
        }
        
        
        
    }
    else
    {
        [self SaveFormtoDB];
    }
    
    
    
    
    
    
    
}


-(void)SaveFormtoDB
{
    
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    
    NSError *error;
    
    NSEntityDescription *entiDesc=[NSEntityDescription entityForName:@"MyForm" inManagedObjectContext:context];
    
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    [request setEntity:entiDesc];
    
    NSEntityDescription *obj;
    if (isNewform)
    {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                            initWithKey:@"formId" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        
        
        NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
        
        if([fetchedObjects count]==0)
        {
            formId=@"0";
        }
        else
        {
            NSManagedObject *obj=[fetchedObjects objectAtIndex:([fetchedObjects count]-1)];
            
            int value=[[obj valueForKey:@"formId"] intValue];
            
            value=value+1;
            formId=[NSString stringWithFormat:@"%d",value];
            
        }
        obj=[NSEntityDescription insertNewObjectForEntityForName:@"MyForm" inManagedObjectContext:context];
        
    }
    else
    {
        [request setPredicate:[NSPredicate predicateWithFormat:@"formId=%@",formId]];
        obj = [[context executeFetchRequest:request error:&error] lastObject];
        self.FormTitleTxtfiled.text = self.formtitle;
    }
    
    if ([self.Address1Txtfiled.text isEqualToString:@""] || (self.Address1Txtfiled.text == nil))
    {
        [obj setValue:@"" forKey:@"address"];
        
    }
    else
    {
        [obj setValue:self.Address1Txtfiled.text forKey:@"address"];
    }
    if ([self.Address2Txtfiled.text isEqualToString:@""] || (self.Address2Txtfiled.text == nil))
    {
        [obj setValue:@"" forKey:@"address2"];
    }
    else
    {
        [obj setValue:self.Address2Txtfiled.text forKey:@"address2"];
    }
    if ([self.CategoryString isEqualToString:@""] || (self.CategoryString == nil))
    {
        [obj setValue:@"" forKey:@"choiceOne"];
    }
    else
    {
        [obj setValue:self.CategoryString forKey:@"choiceOne"];
    }
    
    if (isNewform)
    {
        NSDate * FormDate = [NSDate date];
        [obj setValue:FormDate forKey:@"crtDt"];
        
        NSDate * submitDate = [NSDate date];
        [obj setValue:submitDate forKey:@"sbtDt"];
        
        NSDate * updateDate = [NSDate date];
        [obj setValue:updateDate forKey:@"uptDt"];
    }
    else
    {
        [obj setValue:updatetime forKey:@"sbtDt"];
        
        [obj setValue:updatetime forKey:@"uptDt"];
    }
    
    if ([self.EmailTxtfiled.text isEqualToString:@""] || (self.EmailTxtfiled.text == nil))
    {
        [obj setValue:@"" forKey:@"email"];
    }
    else
    {
        [obj setValue:self.EmailTxtfiled.text forKey:@"email"];
    }
    if ([self.SAlesTxtfiled.text isEqualToString:@""] || (self.SAlesTxtfiled.text == nil))
    {
        [obj setValue:@"" forKey:@"sales"];
    }
    else
    {
        [obj setValue:self.SAlesTxtfiled.text forKey:@"sales"];
    }
    if ([self.FaxTxtfiled.text isEqualToString:@""] || (self.FaxTxtfiled.text == nil))
    {
        [obj setValue:@"" forKey:@"fax"];
    }
    else
    {
        
        
        [obj setValue:self.FaxTxtfiled.text forKey:@"fax"];
    }
    if ([self.InstitutionTxtfiled.text isEqualToString:@""] || (self.InstitutionTxtfiled.text == nil))
    {
        [obj setValue:@"" forKey:@"institution"];
    }
    else
    {
        [obj setValue:self.InstitutionTxtfiled.text forKey:@"institution"];
    }
    if ([self.InformationTxtView.text isEqualToString:@""] || (self.InformationTxtView.text == nil))
    {
        [obj setValue:@"" forKey:@"information"];
    }
    else
    {
        [obj setValue:self.InformationTxtView.text forKey:@"information"];
    }
    if ([self.NameTxtfiled.text isEqualToString:@""] || (self.NameTxtfiled.text == nil))
    {
        [obj setValue:@"" forKey:@"name"];
    }
    else
    {
        [obj setValue:self.NameTxtfiled.text forKey:@"name"];
    }
    if ([self.TelePhoneTxtfiled.text isEqualToString:@""] || (self.TelePhoneTxtfiled.text == nil))
    {
        [obj setValue:@"" forKey:@"phone"];
    }
    else
    {
        
        [obj setValue:self.TelePhoneTxtfiled.text forKey:@"phone"];
    }
    if ([self.ResponseString isEqualToString:@""] || (self.ResponseString == nil))
    {
        [obj setValue:@"" forKey:@"respMode"];
    }
    else
    {
        [obj setValue:self.ResponseString forKey:@"respMode"];
    }
    if ([self.OthersTxtfiled.text isEqualToString:@""] || (self.OthersTxtfiled.text == nil))
    {
        [obj setValue:@"" forKey:@"others"];
    }
    else
    {
        [obj setValue:self.OthersTxtfiled.text forKey:@"others"];
    }
    if ([self.StateTxtfiled.text isEqualToString:@""] || (self.StateTxtfiled.text == nil))
    {
        [obj setValue:@"" forKey:@"state"];
    }
    else
    {
        [obj setValue:self.StateTxtfiled.text forKey:@"state"];
    }
    if ([self.TerritoryTxtfiled.text isEqualToString:@""] || (self.TerritoryTxtfiled.text == nil))
    {
        [obj setValue:@"" forKey:@"territory"];
    }
    else
    {
        [obj setValue:self.TerritoryTxtfiled.text forKey:@"territory"];
    }
    if ([self.formtitle isEqualToString:@""] || (self.formtitle == nil))
    {
        [obj setValue:@"" forKey:@"formTitle"];
    }
    else
    {
        [obj setValue:self.formtitle forKey:@"formTitle"];
    }
    if ([self.TitleTxtfiled.text isEqualToString:@""] || (self.TitleTxtfiled.text == nil))
    {
        [obj setValue:@"" forKey:@"title"];
    }
    else
    {
        [obj setValue:self.TitleTxtfiled.text forKey:@"title"];
    }
    if ([self.PostalcodeTxtfiled.text isEqualToString:@""] || (self.PostalcodeTxtfiled.text == nil))
    {
        [obj setValue:@"" forKey:@"zipCode"];
    }
    else
    {
        [obj setValue:self.PostalcodeTxtfiled.text forKey:@"zipCode"];
    }
    
    if ([formId isEqualToString:@""] || (formId == nil))
    {
        [obj setValue:@"" forKey:@"formId"];
    }
    else
    {
        [obj setValue:formId forKey:@"formId"];
    }
    if (self.SignatureImage.image == nil)
    {
        NSData * signatureimagedata = nil;
        [obj setValue:signatureimagedata forKey:@"signature"];
    }
    else
    {
        
        NSData * signatureimagedata = UIImagePNGRepresentation(self.SignatureImage.image);
        [obj setValue:signatureimagedata forKey:@"signature"];
    }
    
    if ([context  save:&error])
    {
        if (isNewform)
        {
            UIAlertView *alertview=[[UIAlertView alloc]initWithTitle:@"" message:@"Saved successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alertview.tag = 100;
            [alertview show];
            
        }
        else
        {
            UIAlertView *alertview=[[UIAlertView alloc]initWithTitle:@"" message:@"Updated successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alertview.tag = 100;
            [alertview show];
        }
        
    }
}


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==1234)
    {
        if(buttonIndex==alertView.cancelButtonIndex)
        {
            
        }
        else
        {
            [self removedataFields];
            [self.view removeFromSuperview];
        }
    }
    if(alertView.tag==2222)
    {
        if(buttonIndex==alertView.cancelButtonIndex)
        {
            
        }
        else
        {
            NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
            
            NSError *error;
            
            NSEntityDescription *entiDesc=[NSEntityDescription entityForName:@"MyForm" inManagedObjectContext:context];
            
            NSFetchRequest *request=[[NSFetchRequest alloc] init];
            [request setEntity:entiDesc];
            [request setPredicate:[NSPredicate predicateWithFormat:@"formId=%@",formId]];
            NSManagedObject * obj = [[context executeFetchRequest:request error:&error] lastObject];
            if (obj)
            {
                [context deleteObject:obj];
                [context save:nil];
            }
            // [self dismissViewControllerAnimated:YES completion:nil];
            [[APP_DELEGATE tabBarController] setSelectedIndex:2];
            [[APP_DELEGATE tabBarController] setSelectedIndex:5];
            [self removedataFields];
            [self.view removeFromSuperview];
            
        }
    }
    
    if(alertView.tag==100)
    {
        if(buttonIndex==alertView.cancelButtonIndex)
        {
            
            
            [[APP_DELEGATE tabBarController] setSelectedIndex:2];
            [[APP_DELEGATE tabBarController] setSelectedIndex:5];
            [self removedataFields];
            [self.view removeFromSuperview];
        }
    }
    
    if(alertView.tag ==555)
    {
        if(buttonIndex==0)
        {
            
            [self.FormTitleTxtfiled resignFirstResponder];
            
            
        }
        
        else if(buttonIndex==1)
        {
            
            if([self.FormTitleTxtfiled.text isEqualToString:@""])
            {
                UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Please enter form name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView setTag:1717];
                [alertView show];
                
            }
            else
            {
                self.formtitle = self.FormTitleTxtfiled.text;
                
                
                NSManagedObjectContext *context=[APP_DELEGATE managedObjectContext];
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription
                                               entityForName:@"MyForm" inManagedObjectContext:context];
                [fetchRequest setEntity:entity];
                NSError *error;
                
                NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
                BOOL titleExists = NO;
                if (fetchedObjects.count > 0)
                {
                    
                    for (NSManagedObject *info in fetchedObjects)
                    {
                        if ([[[info valueForKey:@"formTitle"]lowercaseString] isEqualToString:[self.FormTitleTxtfiled.text lowercaseString]] )
                        {
                            titleExists = YES;
                        }

                    }
                    
                }
                
                if (titleExists == YES)
                {
                    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Title Exists.Please enter another title" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView setTag:1717];
                    [alertView show];
                }
                else
                  [self SaveFormtoDB];
            }
        }
    }
    if (alertView.tag == 1717)
    {
        [self SaveBtnPressed:nil];
//        UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"Enter Form Name" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//        UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 40.0, 260.0, 20.0)];
//        [myTextField setBackgroundColor:[UIColor whiteColor]];
//        
//        [alertView1 setTag:555];
//        [alertView1 addSubview:myTextField];
//        myTextField.keyboardType=UIKeyboardTypeAlphabet;
//        self.FormTitleTxtfiled=myTextField;
//        self.FormTitleTxtfiled.delegate = self;
//        [self.FormTitleTxtfiled becomeFirstResponder];
//        self.FormTitleTxtfiled.tag=121;
//        [alertView1 show];
        
        
    }
    if(alertView.tag==15)
    {
        if(buttonIndex==alertView.cancelButtonIndex)
        {
            if (![pdfFilePath isEqualToString:@"(null)" ] && ![pdfFilePath isEqualToString:@""])
            {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:pdfFilePath error:NULL];
                // //nslog(@"pdfFilePath====%@  fileManager ===%@ ",pdfFilePath,fileManager);
            }
            [self dismissViewControllerAnimated:YES completion:nil];
            [[APP_DELEGATE tabBarController] setSelectedIndex:2];
            [[APP_DELEGATE tabBarController] setSelectedIndex:5];
            [self removedataFields];
            [self.view removeFromSuperview];
        }
    }
}
-(IBAction)ResponseBtnPressed:(id)sender
{
    if([sender tag]==200)
    {
        [self.responsemethod1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.responsemethod2.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.responsemethod3.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.responsemethod4.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.responsemethod5.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        
        self.ResponseString = self.responsemethod1.titleLabel.text;
        
    }
    else if([sender tag]==201)
    {
        [self.responsemethod2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.responsemethod1.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.responsemethod3.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.responsemethod4.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.responsemethod5.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        
        self.ResponseString = self.responsemethod2.titleLabel.text;
        
    }
    else if([sender tag]==202)
    {
        [self.responsemethod3 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.responsemethod2.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.responsemethod1.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.responsemethod4.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.responsemethod5.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        
        self.ResponseString = self.responsemethod3.titleLabel.text;
        
    }
    else if([sender tag]==203)
    {
        [self.responsemethod4 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.responsemethod2.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.responsemethod3.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.responsemethod1.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.responsemethod5.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        
        self.ResponseString = self.responsemethod4.titleLabel.text;
        
    }
    else if([sender tag]==204)
    {
        [self.responsemethod5 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.responsemethod2.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.responsemethod3.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.responsemethod4.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        self.responsemethod1.titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
        
        self.ResponseString = self.responsemethod5.titleLabel.text;
        
    }
    
    
}


-(IBAction)SignatureBtnPressed:(id)sender
{
    // ViewController * SignVC = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    //  [self.view addSubview:SignVC.view];
    if (self.SignatureImage.image)
    {
        self.appDelegate.SignatureImage = self.SignatureImage.image;
    }
    
    
    self.SignVC = [[SignatureViewController alloc] initWithNibName:@"SignatureViewController" bundle:nil];
    
    self.SignVC.delegate =self;
    self.SignVC.view.frame = CGRectMake(0, 0, 1024, 768);
    //
    [self.view addSubview:self.SignVC.view];
    
}

- (void)AddSignature
{
    self.SignatureImage.image = self.appDelegate.SignatureImage;
     [self.SignatureBtn setTitle:@"" forState:UIControlStateNormal];
    
}

- (void) doubleTap: (UITapGestureRecognizer *) sender
{
    
    self.SignatureImage.image = nil;
    self.appDelegate.SignatureImage = nil;
     [self.SignatureBtn setTitle:@"Tap to sign" forState:UIControlStateNormal];
}

- (void) singleTap:(UITapGestureRecognizer *)sender
{
    [self resignFirstResponder];
    [self SignatureBtnPressed:nil];
}


- (IBAction)privacyPolicyTouched:(id)sender
{
    PrivacyPolicyVC *vc = [[PrivacyPolicyVC alloc] initWithNibName:@"PrivacyPolicyVC" bundle:nil];
    
    //    PrivacyPolicyVC *vc = (PrivacyPolicyVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyID"];
    vc.istypeof = @"MIR";
    [self presentViewController:vc animated:YES completion:nil];
}
-(void)generatepdf
{
    int defaultheigth=1400;
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"sampleData" ofType:@"plist"];
    path = NSTemporaryDirectory();
    
    NSString *filenamestring=[NSString stringWithFormat:@"%@_MIRFORM.pdf",self.TitleTxtfiled.text];
    
    self.pdfFilePath = [path stringByAppendingPathComponent:filenamestring];
    
    int y=150;
    UIGraphicsBeginPDFContextToFile(self.pdfFilePath, CGRectZero, nil);
    //  //nslog(@"pdfFilePath %@",pdfFilePath);
    
    
    
    UIFont *mainsizeFont= [UIFont boldSystemFontOfSize:20];
    
    UIFont *subsizefont= [UIFont fontWithName:@"Arial" size:18];
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 40, 1207, defaultheigth), nil);
    
    
    //===========Company Details ===================
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
    
    
    NSDate *todaydate=[NSDate date];
    
    // NSDateFormatter *todaydateformatter=[[NSDateFormatter alloc]init];
    //[todaydateformatter setDateFormat:@"MM/dd/yyyy"];
    
    
    NSDateFormatter *todaydateformatter=[[NSDateFormatter alloc]init];
    // [todaydateformatter setDateFormat:@"EEEE MMMM dd, yyyy hh:mm a"];
    [todaydateformatter setDateFormat:@"MM/dd/yyyy"];
    [todaydateformatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSString *todaydatestring=[todaydateformatter stringFromDate:todaydate];
    
    
    //   [todaydatestring drawInRect:CGRectMake(700, 10, 500, 20) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentRight];
    NSString * mirformstring = @"Medical Information Request Form";
    
    [mirformstring drawInRect:CGRectMake(700, 40, 500, 20) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentRight];
    
    UIImage * demoImage = [UIImage imageNamed:@"ethicon_logonew.png"];
    [demoImage drawInRect:CGRectMake( 30,40,560,88)];
    
    NSString * salesnamestring = @"Sales Representative:";
    [salesnamestring drawInRect:CGRectMake(50, y, 250, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    [self.SAlesTxtfiled.text  drawInRect:CGRectMake(270, y+5, 380, 20) withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    NSString * terstring = @"Territory:";
    [terstring drawInRect:CGRectMake(750, y, 100, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    [self.TerritoryTxtfiled.text drawInRect:CGRectMake(870, y+5, 400, 20) withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    y= y+50;
                                                               
    NSString * Tostring = @"To:";
    [Tostring drawInRect:CGRectMake(50, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    [@"Ethicon Medical Affairs" drawInRect:CGRectMake(200, y+5, 300, 20) withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    y= y+50;
    NSString * date = @"Date:";
    [date drawInRect:CGRectMake(50, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    [todaydatestring drawInRect:CGRectMake(250, y+5, 500, 20) withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    y= y+50;
    NSString * Requestor = @"From (Requestor):";
    [Requestor drawInRect:CGRectMake(50, y, 250, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [[NSString stringWithFormat:@"%@ %@",[userDefaults objectForKey:@"firstName"],[userDefaults objectForKey:@"lastName"]] drawInRect:CGRectMake(250, y+5, 700, 20) withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    y = y+50;
    NSString * namestring = @"Name:";
    [namestring drawInRect:CGRectMake(50, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    [self.NameTxtfiled.text drawInRect:CGRectMake(200, y+5, 600, 20) withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    y= y+50;
    NSString * titlestring = @"Title:";
    [titlestring drawInRect:CGRectMake(50, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    [self.TitleTxtfiled.text drawInRect:CGRectMake(200, y+5, 320, 20) withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    NSString * institutionstring = @"Institution/Office:";
    [institutionstring drawInRect:CGRectMake(550, y, 200, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    [self.InstitutionTxtfiled.text drawInRect:CGRectMake(750, y+5, 360, 20) withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    y= y+50;
    NSString * catstring = @"Degree:";
    [catstring drawInRect:CGRectMake(50, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    [self.CategoryString drawInRect:CGRectMake(200, y+5, 300, 20) withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    NSString * otherstring = @"Others:";
    [otherstring drawInRect:CGRectMake(550, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    [self.OthersTxtfiled.text drawInRect:CGRectMake(750, y+5, 300, 20) withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    y= y+50;
    NSString * address1tring = @"Address:";
    [address1tring drawInRect:CGRectMake(50, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    CGSize stringSize = [self.Address1Txtfiled.text sizeWithFont:subsizefont
                                               constrainedToSize:CGSizeMake(200, y+5)
                                                   lineBreakMode:NSLineBreakByCharWrapping];
    
    CGRect renderingRect = CGRectMake(200, y+5, 800, stringSize.height);
    [self.Address1Txtfiled.text drawInRect:renderingRect withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    if (self.Address1Txtfiled.text.length > 100)
    {
        //nslog(@"in logg");
        y = y+((self.Address1Txtfiled.text.length/100)*15)+65;
    }
    else
        y=y+50;
    
    NSString * address2tring = @"City:";
    [address2tring drawInRect:CGRectMake(50, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    CGSize stringSize1 = [self.Address2Txtfiled.text sizeWithFont:subsizefont
                                                constrainedToSize:CGSizeMake(200, y+5)
                                                    lineBreakMode:NSLineBreakByCharWrapping];
    
    CGRect renderingRect1 = CGRectMake(200, y+5, 250, stringSize1.height);
    [self.Address2Txtfiled.text drawInRect:renderingRect1 withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    NSString * staterstring = @"State:";
    [staterstring drawInRect:CGRectMake(550, y, 80, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    [self.StateTxtfiled.text drawInRect:CGRectMake(630, y+5, 150, 20) withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    NSString * zipstring = @"Zip:";
    [zipstring drawInRect:CGRectMake(800, y, 100, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    [self.PostalcodeTxtfiled.text drawInRect:CGRectMake(900, y+5, 150, 20) withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    if (self.Address2Txtfiled.text.length > 30)
    {
        //nslog(@"in logg");
        y = y+((self.Address2Txtfiled.text.length/30)*15)+65;
    }
    else
        y=y+50;
    
    
    NSString * telestring = @"Telephone:";
    [telestring drawInRect:CGRectMake(50, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    [self.TelePhoneTxtfiled.text drawInRect:CGRectMake(200, y, 200, 20) withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    NSString * faxstring = @"Fax:";
    [faxstring drawInRect:CGRectMake(400, y, 70, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    [self.FaxTxtfiled.text drawInRect:CGRectMake(470, y, 160, 20) withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    NSString * emailstring = @"Email:";
    [emailstring drawInRect:CGRectMake(650, y, 60, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    [self.EmailTxtfiled.text drawInRect:CGRectMake(730, y, 400, 20) withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    y=y+50;
    NSString * responsestring = @"Desired response method:";
    [responsestring drawInRect:CGRectMake(50, y, 300, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    [self.ResponseString drawInRect:CGRectMake(350, y+5, 400, 20) withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    y= y+80;
    NSString * sigstring = @"Requestor's Signature:";
    [sigstring drawInRect:CGRectMake(50, y, 300, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    UIImage * demoImage1 = [UIImage imageNamed:@"signature_box.png"];
    [demoImage1 drawInRect:CGRectMake(395,y-25,373,94)];
    
    [self.SignatureImage.image drawInRect:CGRectMake(400,y-20,363,84)];
    
    
    y=y+90;
    
    UIImage * emptybox = [UIImage imageNamed:@"emptybox.png"];
    [emptybox drawInRect:CGRectMake(100,y,1000,400)];
    
    y= y+5;
    NSString * infostring = [NSString stringWithFormat:@"%@\n%@",@"Please send medical information on the following topic(s):",@"(Be as specific as possible with respect to product topic, area of use, outcome of interest etc.)"];
    [infostring drawInRect:CGRectMake(100, y, 1000, 60) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentCenter];
    y=y+60;
    CGSize stringSize3 = [self.InformationTxtView.text sizeWithFont:subsizefont
                                                  constrainedToSize:CGSizeMake(200, y)
                                                      lineBreakMode:NSLineBreakByCharWrapping];
    
    CGRect renderingRect3 = CGRectMake(120, y+5, 930, stringSize3.height);
    [self.InformationTxtView.text drawInRect:renderingRect3 withFont:subsizefont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    if (self.InformationTxtView.text.length > 115)
    {
        
        y = y+((self.InformationTxtView.text.length/115)*15)+65;
    }
    else
        y=y+50;
    
    
    UIGraphicsEndPDFContext();
    
    
    if ([MFMailComposeViewController canSendMail])
    {
        
        
        MFMailComposeViewController *mailView= [[MFMailComposeViewController alloc] init];
        mailView.mailComposeDelegate=self;
        [mailView setSubject:@"MIRFORM"];
        
        NSLog(@"---- %@",filenamestring);
        NSData *pdfData = [NSData dataWithContentsOfFile:pdfFilePath];
        
        [mailView setToRecipients:[NSArray arrayWithObject:@"ETH_Medical_Info@its.jnj.com"]];
        [mailView addAttachmentData:pdfData mimeType:@"application/pdf" fileName:filenamestring];
        
        
        
        
        
        NSString * emailstring = @"<html> <head> <link rel=stylesheet type=text/css media=all href=http://m.eprodevbox.com/assets/email_templates/style.css /> </head> <body> <div class=wrap> <span class=greeting>Hello,</span> <br> <p>Please find attachment.</p> </div> <footer> <div class=wrap> <p class='notice'> <span class='name'>Confidentiality Notice:</span> This e-mail transmission may contain confidential or legally privileged information that is intended only for the individual or entity named in the e-mail address. If you are not the intended recipient, you are hereby notified that any disclosure, copying, distribution, or reliance upon the contents of this e-mail is strictly prohibited. If you have received this e-mail transmission in error, please reply to the sender, so that J&J can arrange for proper delivery, and then please delete the message from your inbox. </p> </div> </footer> </body></html>" ;
         emailstring = [emailstring stringByReplacingOccurrencesOfString:@"http://m.eprodevbox.com" withString:WEB_SERVICE_BASE_SERVER];
         UIImage *logoImage = [UIImage imageNamed:@"logo_email.png"];
         NSData * imagedata =  UIImageJPEGRepresentation(logoImage, 1.0);
        // NSData * emaildata = UIImageJPEGRepresentation(entryimage.image, 1.0);
        
        [mailView addAttachmentData:imagedata mimeType:@"image/png" fileName:@"File"];
        [mailView setMessageBody:emailstring isHTML:YES];
       
        [self presentViewController:mailView animated:YES completion:nil];
        
        
    }
    // QLPreviewController* preview = [[QLPreviewController alloc] init];
    // preview.dataSource = self;
    //  preview.delegate = self;
    
    //    [self presentViewController:preview animated:YES completion:nil];
    
    
}

#pragma mark - QLPreviewControllerDataSource
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:self.pdfFilePath];
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    if (![pdfFilePath isEqualToString:@"(null)" ] && ![pdfFilePath isEqualToString:@""])
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:pdfFilePath error:NULL];
        // //nslog(@"pdfFilePath====%@  fileManager ===%@ ",pdfFilePath,fileManager);
    }
}

-(void)removedataFields
{
    self.appDelegate.SignatureImage = nil;
    bckgroundimage1 = nil;
    self.NameTxtfiled.text = @"";
    self.TitleTxtfiled.text = @"";
    self.InstitutionTxtfiled.text = @"";
    self.OthersTxtfiled.text = @"";
    self.Address1Txtfiled.text = @"";
    self.Address2Txtfiled.text = @"";
    self.StateTxtfiled.text = @"";
    self.PostalcodeTxtfiled.text = @"";
    self.TelePhoneTxtfiled.text = @"";
    self.FaxTxtfiled.text = @"";
    self.EmailTxtfiled.text = @"";
    self.SAlesTxtfiled.text = @"";
    self.TerritoryTxtfiled.text = @"";
    self.FormTitleTxtfiled.text = @"";
    self.CategoryString = nil;
    self.ResponseString = nil;
    self.categorybuton1 = nil;
    self.categorybuton2 = nil;
    self.categorybuton3 = nil;
    self.categorybuton4 = nil;
    self.categorybuton5 = nil;
    self.categorybuton6 = nil;
    self.responsemethod1 = nil;
    self.responsemethod2 = nil;
    self.responsemethod3 = nil;
    self.responsemethod4 = nil;
    self.responsemethod5 = nil;
    self.deleteBtn = nil;
    self.formId = @"";
    self.FormObj = nil;
    self.formtitle = @"";
    self.FormTitleTxtfiled.text = @"";
    self.BackGroundScrView = nil;
    self.InformationTxtView.text = @"";
    self.SignatureImage = nil;
    self.SignatureBtn = nil;
    self.pdfFilePath = @"";
    self.SignVC = nil;
    //self.view = nil;
}

@end