//
//  ContentModel.h
//  edge
//
//  Created by iPhone Developer on 6/30/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Favorite;
@class Procedure;
@class Presentation;
@class Product;
@class ContentCategory;
@class Speciality;
@class Content;
@class ProductCategory;

// web services urls defined here
//#define AMAZON_BASE_SERVER_QA                     @"http://ec2-54-235-241-255.compute-1.amazonaws.com:8080"
#define AMAZON_BASE_SERVER_QA                     @"http://pilot.eta.eprosoftlabs.com"

#define EPRODEV_BASE_SERVER_DEV                   @"http://www.eprodevbox.com"
#define EPRODEV_BASE_SERVER_QA                    @"http://eta.eprosoftlabs.com"
#define EPRODEV_BASE_SERVER_LIVE                  @"http://eta.eprosoftlive.com"

#define WEB_SERVICE_BASE                          @"http://192.168.1.56"

#ifdef EDGE
    #define WEB_SERVICE_BASE_SERVER               EPRODEV_BASE_SERVER_DEV
#elif EDGE_DEV
    #define WEB_SERVICE_BASE_SERVER               EPRODEV_BASE_SERVER_DEV
#elif EDGE_LIVE         //LIVE
    #define WEB_SERVICE_BASE_SERVER               EPRODEV_BASE_SERVER_LIVE
#elif EDGE_QA           //QA
    #define WEB_SERVICE_BASE_SERVER               AMAZON_BASE_SERVER_QA
#elif PS_Digital        //LABS
    #define WEB_SERVICE_BASE_SERVER               EPRODEV_BASE_SERVER_QA
#elif PS_Digital_Live   //LIVE
    #define WEB_SERVICE_BASE_SERVER               EPRODEV_BASE_SERVER_LIVE
#endif


#define WEB_SERVICE_BASE_SERVER_NOTES         @"http://m.eprodevbox.com"
#define POST_REGISTRATION_SERVICE             @"/regapi/processregdata"

/*
 Following is api is for checking new updates availability:
 
 {domain}/notifyapi/notifyupdate
 
 if in the response you get statusCode = 204, then it means there are no new updates available.
 else if statusCode = 200, then it means there are new updates available.
 */
#define CHECK_FOR_CONTENT_UPDATES       @"/notifyapi/notifyupdate"

#define STATUS_DEFAULT                  1
#define DEFAULT_WEB_SERVICE_TIMEOUT     20
#define PRODUCT_THUMBNAIL_IMAGE_NOT_FOUND   @"150x150.png"

/*
 MedicalCategory =         (
 {
 medCatId = 1;
 name = Speciality;
 },
 {
 medCatId = 2;
 name = Procedure;
 },
 {
 medCatId = 3;
 name = Product;
 },
 {
 medCatId = 4;
 name = ARCStep;
 },
 {
 medCatId = 5;
 name = Assembly;
 }
 */
enum MedCatIds {
    kMedCatIdSpeciality = 1,
    kMedCatIdProcedure = 2,
    kMedCatIdProduct = 3,
    kMedCatIdARCStep = 4,
    kMedCatIdAssembly = 5
};

enum SearchResultsSort {
    kSearchResultsSortType = 0,
    kSearchResultsSortABCD,
    kSearchResultsSortDate
};

enum ContentCategoryId
{
    kSpecialtyMessage = 1,
    kSpecialtyVideo,
    kSpecialtyImage,
    kSpecialtyArticle,
    kProcedureMessage,
    kProcedureImage,
    kProcedureVideo,
    kProcedureArticle,
    kProcedureStepMessage,
    kProcedureStepKeyGoals,
    kProductMessage,
    kProductClinicalMessage,
    kProductNonClinicalMessage,
    kProductArticle,
    //15	ProductSpecificationArticle		DELETED
    //16	ProductCompetitiveMessage		DELETED
    //17	ProductAssemblyArticle		DELETED
    kProductVideo = 18,
    kProductImage,
    kApplications,
    //21	pstool mini	pstool mini         not sure how/where used?
    kSpecialtyPresentations	= 22,
    kProductClinicalArticles,
    kProductClinicalArticlesCharts,
    kProductClinicalArticlesOthers,
    kProductCompetitiveInfo,
    kProductCompetitiveInfoVideos,
    kProductCompetitiveInfoCharts,
    kProductCompetitiveInfoOthers,
    kSpecialtyOtherCollateralBrochures,
    kSpecialtyOtherCollateralCharts,
    kSpecialtyOtherCollateralFAQS,
    kSpecialtyOtherCollateralOther,
    kSpecialtyOtherCollateralApps,
    kProductVACPAC510k,
    kProductVACPACIFU,
    kProductVACPACEconomic,
    kProductVACPACEvidenceSummary,
    kProductVACPACMSDS,
    kProductVACPACOther,
    kProductResourcesSalesaid,
    kProductResourcesReimbursementSheet,
    kProductResourcesSellsheet,
    kProductResourcesSSI,
    kProductResourcesBrochures,
    kProductResourcesInservice,
    kProductResourcesFAQS,
    kProductResourcesApps,
    kProductSpecs,
    kProductSpecsIFU,
    kProcedureOtherCollateralBrochures,
    kProcedureOtherCollateralCharts,
    kProcedureOtherCollateralFAQS,
    kProcedureOtherCollateralOther,
    kProcedureOtherCollateralApps,
    kSpecialtyDashBoardIcon = 59
    
};

