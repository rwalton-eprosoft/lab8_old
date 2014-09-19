//
//  FavoritesVC.h
//  edge
//
//  Created by iPhone Developer on 5/31/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "BaseVC.h"
#import "LXReorderableCollectionViewFlowLayout.h"

#define TAG_LX          666
#define TAG_FAVS        999

enum FavoritesVCActionSheet
{
    kFavoritesVCActionSheetFavorites = 0,
    kFavoritesVCActionSheetDashboard = 99,
    kFavoritesVCActionSheetFilters = 199
    
};

typedef enum favCellImageType {
    kFavCellImageTypeIcon,
    kFavCellImageTypeOverlay
} FavCellImageType;

@class FavLXReorderableCVLayout;

@interface FavoritesVC : BaseVC <UICollectionViewDelegate, UIGestureRecognizerDelegate, LXReorderableCollectionViewDataSource,LXReorderableCollectionViewDelegateFlowLayout, UIActionSheetDelegate>
{
//    UIImageView *appCopyView;
}
@property (nonatomic, strong) IBOutlet UILabel * titlelabel;
@property (strong, nonatomic) IBOutlet UIImageView *sortImageView;
@property (strong, nonatomic) IBOutlet FavLXReorderableCVLayout *lxLayout;
@property (weak, nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIToolbar *favoritesToolbar;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortSegmentedControl;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *dashboardBarButton;
@property (weak, nonatomic) IBOutlet UIButton *editDashboardBarButton;
@property (weak, nonatomic) IBOutlet UIButton *editingModeDeleteButton;
@property (strong, nonatomic) IBOutlet UICollectionView *favCollectionView;
@property (strong, nonatomic) IBOutlet UICollectionView *lxCollectionView;
@property (strong, nonatomic) NSIndexPath *longPressIndexPath;
@property (strong, nonatomic) NSIndexPath *deleteTapIndexPath;
@property (strong, nonatomic) IBOutlet UIButton *dashboardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *favFilterBarItem;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;;
//@property (weak, nonatomic) IBOutlet UIImageView *alertImageView;
@property (weak, nonatomic) IBOutlet UILabel *appCopyView;

- (void) addFavoriteWithType:(NSNumber *) contentCatId;

@end
