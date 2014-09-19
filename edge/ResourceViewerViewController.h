//
//  ResourceViewerViewController.h
//  edgesync
//
//  Created by Vijaykumar on 6/29/13.
//  Copyright (c) 2013 eprosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFScrollView.h"
#import "MyMovieViewController.h"
#import "DrawVC.h"
#import <PDFTouch/PDFTouch.h>
#import "AppDelegate.h"

@interface ResourceViewerViewController : UIViewController<UIWebViewDelegate>
{
    BOOL Isfullpath;
}

@property (atomic,strong) NSString* filePath;
@property (nonatomic, strong) AppDelegate * appdelegate;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * Spinner;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) IBOutlet PDFScrollView *pdfScrollView;
@property (nonatomic, retain) IBOutlet MyMovieViewController* myMovieViewController;

@property (nonatomic, strong) DrawVC *drawView;
@property (nonatomic, readonly) YLDocument *document;

- (void) play;
-(void)loadExternalurl;
-(void)loadrefernce;

@end
