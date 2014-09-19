//
//  Constants.h
//  edge
//
//  Created by Vijaykumar on 7/15/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]

//Notifications/Events
#define DOWNLOAD_COMPLETE_EVENT         @"DownloadComplete"
#define BROADCAST_DOWNLOAD_COMPLETE_EVENT @"BroadCastDownloadComplete"
#define DOWNLOAD_FAILED_EVENT           @"DownloadFailed"
#define DOWNLOAD_REMOVED_EVENT          @"DownloadRemoved"
#define DOWNLOAD_ALL_COMPLETE_EVENT     @"AllDownloadComplete"
#define DOWNLOAD_NETWORKSPEED           @"NetworkSpeed"
#define DOWNLOAD_TIMER_INTERVAL         35.0
#define START_INTERVAL                   5.0

//Core Data Attributes and Entities
#define ENT_FILECONTENT                 @"FileContent"
#define ENT_SPECIALITY                  @"Speciality"
#define ATTR_PATH                       @"path"
#define ATTR_STATUS                     @"status"
#define ATTR_DOWNLOADSTATUS             @"downloadStatus"
#define ATTR_INITIALSYNC                @"initialSync"
#define ATTR_SIZE                       @"size"
#define ATTR_SPLID                      @"splId"
#define ATTR_LAST_SYNC_DT               @"lastSyncDt"
#define VALUE_FAILED                    @"Failed"
#define VALUE_FETCHED                   @"Fetched"

//Core Data Relations
#define REL_SPECIALITYTOPROCEDURE       @"SpecialityToProcedure"
#define REL_PROCEDURETOSPECIALITY       @"ProcedureToSpeciality"
#define REL_PRODUCTTOPROCEDURE          @"ProductToProcedure"
#define REL_PROCEDURETOPRODUCT          @"ProcedureToProduct"
#define REL_MARKETTOPRODUCT             @"MarketToProduct"
#define REL_PRODUCTTOMARKET             @"ProductToMarket"

#define REL_PROCEDURETOPROCEDURESTEP    @"ProcedureToProcedureStep"
#define REL_PROCEDURESTEPTOPROCEDURE    @"ProcedureStepToProcedure"

#define REL_PROCEDURESTEPTOPRODUCT      @"ProcedureStepToProduct"
#define REL_PRODUCTTOPROCEDURESTEP      @"ProductToProcedureStep"
#define REL_PROCEDURESTEPTOCONCERN      @"ProcedureStepToConcern"
#define REL_CONCERNTOPROCEDURESTEP      @"ConcernToProcedureStep"
#define REL_CONCERNTOPRODUCT            @"ConcernToProduct"
#define REL_PRODUCTTOCONCERN            @"ProductToConcern"
#define REL_PRODUCTTOCOMPPRODUCT        @"ProductToCompProduct"
#define REL_COMPPRODUCTTOPRODUCT        @"CompProductToProduct"

//Download
#define TEMP_FILE_EXT                   @"%@.download"

//HTTP
#define HTTP_GET                        @"GET"
#define HTTP_X_ASCCPE_USERNAME          @"USERNAME"
#define HTTP_X_ASCCPE_PASSWORD          @"PASSWORD"
#define HTTP_HEADER_ACCEPT              @"Accept"
#define HTTP_APPLICATION_JSON           @"application/json"
#define SERVER_RESPONSE_BODY            @"body"
#define SERVER_RESPONSE_HEADER          @"header"
//#define WEB_SERVICE_BASE_SERVER_URL     @"http://ec2-54-237-63-176.compute-1.amazonaws.com:8080"

//#define WEB_SERVICE_BASE_SERVER_URL [[NSUserDefaults standardUserDefaults] objectForKey:@"Server"]

#define kNoContent 204
#define kSuccessContent 200

@interface Constants : NSObject

@end
