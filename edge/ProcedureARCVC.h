//
//  ProcedureARCVC.h
//  edge
//
//  Created by Jerry Walton on 10/1/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "BaseVC.h"

/*
Outline border colors
Red :
R : 237
G : 28
B : 26

Orange :
R : 239
G : 112
B : 33

Yellow :
R : 228
G : 160
B : 0
 */
#define OUTLINE_RED         [UIColor colorWithRed:237/255.f green:28/255.f blue:26/255.f alpha:1.0]
#define OUTLINE_ORANGE      [UIColor colorWithRed:239/255.f green:112/255.f blue:33/255.f alpha:1.0]
#define OUTLINE_YELLOW      [UIColor colorWithRed:228/255.f green:160/255.f blue:0 alpha:1.0]

#define TAG_ACTION_SHEET_SPECIALTY      1990
#define TAG_ACTION_SHEET_PROCEDURE      1991

@interface ProcedureARCVC : BaseVC <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UIView *accessBackView;
@property (nonatomic, strong) IBOutlet UIView *accessSlideView;
@property (nonatomic, strong) IBOutlet UIView *accessOpenHandleView;
@property (nonatomic, strong) IBOutlet UIView *accessCloseHandleView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *accessSlideConstraint;
@property (nonatomic, strong) IBOutlet UITableView *accessStepTbl;
@property (nonatomic, strong) IBOutlet UITableView *accessConcernTbl;
@property (nonatomic, strong) IBOutlet UICollectionView *accessColView;
@property (nonatomic, strong) IBOutlet UIPageControl *accessPageCtl;

@property (nonatomic, strong) IBOutlet UIView *repairBackView;
@property (nonatomic, strong) IBOutlet UIView *repairSlideView;
@property (nonatomic, strong) IBOutlet UIView *repairOpenHandleView;
@property (nonatomic, strong) IBOutlet UIView *repairCloseHandleView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *repairSlideConstraint;
@property (nonatomic, strong) IBOutlet UITableView *repairStepTbl;
@property (nonatomic, strong) IBOutlet UITableView *repairConcernTbl;
@property (nonatomic, strong) IBOutlet UICollectionView *repairColView;
@property (nonatomic, strong) IBOutlet UIPageControl *repairPageCtl;

@property (nonatomic, strong) IBOutlet UIView *closureBackView;
@property (nonatomic, strong) IBOutlet UIView *closureSlideView;
@property (nonatomic, strong) IBOutlet UIView *closureOpenHandleView;
@property (nonatomic, strong) IBOutlet UIView *closureCloseHandleView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *closureSlideConstraint;
@property (nonatomic, strong) IBOutlet UITableView *closureStepTbl;
@property (nonatomic, strong) IBOutlet UITableView *closureConcernTbl;
@property (nonatomic, strong) IBOutlet UICollectionView *closureColView;
@property (nonatomic, strong) IBOutlet UIPageControl *closurePageCtl;

@property (nonatomic, strong) IBOutlet UILabel *titleLbl;

@property (nonatomic, strong) IBOutlet UITextView *accessTextView;
@property (nonatomic, strong) IBOutlet UITextView *repairTextView;
@property (nonatomic, strong) IBOutlet UITextView *closureTextView;




// per Satish, disable Specialty,Procedure menus for now (10/09/13, jw)
//@property (nonatomic, strong) IBOutlet UIButton *specialtyMenuBtn;
//@property (nonatomic, strong) IBOutlet UIButton *procedureMenuBtn;

- (IBAction) backBtnTouched;
//- (IBAction) specialtyMenuBtnTouched;
//- (IBAction) procedureMenuBtnTouched;

@end