@interface ContentModel : NSObject

+ (ContentModel*) sharedInstance;

- (NSString*) addAppDocumentsPathToPath:(NSString*)path;

- (NSFetchedResultsController*) products;
- (NSFetchedResultsController*) productsWithSpecialityIds:(NSArray*)splIds andProcedureIds:(NSArray*)procIds  andProductCategoryIds:(NSArray*)prodCatIds;

- (NSFetchedResultsController*) procedures;

- (NSFetchedResultsController*) specialities;

- (NSFetchedResultsController*) productCategories;

- (Procedure*) procedureWithProcId:(NSNumber*)procId;

- (Content*) contentWithId:(int)contentId;

- (Content*) contentWithThumbPath:(NSString *)thumbPath;

- (Product*) productWithId:(int)productId;

- (ProductCategory*) productCategoryWithProdCatId:(NSNumber*)prodCatId;

// all Contents for a Product
- (NSArray*) contentsForProduct:(Product*)product;

// get the ContentCategory for a given content cat id
- (ContentCategory*) contentCategoryWithContentCatId:(NSNumber*)contentCatId;

// specific type of Content for a Product
//- (NSArray*) contentsForProduct:(Product*)product withContentCatId:(int)contentCatId;
- (NSArray*) contentsForProduct:(Product*)product withContentCatIds:(NSArray*)contentCatIds;

// specific type of Content for a Speciality
//- (NSArray*) contentsForSpeciality:(Speciality*)speciality withContentCatId:(int)contentCatId;
- (NSArray*) contentsForSpeciality:(Speciality*)speciality withContentCatIds:(NSArray*)contentCatIds;

// specific type of Content for a Procedure
//- (NSArray*) contentsForProcedure:(Procedure*)procedure withContentCatId:(int)contentCatId;
- (NSArray*) contentsForProcedure:(Procedure*)procedure withContentCatIds:(NSArray*)contentCatIds;

// search all Contents with search string for given content type
- (NSFetchedResultsController*) searchContentsWithSearchString:(NSString*)searchStr searchResultsSort:(int)searchResultsSort filterType:(int)filterType;

// search all Products with search string
- (NSFetchedResultsController*) searchProductsWithSearchString:(NSString*)searchStr;

// search for suggestions with search string
- (NSArray*) suggestionsSearchWithSearchString:(NSString*)searchStr;

// get objects reverse mapped to ContentMappings for a given Content and MedCatId
- (NSArray*) reverseMappedContentForContent:(Content*)content withMedCatId:(NSNumber*)medCatId;

- (void) dumpContentMappingsWithCntId:(NSNumber*)cntId withMedCatId:(NSNumber*)medCatId;

- (void) syncMasterData;
- (void) syncData;
- (void) callClearMasterData:(BOOL)runInBackground;
- (void) clearUserData;
- (void) deleteFavorites;

- (void) dumpForDebugAssist;

- (void) registrationWithParams:(NSDictionary*)params;

- (void) syncDataInBackgroundWithEntitlements : (NSArray*) myEntitlements;

- (NSArray*) productCategoryWithProdIds:(NSArray*) prodCatIds;

- (UIImage*) thumbnailImageForContentCatId:(NSNumber*)contentCatId;

- (UIImage*) thumbnailImageForContentTitle:(NSString*)contentTitle;

- (void) deleteAllFromEntityWithName:(NSString*)entityName;

@property (nonatomic, strong) NSDictionary *registrationResponseHeader;
@property (nonatomic, readwrite) BOOL isResetAll;

