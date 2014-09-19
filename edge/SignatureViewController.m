//
//  SignatureViewController.m
//  JPOP
//
//  Created by Varma Bhupatiraju on 5/20/13.
//  Copyright (c) 2013 Varma Bhupatiraju. All rights reserved.
//
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#import "SignatureViewController.h"
#import <QuartzCore/CoreAnimation.h>
#import <QuartzCore/QuartzCore.h>
#import "MIRFormVC.h"


@interface SignatureViewController ()

@end

@implementation SignatureViewController
@synthesize drawSignView,mainImage,tempDrawImage;

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
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    //by goutham may20
    if (appDelegate.SignatureImage)
    {
        self.mainImage.image = appDelegate.SignatureImage;
        self.tempDrawImage.image = appDelegate.SignatureImage;
        
    }
    
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    opacity = 1.0;
    brush = 2.2;
    
    /////========
    
}

- (void)viewDidUnload
{
    [self setMainImage:nil];
    [self setTempDrawImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(IBAction)saveButtonAction:(id)sender
{
    UIGraphicsBeginImageContextWithOptions(self.mainImage.bounds.size, NO, 0.0);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height)];
    UIImage *saveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    appDelegate.SignatureImage=saveImage;
    //    MIRFormVC* mySuperView =  (MIRFormVC*) self.view.superview ;
    //    mySuperView.SignatureImage.image = saveImage;
    
    [self.delegate AddSignature];
    [self.view removeFromSuperview];
    
    
    
    
    //  NSData *imageData = UIImageJPEGRepresentation(saveImage,0.75);
    
    
    // //nslog(@"signatureImageView ==%@",appDelegate.detailviewcontroller.signatureImageView.image);
    
    // appDelegate.detailviewcontroller.isSaved=NO;
    // [appDelegate.detailviewcontroller.popoverController dismissPopoverAnimated:YES];
    
}
-(IBAction)cancelButtonAction:(id)sender
{
    // [appDelegate.detailviewcontroller.popoverController dismissPopoverAnimated:YES];
    self.mainImage.image = nil;
    appDelegate.SignatureImage = nil;
    [self.view removeFromSuperview];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    //lastPoint = [touch locationInView:self.view];
    lastPoint = [touch locationInView:self.drawSignView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    //CGPoint currentPoint = [touch locationInView:self.view];
    CGPoint currentPoint = [touch locationInView:self.drawSignView];
    
    //UIGraphicsBeginImageContext(self.view.frame.size);
    UIGraphicsBeginImageContext(self.drawSignView.frame.size);
    
    
    //[self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.drawSignView.frame.size.width, self.drawSignView.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempDrawImage setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(!mouseSwiped)
    {
        //UIGraphicsBeginImageContext(self.view.frame.size);
        UIGraphicsBeginImageContext(self.drawSignView.frame.size);
        
        
        //[self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.drawSignView.frame.size.width, self.drawSignView.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContext(self.mainImage.frame.size);
    //[self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.drawSignView.frame.size.width, self.drawSignView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    
    
    //[self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.drawSignView.frame.size.width, self.drawSignView.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempDrawImage.image = nil;
    UIGraphicsEndImageContext();
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
