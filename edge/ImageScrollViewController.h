//
//  ImageScrollViewController.h
//  edge
//
//  Created by EAI-WKS-00011 on 10/29/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawVC.h"

@interface ImageScrollViewController : UIViewController<UIScrollViewDelegate>
{
    IBOutlet UIButton * leftButton;
    IBOutlet UIButton * rigthButton;
}


@property (nonatomic,weak) IBOutlet UIImageView * LargeIMGView;
@property (nonatomic,weak) IBOutlet UIScrollView * ListScrView;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView * Spinner;

@property (nonatomic,strong) NSArray *pathsarray;
@property (nonatomic,strong) NSString * Imagepaths;
@property (nonatomic,retain) NSString * currentPath;
@property (nonatomic,readwrite) int selectedindex;
@property (nonatomic, strong) DrawVC *drawView;

-(void)showimage:(NSString *)path;
- (IBAction)closeButtonTouched:(id)sender;
-(IBAction)drawToolButtonClicked:(id)sender;
-(void)createscrollview;
-(IBAction)ImageBtnpressed:(id)sender;

-(IBAction)pushright:(id)sender;
-(IBAction)pushleft:(id)sender;

@end
