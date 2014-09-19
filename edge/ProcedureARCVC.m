//
//  ProcedureARCVC.m
//  edge
//
//  Created by Jerry Walton on 10/1/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ProcedureARCVC.h"
#import "AppDelegate.h"
#import "ProcedureARCGridCell.h"
#import "ContentModel.h"
#import "ProcedureModel.h"
#import "DashboardModel.h"
#import "Procedure.h"
#import "Speciality.h"
#import "ProcedureStep.h"
#import "Concern.h"
#import "Product.h"
#import "Content.h"
#import "TrackingModel.h"

@interface ProcedureARCVC ()
@property (nonatomic, strong) NSMutableArray *accessArcSteps;
@property (nonatomic, strong) NSMutableArray *repairArcSteps;
@property (nonatomic, strong) NSMutableArray *closureArcSteps;
@property (nonatomic, strong) NSMutableArray *accessConcerns;
@property (nonatomic, strong) NSMutableArray *repairConcerns;
@property (nonatomic, strong) NSMutableArray *closureConcerns;

@property (nonatomic, strong) NSArray *accessProducts;
@property (nonatomic, strong) NSArray *accessProductIdsForSelectedConcern;
@property (nonatomic, strong) NSArray *repairProducts;
@property (nonatomic, strong) NSArray *repairProductIdsForSelectedConcern;
@property (nonatomic, strong) NSArray *closureProducts;
@property (nonatomic, strong) NSArray *closureProductIdsForSelectedConcern;

@property (nonatomic, strong) NSNumber *splId;
@property (nonatomic, strong) NSNumber *procId;
@property (nonatomic, strong) NSNumber *accessSelectedConcernId;
@property (nonatomic, strong) NSNumber *repairSelectedConcernId;
@property (nonatomic, strong) NSNumber *closureSelectedConcernId;

@end

@implementation ProcedureARCVC
{
    BOOL pageControlBeingUsed;
    BOOL backbuttonTouched;
    BOOL isGoingToDetailView;
    BOOL backFromDetail;


}

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
	// Do any additional setup after loading the view.
    _titleLbl.font = [UIFont fontWithName:@"StagSans-Book" size:21];
    [self configLayerForViews];
    
    [self setupSlideEffectsWithOpenView:self.accessOpenHandleView closeView:self.accessCloseHandleView];
    [self setupSlideEffectsWithOpenView:self.repairOpenHandleView closeView:self.repairCloseHandleView];
    [self setupSlideEffectsWithOpenView:self.closureOpenHandleView closeView:self.closureCloseHandleView];
    
    [self updateMenus];
    
    //[self dumpData];
    [self loadStepsAndConcerns];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[DashboardModel sharedInstance] setCurrentProductProcedureFlow:nil];
    self.accessConcernTbl.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.repairConcernTbl.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.closureConcernTbl.separatorStyle = UITableViewCellSeparatorStyleNone;
    /*
    self.accessTextView.text = [NSString stringWithFormat:@"Solutions that may address the specific challenges for:\n\n\u2022 Entry\n\u2022 Visualization\n\u2022 Dissection"];
    self.repairTextView.text = [NSString stringWithFormat:@"Solutions that may help:\n\n\u2022 Avoid damage to surrounding tissues\n\u2022 Provide effective hemostasis"];
    self.closureTextView.text = [NSString stringWithFormat:@"Solutions that may help optimize the healing process by:\n\n\u2022 Providing strength and support to maintain tissue integrity\n\u2022 Minimize surgical site infection (SSI)\n\u2022 Minimize tissue trauma"];
     */
    self.accessTextView = nil;
    self.repairTextView = nil;
    self.closureTextView = nil;
    isGoingToDetailView = NO;

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (!backbuttonTouched && !isGoingToDetailView)
    {
        [self.navigationController popViewControllerAnimated:YES];
        //NSLog(@"Leaving without Backbutton touched");
        
        backbuttonTouched = NO;
        isGoingToDetailView = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
        
    }
    else if (!backbuttonTouched && backFromDetail)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - handle actions

- (IBAction) backBtnTouched
{
    [self.navigationController popViewControllerAnimated:YES];
    backbuttonTouched = YES;

}

- (void) updateMenus
{
    NSString *sn = [[[DashboardModel sharedInstance] currentSpeciality] name];
    NSNumber *pid = [[[DashboardModel sharedInstance] currentProcedure] procId];
    NSString *pn = [[[DashboardModel sharedInstance] currentProcedure] name];
    
    self.titleLbl.text = [NSString stringWithFormat:@"%@ - %@", sn, pn];
    
    NSString *tempStr = [NSString stringWithFormat:@"%@:%@", pid, pn];
    [[TrackingModel sharedInstance] createTrackingDataWithResource:tempStr activityCode:TRACKING_ACTIVITY_VIEWED_PROCEDURE_ARC];
    
    //NSLog(@"TRACKING ARC for %@", tempStr);
    
//    [self.specialtyMenuBtn setTitle:[[[DashboardModel sharedInstance] currentSpeciality] name] forState:UIControlStateNormal];
//    [self.procedureMenuBtn setTitle:[[[DashboardModel sharedInstance] currentProcedure] name] forState:UIControlStateNormal];
}

