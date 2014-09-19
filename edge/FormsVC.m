//
//  FormsVC.m
//  edge
//
//  Created by iPhone Developer on 5/21/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "FormsVC.h"
#import "GenericCell.h"
#import "MIRFormVC.h"
#import "FeedBackVC.h"
#import "MyForm.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "FormsObject.h"
#import "ContentModel.h"
#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]

#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]

@interface FormsVC ()
@property(nonatomic,strong) MIRFormVC * MirView;
@property(nonatomic,strong) FeedBackVC *FeedBKView;
@property(nonatomic,strong) NSMutableArray * formsArray;


@end

@implementation FormsVC
@synthesize scrView,sortingimage,pdfFilePath;

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
    self.formsArray = [[NSMutableArray alloc] init];
	// Do any additional setup after loading the view.
    _FormLabel.font = [UIFont fontWithName:@"StagSans-Book" size:21];
    if ([self.formsArray count]>0)
    {
        _alertImageView.hidden = YES;
    }
    else{
        _alertImageView.hidden = NO;
    }

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getSavedForms];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
   // self.scrView = nil;
    [self.view removeFromSuperview];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark handle actions

- (IBAction) addMirFormBtnTouched
{
    
    self.MirView = [[MIRFormVC alloc] initWithNibName:@"MIRFormVC" bundle:nil];
    // self.MirView = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"MIRFormVC"];
    self.MirView.isNewform = YES;
    
    self.MirView.view.frame = CGRectMake(0, 0, 1024, 768);
    
    [self.view addSubview:self.MirView.view];
    
}

- (IBAction) addFeedbackFormBtnTouched
{
    
    self.FeedBKView = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"FeedBackVCon"];
    
    self.FeedBKView.view.frame = CGRectMake(0, 0, 1024, 768);
    
    [self.view addSubview:self.FeedBKView.view];
}

- (IBAction) mirFormViaEmailBtnTouched
{
    
    [self generatepdf];
    
//    if ([MFMailComposeViewController canSendMail])
//    {
    
        /*
        MFMailComposeViewController *mailView= [[MFMailComposeViewController alloc] init];
        mailView.mailComposeDelegate=self;
        [mailView setSubject:@"MirForm"];
        [mailView setToRecipients:[NSArray arrayWithObject:@"ETH_Medical_Info@its.jnj.com"]];
        //Create a string with HTML formatting for the email body
        NSString * emailBody = [NSString stringWithFormat:@"Name: %@\n Title: %@ \n Institution: %@ \n Others: %@ \n Address1: %@ \n Address2: %@ \n State: %@ \n Zipcode: %@ \n Telephone: %@ \n Category: %@\n Response: %@\n Fax: %@ \n Email: %@ \n Sales: %@ \n Territory: %@ \n Information: %@",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@""];
        [mailView setMessageBody:emailBody isHTML:NO];
        */
//        NSData * imagedata = UIImageJPEGRepresentation(self.SignatureImage.image, 1.0);
//        
//        [mailView addAttachmentData:imagedata mimeType:@"image/png" fileName:@"File"];
        
        //[mailView setToRecipients:[NSArray arrayWithObject:@""]];
        //  [mailView addAttachmentData:myData mimeType:@"application/pdf" fileName:@"JPOP.pdf"];
        //[self presentViewController:mailView animated:YES completion:nil];
        
        
//    }
}


