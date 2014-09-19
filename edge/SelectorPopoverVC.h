//
//  SelectorVC.h
//  edge
//
//  Created by iPhone Developer on 6/13/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopoverDismissor.h"

@protocol SelectorPopoverDelegate <NSObject>

- (void) itemSelectedWithIndex:(int)index tag:(int)tag;

@end


@interface SelectorPopoverVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *popoverTitle;
@property (nonatomic, weak) id<SelectorPopoverDelegate> selectorDelegate;
@property (nonatomic, weak) id <PopoverDismissor> popoverDelegate;

@property (nonatomic, assign) int tag;
@property (nonatomic, weak) NSArray *items;
@property (nonatomic, assign) int selectedItemIndex;

- (IBAction) cancelBtnTouched;

@end