/*
- (IBAction) specialtyMenuBtnTouched
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                              delegate: self
                                                     cancelButtonTitle: nil
                                                destructiveButtonTitle: nil
                                                     otherButtonTitles: nil];
    
    actionSheet.tag = TAG_ACTION_SHEET_SPECIALTY;
    
    NSArray *specialties = [[DashboardModel sharedInstance] specialities];
    
    for (Speciality *specialty in specialties)
    {
        [actionSheet addButtonWithTitle:specialty.name];
    }
    
    CGRect frame = [self.view convertRect:self.specialtyMenuBtn.frame toView:self.view];
    [actionSheet showFromRect:frame inView:self.view animated:YES];
    
}
 */

/*
- (IBAction) procedureMenuBtnTouched
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                              delegate: self
                                                     cancelButtonTitle: nil
                                                destructiveButtonTitle: nil
                                                     otherButtonTitles: nil];
    actionSheet.tag = TAG_ACTION_SHEET_PROCEDURE;
    
    NSArray *procedures = [[[[DashboardModel sharedInstance] currentSpeciality] specialityToProcedure] allObjects];
    
    for (Procedure *procedure in procedures)
    {
        [actionSheet addButtonWithTitle:procedure.name];
    }
    
    CGRect frame = [self.view convertRect:self.procedureMenuBtn.frame toView:self.view];
    [actionSheet showFromRect:frame inView:self.view animated:YES];
    
}
 */

#pragma mark - UIActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /*
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {   // be careful, cancelButtonIndex = -1
        
        switch (actionSheet.tag) {
            case TAG_ACTION_SHEET_SPECIALTY:
            {
                // set the current Specialty in the Dashboard
                NSArray *specs = [[DashboardModel sharedInstance] specialities];
                Speciality *spec = [specs objectAtIndex:buttonIndex];
                [[DashboardModel sharedInstance] setCurrentSpeciality:spec];
                [[DashboardModel sharedInstance] setCurrentSpecialityId:[spec.splId intValue]];
                
                // set the Specialty menu
                [self.specialtyMenuBtn setTitle:spec.name forState:UIControlStateNormal];
                // set the Procedure menu as needed
                if (![self.procedureMenuBtn.titleLabel.text isEqualToString:@"Procedure"])
                {
                    [self.procedureMenuBtn setTitle:@"Procedure" forState:UIControlStateNormal];
                    [self toggleARCViews];
                }
            }
                break;
            case TAG_ACTION_SHEET_PROCEDURE:
            {
                // set the current Procedure in the Dashboard
                NSArray *procs = [[[[DashboardModel sharedInstance] currentSpeciality] specialityToProcedure] allObjects];
                Procedure *proc = [procs objectAtIndex:buttonIndex];
                [[DashboardModel sharedInstance] setCurrentProcedure:proc];
                
                // set the Procedure menu as needed
                if ([self.procedureMenuBtn.titleLabel.text isEqualToString:@"Procedure"])
                {
                    [self toggleARCViews];
                }
                [self.procedureMenuBtn setTitle:proc.name forState:UIControlStateNormal];
                // lastly, reload steps and concerns
                [self loadStepsAndConcerns];
            }
                break;
                
            default:
                break;
        }
    }
     */
    
}

- (void) toggleARCViews
{
    self.accessBackView.hidden = !self.accessBackView.hidden;
    self.repairBackView.hidden = !self.repairBackView.hidden;
    self.closureBackView.hidden = !self.closureBackView.hidden;
}

#pragma mark - 

