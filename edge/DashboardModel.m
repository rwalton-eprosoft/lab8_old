//
//  DashboardModel.m
//  edge
//
//  Created by iPhone Developer on 6/5/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "DashboardModel.h"
#import "AppDelegate.h"
#import "Speciality.h"
#import "RegistrationModel.h"
#import "MyProfile.h"
#import "MyEntitlement.h"
#import "MyRecentlyViewed.h"
#import "Content.h"
#import "ContentModel.h"
#import "Product.h"

@implementation DashboardItem

- (id) initWithTitle:(NSString*)title itemType:(int)itemType itemId:(int)itemId selected:(BOOL)selected defaultSelection:(BOOL)defaultSelection
{
    if (self = [super init])
    {
        _title = title;
        _itemType = itemType;
        _itemId = itemId;
        _currentSelection = selected;
        _defaultSelection = defaultSelection;
        _isProduct = NO;
    }
    return self;
    
}

- (id) initWithTitle:(NSString*)title itemType:(int)itemType itemId:(int)itemId selected:(BOOL)selected defaultSelection:(BOOL)defaultSelection isProduct:(BOOL)isProduct
{
    if (self = [self initWithTitle:title itemType:itemType itemId:itemId selected:selected defaultSelection:defaultSelection])
    {
        _isProduct = isProduct;
    }
    
    return self;
    
}

@end



@interface DashboardModel ()
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, assign) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray *stakeHolders;       // DashboardItems
@property (nonatomic, strong) NSArray *entitlements;    // DashboardItems
@property (nonatomic, strong) NSArray *myRecentlyVieweds;    // DashboardItems
@end

static int currentItem;
static int currentItem1;

@implementation DashboardModel

+ (DashboardModel*) sharedInstance
{
    static DashboardModel *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[DashboardModel alloc] init];
        // Do any other initialisation stuff here
        instance.appDelegate = [UIApplication sharedApplication].delegate;
        instance.managedObjectContext = instance.appDelegate.managedObjectContext;
        [instance initModel];
    });
    
    return instance;
    
}

#pragma mark -

- (void) initModel
{
    // set initial dashboard selection state defaults.
    _currentCustomerType = NSNotFound;
    //_currentCustomerType = kCustomerTypeDefault;
    _currentSpecialityId = NSNotFound;
    
    // strakeholders are static
    [self loadStakeHolders];
    
    // refresh the dynamic data sets
    [self refreshDashboard];
}

- (void) loadStakeHolders
{
    // init StakeHolders
    NSMutableArray *stakes = [NSMutableArray array];
    
    DashboardItem *item = [[DashboardItem alloc] initWithTitle:@"Clinician"
                                                      itemType:kDashboardItemTypeStakeHolder
                                                        itemId:kCustomerTypeClinical
                                                      selected:_currentCustomerType == kCustomerTypeClinical
                                              defaultSelection:NO];
    [item setCustomerType:kCustomerTypeClinical];
    [self setImagesForDashboardItem:item];
    [stakes addObject:item];
    
    item = [[DashboardItem alloc] initWithTitle:@"Non-Clinician"
                                       itemType:kDashboardItemTypeStakeHolder
                                         itemId:kCustomerTypeNonClinical
                                       selected:_currentCustomerType == kCustomerTypeNonClinical
                               defaultSelection:NO];
    [item setCustomerType:kCustomerTypeNonClinical];
    [self setImagesForDashboardItem:item];
    [stakes addObject:item];
    
    [self setStakeHolders:stakes];
}

- (void) loadEntitlements
{
    DashboardItem *item;
    
    // init Entitlements (Specialty)
    NSMutableArray *ents = [NSMutableArray array];
    NSArray *items = [[RegistrationModel sharedInstance].profile myProfileToMyEntitlement].allObjects;
    for (MyEntitlement *entitlement in items)
    {
        if ([[RegistrationModel sharedInstance] isMyEntitlementEnabled:entitlement])
        {
            item = [[DashboardItem alloc] initWithTitle:entitlement.name
                                               itemType:kDashboardItemTypeSpeciality
                                                 itemId:[entitlement.splId intValue]
                                               selected:_currentSpecId == [entitlement.splId intValue]
                                       defaultSelection:[entitlement.isDefault boolValue]];
            [self setimagesforSpeciality:item];
            item.managedObject = entitlement;
            [ents addObject:item];
        }
        
    }
    
    // set our local copy of MyEntitlements
    [self setEntitlements:ents];
}