-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        if(result==MFMailComposeResultCancelled)
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Your mail has been cancelled." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        }
        else if (result == MFMailComposeResultSaved)
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Your mail has been saved successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        }
        else if (result==MFMailComposeResultSent)
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Your mail has been sent successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else{
        
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
}


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
 
    if(alertView.tag==15)
	{
        if(buttonIndex==alertView.cancelButtonIndex)
		{
//            if (![pdfFilePath isEqualToString:@"(null)" ] && ![pdfFilePath isEqualToString:@""])
//            {
//                NSFileManager *fileManager = [NSFileManager defaultManager];
//                [fileManager removeItemAtPath:pdfFilePath error:NULL];
//                // //nslog(@"pdfFilePath====%@  fileManager ===%@ ",pdfFilePath,fileManager);
//            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

-(void)getSavedForms
{
    if ([self.formsArray count]>0)
    {
        [self.formsArray removeAllObjects];
    }
    NSManagedObjectContext *context=[APP_DELEGATE managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"MyForm" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
   
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0)
    {
        
        for (NSManagedObject *info in fetchedObjects)
        {
            FormsObject * formdetails = [[FormsObject alloc] init];
            
         
            if ([[info valueForKey:@"name"] isEqualToString:@""])
            {
                formdetails.name = @"";
            }
            else
                formdetails.name = [info valueForKey:@"name"];
            if ([[info valueForKey:@"address"] isEqualToString:@""])
            {
                formdetails.address = @"";
            }
            else
                formdetails.address = [info valueForKey:@"address"];
            if ([[info valueForKey:@"address2"] isEqualToString:@""])
            {
                formdetails.address2 = @"";
            }
            else
                formdetails.address2 = [info valueForKey:@"address2"];
            if ([[info valueForKey:@"choiceOne"] isEqualToString:@""])
            {
                formdetails.choiceOne = @"";
            }
            else
                formdetails.choiceOne = [info valueForKey:@"choiceOne"];
            if ([info valueForKey:@"crtDt"] == nil)
            {
                formdetails.crtDt = nil;
            }
            else
                formdetails.crtDt = [info valueForKey:@"crtDt"];
            if ([[info valueForKey:@"email"] isEqualToString:@""])
            {
                formdetails.email = nil;
            }
            else
                formdetails.email = [info valueForKey:@"email"];
            if ([[info valueForKey:@"fax"] isEqualToString:@""])
            {
                formdetails.fax = @"";
            }
            else
                formdetails.fax = [info valueForKey:@"fax"];
            if ([[info valueForKey:@"institution"] isEqualToString:@""])
            {
                formdetails.institution = @"";
            }
            else
                formdetails.institution = [info valueForKey:@"institution"];
            if ([[info valueForKey:@"phone"] isEqualToString:@""])
            {
                formdetails.phone = @"";
            }
            else
                formdetails.phone = [info valueForKey:@"phone"];
            if ([[info valueForKey:@"others"] isEqualToString:@""])
            {
                formdetails.others = @"";
            }
            else
                formdetails.others = [info valueForKey:@"others"];
            if ([[info valueForKey:@"respMode"] isEqualToString:@""])
            {
                formdetails.respMode = @"";
            }
            else
                formdetails.respMode = [info valueForKey:@"respMode"];
            if ([info valueForKey:@"sbtDt"] == nil)
            {
                formdetails.sbtDt = nil;
            }
            else
                formdetails.sbtDt = [info valueForKey:@"sbtDt"];
            if ([info valueForKey:@"uptDt"] == nil)
            {
                formdetails.uptDt = nil;
            }
            else
                formdetails.uptDt = [info valueForKey:@"uptDt"];
            if ([[info valueForKey:@"state"] isEqualToString:@""])
            {
                formdetails.state = @"";
            }
            else
                formdetails.state = [info valueForKey:@"state"];
            if ([[info valueForKey:@"territory"] isEqualToString:@""])
            {
                formdetails.territory = @"";
            }
            else
                formdetails.territory = [info valueForKey:@"territory"];
            if ([[info valueForKey:@"title"] isEqualToString:@""])
            {
                formdetails.title = @"";
            }
            else
                formdetails.title = [info valueForKey:@"title"];
            if ([[info valueForKey:@"zipCode"] isEqualToString:@""])
            {
                formdetails.zipCode = @"";
            }
            else
                formdetails.zipCode = [info valueForKey:@"zipCode"];
            if ([[info valueForKey:@"formId"] isEqualToString:@""])
            {
                formdetails.formId = @"";
            }
            else
                formdetails.formId = [info valueForKey:@"formId"];
            if ([[info valueForKey:@"formTitle"] isEqualToString:@""])
            {
                formdetails.formTitle = @"";
            }
            else
                formdetails.formTitle = [info valueForKey:@"formTitle"];
            if ([[info valueForKey:@"information"] isEqualToString:@""])
            {
                formdetails.information = @"";
            }
            else
                formdetails.information = [info valueForKey:@"information"];
            if ([[info valueForKey:@"sales"] isEqualToString:@""])
            {
                formdetails.sales = @"";
            }
            else
                formdetails.sales = [info valueForKey:@"sales"];
            
            if ([info valueForKey:@"signature"] == nil)
            {
                formdetails.signature = nil;
            }
            else
                formdetails.signature = [info valueForKey:@"signature"];
            
            [self.formsArray addObject:formdetails];
            
        }
        
    }
    NSArray *subviews=[self.scrView subviews];
    for(int i=0;i<[subviews count];i++)
    {
        UIView *view=[subviews objectAtIndex:i];
        [view removeFromSuperview];
    }
    if ([self.formsArray count]>0)
    {
        [self.alertImageView setHidden:YES];
    [self createscrollview];
    }
    else{
        [self.alertImageView setHidden:NO];
    }

}

-(void)createscrollview
{
    
    int x= 0;
    int y = 50;
    
    UILabel * savedforms = [[UILabel alloc] initWithFrame:CGRectMake(412, 10, 200, 30)];
    savedforms.text = @"Saved MIR Forms";
    savedforms.textColor = [UIColor colorWithRed:77.0f/255.f green:79.0f/255.f blue:83.0f/255.f alpha:1];
    savedforms.textAlignment = NSTextAlignmentCenter;
    [self.scrView addSubview:savedforms];
    
    for (int i=0; i<[self.formsArray count]; i++)
    {
        
        FormsObject * formObj = [self.formsArray objectAtIndex:i];
        UIView *userView=[[UIView alloc] initWithFrame:CGRectMake(x, y, 200, 200)];
        UIImageView *backgroundImgView=[[UIImageView alloc] initWithFrame:CGRectMake(30,10, 137,87)];
        backgroundImgView.image = [UIImage imageNamed:@"form_thumb.png"];
        UIButton * button1 = [[UIButton alloc] initWithFrame:CGRectMake(30, 10, 137, 87)];
        [button1 addTarget:self action:@selector(selectedform:) forControlEvents:UIControlEventTouchUpInside];
        button1.tag = i;
        UILabel * title1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 200, 25)];
        title1.font = [UIFont fontWithName:@"Arial" size:14];
        title1.textAlignment = NSTextAlignmentCenter;
        title1.backgroundColor=[UIColor clearColor];
        title1.text=formObj.formTitle;
        title1.textColor = [UIColor redColor];
        UILabel * Datelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 135, 200, 25)];
        Datelabel.font = [UIFont fontWithName:@"Arial" size:14];
        Datelabel.textAlignment = NSTextAlignmentCenter;
        Datelabel.backgroundColor=[UIColor clearColor];
        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        
        
        Datelabel.text=[dateFormatter stringFromDate:formObj.crtDt];
        Datelabel.textColor = [UIColor colorWithRed:77.0f/255.f green:79.0f/255.f blue:83.0f/255.f alpha:1];
        
        [userView addSubview:backgroundImgView];
        [userView addSubview:title1];
        [userView addSubview:Datelabel];
        [userView addSubview:button1];
        [self.scrView addSubview:userView];
        x=x+200;
        if ((i+1)%5==0)
        {
            x=0;
            y=y+200;
        }
        
        
        
    }
    self.scrView.contentSize=CGSizeMake(1000, y+200);
    if ([self.formsArray count]>0)
    {
        _alertImageView.hidden = YES;
    }
    else{
        _alertImageView.hidden = NO;
    }

}