- (void) configLayerForViews
{
    self.accessBackView.layer.borderWidth = 1.f;
    self.accessBackView.layer.borderColor = OUTLINE_RED.CGColor;
    self.accessBackView.layer.cornerRadius = 10.f;
    self.accessSlideView.layer.borderWidth = 1.f;
    self.accessSlideView.layer.borderColor = OUTLINE_RED.CGColor;
    self.accessStepTbl.layer.cornerRadius = 10.f;
    self.accessStepTbl.layer.borderWidth = 1.f;
    self.accessStepTbl.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.accessConcernTbl.layer.cornerRadius = 10.f;
    self.accessConcernTbl.layer.borderWidth = 1.f;
    self.accessConcernTbl.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.repairBackView.layer.borderWidth = 1.f;
    self.repairBackView.layer.borderColor = OUTLINE_ORANGE.CGColor;
    self.repairBackView.layer.cornerRadius = 10.f;
    self.repairSlideView.layer.borderWidth = 1.f;
    self.repairSlideView.layer.borderColor = OUTLINE_ORANGE.CGColor;
    self.repairStepTbl.layer.cornerRadius = 10.f;
    self.repairStepTbl.layer.borderWidth = 1.f;
    self.repairStepTbl.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.repairConcernTbl.layer.cornerRadius = 10.f;
    self.repairConcernTbl.layer.borderWidth = 1.f;
    self.repairConcernTbl.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.closureBackView.layer.borderWidth = 1.f;
    self.closureBackView.layer.borderColor = OUTLINE_YELLOW.CGColor;
    self.closureBackView.layer.cornerRadius = 10.f;
    self.closureSlideView.layer.borderWidth = 1.f;
    self.closureSlideView.layer.borderColor = OUTLINE_YELLOW.CGColor;
    self.closureStepTbl.layer.cornerRadius = 10.f;
    self.closureStepTbl.layer.borderWidth = 1.f;
    self.closureStepTbl.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.closureConcernTbl.layer.cornerRadius = 10.f;
    self.closureConcernTbl.layer.borderWidth = 1.f;
    self.closureConcernTbl.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    
}
/*
- (void) dumpData
{
    //nslog(@"%@\n\n\n",[[ProcedureModel sharedInstance] arcStepsForProcedure:7 andForSpeciality: 2]);
    
    //NSNumber *splId = [NSNumber numberWithInt:1];
    //NSNumber *procId = [NSNumber numberWithInt:2];
    
    //NSArray *arcSteps = [[ProcedureModel sharedInstance] arcStepsForProcedure:[procId intValue] andForSpeciality:[splId intValue]];
    //NSArray *concerns = [[ProcedureModel sharedInstance] concernsForProcedure:[procId intValue] andForSpeciality:[splId intValue]];
    
    //splId = [NSNumber numberWithInt:2];
    //procId = [NSNumber numberWithInt:7];
    
    //arcSteps = [[ProcedureModel sharedInstance] arcStepsForProcedure:[procId intValue] andForSpeciality:[splId intValue]];
    //concerns = [[ProcedureModel sharedInstance] concernsForProcedure:[procId intValue] andForSpeciality:[splId intValue]];
}
*/
- (void) loadStepsAndConcerns
{
    self.procId = [[DashboardModel sharedInstance] currentProcedure].procId;
    self.splId = [[DashboardModel sharedInstance] currentSpeciality].splId;
    
    NSArray *arcSteps = [[ProcedureModel sharedInstance] arcStepsForProcedure:[self.procId intValue] andForSpeciality:[self.splId intValue]];
    NSArray *concerns = [[ProcedureModel sharedInstance] concernsForProcedure:[self.procId intValue] andForSpeciality:[self.splId intValue]];
    
    //nslog(@"Proc id = %@\n", self.procId);
    //nslog(@"Spl id = %@\n", self.splId);
    
    if (!self.accessArcSteps) {
        self.accessArcSteps = [NSMutableArray array];
        self.repairArcSteps = [NSMutableArray array];
        self.closureArcSteps = [NSMutableArray array];

        self.accessConcerns = [NSMutableArray array];
        self.repairConcerns = [NSMutableArray array];
        self.closureConcerns = [NSMutableArray array];
        
        self.accessProducts = [NSArray array];
        self.repairProducts = [NSArray array];
        self.closureProducts = [NSArray array];
    }

    // iterate over ArcSteps and load into specific array by ARC step name
    for (ProcedureStep *procedureStep in arcSteps)
    {
        switch ([procedureStep.arcCatId intValue]) {
            case 1:
                [self.accessArcSteps addObject:procedureStep];
                break;
            case 2:
                [self.repairArcSteps addObject:procedureStep];
                break;
            case 3:
                [self.closureArcSteps addObject:procedureStep];
                break;
                
            default:
                break;
        }
    }

    // iterate over the Concerns and load into specific array by ARC step name
    for (Concern *concern in concerns)
    {
        ////nslog(@"Concern = %@", concern.name);
        
        NSSet *procedureSteps = concern.concernToProcedureStep;
        for (ProcedureStep *procedureStep in procedureSteps.allObjects)
        {
            switch ([procedureStep.arcCatId intValue])
            {
                case 1:
                    [self.accessConcerns addObject:concern];
                    break;
                case 2:
                    [self.repairConcerns addObject:concern];
                    break;
                case 3:
                    [self.closureConcerns addObject:concern];
                    break;
                    
                default:
                    break;
            }
            
            break;
        }
    }
    
    self.accessConcerns  = [self sortConcernBySortOrder:self.accessConcerns];
    self.repairConcerns  = [self sortConcernBySortOrder:self.repairConcerns];
    self.closureConcerns = [self sortConcernBySortOrder:self.closureConcerns];
    
    self.accessProducts = [[ProcedureModel sharedInstance] productsForProcedure:[self.procId intValue] andForSpeciality:[self.splId intValue] andForArcStepName:@"A"];
    self.repairProducts = [[ProcedureModel sharedInstance] productsForProcedure:[self.procId intValue] andForSpeciality:[self.splId intValue] andForArcStepName:@"R"];
    self.closureProducts = [[ProcedureModel sharedInstance] productsForProcedure:[self.procId intValue] andForSpeciality:[self.splId intValue] andForArcStepName:@"C"];
    
    [self.accessStepTbl reloadData];
    [self.accessConcernTbl reloadData];
    [self.accessColView reloadData];
    [self.repairStepTbl reloadData];
    [self.repairConcernTbl reloadData];
    [self.repairColView reloadData];
    [self.closureStepTbl reloadData];
    [self.closureConcernTbl reloadData];
    [self.closureColView reloadData];
    
    int cntAccess = 0;
    int itemCntAccess = self.accessProducts.count;
    int cntRepair = 0;
    int itemCntRepair = self.repairProducts.count;
    int cntClosure = 0;
    int itemCntClosure = self.closureProducts.count;

    if (itemCntAccess > 0)
    {
        if (itemCntAccess > 3)
        {
            cntAccess = itemCntAccess / 3;
            
            if (itemCntAccess % 3 > 0)
            {
                cntAccess++;
            }
        }
        else
        {
            cntAccess = 1;
        }
    }
    
    self.accessPageCtl.numberOfPages = cntAccess;
    
    if (itemCntRepair > 0)
    {
        if (itemCntRepair > 3)
        {
            cntRepair = itemCntRepair / 3;
            
            if (itemCntRepair % 3 > 0)
            {
                cntRepair++;
            }
        }
        else
        {
            cntRepair = 1;
        }
    }
    
    self.repairPageCtl.numberOfPages = cntRepair;
    
    if (itemCntClosure > 0)
    {
        if (itemCntClosure > 3)
        {
            cntClosure = itemCntClosure / 3;
            
            if (itemCntClosure % 3 > 0)
            {
                cntClosure++;
            }
        }
        else
        {
            cntClosure = 1;
        }
    }
    
    self.closurePageCtl.numberOfPages = cntClosure;
}

