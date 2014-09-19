//
//  Filter.h
//  edge
//
//  Created by iPhone Developer on 5/30/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Speciality;

enum FilterSection {
    kFilterSpecialty = 0,
    kFilterProcedure,
    kFilterProductCategory
    };

@interface Filterable : NSObject
@property (nonatomic, weak) id filterObj;
@property (nonatomic, retain) NSNumber *filterId;
@property (nonatomic, weak) NSString *filterName;
@property (nonatomic, assign) BOOL enabled;
@end

@interface FilterModel : NSObject

@property (nonatomic, strong) NSMutableDictionary *specialtyEnablements;
@property (nonatomic, strong) NSMutableDictionary *procedureEnablements;
@property (nonatomic, strong) NSMutableDictionary *productCategoryEnablements;

+ (FilterModel*) sharedInstance;

- (NSString*) filterKeyWithFilterId:(NSNumber*)filterId filterName:(NSString*)filterName;
- (void) setEnablementWithFilterSection:(int)filterSection filterObj:(id)filterObj filterId:(NSNumber*)filterId filterName:(NSString*)filterName enabled:(BOOL)enabled;
- (BOOL) areAllEnabledForFilterSection:(int)filterSection;
- (void) enableAllForFilterSection:(int)filterSection;
- (void) enableNoneForFilterSection:(int)filterSection;
- (void) removeAllForFilterSection:(int)filterSection;
- (void) enableProceduresForSpeciality:(Speciality*)speciality;

- (NSArray*) enabledIdsForFilterSection:(int)filterSection;
- (NSArray*) proceduresWithSpecialityIds:(NSArray*)specialityIds;

@end