//from arcDev
- (NSArray*)hotSpotsForSpecialty:(Speciality*)specialty;

#pragma mark - TEST CODE, these values should come from content download
- (void) createDummySpecialtyHotSpots;
//

- (NSFetchRequest*)contentMappingFetchRequestWithMedId:(NSNumber*)medId;

@end


/*
 The folder structure is as follows:
 /content/
 /articles/
 ------ procedure
 ------ procedure -> thumbs
 ------ product
 ------ product -> assembly
 ------ product -> assembly -> thumb
 ------ product -> specification
 ------ product -> specification -> thumb
 ------ product -> thumbs
 ------ speciality
 ------ speciality-> thumbs
 
 /images/
 ------ procedure
 ------ procedure -> thumbs
 ------ product
 ------ product -> thumbs
 ------ speciality
 ------ speciality-> thumbs
 
 /messages/
 ------ procedure
 ------ procedure -> thumbs
 ------ procedurestep
 ------ procedurestep -> keygoals
 ------ procedurestep-> keygoals -> thumbs
 ------ procedurestep-> thumbs
 ------ product
 ------ product-> clinical
 ------ product -> clinical -> thumb
 ------ product -> nonclinical
 ------ product -> nonclinical-> thumbs
 ------ product -> competitive
 ------ product -> competitive -> thumbs
 ------ product-> thumbs
 ------ speciality
 ------ speciality -> thumbs
 /videos/
 ------ procedure
 ------ procedure -> thumbs
 ------ product
 ------ product -> thumbs
 ------ speciality
 ------ speciality -> thumbs
 */

/*
 
 Speciality 1-4
 Procedure 5-10
 Product 11-19
 
 );
 ContentCategory =         (
 {
 contentCatId = 1;
 desc = "";
 name = SpecialityMessage;
 status = 1;
 },
 {
 contentCatId = 2;
 desc = "";
 name = SpecialityVideo;
 status = 1;
 },
 {
 contentCatId = 3;
 desc = "";
 name = SpecialityImage;
 status = 1;
 },
 {
 contentCatId = 4;
 desc = "";
 name = SpecialityArticle;
 status = 1;
 },
 {
 contentCatId = 5;
 desc = "";
 name = ProcedureMessage;
 status = 1;
 },
 {
 contentCatId = 6;
 desc = "";
 name = ProcedureImage;
 status = 1;
 },
 {
 contentCatId = 7;
 desc = "";
 name = ProcedureVideo;
 status = 1;
 },
 {
 contentCatId = 8;
 desc = "";
 name = ProcedureArticle;
 status = 1;
 },
 {
 contentCatId = 9;
 desc = "";
 name = ProcedureStepMessage;
 status = 1;
 },
 {
 contentCatId = 10;
 desc = "";
 name = ProcedureStepKeyGoals;
 status = 1;
 },
 {
 contentCatId = 11;
 desc = "";
 name = ProductMessage;
 status = 1;
 },
 {
 contentCatId = 12;
 desc = "";
 name = ProductClinicalMessage;
 status = 1;
 },
 {
 contentCatId = 13;
 desc = "";
 name = ProductNonClinicalMessage;
 status = 1;
 },
 {
 contentCatId = 14;
 desc = "";
 name = ProductArticle;
 status = 1;
 },
 {
 contentCatId = 15;
 desc = "";
 name = ProductSpecificationArticle;
 status = 1;
 },
 {
 contentCatId = 16;
 desc = "";
 name = ProductCompetitiveMessage;
 status = 1;
 },
 {
 contentCatId = 17;
 desc = "";
 name = ProductAssemblyArticle;
 status = 1;
 },
 {
 contentCatId = 18;
 desc = "";
 name = ProductVideo;
 status = 1;
 },
 {
 contentCatId = 19;
 desc = "";
 name = ProductImage;
 status = 1;
 }
 
 */

/*
 Procedure ...
 
 At a high level the relations b/w different entities as follows:
 Procedures can be associated with 0 to many Procedure Steps.
 Procedure Steps can be categorized/ grouped by A- Access or R- Repair or  C- Closure.
 Procedure Steps can be associated with 0 to many Products.
 Concerns can be associated with 0 to many Products.
 Procedure Steps can be associated with 0 to many Concerns.
 Procedure Steps can also be independently associated with Products.
 At this time, Procedure Steps & Concerns are NOT associated with any content. But, for the future scalability we can have this. So, the content was added. You can ignore if you find any content while coding.
 
 */