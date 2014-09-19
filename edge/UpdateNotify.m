//
//  UpdateNotify.m
//  edge
//
//  Created by epromacmini2 on 9/27/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "UpdateNotify.h"

@implementation UpdateNotify
@synthesize titlearray;
@synthesize lastArray;
@synthesize entitlementsArray;
@synthesize syncArray;
@synthesize newentitlementsArray;
@synthesize Filecontentdict;

static UpdateNotify *SharedObject = nil;

+ (UpdateNotify *)SharedManager
{
    if (nil == SharedObject)
    {
        SharedObject = [[UpdateNotify alloc]init];
        SharedObject.titlearray = [[NSMutableArray alloc]init];
        SharedObject.lastArray = [[NSMutableArray alloc]init];
        SharedObject.entitlementsArray = [[NSMutableArray alloc]init];
        SharedObject.syncArray = [[NSMutableArray alloc]init];
        SharedObject.newentitlementsArray = [[NSMutableArray alloc]init];
        SharedObject.Filecontentdict = [[NSArray alloc]init];


    }
    return SharedObject;
}


@end