-(void) setimagesforSpeciality : (DashboardItem*)item
{
    NSString *imgName1;
    NSString *imgNameSelected1;
    
    NSArray* contentMappings = [self fetchContentMapping:[NSNumber numberWithInt:item.itemId]];
    NSMutableArray* cntIds = [[NSMutableArray alloc] init];
    for (NSManagedObject* mo in contentMappings) {
        [cntIds addObject:[mo valueForKey:@"cntId"]];
        
    }
    
    if (cntIds != nil && cntIds.count > 0)
    {
        NSError* error;
        NSFetchRequest * fetchRequest = [self fetchRequestWithEntity:@"Content"];
        NSPredicate *predicate1;
        predicate1 = [NSPredicate predicateWithFormat:@"cntId in %@ and contentCatId == %d", cntIds, kSpecialtyDashBoardIcon];
        [fetchRequest setPredicate:predicate1];
        NSArray* contents = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for (NSManagedObject* mo in contents)
        {
            imgName1 = [mo valueForKey:@"path"];
            
            imgNameSelected1 = [mo valueForKey:@"thumbnailImgPath"];
        }
    }
    
    item.imageName = imgName1;
    item.imageNameSelected = imgNameSelected1;
    
    
    
    
}
- (NSFetchRequest*)fetchRequestWithEntity:(NSString*)entityName
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    return fetchRequest;
}