- (NSMutableArray*) sortConcernBySortOrder :(NSArray*) array {
    
    NSArray* sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        Concern *concernA = (Concern*)a;
        Concern *concernB = (Concern*)b;
        NSNumber* sortOrderA = concernA.sortOrder;
        NSNumber* sortOrderB = concernB.sortOrder;
        return [sortOrderA compare:sortOrderB];
    }];
    return [sortedArray mutableCopy];
}

//
// access/repair/closure slide gestures and animations
//
- (void) setupSlideEffectsWithOpenView:(UIView*)openView closeView:(UIView*)closeView
 {
     UITapGestureRecognizer *tap;

    openView.translatesAutoresizingMaskIntoConstraints = NO;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openSlideHandleTap:)];
    [openView addGestureRecognizer:tap];

     closeView.translatesAutoresizingMaskIntoConstraints = NO;
     tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSlideHandleTap:)];
     [closeView addGestureRecognizer:tap];
}

/*
- (void)pan:(UIPanGestureRecognizer *)gesture
{
    CGPoint newLoc = [gesture locationInView:self.view];

    if (newLoc.x < accessOrigLoc.x)
    {
        self.accessSlideConstraint.constant -= (accessOrigLoc.x - newLoc.x);
    }
    else
    {
        self.accessSlideConstraint.constant += (newLoc.x - accessOrigLoc.x);
    }
}
 */

- (void)openSlideHandleTap:(UITapGestureRecognizer *)gesture
{
    NSLayoutConstraint *constraint;
    //UIView *slideView;
    
    if (gesture.view == self.accessOpenHandleView || gesture.view == self.accessCloseHandleView)
    {
        constraint = self.accessSlideConstraint;
        //slideView = self.accessSlideView;
    } else if (gesture.view == self.repairOpenHandleView || gesture.view == self.repairCloseHandleView)
    {
        constraint = self.repairSlideConstraint;
        //slideView = self.repairSlideView;
    } else if (gesture.view == self.closureOpenHandleView || gesture.view == self.closureCloseHandleView)
    {
        constraint = self.closureSlideConstraint;
        //slideView = self.closureSlideView;
    }
    
    [UIView animateWithDuration:5.f
                          delay:0.5 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         constraint.constant = -500.f;
                     }
                     completion:^(BOOL finished){
                     }];
    
}

- (void)closeSlideHandleTap:(UITapGestureRecognizer *)gesture
{
    NSLayoutConstraint *constraint;
    
    if (gesture.view == self.accessOpenHandleView || gesture.view == self.accessCloseHandleView)
    {
        constraint = self.accessSlideConstraint;
    } else if (gesture.view == self.repairOpenHandleView || gesture.view == self.repairCloseHandleView)
    {
        constraint = self.repairSlideConstraint;
    } else if (gesture.view == self.closureOpenHandleView || gesture.view == self.closureCloseHandleView)
    {
        constraint = self.closureSlideConstraint;
    }
    
    [UIView animateWithDuration:5.f
                          delay:0.5 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         constraint.constant = 35;
                     }
                     completion:^(BOOL finished){
                     }];
}

