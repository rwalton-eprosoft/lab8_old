//
//  FeedBackVC.m
//  edge
//
//  Created by EAI-WKS-00011 on 8/9/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "FeedBackVC.h"
#import "TrackingModel.h"


@interface FeedBackVC ()

@property (nonatomic,strong) IBOutlet UITextField * NameTxtfiled;
@property (nonatomic,strong) IBOutlet UITextField * LastNameTxtfiled;
@property (nonatomic,strong) IBOutlet UILabel * SubAreaTxtfiled;
@property (nonatomic,strong) IBOutlet UITextView * MessageTxtfiled;
@property (nonatomic,strong) IBOutlet UITableView * SubTbleView;
@property (nonatomic,strong) NSMutableArray * SubAreaArray;


@end

@implementation FeedBackVC

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
    self.SubTbleView.hidden = YES;
   
    self.SubAreaArray = [[NSMutableArray alloc] initWithObjects:@"Insights",@"Suggestions",@"Ideas",@"Requirements Enhancements",@"Share Experience", @"Request additional content", nil];
    [self.SubTbleView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    self.SubTbleView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.SubTbleView.layer.cornerRadius = 7;
    self.SubTbleView.layer.masksToBounds = YES;
    self.SubTbleView.layer.borderWidth = 1.0f;
    
    //
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *firstStr;
    NSString *secStr;
    firstStr = [userDefaults objectForKey:@"firstName"];
    secStr = [userDefaults objectForKey:@"lastName"];
    
    self.NameTxtfiled.text = firstStr;
    self.LastNameTxtfiled.text = secStr;
    
    self.NameTxtfiled.userInteractionEnabled = NO;
    self.LastNameTxtfiled.userInteractionEnabled = NO;

    
    
    // Do any additional setup after loading the view from its nib.
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.view removeFromSuperview];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)SendBtnPressed:(id)sender
{
    
    if ([self.NameTxtfiled.text isEqualToString:@""] || [self.LastNameTxtfiled.text isEqualToString:@""] || [self.MessageTxtfiled.text isEqualToString:@""] || [self.SubAreaTxtfiled.text isEqualToString:@""])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please enter all the fields" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //alert.backgroundColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
        alert.delegate=nil;
        [alert show];
    }
    else
    {
        if (self.MessageTxtfiled.text.length > 2000)
        {
             UIAlertView * limitalert = [[UIAlertView alloc] initWithTitle:@"" message:@"Characters should not exceed 2000" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"", nil];
            [limitalert show];
        }
       
        else
        {
            if ([MFMailComposeViewController canSendMail])
            {
                if ([self.SubAreaTxtfiled.text isEqualToString:@ "Request additional content"])
                {
                    NSString *formattedMessage;

                    formattedMessage = [self.MessageTxtfiled.text stringByReplacingOccurrencesOfString:@": \n" withString:@":<p>"];
                    formattedMessage = [self.MessageTxtfiled.text stringByReplacingOccurrencesOfString:@"\n" withString:@"<p>"];

                    MFMailComposeViewController *mailView= [[MFMailComposeViewController alloc] init];
                    mailView.mailComposeDelegate=self;
                    [mailView setSubject:@"Feedback"];
                    [mailView setToRecipients:[NSArray arrayWithObject:@"RA-Ethus-totalaccess@its.jnj.com"]];
                    NSString *emailBody = @"<html> <head> <link rel='stylesheet' type='text/css' media='all' href='http://m.eprodevbox.com/assets/email_templates/style.css' /> </head> <body> <div class='wrap'> <span class='greeting'><span style='color:black;'>Hello,</span></span> <p>Please find my feedback provided below.</p> </div> <div class='hr'></div> <div class='wrap'> <table><tr> <td><span class='name'>Sub Area:</span></td> <td><div class='feedback'>{{Sub Area}}</div></td> </tr> <tr> <td><span class='name'>Message:</span></td> <td><div class='feedback'>{{Message}}</div></td> </tr> </table> </div> <div class='hr'></div> <div class='wrap'> <p>Sincerely,</p> <span class='name'>{{First Name}} {{Last Name}}</span> <br/><br/> <div><img src='http://m.eprodevbox.com/assets/email_templates/logo.png'/></div> </div> <br/> <div class='hr'></div> <footer> <div class='wrap'> <p class='notice'> <span>Confidentiality Notice:</span>This e-mail transmission may contain confidential or legally privileged information that is intended only for the individual or entity named in the e-mail address. If you are not the intended recipient, you are hereby notified that any disclosure, copying, distribution, or reliance upon the contents of this e-mail is strictly prohibited. If you have received this e-mail transmission in error, please reply to the sender, so that J&J can arrange for proper delivery, and then please delete the message from your inbox. </p> </div> </footer> </body></html>";
                     emailBody = [emailBody stringByReplacingOccurrencesOfString:@"http://m.eprodevbox.com" withString:WEB_SERVICE_BASE_SERVER];
                    emailBody = [emailBody stringByReplacingOccurrencesOfString:@"{{First Name}}" withString:self.NameTxtfiled.text];
                    emailBody = [emailBody stringByReplacingOccurrencesOfString:@"{{Last Name}}" withString:self.LastNameTxtfiled.text];
                    emailBody = [emailBody stringByReplacingOccurrencesOfString:@"{{Sub Area}}" withString:self.SubAreaTxtfiled.text];
                    emailBody = [emailBody stringByReplacingOccurrencesOfString:@"{{Message}}" withString:formattedMessage];
                    
                    [mailView setMessageBody:emailBody isHTML:YES];
                    [mailView setToRecipients:[NSArray arrayWithObject:@""]];
                    
                    [self presentViewController:mailView animated:YES completion:nil];
                }
                else
                {
                    MFMailComposeViewController *mailView= [[MFMailComposeViewController alloc] init];
                    mailView.mailComposeDelegate=self;
                    [mailView setSubject:@"Feedback"];
                    [mailView setToRecipients:[NSArray arrayWithObject:@"RA-Ethus-totalaccess@its.jnj.com"]];
                    NSString *emailBody = @"<html> <head> <link rel='stylesheet' type='text/css' media='all' href='http://m.eprodevbox.com/assets/email_templates/style.css' /> </head> <body> <div class='wrap'> <span class='greeting'><span style='color:black;'>Hello,</span></span> <p>Please find my feedback provided below.</p> </div> <div class='hr'></div> <div class='wrap'> <table><tr> <td><span class='name'>Sub Area:</span></td> <td><div class='feedback'>{{Sub Area}}</div></td> </tr> <tr> <td><span class='name'>Message:</span></td> <td><div class='feedback'>{{Message}}</div></td> </tr> </table> </div> <div class='hr'></div> <div class='wrap'> <p>Sincerely,</p> <span class='name'>{{First Name}} {{Last Name}}</span> <br/><br/> <div><img src='http://m.eprodevbox.com/assets/email_templates/logo.png'/></div> </div> <br/> <div class='hr'></div> <footer> <div class='wrap'> <p class='notice'> <span>Confidentiality Notice:</span>This e-mail transmission may contain confidential or legally privileged information that is intended only for the individual or entity named in the e-mail address. If you are not the intended recipient, you are hereby notified that any disclosure, copying, distribution, or reliance upon the contents of this e-mail is strictly prohibited. If you have received this e-mail transmission in error, please reply to the sender, so that J&J can arrange for proper delivery, and then please delete the message from your inbox. </p> </div> </footer> </body></html>";
                     emailBody = [emailBody stringByReplacingOccurrencesOfString:@"http://m.eprodevbox.com" withString:WEB_SERVICE_BASE_SERVER];
                    emailBody = [emailBody stringByReplacingOccurrencesOfString:@"{{First Name}}" withString:self.NameTxtfiled.text];
                    emailBody = [emailBody stringByReplacingOccurrencesOfString:@"{{Last Name}}" withString:self.LastNameTxtfiled.text];
                    emailBody = [emailBody stringByReplacingOccurrencesOfString:@"{{Sub Area}}" withString:self.SubAreaTxtfiled.text];
                    emailBody = [emailBody stringByReplacingOccurrencesOfString:@"{{Message}}" withString:self.MessageTxtfiled.text];
                    
                    
                    //Create a string with HTML formatting for the email body
                    //  NSString * emailBody2 =  [NSString stringWithFormat:@"First Name: %@ \n Last Name: %@ \n Sub Area: %@  \n Message: %@ ",self.NameTxtfiled.text,self.LastNameTxtfiled.text,self.SubAreaTxtfiled.text,self.MessageTxtfiled.text];
                    [mailView setMessageBody:emailBody isHTML:YES];
                    
                    [mailView setToRecipients:[NSArray arrayWithObject:@""]];
                    //  [mailView addAttachmentData:myData mimeType:@"application/pdf" fileName:@"JPOP.pdf"];
                    [self presentViewController:mailView animated:YES completion:nil];
                    
                    
                    
                }
            }
        }
        
        
        
    }
    
    
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //[self becomeFirstResponder];
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
    }
    else if (result==MFMailComposeResultSent)
    {
          [[TrackingModel sharedInstance] createTrackingDataWithResource:@"Feedback Form" activityCode:TRACKING_ACTIVITY_SUBMITTED_FEEDBACK_FORM];
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
            [self.view removeFromSuperview];
        }
    }
}
-(IBAction)CloseBtnPressed:(id)sender
{
     [self.view removeFromSuperview];
}

