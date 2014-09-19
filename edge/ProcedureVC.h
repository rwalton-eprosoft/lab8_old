//
//  ProcedureVC.h
//  edge
//
//  Created by iPhone Developer on 6/4/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "BaseVC.h"
#import "ProcedurePickerViewController.h"
#import "ProcPickVC.h"

@class SpecialtyHotSpot;

enum AssetsSortType {
    kAssetsSortTypeVideo = 0,
    kAssetsSortTypeArticle = 1,
    kAssetsSortTypeResources = 2
};

enum ActionSheetIsFavoriteOnProcedureTags
{
    kActionSheetIsFavoriteOnProcedureTagCancel = 0,
    kActionSheetIsFavoriteOnProcedureTagAddToFavorite,
    kActionSheetIsFavoriteOnProcedureTagCancelandSharable
};


#define TAG_ACTION_SHEET_SPECIALTY       219
#define TAG_ACTION_SHEET_PROCEDURE       319
#define TAG_ACTION_SHEET_CONTENT         419

@interface HotSpotBtn : UIButton
@property (nonatomic, strong) SpecialtyHotSpot *hot;
@end

@interface ProcedureVC : BaseVC <UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ProcedurePickerDelegate, ProcPickDelegate>

@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;



// refernce view

@property (nonatomic, strong) IBOutlet UIView * refernceView;
@property (nonatomic, weak) IBOutlet UIView * refernceViewborder;
@property (nonatomic, strong) IBOutlet UIWebView * RefernceWebview;


@property (nonatomic, strong) IBOutlet UILabel *imageNameLbl;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) IBOutlet UIWebView *descriptionWebView;

@property (nonatomic, strong) IBOutlet UISegmentedControl *assetsSortSegCtl;
@property (nonatomic, strong) IBOutlet UIScrollView *assetsScrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *assetsPageCtl;
@property (nonatomic, strong) IBOutlet UIButton *procedureARCViewBtn;

@property (nonatomic, strong) IBOutlet UIButton *specialtyMenuBtn;
@property (nonatomic, strong) IBOutlet UIButton *procedureMenuBtn;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIView *contentsAreaView;
@property (strong, nonatomic) IBOutlet UICollectionView *procedureCollectionView;
@property (strong, nonatomic) IBOutlet UIPageControl *contentPageControl;
@property (strong, nonatomic) NSIndexPath *contentLongPressIndexPath;
@property (nonatomic, strong) IBOutlet UIButton *interactiveViewerBtn;

@property (nonatomic, strong) ProcedurePickerViewController *procPicker;
@property (nonatomic, strong) UIPopoverController *procedurePickerPopover;
@property (nonatomic, strong) ProcPickVC *procPickVC;


- (void)loadDefaultSpecialty;

- (IBAction) specialtyMenuBtnTouched;
- (IBAction) procedureMenuBtnTouched;

- (IBAction) assetsSortChanged;
- (IBAction) procedureARCViewBtnTouched;
-(IBAction)closeReferenceview:(id)sender;

@end

/*
 
 Procedural Flow -- Queries (updated)
 
 For 1) get all arc steps for a given procedure:
 
 Procedures have Procedure Steps; and Mappings are done in an Intersection Table. "Procedure Step" has a field known as "ARC Step" which have ARC categories (Access, Repair and Closure).
 
 Pesudo Code:
 
 SELECT ps.name, arc.name FROM tblProcedure proc
 INNER JOIN tblIntProcStepsProc pp ON proc.procId = pp.procId
 INNER JOIN  tblProcSteps ps ON pp.procStepId = ps.procStepId
 INNER JOIN  tblLkpArcCategory arc ON arc.arcCatId = ps.arcCatId
 WHERE proc.procId = 7 and arc.name = 'A'
 
 2) get all arc concerns for a given procedure
 
 Procedures have Procedure Steps; and Mappings are done in an Intersection Table. Each Procedure Step have related Concerns; and Mappings are done in an Intersection Table. As of now these mapping are not yet implemented as Core Data is yet to be updated.
 
 Pesudo Code:
 
 SELECT c.name, arc.name FROM tblProcedure proc
 INNER JOIN tblIntProcStepsProc pp ON proc.procId = pp.procId
 INNER JOIN  tblProcSteps ps ON pp.procStepId = ps.procStepId
 INNER JOIN  tblIntProcStepsConcerns psc ON psc.procStepId = ps.procStepId
 INNER JOIN  tblConcerns c ON c.concernId = psc.concernId
 INNER JOIN  tblLkpArcCategory arc ON arc.arcCatId = ps.arcCatId
 WHERE proc.procId = 7 and arc.name = 'A'
 
 */
