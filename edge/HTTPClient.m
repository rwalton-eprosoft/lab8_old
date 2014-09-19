//
//  HTTPClient.m
//  edge
//
//  Created by Vijaykumar on 8/17/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "HTTPClient.h"
#import "DataSyncServiceHelper.h"
#import "DownloadManager.h"
#import "ContentSyncModel.h"
#import "AppDelegate.h"

#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]

@implementation HTTPClient
static HTTPClient *_sharedClient = nil;
static HTTPClient *_sharedClient1 = nil;

+(HTTPClient *)sharedClient {
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.google.com/"]];
    });
    return _sharedClient;
}

+(HTTPClient *)sharedClient1 {
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient1 = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.google.com/"]];
    });
    return _sharedClient1;
}

/**
 
 */
- (void) initializeReachability {
    
    [_sharedClient1 setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable: {
                NSLog(@"Not connected to the internet");
                _hasWifi = NO;
                [APP_DELEGATE postApplicationEvent:APP_EVENT_NO_WIFI];
                break;
            } case AFNetworkReachabilityStatusReachableViaWiFi: {
                NSLog(@"Connected to the internet via WiFi");
                _hasWifi = YES;
                break;
            } case AFNetworkReachabilityStatusReachableViaWWAN: {
                NSLog(@"Connected to the internet via WWAN");
                //if (!_isWifiOnlyON) _hasWifi = YES;
                _hasWifi = NO;
                _isWWANON = YES;
                break;
            } case AFNetworkReachabilityStatusUnknown : {
                NSLog(@"AFNetworkReachabilityStatusUnknown");
                _hasWifi = NO;
                break;
            }
            default:
                break;
        }
    }];
}

- (NSData*) makeRequestTo:(NSString *) urlStr
               parameters:(NSDictionary *) params
                         :(NSString*) httpMethod
{
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSURL *url = [NSURL URLWithString:urlStr];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    httpClient.parameterEncoding = AFFormURLParameterEncoding;
    httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient setDefaultHeader:HTTP_HEADER_ACCEPT value:HTTP_APPLICATION_JSON];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
    NSMutableURLRequest *request = [httpClient requestWithMethod:httpMethod path:[url path] parameters:params];
    [request setValue:@"vkumar@eprosoft.com" forHTTPHeaderField:HTTP_X_ASCCPE_USERNAME];
    [request setValue:@"" forHTTPHeaderField:HTTP_X_ASCCPE_PASSWORD];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error) {
        //NSLog(@"Error .... %@", error);
        data = nil;
    } else {
        //NSLog(@"Data .... %@", data);
    }
    return data;
}

@end