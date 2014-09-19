//
//  HTTPClient.h
//  edge
//
//  Created by Vijaykumar on 8/17/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "AFHTTPClient.h"
#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface HTTPClient : AFHTTPClient

+(HTTPClient *)sharedClient;
+(HTTPClient *)sharedClient1;

@property (atomic, strong) NSMutableArray* operationsArray;

- (void) initializeReachability;
@property (nonatomic, assign) BOOL isWifiOnlyON;
@property (nonatomic, assign) BOOL isWWANON; //3G
@property (nonatomic, assign) BOOL hasWifi;

@end
