//
//  UpdateNotify.h
//  edge
//
//  Created by epromacmini2 on 9/27/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateNotify : NSObject

{
    NSMutableArray *titlearray,*lastArray,*entitlementsArray,*syncArray,*newentitlementsArray;
    NSArray *Filecontentdict;
}

+ (UpdateNotify *)SharedManager;

@property(nonatomic, strong)NSMutableArray *titlearray;
@property(nonatomic, strong)NSMutableArray *lastArray;
@property(nonatomic, strong)NSMutableArray *entitlementsArray;
@property(nonatomic, strong)NSMutableArray *syncArray;
@property(nonatomic, strong)NSMutableArray *newentitlementsArray;
@property(nonatomic, strong)NSArray *Filecontentdict;

@end
