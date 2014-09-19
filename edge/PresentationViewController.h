//
//  PresentationViewController.h
//  edge
//
//  Created by Vijaykumar on 7/8/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyMovieViewController.h"
#import "DrawVC.h"

@interface PresentationViewController : UIViewController

@property (atomic, strong) NSDictionary* presentations;
@property (atomic, strong) NSArray* prstCntIds;
@property (strong, nonatomic) NSMutableDictionary *viewControllers ;

@property (atomic, assign) int counter;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet MyMovieViewController* myMovieViewController;
@property (atomic,strong) NSString* filePath;
@property (nonatomic, strong) DrawVC *drawView;
@property (nonatomic,readwrite) BOOL isSeleted;
@property (nonatomic,strong) IBOutlet UIButton * leftBtn;
@property (nonatomic,strong) IBOutlet UIButton * rigthbtn;


- (void) loadPresentations : (NSMutableArray*) parsedObject;
-(IBAction)drawToolButtonClicked:(id)sender;

@end