-(IBAction)selectedform:(id)sender
{
//      self.MirView = [[MIRFormVC alloc] init];
//    self.MirView = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"MIRFormVC"];
//    self.MirView.isNewform = NO;
//    self.MirView.view.frame = CGRectMake(0, 0, 1024, 768);
//    [self.view addSubview:self.MirView.view];
    
    
    self.MirView = [[MIRFormVC alloc] initWithNibName:@"MIRFormVC" bundle:nil];
    // self.MirView = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"MIRFormVC"];
    self.MirView.isNewform = NO;
    
    self.MirView.view.frame = CGRectMake(0, 0, 1024, 768);
    
    [self.view addSubview:self.MirView.view];
     FormsObject * formObj = [self.formsArray objectAtIndex:[sender tag]];
    self.MirView.NameTxtfiled.text = formObj.name;
    self.MirView.OthersTxtfiled.text = formObj.others;
    self.MirView.TitleTxtfiled.text = formObj.title;
    self.MirView.InstitutionTxtfiled.text = formObj.institution;
    self.MirView.Address1Txtfiled.text = formObj.address;
    self.MirView.Address2Txtfiled.text = formObj.address2;
    self.MirView.StateTxtfiled.text = formObj.state;
    self.MirView.PostalcodeTxtfiled.text = formObj.zipCode;
    self.MirView.TelePhoneTxtfiled.text = formObj.phone;
    self.MirView.FaxTxtfiled.text = formObj.fax;
    self.MirView.EmailTxtfiled.text = formObj.email;
    self.MirView.FormTitleTxtfiled.text = formObj.formTitle;
    self.MirView.InformationTxtView.text = formObj.information;
    self.MirView.SAlesTxtfiled.text = formObj.sales;
    self.MirView.TerritoryTxtfiled.text = formObj.territory;
    self.MirView.updatetime = formObj.uptDt;
    self.MirView.formId = formObj.formId;
    self.MirView.formtitle = formObj.formTitle;
    self.MirView.ResponseString = formObj.respMode;
    self.MirView.CategoryString = formObj.choiceOne;
    if (formObj.signature)
    {
        self.MirView.SignatureImage.image = [UIImage imageWithData:formObj.signature];
    }

    if ([formObj.respMode isEqualToString:@"US Mail"])
    {
        [self.MirView.responsemethod1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    else if ([formObj.respMode isEqualToString:@"Phone"])
    {
        [self.MirView.responsemethod2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
    }
    else if ([formObj.respMode isEqualToString:@"Email"])
    {
        [self.MirView.responsemethod3 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    else if ([formObj.respMode isEqualToString:@"Fax"])
    {
        [self.MirView.responsemethod4 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    else
    {
        [self.MirView.responsemethod5 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    
    
    if ([formObj.choiceOne isEqualToString:@"M.D"])
    {
        [self.MirView.categorybuton1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    else if ([formObj.choiceOne isEqualToString:@"D.O"])
    {
        [self.MirView.categorybuton2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    else if ([formObj.choiceOne isEqualToString:@"Pharm D."])
    {
        [self.MirView.categorybuton3 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    else if ([formObj.choiceOne isEqualToString:@"Ph. D"])
    {
        [self.MirView.categorybuton4 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    else if ([formObj.choiceOne isEqualToString:@"R.N"])
    {
        [self.MirView.categorybuton5 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    else
    {
        [self.MirView.categorybuton6 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

    }
    
    
}

-(IBAction)sorting:(id)sender
{
    if ([sender tag]==2)
    {
        self.sortingimage.image = [UIImage imageNamed:@"segment_date.png"];
        
        NSSortDescriptor * formidSort = [[NSSortDescriptor alloc] initWithKey:@"formId" ascending:YES selector:@selector(localizedStandardCompare:)];
        NSMutableArray * sortDescriptor;
        sortDescriptor = [NSMutableArray arrayWithObject:formidSort];
        NSMutableArray * newarray = [[NSMutableArray alloc] init];
        [newarray addObjectsFromArray:(NSMutableArray *)[self.formsArray sortedArrayUsingDescriptors:sortDescriptor]];
        [self.formsArray removeAllObjects];
        for (int k = 0; k<[newarray count]; k++)
        {
            FormsObject * Obj1 = [newarray objectAtIndex:k];
            [self.formsArray addObject:Obj1];
        }
    //    NSArray *subviews=[self.scrView subviews];
//        for(int i=0;i<[subviews count];i++)
//        {
//            UIView *view=[subviews objectAtIndex:i];
//            [view removeFromSuperview];
//        }
       // [self createscrollview];
        
    }
    else
    {
        self.sortingimage.image = [UIImage imageNamed:@"segment_atoz.png"];
        
        
        NSSortDescriptor * formtitlesort = [[NSSortDescriptor alloc] initWithKey:@"formTitle" ascending:YES selector:@selector(localizedStandardCompare:)];
        NSMutableArray * sortDescriptor;
        sortDescriptor = [NSMutableArray arrayWithObject:formtitlesort];
        NSMutableArray * newarray = [[NSMutableArray alloc] init];
        [newarray addObjectsFromArray:(NSMutableArray *)[self.formsArray sortedArrayUsingDescriptors:sortDescriptor]];
        [self.formsArray removeAllObjects];
        for (int k = 0; k<[newarray count]; k++)
        {
            FormsObject * Obj1 = [newarray objectAtIndex:k];
            [self.formsArray addObject:Obj1];
        }
        
       

    }
    NSArray *subviews=[self.scrView subviews];
    for(int i=0;i<[subviews count];i++)
    {
        UIView *view=[subviews objectAtIndex:i];
        [view removeFromSuperview];
    }
    if (self.formsArray.count>0)
    {
        [self createscrollview];
    }
}


-(void)generatepdf
{
    /*int defaultheigth=1400;
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"sampleData1" ofType:@"plist"];
    path = NSTemporaryDirectory();
    
    NSString *filenamestring=@"MIRFORM.pdf";
    
    self.pdfFilePath = [path stringByAppendingPathComponent:filenamestring];
    
    int y=170;
    UIGraphicsBeginPDFContextToFile(self.pdfFilePath, CGRectZero, nil);
    //  //nslog(@"pdfFilePath %@",pdfFilePath);
    
    
    
    UIFont *mainsizeFont= [UIFont boldSystemFontOfSize:20];
    
    
    
    
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
    
    
   // [todaydatestring drawInRect:CGRectMake(700, 10, 500, 20) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentRight];
    NSString * mirformstring = @"Medical Information Request Form";
    
    [mirformstring drawInRect:CGRectMake(700, 40, 500, 20) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentRight];
    
    UIImage * demoImage = [UIImage imageNamed:@"ethicon_logonew.png"];
    [demoImage drawInRect:CGRectMake( 30,40,560,88)];
    
    NSString * salesnamestring = @"Sales Representative:";
    [salesnamestring drawInRect:CGRectMake(50, y, 250, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    
    NSString * terstring = @"Territory:";
    [terstring drawInRect:CGRectMake(750, y, 100, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
     y = y+50;
    NSString * Tostring = @"To:";
    [Tostring drawInRect:CGRectMake(50, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    y= y+50;
    NSString * date = @"Date:";
    [date drawInRect:CGRectMake(50, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    y = y+50;
    NSString * Requestor = @"From (Requestor):";
    [Requestor drawInRect:CGRectMake(50, y, 250, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
 
    
    
    y= y+50;
    NSString * namestring = @"Name:";
    [namestring drawInRect:CGRectMake(50, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    y = y+50;
    NSString * titlestring = @"Title:";
    [titlestring drawInRect:CGRectMake(50, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    NSString * institutionstring = @"Institution/Office:";
    [institutionstring drawInRect:CGRectMake(550, y, 200, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    y = y+50;
    NSString * catstring = @"Degree:";
    [catstring drawInRect:CGRectMake(50, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    NSString * otherstring = @"Others:";
    [otherstring drawInRect:CGRectMake(550, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    y = y+50;
    NSString * address1tring = @"Address:";
    [address1tring drawInRect:CGRectMake(50, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    y = y+50;
     NSString * address2tring = @"City:";
    [address2tring drawInRect:CGRectMake(50, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
   
    
    NSString * staterstring = @"State:";
    [staterstring drawInRect:CGRectMake(550, y, 80, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    NSString * zipstring = @"Zip:";
    [zipstring drawInRect:CGRectMake(850, y, 120, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    y = y+50;
    NSString * telestring = @"Telephone:";
    [telestring drawInRect:CGRectMake(50, y, 150, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    NSString * faxstring = @"Fax:";
    [faxstring drawInRect:CGRectMake(400, y, 70, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    NSString * emailstring = @"Email:";
    [emailstring drawInRect:CGRectMake(650, y, 80, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    y = y+50;
    NSString * responsestring = @"Desired response method:";
    [responsestring drawInRect:CGRectMake(50, y, 300, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    
    
    y= y+80;
    NSString * sigstring = @"Requestor's Signature:";
    [sigstring drawInRect:CGRectMake(50, y, 300, 30) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    UIImage * demoImage1 = [UIImage imageNamed:@"signature_box.png"];
    [demoImage1 drawInRect:CGRectMake(395,y-25,373,94)];
    
    
    y=y+90;
    
    //UIImage * emptybox = [UIImage imageNamed:@"emptybox_800x400.png"];
    UIImage * emptybox = [UIImage imageNamed:@"emptybox.png"];
    [emptybox drawInRect:CGRectMake(100,y,1000,400)];
    
    y= y+5;
    NSString * infostring = [NSString stringWithFormat:@"%@\n%@",@"Please send medical information on the following topic(s):",@"(Be as specific as possible with respect to product topic, area of use, outcome of interest etc.)"];

    [infostring drawInRect:CGRectMake(100, y, 1000, 60) withFont:mainsizeFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentCenter];
    
    
    
    UIGraphicsEndPDFContext();*/
    
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
        mailView.mailComposeDelegate = self;
        [mailView setSubject:@"MIRFORM"];
        
        NSString *filenamestring=@"MIRFORM.pdf";

         //wasnt sending pdf as attachment --
         pdfFilePath = [NSString stringWithFormat:@"%@%@",DocumentsDirectory,[self.appDelegate getAppContentPath:@"blank_mir_form"]];
         //pdfFilePath = [NSString stringWithFormat:@"%@%@",DocumentsDirectory,[self.appDelegate getMirformPdf]];
         
         NSLog(@"pdfFilePath = %@", pdfFilePath);
         
         NSData *pdfData = [NSData dataWithContentsOfFile:pdfFilePath];
         [mailView setToRecipients:[NSArray arrayWithObject:@""]];
         [mailView addAttachmentData:pdfData mimeType:@"application/pdf" fileName:filenamestring];
        
        /*
        //Get filepaths
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        // Get documents folder
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/assets/content/pstoolappcontent/blank_mir_form.pdf"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        {
            NSLog(@"datapath exists: %@", dataPath);
        }
        
        NSLog(@"[[path pathComponents] lastObject] = %@", [[dataPath pathComponents] lastObject]);
        pdfFilePath = dataPath;
       
        NSLog(@"pdfFilePath = %@", pdfFilePath);
        
        NSData *pdfData = [NSData dataWithContentsOfFile:pdfFilePath];
        
        //add recipients and the pdf attachment
        [mailView setToRecipients:[NSArray arrayWithObject:@""]];
        [mailView addAttachmentData:pdfData mimeType:@"application/pdf" fileName:filenamestring];*/
        
        //get logo and convert to nsdata
        UIImage *logoImage = [UIImage imageNamed:@"logo_email.png"];
        NSData *imagedata =  UIImageJPEGRepresentation(logoImage, 1.0);
        // NSData * emaildata = UIImageJPEGRepresentation(entryimage.image, 1.0);
        
        //add logo to email as attachment
        [mailView addAttachmentData:imagedata mimeType:@"image/png" fileName:@"File"];
        
        NSString *emailstring = @" <html> <head> <link rel='stylesheet' type='text/css' media='all' href='http://m.eprodevbox.com/assets/email_templates/style.css' /> </head> <body> <p>As requested, enclosed is a blank 'Medical Information Request' form. Please fill and fax it to the below number. Alternatively, you can also call our toll free number and make this request.</p><br></br><br></br><p>Ethicon</p><p>Medical Information Request</p><p>Toll Free: 800-888-9234 x3800</p><p>Fax: (800) 372-7112</p>Thank you,<p><p>{{First Name}} {{Last Name}}</p> <footer> <div class='wrap'> <p class='notice'> <span>Confidentiality Notice:</span>This e-mail transmission may contain confidential or legally privileged information that is intended only for the individual or entity named in the e-mail address. If you are not the intended recipient, you are hereby notified that any disclosure, copying, distribution, or reliance upon the contents of this e-mail is strictly prohibited. If you have received this e-mail transmission in error, please reply to the sender, so that J&J can arrange for proper delivery, and then please delete the message from your inbox. </p> </div> </footer></body> </html>";
         emailstring = [emailstring stringByReplacingOccurrencesOfString:@"http://m.eprodevbox.com" withString:WEB_SERVICE_BASE_SERVER];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        emailstring = [emailstring stringByReplacingOccurrencesOfString:@"{{First Name}}" withString:[userDefaults objectForKey:@"firstName"]];
        emailstring = [emailstring stringByReplacingOccurrencesOfString:@"{{Last Name}}" withString:[userDefaults objectForKey:@"lastName"]];
        
        [mailView setMessageBody:emailstring isHTML:YES];
        // [mailView addAttachmentData:myData mimeType:@"application/pdf" fileName:@"JPOP.pdf"];
        [self presentViewController:mailView animated:YES completion:nil];
    }
    
      //  QLPreviewController* preview = [[QLPreviewController alloc] init];
      //  preview.dataSource = self;
      //  preview.delegate = self;
      //  [self presentViewController:preview animated:YES completion:nil];
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




@end
