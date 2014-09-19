//
//  sizeValidation.m
//  edge
//
//  Created by Dheeraj Raju on 24/07/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import "sizeValidation.h"
#import "DownloadManager.h"
#import "MyEntitlement.h"
#import "RegistrationModel.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "ContentModel.h"
#import "Constants.h"
#import "BytesConversionHelper.h"
#import "AppDelegate.h"
#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]

@implementation sizeValidation

@synthesize totalContentDownloadSize;

static sizeValidation *SharedObject = nil;

+ (sizeValidation *)SharedManager
{
    if (nil == SharedObject)
    {
        SharedObject = [[sizeValidation alloc] init];
        SharedObject.totalContentDownloadSize = 0.0f;
    }
    return SharedObject;
}


- (void) callServer:(NSArray*)array isIncrSize:(int)isIncrSize
{

    NSString* serverBaseURL = WEB_SERVICE_BASE_SERVER;
    NSString *email = [[RegistrationModel sharedInstance].profile email];

    NSString* newString = [NSString stringWithFormat:@"%@%@", serverBaseURL, @"/notifyapi/getmesize"];
    if (array.count > 0)
    {
        
        [self invokeWebService:newString usingHttpMethod:@"POST" withRequestData:array forEmailId:email forPassword:nil isIncrSize:isIncrSize];
    }
    else{
        totalContentDownloadSize = 0;
        [APP_DELEGATE postApplicationEvent:SIZE_VALIDATION_FAILURE];
    }
}
- (CGFloat) totalFreeStorageSpace
{
    CGFloat freeSpace = [[DownloadManager sharedManager] totalDiskSpaceInBytes];
    CGFloat space = [BytesConversionHelper convertBytesToRead:freeSpace];
    return space;
}

- (void) invokeWebService : (NSString*) urlString usingHttpMethod:(NSString*) httpMethod withRequestData: (NSArray*) data forEmailId : (NSString*) emailId  forPassword : (NSString*) password isIncrSize: (int) status{
    
    NSURL *url = [NSURL URLWithString:urlString];
   AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:data forKey:@"splIds"];
    [dict setObject:[NSNumber numberWithInt:status] forKey:@"isIncrSize"];
    [dict setObject:[[RegistrationModel sharedInstance] uuid] forKey:@"uuid"];
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [httpClient setDefaultHeader:HTTP_HEADER_ACCEPT value:HTTP_APPLICATION_JSON];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
    
    NSString *filepath = [url path];
    NSMutableURLRequest *request = [httpClient requestWithMethod:httpMethod path:filepath parameters:dict];
    [request setValue:emailId forHTTPHeaderField:HTTP_X_ASCCPE_USERNAME];
    [request setValue:[[RegistrationModel sharedInstance] uuid] forHTTPHeaderField:@"UUID"];
    [request setTimeoutInterval:3600];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:HTTP_APPLICATION_JSON, nil]];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
        // NSLog(@"%@", JSON);
         CGFloat specSize = [[[JSON objectForKey:@"body"] objectForKey:@"totalSize"] floatValue];
         totalContentDownloadSize = [BytesConversionHelper convertBytesToRead:specSize];
         NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
         if (status == 0) {
             if ([[RegistrationModel sharedInstance] isRegistered])
             {
                 float size = [[defaults objectForKey:@"totalSize"]floatValue];
                 size += specSize;
                 [defaults setFloat:size forKey:@"totalSize"];

             }
             else{
                 [defaults setFloat:specSize forKey:@"totalSize"];}
         }
         else{
              float size = [[defaults objectForKey:@"totalSize"]floatValue];
             size += specSize;
           [defaults setFloat:size forKey:@"totalSize"];
         }
         [defaults synchronize];
         [APP_DELEGATE postApplicationEvent:SIZE_VALIDATION_SUCESS];

     }
                                                    failure:^(NSURLRequest *request,
                                                              NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        NSLog(@"Request Failure Because %@",[error userInfo]);
                                                        [APP_DELEGATE postApplicationEvent:SIZE_VALIDATION_FAILURE];

                                                    }
     ];
    [httpClient enqueueHTTPRequestOperation:operation];
}

@end