//
//
//
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    
    if (tableView == self.accessStepTbl)
    {
        rows = self.accessArcSteps.count;
    }
    else if (tableView == self.repairStepTbl)
    {
        rows = self.repairArcSteps.count;
    }
    else if (tableView == self.closureStepTbl)
    {
        rows = self.closureArcSteps.count;
    }
    else if (tableView == self.accessConcernTbl)
    {
        rows = self.accessConcerns.count;

        if (rows == 0)
        {
            UILabel* emptyLabel = [[UILabel alloc] init];
            emptyLabel.textAlignment = NSTextAlignmentLeft;
            emptyLabel.backgroundColor = [UIColor clearColor];
            emptyLabel.frame = tableView.bounds;
            emptyLabel.text = @"   \u2022 Not Applicable";
            emptyLabel.font = [UIFont fontWithName:@"Arial" size:14];
            emptyLabel.textColor = [UIColor darkGrayColor];
            [tableView addSubview:emptyLabel];
        }
    }
    else if (tableView == self.repairConcernTbl)
    {
        rows = self.repairConcerns.count;
        
        if (rows == 0)
        {
            UILabel* emptyLabel = [[UILabel alloc] init];
            emptyLabel.textAlignment = NSTextAlignmentLeft;
            emptyLabel.backgroundColor = [UIColor clearColor];
            emptyLabel.frame = tableView.bounds;
            emptyLabel.text = @"   \u2022 Not Applicable";
            emptyLabel.font = [UIFont fontWithName:@"Arial" size:14];
            emptyLabel.textColor = [UIColor darkGrayColor];
            [tableView addSubview:emptyLabel];

        }
    }
    else if (tableView == self.closureConcernTbl)
    {
        rows = self.closureConcerns.count;
        
        if (rows == 0)
        {
            UILabel* emptyLabel = [[UILabel alloc] init];
            emptyLabel.textAlignment = NSTextAlignmentLeft;
            emptyLabel.backgroundColor = [UIColor clearColor];
            emptyLabel.frame = tableView.bounds;
            emptyLabel.text = @"   \u2022 Not Applicable";
            emptyLabel.font = [UIFont fontWithName:@"Arial" size:14];
            emptyLabel.textColor = [UIColor darkGrayColor];
            [tableView addSubview:emptyLabel];

        }
    }
    
    tableView.separatorColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    ////nslog(@"Closure concern row count = %lu", (unsigned long)self.closureConcerns.count);
    
    return rows;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (tableView == self.accessStepTbl) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"StepCell"];
        // NOTE: next line for displaying the actual Step text from core data
        //cell.textLabel.text = [[self.accessArcSteps objectAtIndex:indexPath.row] name];
        // per Valeska, text was changed to "relative" text ... Step #1, Step #2, ...
        cell.textLabel.text = [NSString stringWithFormat:@"Step #%d", indexPath.row + 1];
    } else if (tableView == self.repairStepTbl) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"StepCell"];
        // NOTE: next line for displaying the actual Step text from core data
        //cell.textLabel.text = [[self.repairArcSteps objectAtIndex:indexPath.row] name];
        // per Valeska, text was changed to "relative" text ... Step #1, Step #2, ...
        cell.textLabel.text = [NSString stringWithFormat:@"Step #%d", indexPath.row + 1];
    } else if (tableView == self.closureStepTbl) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"StepCell"];
        // NOTE: next line for displaying the actual Step text from core data
        //cell.textLabel.text = [[self.closureArcSteps objectAtIndex:indexPath.row] name];
        // per Valeska, text was changed to "relative" text ... Step #1, Step #2, ...
        cell.textLabel.text = [NSString stringWithFormat:@"Step #%d", indexPath.row + 1];
    }
    else if (tableView == self.accessConcernTbl)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ConcernCell"];
        // NOTE: next line for displaying the actual Concern text from core data
        //cell.textLabel.text = [[self.accessConcerns objectAtIndex:indexPath.row] name];
        
        NSString *str = [NSString stringWithFormat:@"\u2022 %@",[[self.accessConcerns objectAtIndex:indexPath.row] name]];
        cell.textLabel.text = str;
        
        // per Valeska, text was changed to "relative" text ... Concern #1, Concern #2 ...
        //cell.textLabel.text = [NSString stringWithFormat:@"Concern #%d", indexPath.row + 1];
    } else if (tableView == self.repairConcernTbl) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ConcernCell"];
        // NOTE: next line for displaying the actual Concern text from core data
        //cell.textLabel.text = [[self.repairConcerns objectAtIndex:indexPath.row] name];
                
        NSString *str = [NSString stringWithFormat:@"\u2022 %@",[[self.repairConcerns objectAtIndex:indexPath.row] name]];
        cell.textLabel.text = str;
        
        // per Valeska, text was changed to "relative" text ... Concern #1, Concern #2 ...
        //cell.textLabel.text = [NSString stringWithFormat:@"Concern #%d", indexPath.row + 1];
    } else if (tableView == self.closureConcernTbl) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ConcernCell"];
        // NOTE: next line for displaying the actual Concern text from core data
        //cell.textLabel.text = [[self.closureConcerns objectAtIndex:indexPath.row] name];
        
        NSString *str = [NSString stringWithFormat:@"\u2022 %@",[[self.closureConcerns objectAtIndex:indexPath.row] name]];
        cell.textLabel.text = str;
        
        // per Valeska, text was changed to "relative" text ... Concern #1, Concern #2 ...
        //cell.textLabel.text = [NSString stringWithFormat:@"Concern #%d", indexPath.row + 1];
    }
    
    //[[cell.textLabel layer]setBorderWidth:2.0f];
    
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:14];
    
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.numberOfLines = 0;
    cell.userInteractionEnabled = NO;
    NSLog(@"%f", cell.bounds.size.height);
    //[tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    /*
    //iOS7 check - Used to make consistant seperator lines on tableview post iOS7
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
     */

    return cell;
}


