//
//  RootViewController.h
//  edge
//
//  Created by Vijaykumar on 8/22/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarViewController.h"
#import "UpdateNotify.h"

@class TabBarViewController;
@protocol RootVCDelegate <NSObject>

-(void)syncButtonStatus:(BOOL)isthere;

@end

@interface RootViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<RootVCDelegate> delegate1;

@property (nonatomic, retain) NSArray *contentSyncList;
@property (nonatomic, retain) UIPopoverController *popover;
@property (nonatomic, retain) TabBarViewController *delegate;
@property (strong, nonatomic) IBOutlet UITableView *contentSyncOption;

-(IBAction)closeButton:(id)sender;
- (void)invokeDiagnosticsViewController;

- (IBAction)syncButn:(id)sender;

@end
