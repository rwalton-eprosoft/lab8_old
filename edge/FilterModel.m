//
//  Filter.m
//  edge
//
//  Created by iPhone Developer on 5/30/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "FilterModel.h"
#import "AppDelegate.h"
#import "Procedure.h"
#import "Speciality.h"

@implementation Filterable

- (id) initWithFilterId:(NSNumber*)filterId filterName:(NSString*)filterName
{
    if (self = [super init])
    {
        _filterId = filterId;
        _filterName = filterName;        
    }
    return self;
}

@end


@interface FilterModel ()
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, assign) NSManagedObjectContext *managedObjectContext;
@end


@implementation FilterModel

- (id) init
{
    if (self = [super init])
    {
        _appDelegate = [UIApplication sharedApplication].delegate;
        _managedObjectContext = _appDelegate.managedObjectContext;

        _specialtyEnablements = [[NSMutableDictionary alloc] init];
        _procedureEnablements = [[NSMutableDictionary alloc] init];
        _productCategoryEnablements = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (FilterModel*) sharedInstance
{
    static FilterModel *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[FilterModel alloc] init];
        // Do any other initialisation stuff here
    });
    
    return instance;
    
}

- (NSMutableDictionary*)dictionaryForFilterSection:(int)filterSection
{
    NSMutableDictionary *dict;
    switch (filterSection)
    {
        case kFilterSpecialty:
            dict = _specialtyEnablements;
            break;
        case kFilterProcedure:
            dict = _procedureEnablements;
            break;
        case kFilterProductCategory:
            dict = _productCategoryEnablements;
            break;
            
        default:
            break;
    }
    return dict;
}

- (NSString*) filterKeyWithFilterId:(NSNumber*)filterId filterName:(NSString*)filterName
{
    return [NSString stringWithFormat:@"%d/%@", [filterId intValue], filterName];
}

- (void) setEnablementWithFilterSection:(int)filterSection filterObj:(id)filterObj filterId:(NSNumber*)filterId filterName:(NSString*)filterName enabled:(BOOL)enabled
{
    NSMutableDictionary *dict = [self dictionaryForFilterSection:filterSection];

    if (dict)
    {
        NSString *key = [self filterKeyWithFilterId:filterId filterName:filterName];
        
        Filterable *filterable = [dict objectForKey:key];
        if (!filterable)
        {
            filterable = [[Filterable alloc] initWithFilterId:filterId filterName:filterName];
            [dict setObject:filterable forKey:key];
        }
        
        filterable.enabled = enabled;
        filterable.filterObj = filterObj;
    }
}

- (BOOL) areAllEnabledForFilterSection:(int)filterSection
{
    BOOL allEnabled = NO;
    
    NSDictionary *dict = [self dictionaryForFilterSection:filterSection];

    if (dict)
    {
        for (Filterable *filterable in dict.allValues)
        {
            allEnabled = filterable.enabled;
            if (allEnabled == NO)
            {
                break;
            }
        }
    }
    
    return allEnabled;
}

- (void) enableAllForFilterSection:(int)filterSection
{
    NSMutableDictionary *dict = [self dictionaryForFilterSection:filterSection];

    if (dict)
    {
        for (Filterable *filterable in dict.allValues)
        {
            filterable.enabled = YES;
        }
    }
    
}

- (void) enableNoneForFilterSection:(int)filterSection
{
    NSMutableDictionary *dict = [self dictionaryForFilterSection:filterSection];
    
    if (dict)
    {
        for (Filterable *filterable in dict.allValues)
        {
            filterable.enabled = NO;
        }
    }
    
}

- (void) removeAllForFilterSection:(int)filterSection
{
    NSMutableDictionary *dict = [self dictionaryForFilterSection:filterSection];

    if (dict)
    {
        [dict removeAllObjects];
    }
}

- (NSArray*) enabledIdsForFilterSection:(int)filterSection
{
    NSMutableArray *array = [NSMutableArray array];
    
    NSMutableDictionary *dict = [self dictionaryForFilterSection:filterSection];
    
    if (dict)
    {
        for (Filterable *filterable in dict.allValues)
        {
            if (filterable.enabled)
            {
                [array addObject:[NSNumber numberWithInt:[filterable.filterId intValue]]];
            }
        }
        
    }
    
    return array;
    
}

- (void) enableProceduresForSpeciality:(Speciality*)speciality
{
    for (Procedure *procedure in speciality.specialityToProcedure.allObjects)
    {
        [self setEnablementWithFilterSection:kFilterProcedure filterObj:procedure filterId:procedure.procId filterName:procedure.name enabled:YES];
    }
}

- (void) dumpProcedures
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Procedure" inManagedObjectContext:_appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];

    Procedure *procedure;
    NSError *error;
    NSArray *items = [_appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (items && items.count > 0)
        {
            for (procedure in items)
            {
                //nslog(@"procedure name:%@ procId: %d splId: %d", procedure.name, [procedure.procId intValue], [procedure.splId intValue]);
            }
        }
    }
}

@end