#pragma mark - UITableViewDelegate
/*
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Concern *concern;
    
    if (tableView == self.accessConcernTbl)
    {
        concern = [self.accessConcerns objectAtIndex:indexPath.row];
        if (self.accessSelectedConcernId && [concern.concernId isEqualToNumber:self.accessSelectedConcernId])
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            self.accessSelectedConcernId = nil;
        } else {
            self.accessSelectedConcernId = concern.concernId;
            self.accessProductIdsForSelectedConcern = [[ProcedureModel sharedInstance] productsForConcerns:[self.procId intValue] andForSpeciality:[self.splId intValue] andForArcStepName:@"A" andForConcernId:[concern.concernId intValue]];
        }
        [self.accessColView reloadData];
    } else if (tableView == self.repairConcernTbl)
    {
        concern = [self.repairConcerns objectAtIndex:indexPath.row];
        if (self.repairSelectedConcernId && [concern.concernId isEqualToNumber:self.repairSelectedConcernId])
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            self.repairSelectedConcernId = nil;
        } else {
            self.repairSelectedConcernId = concern.concernId;
            self.repairProductIdsForSelectedConcern = [[ProcedureModel sharedInstance] productsForConcerns:[self.procId intValue] andForSpeciality:[self.splId intValue] andForArcStepName:@"R" andForConcernId:[concern.concernId intValue]];
        }
        [self.repairColView reloadData];
    } else if (tableView == self.closureConcernTbl)
    {
        concern = [self.closureConcerns objectAtIndex:indexPath.row];
        if (self.closureSelectedConcernId && [concern.concernId isEqualToNumber:self.closureSelectedConcernId])
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            self.closureSelectedConcernId = nil;
        } else {
            self.closureSelectedConcernId = concern.concernId;
            self.closureProductIdsForSelectedConcern = [[ProcedureModel sharedInstance] productsForConcerns:[self.procId intValue] andForSpeciality:[self.splId intValue] andForArcStepName:@"C" andForConcernId:[concern.concernId intValue]];
        }
        [self.closureColView reloadData];
    }
}
*/
- (BOOL) isTableViewAStepsTable:(UITableView*)tableView
{
    // is the passed tableview same address as one of the step tables?
    return tableView == self.accessStepTbl || tableView == self.repairStepTbl || tableView == self.closureStepTbl;
}

