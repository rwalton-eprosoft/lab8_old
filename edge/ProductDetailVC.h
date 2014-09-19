//
//  ProductDetailVC.h
//  edge
//
//  Created by iPhone Developer on 5/24/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "BaseVC.h"

@class Product;

enum MessageTypes {
    kMessageTypeClinical = 100,
    kMessageTypeEconomical
    };

enum ContentTypes {
    kContentTypeProductVideos = 200,
    kContentTypeClinicalArticles,
    kContentTypeProductSpecs,
    kContentTypeCompetitiveInfo,
    kContentTypeVACPAC,
    kContentTypeResources
    };

enum ActionSheetIsFavoriteTags
{
    kActionSheetIsFavoriteTagCancel = 0,
    kActionSheetIsFavoriteTagAddToFavorite,
    kActionSheetIsFavoriteTagCancelandSharable
    };

@interface ProductDetailVC : BaseVC <UIActionSheetDelegate, UIScrollViewDelegate,UIWebViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel *topProductNameLbl;

// refernce view

@property (nonatomic, strong) IBOutlet UIView * refernceView;
@property (nonatomic, weak) IBOutlet UIView * refernceViewborder;
@property (nonatomic, strong) IBOutlet UIWebView * RefernceWebview;


@property (nonatomic, strong) IBOutlet UIButton *interactiveViewerBtn;


// images area
@property (nonatomic, strong) IBOutlet UIView *imagesAreaView;
@property (nonatomic, weak) IBOutlet UIImageView *productImageView;
@property (nonatomic, strong) IBOutlet UIPageControl *imagesPageControl;
@property (nonatomic, strong) IBOutlet UIButton *imageZoomBtn;
@property (nonatomic, strong) IBOutlet UIButton *image360Btn;
@property (nonatomic, strong) IBOutlet UILabel *imagesNbrLbl;

// product description area
@property (nonatomic, weak) IBOutlet UIView *productDescAreaView;
@property (nonatomic, weak) IBOutlet UIImageView *productNameBackView;
@property (nonatomic, strong) IBOutlet UILabel *productNameLbl;
@property (nonatomic, strong) IBOutlet UITextView *productDescTextView;

// messages area
@property (nonatomic, weak) IBOutlet UIView *messagesAreaView;
@property (nonatomic, weak) IBOutlet UIImageView *messagesControlsBackView;
@property (nonatomic, strong) IBOutlet UIButton *clinicalMessagesBtn;
@property (nonatomic, strong) IBOutlet UIButton *economicalMessagesBtn;
@property (nonatomic, weak) IBOutlet UITableView *messagesTbl;

// content area
@property (nonatomic, weak) IBOutlet UIView *contentsAreaView;
@property (nonatomic, strong) IBOutlet UIImageView *contentsControlsBackView;
@property (nonatomic, strong) IBOutlet UIButton *videosContentBtn;
@property (nonatomic, strong) IBOutlet UIButton *articlesContentBtn;
@property (nonatomic, strong) IBOutlet UIButton *specsContentBtn;
@property (nonatomic, strong) IBOutlet UIButton *competitiveContentBtn;
@property (nonatomic, strong) IBOutlet UIButton *vacPacContentBtn;
@property (nonatomic, strong) IBOutlet UIButton *resourcesContentBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *contentsCollectionView;
@property (strong, nonatomic) NSIndexPath *contentLongPressIndexPath;
@property (strong, nonatomic) IBOutlet UIPageControl *contentPageControl;


// the product being displayed
@property (nonatomic, strong) Product *product;
- (IBAction) backBtnTouched;
- (IBAction) imagesPageControlChanged;
- (IBAction) imageZoomBtnTouched;
- (IBAction) image360BtnTouched;
- (IBAction) messagesControlBtnTouched:(id)sender;
- (IBAction) contentsControlBtnTouched:(id)sender;
//- (IBAction) contentsPageControlChanged;

-(IBAction)closeReferenceview:(id)sender;
- (IBAction)privacyPolicyTouched:(id)sender;
-(NSString *)scanString:(NSString *)string startTag:(NSString *)startTag endTag:(NSString *)endTag;

@end

