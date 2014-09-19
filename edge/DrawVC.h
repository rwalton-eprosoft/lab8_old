//
//  DrawVC.h
//  edge
//
//  Created by Vijaykumar on 6/22/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawView.h"
#import "BrushView.h"

@protocol DrawVCDelegate <NSObject>

- (void) drawToolRemoved;

@end

@interface DrawVC : UIViewController
{
    BOOL isWhiteCanvas;
}
@property (strong, nonatomic) IBOutlet DrawView *drawView;

@property (nonatomic, weak) id<DrawVCDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIView *drawControlView;

@property (nonatomic, retain) UIColor *color;
@property(atomic, retain) UIPopoverController* activePopover;
@property(atomic, retain) UIPopoverController* brushViewController;

@property (strong, nonatomic) IBOutlet UIView *mainDrawControlView;
@property (strong, nonatomic) IBOutlet UIView *topDrawControlView;
@property (strong, nonatomic) IBOutlet UIView *bottomDrawControlView;
@property (strong, nonatomic) IBOutlet UIView *middleDrawControlView;
@property(atomic, assign) IBOutlet UIButton * CloseButton;

//// Manoj.

@property ( strong, nonatomic) IBOutlet UIImageView * DrawToolImageview;
@property ( strong, nonatomic) IBOutlet UILabel * selectedcolor;
@property ( strong, nonatomic) IBOutlet UILabel * selectedpencil;
@property ( strong, nonatomic) IBOutlet UILabel * selectederaser;

@property (strong, nonatomic) IBOutlet UIView *PencilView;
@property (strong, nonatomic) IBOutlet UIView *ColorView;
@property (strong, nonatomic) IBOutlet UIView *EraseView;

@property (nonatomic,readwrite) BOOL IsPencilViewThere;
@property (nonatomic,readwrite) BOOL IsColorViewThere;
@property (nonatomic,readwrite) BOOL IsEraseViewThere;



-(IBAction)ShowPencilView:(id)sender;
-(IBAction)ShowcolorsView:(id)sender;
-(IBAction)ShowEraseView:(id)sender;


/// --- Manoj



- (void) removeFromSuperView;
@property (strong, nonatomic) IBOutlet UIView *drawToolBoxArrowView;

@end