// custom view for header. will be adjusted to default or specified header height
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, tableView.frame.size.width, 22.f)];
    [view setBackgroundColor:[UIColor darkGrayColor]];
    UILabel *label = [[UILabel alloc] initWithFrame:view.frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"Arial-BoldMT" size:17];

    //label.text = [self isTableViewAStepsTable:tableView] ? @"Steps" : @"Considerations";
    
    if (tableView == self.accessConcernTbl)
    {
        label.text =  @"Goals";

    }
    else if (tableView == self.repairConcernTbl)
    {
        label.text =  @"Goals";
        
    }
    else if (tableView == self.closureConcernTbl)
    {
        label.text =  @"Goals";
    }
    
    tableView.separatorColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    label.backgroundColor = [UIColor clearColor];
    
    [view addSubview:label];
    return view;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Create padding for cells
    
    NSString *cellText;
    
    if (tableView == self.accessConcernTbl)
    {
       cellText = [[self.accessConcerns objectAtIndex:indexPath.section] name];
    }
    else if (tableView == self.repairConcernTbl)
    {
        cellText = [[self.repairConcerns objectAtIndex:indexPath.section] name];
    }
    else if (tableView == self.closureConcernTbl)
    {
        cellText = [[self.closureConcerns objectAtIndex:indexPath.section] name];
    }
    
    UIFont *cellFont = [UIFont fontWithName:@"Arial" size:14];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    
    if (labelSize.height > 16)
    {
        NSLog(@"Label height = %f", labelSize.height);
    }
    
    tableView.separatorColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    return labelSize.height + 8;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    int items = 0;
    
    if (collectionView == self.accessColView)
    {
        items = self.accessProducts.count;
        if (items == 0)
        {
            //NSLog(@"No items for access");
            UILabel *label = [[UILabel alloc] initWithFrame:self.accessColView.bounds];
            label.font = [UIFont fontWithName:@"Arial" size:16];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor darkGrayColor];
            label.text = @"Not Applicable";
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y + 10, label.frame.size.width, label.frame.size.height);
            [collectionView addSubview:label];
        }
    }
    else if (collectionView == self.repairColView)
    {
        items = self.repairProducts.count;
        if (items == 0)
        {
            //NSLog(@"No items for repair");
            UILabel *label = [[UILabel alloc] initWithFrame:self.repairColView.bounds];
            label.font = [UIFont fontWithName:@"Arial" size:16];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor darkGrayColor];
            label.text = @"Not Applicable";
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y + 10, label.frame.size.width, label.frame.size.height);
            [collectionView addSubview:label];
        }
    }
    else if (collectionView == self.closureColView)
    {
        items = self.closureProducts.count;
        if (items == 0)
        {
            //NSLog(@"No items for closure");
            UILabel *label = [[UILabel alloc] initWithFrame:self.closureColView.bounds];
            label.font = [UIFont fontWithName:@"Arial" size:16];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor darkGrayColor];
            label.text = @"Not Applicable";
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y + 10, label.frame.size.width, label.frame.size.height);
            [collectionView addSubview:label];
        }
    }
    return items;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    Product *product;
    BOOL hilight = NO;
    
    if (collectionView == self.accessColView)
    {
        product = [self.accessProducts objectAtIndex:indexPath.row];
        
        if (self.accessSelectedConcernId)
        {
            for (NSNumber *prodId in self.accessProductIdsForSelectedConcern)
            {
                if ([product.prodId isEqualToNumber:prodId])
                {
                    hilight = YES;
                    break;
                }
            }
        }
    } else if (collectionView == self.repairColView)
    {
        product = [self.repairProducts objectAtIndex:indexPath.row];

        if (self.repairSelectedConcernId)
        {
            for (NSNumber *prodId in self.repairProductIdsForSelectedConcern)
            {
                if ([product.prodId isEqualToNumber:prodId])
                {
                    hilight = YES;
                    break;
                }
            }
        }
    } else if (collectionView == self.closureColView)
    {
        product = [self.closureProducts objectAtIndex:indexPath.row];

        if (self.closureSelectedConcernId)
        {
            for (NSNumber *prodId in self.closureProductIdsForSelectedConcern)
            {
                if ([product.prodId isEqualToNumber:prodId])
                {
                    hilight = YES;
                    break;
                }
            }
        }
    }

    NSArray *contents = [[ContentModel sharedInstance] contentsForProduct:product withContentCatIds:[NSArray arrayWithObject:[NSNumber numberWithInt:kProductImage]]];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 112, 84)];
    
    for (Content *content in contents)
    {
        if (content.thumbnailImgPath)
        {
            tempImageView.image = [self.appDelegate loadImage:content.thumbnailImgPath];
            break;
        }
    }
    
    if (!tempImageView.image)
    {
        UILabel *productTitleLabel;
        productTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 112, 84)];
        productTitleLabel.text = product.name;
        productTitleLabel.numberOfLines = 0;
        productTitleLabel.font = [UIFont fontWithName:@"Arial" size:14];
        productTitleLabel.textAlignment = NSTextAlignmentCenter;
        [tempImageView addSubview:productTitleLabel];
        
        UIGraphicsBeginImageContext(tempImageView.bounds.size);
        [tempImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *bitmap = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        tempImageView.image = bitmap;
    }
    
    ProcedureARCGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProcedureARCGridCell" forIndexPath:indexPath];

    cell.imageView.image = tempImageView.image;
    cell.titleLbl.text = product.name;
    
    if (hilight)
    {
        /*
        CALayer *layer = [cell layer];
        [layer setMasksToBounds:NO];
        [layer setCornerRadius:4];
        [layer setRasterizationScale:[[UIScreen mainScreen] scale]];
        [layer setShouldRasterize:YES];
        [layer setShadowColor:[[UIColor blackColor] CGColor]];
        [layer setShadowOffset:CGSizeMake(0.0f,0.5f)];
        [layer setShadowRadius:8.0f];
        [layer setShadowOpacity:0.2f];
        [layer setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:layer.cornerRadius] CGPath]];
         */
        
        [cell.layer setBorderColor:[UIColor redColor].CGColor];
        [cell.layer setBorderWidth:1.0f];
        [cell.layer setCornerRadius:3.f];
        [cell.layer setShadowOffset:CGSizeMake(0, 1)];
        [cell.layer setShadowColor:[UIColor redColor].CGColor];
        [cell.layer setShadowRadius:3.0];
        [cell.layer setShadowOpacity:0.8];
        [cell.layer setMasksToBounds:NO];
        
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        /*
        cell.layer.borderColor = [UIColor redColor].CGColor;
        cell.layer.borderWidth = 1.0f;
        cell.layer.shadowColor = [UIColor redColor].CGColor;
        cell.layer.shadowRadius = 1.0f;
        cell.layer.shadowOffset = CGSizeMake(2.0f, 3.0f);
        cell.layer.shadowOpacity = 0.5f;
        [cell.layer setMasksToBounds:NO];
         */
    } else{
        cell.layer.borderWidth = 0.f;
        cell.layer.shadowOpacity = 0.f;
        [cell.layer setMasksToBounds:YES];
    }
    
    /*
    cell.contentView.layer.borderColor = [UIColor redColor].CGColor;
    cell.contentView.layer.borderWidth = hilight ? 1.f : 0.f;
    cell.contentView.layer.shadowOpacity = hilight ? .6f : 0.f;
    cell.contentView.layer.shadowOffset = hilight ? CGSizeMake(2.f, 3.f) : CGSizeMake(0.f, 0.f);
     */

    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Product *product;
    
    if (collectionView == self.accessColView)
    {
        product = [self.accessProducts objectAtIndex:indexPath.row];
        
    } else if (collectionView == self.repairColView)
    {
        product = [self.repairProducts objectAtIndex:indexPath.row];
        
    } else if (collectionView == self.closureColView)
    {
        product = [self.closureProducts objectAtIndex:indexPath.row];
        
    }
    
    if (product)
    {
        NSString *str = [NSString stringWithFormat:@"%@:%@", product.prodId, product.name];
        //NSLog(@"TRACKING ARC-PRODUCT for %@", str);

        [[TrackingModel sharedInstance] createTrackingDataWithResource:str activityCode:TRACKING_ACTIVITY_VIEWED_PROCEDURE_ARC_PRODUCT];

        [[DashboardModel sharedInstance] setCurrentProductProcedureFlow:product];
        [self performSegueWithIdentifier:@"ProductDetailSegue" sender:nil];
        isGoingToDetailView = YES;

    }
    
}

