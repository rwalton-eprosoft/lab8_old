//
//  main.m
//  edge
//
//  Created by iPhone Developer on 5/11/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import  <asl.h>

int main(int argc, char *argv[])
{
    @autoreleasepool {
        
//        NSMutableArray *consoleLog = [NSMutableArray array];
//        
//        aslclient client = asl_open(NULL, NULL, ASL_OPT_STDERR);
//        
//        aslmsg query = asl_new(ASL_TYPE_QUERY);
//        asl_set_query(query, ASL_KEY_MSG, NULL, ASL_QUERY_OP_NOT_EQUAL);
//        aslresponse response = asl_search(client, query);
//        
//        asl_free(query);
//        
//        aslmsg message;
//        while((message = aslresponse_next(response)))
//        {
//            const char *msg = asl_get(message, ASL_KEY_MSG);
//            [consoleLog addObject:[NSString stringWithCString:msg encoding:NSUTF8StringEncoding]];
//        }
//        
//        aslresponse_free(response);
//        asl_close(client);
//        
//        NSLog(@"%@ \n", consoleLog);
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}