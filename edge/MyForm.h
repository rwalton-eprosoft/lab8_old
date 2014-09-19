//
//  MyForm.h
//  edge
//
//  Created by Vijaykumar on 1/2/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MyForm : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * address2;
@property (nonatomic, retain) NSString * choiceOne;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSDate * crtDt;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * fax;
@property (nonatomic, retain) NSString * formId;
@property (nonatomic, retain) NSString * formTitle;
@property (nonatomic, retain) NSString * information;
@property (nonatomic, retain) NSString * institution;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * others;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * rep;
@property (nonatomic, retain) NSString * respMode;
@property (nonatomic, retain) NSString * sales;
@property (nonatomic, retain) NSDate * sbtDt;
@property (nonatomic, retain) NSData * signature;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * territory;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * topics;
@property (nonatomic, retain) NSDate * uptDt;
@property (nonatomic, retain) NSString * zipCode;

@end
