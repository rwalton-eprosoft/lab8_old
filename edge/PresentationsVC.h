//
//  PresentationsVC.h
//  edge
//
//  Created by iPhone Developer on 5/21/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "BaseVC.h"
#import "AppDelegate.h"

@interface PresentationsVC : BaseVC <UIScrollViewDelegate>
{
    int selectedpresentation;
    int countCheck;
    int checkingMet;
}

@property (nonatomic, strong) IBOutlet UILabel * titleLabel;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIScrollView * listScrollView;
@property (nonatomic, strong) IBOutlet UIScrollView * detailScrollView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView * spinner;
@property (nonatomic, strong) NSMutableArray * listArray;
@property (nonatomic, strong) NSMutableArray * metalistArray;
@property (nonatomic, strong) NSMutableArray * finalArray;

@property (nonatomic, strong) NSString * ext;
@property (nonatomic, strong) NSString * prstPathCntIds;

@property (nonatomic, strong) UIImageView *centreButton;
@property (nonatomic, strong) NSMutableArray * totalArray;
@property (nonatomic, strong) NSString * pathId;
@property (nonatomic, strong) AppDelegate * appDelegate;

@property (weak, nonatomic) IBOutlet UIButton *playButton;



-(void)loadData;
-(void)creatinglistScrollView;
-(void)creatingdetailScrollView;
-(IBAction)presentationListclicked:(id)sender;
-(IBAction)detailbuttonCLicked:(id)sender;
-(IBAction)playbuttonCLicked:(id)sender;

@end
