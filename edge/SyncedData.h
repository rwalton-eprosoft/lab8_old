//
//  SyncedData.h
//  edge
//
//  Created by epromacmini2 on 10/2/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncedData : NSObject

{
    NSString *names;
    NSMutableArray *contents;
}

@property(nonatomic, strong) NSString *names;
@property(nonatomic, strong) NSMutableArray *contents;
@end
