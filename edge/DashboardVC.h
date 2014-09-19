//
//  DashboardVC.h
//  edge
//
//  Created by iPhone Developer on 5/13/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "BaseVC.h"
#import "DrawVC.h"

enum DashboardVCActionSheet
{
    kDashboardVCActionSheetFavorites = 199
} ;

@class DashboardItem;

@interface DashboardMenuItem : RNGridMenuItem
@property (nonatomic, weak) DashboardItem *dashboardItem;
- (id) initWithImage:(UIImage*)image title:(NSString*)title dashboardItem:(DashboardItem*)dashboardItem;
@end

@interface DashboardLongPressGestureRecognizer : RNLongPressGestureRecognizer
@property (nonatomic, weak) DashboardItem *dashboardItem;
@end

@interface DashboardTapGestureRecognizer : UITapGestureRecognizer
@property (nonatomic, weak) DashboardItem *dashboardItem;
@end

@interface DashboardItemButton : UIButton
@property (nonatomic, strong) DashboardItem *dashboardItem;
@end

@interface DashboardVC : BaseVC  <UIAlertViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIActionSheetDelegate,UIScrollViewDelegate>

{
    UIButton *rightArrowBtn,*arrowBlnk2;
    UILabel *specLab,*stakeLab;
    int dashcheck,currentNo;
    UIImageView *showMsg;
}

@property (nonatomic, strong) IBOutlet UILabel *greetingLbl;
@property (nonatomic, strong) IBOutlet UIPageControl *SpecialitypgControl;
@property (nonatomic, strong) IBOutlet UILabel *appVersionLbl;
@property (nonatomic, strong) IBOutlet UILabel *lastUpdateLbl;
@property (nonatomic, strong) IBOutlet UILabel *StackholderLbl;
@property (nonatomic, strong) IBOutlet UILabel *SpecialityLbl;
@property (nonatomic, strong) IBOutlet UILabel *myfavouritesLbl;
@property (nonatomic, strong) IBOutlet UILabel *recentlyLbl;
@property (nonatomic, strong) IBOutlet UIScrollView *customerSV;
@property (nonatomic, strong) IBOutlet UIScrollView *specialitySV;
@property (nonatomic, strong) IBOutlet UIScrollView *recentlyViewedSV;
@property (nonatomic, strong) IBOutlet UIScrollView *myPresentationsSV;
@property (nonatomic, strong) IBOutlet UIScrollView *advantageSV;
@property (nonatomic, strong) IBOutlet UIButton *rightArrowBtn;

@property (nonatomic, strong) IBOutlet UICollectionView *myFavoritesCV;
@property (strong, nonatomic) IBOutlet UIPageControl *myFavPageControl;
@property (strong, nonatomic) NSIndexPath *favoriteLongPressIndexPath;
@property (strong, nonatomic) IBOutlet UIButton *arrowBlink;
@property (assign) BOOL justRunOnce;
@property (nonatomic, strong) Speciality *currentSpeciality;
@property (nonatomic, weak) MyEntitlement *currentEntitlement;


- (IBAction) rightArrowBtnTouched;
- (IBAction)mySpecPageControlSwiped:(id)sender;
- (void) unregisterForWifiEvents;


@end