-(IBAction)SubAreaBtnPressed:(id)sender
{
//    self.SubTbleView.frame = CGRectMake(608,407, 200, 150);
//  
//    [self.view addSubview:self.SubTbleView];
//    [self.view bringSubviewToFront:self.SubTbleView];
    self.SubTbleView.hidden = NO;
}


# pragma mark - Textfiled methods

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    [theTextField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

# pragma mark - Textviews methods

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView.tag==10)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0.3];
        CGRect rect = self.view.frame;
        rect.origin.y = -200;
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
        
    }
    if ([text length] == 0){
        return YES;
    }else{
        NSUInteger newLength = [textView.text length] + [text length] - range.length;
        return (newLength > 2000) ? NO : YES;
      //  int length = [textView.text length];
        
    }
    return YES;
	
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.tag==10)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0.0];
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

# pragma mark - Tableview methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.SubAreaArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [self.SubAreaArray objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:79.0f/255.0f blue:83.0f/255.0f alpha:1];
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     self.SubTbleView.hidden = YES;
    self.SubAreaTxtfiled.text = [self.SubAreaArray objectAtIndex:indexPath.row];
    if ([self.SubAreaTxtfiled.text isEqualToString:@ "Request additional content"])
    {
        self.MessageTxtfiled.text = @"Please fill below form to request additional collaterals to be added into Ethicon Total Access: \nName of Collateral: \nSpecialty and Procedure: \nCollateral Type (such as vacpak, videos etc): \nCurrent location of Collateral: ";
        
    }
    else
    {
        self.MessageTxtfiled.text = nil;
    }
   
}

@end
