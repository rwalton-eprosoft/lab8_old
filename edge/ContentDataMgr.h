//
//  ContentDataMgr.h
//  edge
//
//  Created by iPhone Developer on 5/18/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Favorite;
@class Procedure;
@class Presentation;
@class Product;

// web services urls defined here
#define WEB_SERVICE_BASE_SERVER         @"http://eprodevbox.com"

//
#define POST_REGISTRATION_SERVICE       @"/regapi/processregdata"

#define STATUS_DEFAULT                  1
#define DEFAULT_WEB_SERVICE_TIMEOUT     20

enum ContentCategoryId {
    kProductMessage = 11,
    kProductClinicalMessage = 12,
    kProductNonClinicalMessage = 13,
    kProductArticle = 14,
    kProductSpecificationArticle = 15,
    kProductCompetitiveMessage = 16,
    kProductAssemblyArticle = 17,
    kProductVideo = 18,
    kProductImage = 19
};

@interface ContentDataMgr : NSObject

+ (ContentDataMgr*) sharedInstance;

- (NSString*) addAppDocumentsPathToPath:(NSString*)path;

- (NSFetchedResultsController*) products;
- (NSFetchedResultsController*) productsWithSpecialityIds:(NSArray*)splIds andProcedureIds:(NSArray*)procIds  andProductCategoryIds:(NSArray*)prodCatIds sectionNameKeyPath:(NSString*)sectionNameKeyPath;

- (NSFetchedResultsController*) procedures;

- (NSFetchedResultsController*) specialities;

- (NSFetchedResultsController*) productCategories;

- (Procedure*) procedureWithProcId:(NSNumber*)procId;
// all contents for a product
- (NSArray*) contentsForProduct:(Product*)product;
// specific type of content for a product
- (NSArray*) contentsForProduct:(Product*)product withContentCatId:(int)contentCatId;

- (void) syncMasterData;
- (void) callClearMasterData:(BOOL)runInBackground;
- (void) clearUserData;

- (void) registrationWithParams:(NSDictionary*)params;
@property (nonatomic, strong) NSDictionary *registrationResponseHeader;

- (void) createMyFavoriteWithDict:(NSDictionary*)dict;
- (void) createPresentationWithDict:(NSDictionary*)dict;


@end

/*
 The REST API for content sync is relocated to http://eprodevbox.com/contentapi/contentsync
 There is NO CHANGE in other params.
 The above URL will give you the content only for the speciality Id provided through the JSON request, on the other hand the older url will return the whole content irrespective of speciality ids supplied.
 
 The Physical resources are also mapped back to content folder.
 
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