- (NSArray*) fetchContentMapping : (NSNumber*) medId
{
    
    NSError* error;
    NSFetchRequest *fetchRequest = [self fetchRequestWithEntity:@"ContentMapping"];
    
    // add the predicate for searching
    NSPredicate *predicate;
    
    predicate = [NSPredicate predicateWithFormat:@"medId == %d and medCatId == %d", [medId intValue], 1];
    [fetchRequest setPredicate:predicate];
    
    return [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}


- (void) loadMyRecentyVieweds
{
    DashboardItem *item;
    
    // init MyRecentyVieweds
    NSMutableArray *myRecents = [NSMutableArray array];
    Content *content;
    for (MyRecentlyViewed *myRecent in [self recentlyViewed])
    {
        content = nil;
        
        if ([myRecent.isProduct boolValue])
        {
            
            // create a dashboard item for a Product
            //
            @try {
                item = [[DashboardItem alloc] initWithTitle:myRecent.myRecentlyViewedToProduct.name
                                                   itemType:kDashboardItemTypeMyRecentlyViewed
                                                     itemId:[myRecent.myRecentlyViewedToProduct.prodId intValue]
                                                   selected:NO
                                           defaultSelection:NO
                                                  isProduct:YES];
                
                Product *product = myRecent.myRecentlyViewedToProduct;
                if (product)
                {
                    NSArray *contents = [[ContentModel sharedInstance] contentsForProduct:product withContentCatIds:[NSArray arrayWithObject:[NSNumber numberWithInt:kProductImage]]];
                    if (contents && contents.count > 0)
                    {
                        content = [contents objectAtIndex:0];
                    }
                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
        else
        {
//            item = [[DashboardItem alloc] initWithTitle:myRecent.myRecentlyViewedToContent.title
//                                               itemType:kDashboardItemTypeMyRecentlyViewed
//                                                 itemId:[myRecent.myRecentlyViewedToContent.cntId intValue]
//                                               selected:NO
//                                       defaultSelection:NO];
//            
//            content = myRecent.myRecentlyViewedToContent;

            // create a dashboard item for a Content
            //
            
            @try {
                item = [[DashboardItem alloc] initWithTitle:myRecent.myRecentlyViewedToContent.title
                               itemType:kDashboardItemTypeMyRecentlyViewed
                                 itemId:[myRecent.myRecentlyViewedToContent.cntId intValue]
                               selected:NO
                       defaultSelection:NO];

                content = myRecent.myRecentlyViewedToContent;
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
           
        }
        
        if (content)
        {
            item.imageName = content.thumbnailImgPath;
            item.imageNameSelected = content.thumbnailImgPath;
            [myRecents addObject:item];
        }
    }
    
    // set our local copy of MyRecentyVieweds
    [self setMyRecentlyVieweds:myRecents];
    
}

- (void) refreshDashboard
{
    // reload MyEntitlements
    [self loadEntitlements];
    
    // reload MyRecentlyVieweds
    [self loadMyRecentyVieweds];
    
    // let everyone know the dashboard got refreshed.
    [self.appDelegate postApplicationEvent:APP_EVENT_DASHBOARD_REFRESHED];
}

- (void) setImagesForDashboardItem:(DashboardItem*)item
{
    NSString *imgName = @"cardio.png";
    NSString *imgNameSelected = @"cardio-select.png";
    
    if ([item.title isEqualToString:@"Clinician"])
    {
        imgName = @"clinical-dashboard.png";
        imgNameSelected = @"clinical-dashboard-select.png";
    }
    else if ([item.title isEqualToString:@"Non-Clinician"])
    {
        imgName = @"non-clinical-dashboard.png";
        imgNameSelected = @"non-clinical-dashboard-select.png";
    }
    else if ([item.title isEqualToString:@"Bariatric"])
    {
        imgName = @"bariatric.png";
        imgNameSelected = @"bariatric-select.png";
    }
    else if ([item.title isEqualToString:@"Gynaecologic"] || [item.title isEqualToString:@"Gynecologic"])
    {
        imgName = @"gynecology.png";
        imgNameSelected = @"gynecology-select.png";
    }
    else if ([item.title isEqualToString:@"Cardio"])
    {
        imgName = @"cardio.png";
        imgNameSelected = @"cardio-select.png";
    }
    else if ([item.title isEqualToString:@"Hernia"])
    {
        imgName = @"cardio.png";
        imgNameSelected = @"cardio-select.png";
    }
    else if ([item.title isEqualToString:@"Orthopedic"])
    {
        imgName = @"ortho.png";
        imgNameSelected = @"ortho_select.png";
    }
    else
    {
        imgName = @"others.png";
        imgNameSelected = @"others-select.png";
    }
    
    item.imageName = imgName;
    item.imageNameSelected = imgNameSelected;
    
}

/*
 - (NSString*) imageNameForSpecialityWithName:(NSString*)name
 {
 NSString *imgName = @"_icon-category.png";
 NSString *imgNameSelect = @"_icon-category-select.png";
 
 if ([name isEqualToString:@"Bariatric"])
 {
 imgName = @"bariatric.png";
 } else if ([name isEqualToString:@"Gynecologic"])
 {
 imgName = @"gynecology.png";
 } else if ([name isEqualToString:@"Cardio"])
 {
 imgName = @"cardio.png";
 }
 
 return imgName;
 }*/

- (NSString*) imageNameForDashboardItemType:(int)itemType
{
    NSString *imgName;
    
    switch (itemType) {
        case kDashboardItemTypeSpeciality:
            imgName = @"cardio.png";
            break;
            
        default:
            break;
    }
    
    return imgName;
}

- (NSArray*) itemsWithDashboardItemType:(int)itemType
{
    NSArray *array = [NSArray array];
    switch (itemType) {
        case kDashboardItemTypeStakeHolder:
        {
            ////nslog(@"_currentCustomerType: %d", _currentCustomerType);
            array = _stakeHolders;
        }
            break;
            
        case kDashboardItemTypeSpeciality:
        {
            array = _entitlements;
            
        }
            break;
            
        case kDashboardItemTypeMyRecentlyViewed:
        {
            array = _myRecentlyVieweds;
            
        }
            break;
            
        default:
            break;
    }
    return array;
}

- (void) clearSelectionWithDashboardItems:(NSArray*)items
{
    for (DashboardItem *item in items)
    {
        if (item.currentSelection == YES)
        {
            item.currentSelection = NO;
            _currentSpecId = NSNotFound;
            _currentEntitlement = Nil;
            _currentSpecialityId = NSNotFound;
            return;
        }
    }
}

- (void) dashboardItemSelected:(DashboardItem*)item
{
    
    switch ((int)item.itemType)
    {
        case kDashboardItemTypeStakeHolder:
        {
            if (currentItem != item.itemId) {
                [self clearSelectionWithDashboardItems:_stakeHolders];
            }
            currentItem = item.itemId;
            _currentCustomerType = item.customerType;
            if (!item.currentSelection)
            {
                
                item.currentSelection = YES;
            }
            
            else
            {
                item.currentSelection = NO;
                [self clearSelectionWithDashboardItems:_stakeHolders];
                _currentCustomerType = NSNotFound;
            }
        }
            break;
            
        case kDashboardItemTypeSpeciality:
        {
            if (currentItem1 != item.itemId) {
                [self clearSelectionWithDashboardItems:_entitlements];
            }
            currentItem1 = item.itemId;
            if (!item.currentSelection)
            {
                [self clearSelectionWithDashboardItems:_entitlements];
                _currentSpecialityId = item.itemId;
                _currentEntitlement = item.managedObject;
                _currentSpecId = _currentSpecialityId;
                
                //_currentSpeciality = _currentEntitlement.myEntitlementToSpeciality;
                _currentProcedure = nil;        // reset the current procedure
                item.currentSelection = YES;
            }
            else
            {
                item.currentSelection = NO;
                [self clearSelectionWithDashboardItems:_entitlements];
                _currentSpecId = NSNotFound;
                _currentEntitlement = Nil;
                _currentSpecialityId = NSNotFound;
            }
        }
            break;
        default:
            break;
    }
}

- (NSArray*) specialities
{
    NSMutableArray *specialities = [NSMutableArray array];
    
    NSArray *myEntitlements = [[RegistrationModel sharedInstance].profile myProfileToMyEntitlement].allObjects;
    
    //added 11/14/2013 to sort alphabetically
    NSArray *sortedArray;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    sortedArray = [myEntitlements sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    //
    
    for (MyEntitlement *myEntitlement in sortedArray)
    {
        if ([[RegistrationModel sharedInstance] isMyEntitlementEnabled:myEntitlement])
        {
            if (myEntitlement.myEntitlementToSpeciality != nil)
            {
                [specialities addObject:myEntitlement.myEntitlementToSpeciality];
            }
        }
        
    }
    
    return specialities;
}

- (NSFetchRequest*) myRecentlyViewedFetchRequest
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyRecentlyViewed" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    return fetchRequest;
}

- (int) countMyRecentlyViewed
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [self myRecentlyViewedFetchRequest];
    NSError *error;
    return [_appDelegate.managedObjectContext countForFetchRequest:fetchRequest error:&error];
}

- (void) deleteOldestMyRecentlyViewed
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [self myRecentlyViewedFetchRequest];
    
    // sort oldest first
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"crtDt" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:
                                sortDescriptor1,
                                nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error;
    NSArray *items;
    items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error)
    {
        if (items && items.count > 0)
        {
            [_appDelegate.managedObjectContext deleteObject:[items objectAtIndex:0]];
        }
    }
    
    [_appDelegate saveContext];
    
}

- (void) ensureMaxRecentlyViewed
{
    while ([self countMyRecentlyViewed] > MAX_RECENTLY_VIEWED)
    {
        [self deleteOldestMyRecentlyViewed];
    }
    
}

#pragma mark -
- (BOOL) didappear:(int)itemId : (BOOL)isProduct
{
    BOOL result = NO;
    for (MyRecentlyViewed *myRecent in [self recentlyViewed])
    {
        if (isProduct)
        {
            if ([myRecent.isProduct boolValue])
            {
                int k =  [myRecent.myRecentlyViewedToProduct.prodId intValue];
                if ( k == itemId)
                {
                    myRecent.crtDt = [NSDate date];
                    result = YES;
                    break;
                }
                
            }
            
        }
        else
        {
            @try {
                if (![myRecent.isProduct boolValue])
                {
                    int k =  [myRecent.myRecentlyViewedToContent.cntId intValue];
                    if ( k == itemId)
                    {
                        myRecent.crtDt = [NSDate date];
                        result = YES;
                        break;
                    }
                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
    }
    
    return result;
}

- (void) addRecentlyViewedForContent:(Content*)content
{
    // Create a new instance of the entity
    if(![self didappear:[content.cntId intValue] :NO])
    {
        MyRecentlyViewed *myRecent = [NSEntityDescription insertNewObjectForEntityForName:@"MyRecentlyViewed"
                                                                   inManagedObjectContext:_appDelegate.managedObjectContext];
        
        myRecent.crtDt = [NSDate date];
        myRecent.myRecentlyViewedToContent = content;
        myRecent.isProduct = [NSNumber numberWithBool:NO];
        
        [_appDelegate saveContext];
        
        [self ensureMaxRecentlyViewed];
    }
}

- (void) addRecentlyViewedForProduct:(Product*)product
{
    
    // Create a new instance of the entity
    if(![self didappear:[product.prodId intValue] :YES])
    {
        MyRecentlyViewed *myRecent = [NSEntityDescription insertNewObjectForEntityForName:@"MyRecentlyViewed"
                                                                   inManagedObjectContext:_appDelegate.managedObjectContext];
        
        myRecent.crtDt = [NSDate date];
        myRecent.myRecentlyViewedToProduct = product;
        myRecent.isProduct = [NSNumber numberWithBool:YES];
        
        [_appDelegate saveContext];
        
        [self ensureMaxRecentlyViewed];
    }
}

- (NSArray*) recentlyViewed
{
    NSArray *items = [NSArray array];
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyRecentlyViewed" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // sort newest first
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"crtDt" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:
                                sortDescriptor1,
                                nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error;
    items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        //nslog(@"error fetching MyRecentlyViewed: %@", [error description]);
    }
    
    return items;
}

@end