- (IBAction)myCVPageControlSwiped:(id)sender
{
    switch ([sender tag])
    {
        case (1001):
        {            
            // update the scroll view to the appropriate page
            CGRect frame;
            frame.origin.x = self.accessColView.frame.size.width * self.accessPageCtl.currentPage;
            frame.origin.y = 0;
            frame.size = self.accessColView.frame.size;
            [self.accessColView scrollRectToVisible:frame animated:YES];
            break;
        }
        case (1002):
        {
            // update the scroll view to the appropriate page
            CGRect frame;
            frame.origin.x = self.repairColView.frame.size.width * self.repairPageCtl.currentPage;
            frame.origin.y = 0;
            frame.size = self.repairColView.frame.size;
            [self.repairColView scrollRectToVisible:frame animated:YES];
            break;
        }
        case (1003):
        {
            // update the scroll view to the appropriate page
            CGRect frame;
            frame.origin.x = self.closureColView.frame.size.width * self.closurePageCtl.currentPage;
            frame.origin.y = 0;
            frame.size = self.closureColView.frame.size;
            [self.closureColView scrollRectToVisible:frame animated:YES];
            break;
        }
        default:
            break;
    }
    
    // Keep track of when scrolls happen in response to the page control
    // value changing. If we don't do this, a noticeable "flashing" occurs
    // as the the scroll delegate will temporarily switch back the page
    // number.
    pageControlBeingUsed = YES;
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate

// keep the page control in-sync with the scrollview
// called when any offset changes
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!pageControlBeingUsed)
    {
        switch ([scrollView tag])
        {
            case 2001:
            {
                // Update the page when more than 50% (when pageWidth/2) of the previous/next page is visible
                CGFloat pageWidth = self.accessColView.frame.size.width;
                int page = floor((self.accessColView.contentOffset.x - pageWidth / 7) / pageWidth) + 1;
                self.accessPageCtl.currentPage = page;
                
                break;
            }
            case 2002:
            {
                // Update the page when more than 50% (when pageWidth/2) of the previous/next page is visible
                CGFloat pageWidth = self.repairColView.frame.size.width;
                int page = floor((self.repairColView.contentOffset.x - pageWidth / 7) / pageWidth) + 1;
                self.repairPageCtl.currentPage = page;
                
                break;
            }
            case 2003:
            {
                // Update the page when more than 50% (when pageWidth/2) of the previous/next page is visible
                CGFloat pageWidth = self.closureColView.frame.size.width;
                int page = floor((self.closureColView.contentOffset.x - pageWidth / 7) / pageWidth) + 1;
                self.closurePageCtl.currentPage = page;
                
                break;
            }
            default:
                break;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlBeingUsed = NO;
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlBeingUsed = NO;
}

@end
