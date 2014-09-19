//
//  DataQuery.m
//  edge
//
//  Created by Vijaykumar on 6/24/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "DataValidator.h"
#import "AppDelegate.h"
#import "CheckPaths.h"
#import "Constants.h"
#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]

@implementation DataValidator

/**
 */
- (void) getContentByContentCategory {
    
    NSManagedObjectContext* context = [APP_DELEGATE managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    fetch.entity = [NSEntityDescription entityForName:@"ContentCategory" inManagedObjectContext:context];
    NSArray *contentCatArray = [context executeFetchRequest:fetch error:nil];
    _report = [[NSMutableString alloc] init];
    [_report appendFormat:@"<html>"];
    [_report appendFormat:@"<body>"];
    [_report appendFormat:@"<p style='font-size:12px;font-family:Georgia,tahoma;'>"];
    [_report appendFormat:@"ContentCategory<br/>"];
    for (NSManagedObject* mo in contentCatArray) {
        NSArray *contentArray;
        contentArray = [self fetchContent:mo context:context fetch:fetch];
        [_report appendFormat:@"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Content<br/>"];
        for (NSManagedObject* mo in contentArray) {
            NSArray *contentMappingArray;
            contentMappingArray = [self fetchContentMapping:mo context:context fetch:fetch];
            [_report appendFormat:@"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ContentMapping<br/>"];
            for (NSManagedObject* mo in contentMappingArray) {
                [_report appendFormat:@"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%@) %@<br/>",  [mo valueForKey:@"medId"], [self medicalCatNameFor:[mo valueForKey:@"medCatId"] context:context forFetchRequest:fetch]];
            }
        }
    }
    [_report appendFormat:@"</p>"];
    [_report appendFormat:@"</body>"];
    [_report appendFormat:@"</html>"];
}

/**
 */
- (NSArray *)fetchContent:(NSManagedObject *)mo context:(NSManagedObjectContext *)context fetch:(NSFetchRequest *)fetch {
    [_report appendFormat:@"<br/>"];
    [_report appendFormat:@"%@) %@<br/>",  [mo valueForKey:@"contentCatId"], [mo valueForKey:@"name"]];
    [_report appendFormat:@"------------------------------------------------------------------------------------<br/>"];
    fetch.entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contentCatId == %d", [[mo valueForKey:@"contentCatId"] integerValue]];
    [fetch setPredicate:predicate];
    NSArray *contentArray = [context executeFetchRequest:fetch error:nil];
    return contentArray;
}

/**
 */
- (NSArray *)fetchContentMapping:(NSManagedObject *)mo context:(NSManagedObjectContext *)context fetch:(NSFetchRequest *)fetch {
    [_report appendFormat:@"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%@) %@<br/>", [mo valueForKey:@"cntId"],  [mo valueForKey:@"path"]];
    [_report appendFormat:@"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%@<br/>", [mo valueForKey:@"thumbnailImgPath"]];
    fetch.entity = [NSEntityDescription entityForName:@"ContentMapping" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cntId == %d", [[mo valueForKey:@"cntId"] integerValue]];
    [fetch setPredicate:predicate];
    NSArray *contentMappingArray = [context executeFetchRequest:fetch error:nil];
    return contentMappingArray;
}

/**
 */
- (NSString*) medicalCatNameFor : (id) medCatId context:(NSManagedObjectContext *)context forFetchRequest: (NSFetchRequest*) fetch {
    fetch.entity = [NSEntityDescription entityForName:@"MedicalCategory" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"medCatId == %d", [medCatId integerValue]];
    [fetch setPredicate:predicate];
    NSArray *contentMappingArray = [context executeFetchRequest:fetch error:nil];
    return (contentMappingArray.count > 0 ? [[contentMappingArray objectAtIndex:0] valueForKey:@"name"] : @"NoMedicalCat");
}

- (void)removeByAttribute:(NSMutableDictionary *)objdict {
    //Remove the date objects
    if ([objdict objectForKey:@"crtDt"]) {
        [objdict removeObjectForKey:@"crtDt"];
    }
    if ([objdict objectForKey:@"uptDt"]) {
        
        [objdict removeObjectForKey:@"uptDt"];
    }
    if ([objdict objectForKey:@"expDt"]) {
        
        [objdict removeObjectForKey:@"expDt"];
    }
    
    if ([objdict objectForKey:@"sbtDt"]) {
        
        [objdict removeObjectForKey:@"sbtDt"];
    }
    if ([objdict objectForKey:@"contentUpdDt"]) {
        
        [objdict removeObjectForKey:@"contentUpdDt"];
    }
    if ([objdict objectForKey:@"lastSyncDt"]) {
        
        [objdict removeObjectForKey:@"lastSyncDt"];
    }
    if ([objdict objectForKey:@"signature"]) {
        
        [objdict removeObjectForKey:@"signature"];
    }
}

-(BOOL)isValidEntity: (NSString *)entityname
{
     if (([entityname isEqualToString:@"FileContent"] || [entityname isEqualToString:@"MyForm"] || [entityname isEqualToString:@"MyProfile"] || [entityname isEqualToString:@"MyFavorite"] || [entityname isEqualToString:@"MyRecentlyViewed"] || [entityname isEqualToString:@"Surgeon"] || [entityname isEqualToString:@"ContentSearch"]|| [entityname isEqualToString:@"SharedLink"] ))
     {
         return NO;
     }
    return YES;
}

-(NSDictionary *)fetchCoreData{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    NSManagedObjectContext* context = [APP_DELEGATE managedObjectContext];
    NSManagedObjectModel* objModel = [APP_DELEGATE managedObjectModel];
    NSArray *entityNames = [[objModel entities] valueForKey:@"name"];
    NSMutableArray *allRelations = [[NSMutableArray alloc]init];
    NSMutableDictionary *relations = [[NSMutableDictionary alloc]init];

    for (int i = 0; i < [entityNames count]; i++)
    {
        if ([self isValidEntity:[entityNames objectAtIndex:i]])
        {
            NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
            fetch.entity = [NSEntityDescription entityForName:[entityNames objectAtIndex:i] inManagedObjectContext:context];
            NSArray *fetchArray = [context executeFetchRequest:fetch error:nil];
            if ([fetchArray count ] == 0) {
                NSDictionary *relationships = [[ NSEntityDescription entityForName:[entityNames objectAtIndex:i] inManagedObjectContext:context] relationshipsByName];
                NSLog(@"entity*****:%@",[[ NSEntityDescription entityForName:[entityNames objectAtIndex:i] inManagedObjectContext:context] relationshipsByName]);
                NSString* relation;
                BOOL isValidRelation = NO;
                for(NSString *key in [relationships allKeys]) {
                    id relationship = [relationships objectForKey: key];
                    relation = [relationship name];
                    NSMutableArray *relArr = [[NSMutableArray alloc]init];
                    if ([self isValidRelation : relation]) {
                        NSArray* relationEntities = [relation componentsSeparatedByString: @"To"];
                        NSString* fromEntity = [relationEntities objectAtIndex:0];
                        NSString* toEntity = [relationEntities objectAtIndex:1];
                        NSString* parentPrimaryKey = [self getPrimaryKeyAttribute:fromEntity];
                        NSMutableArray *toIds = [[NSMutableArray alloc]init];
                        NSString* childPrimaryKey = [self getPrimaryKeyAttribute:toEntity];
                        NSMutableDictionary *relDict = [[NSMutableDictionary alloc]init];
                        [relDict setObject:toIds forKey:childPrimaryKey];
                        [relDict setObject:@"" forKey:parentPrimaryKey];
                        if ([relDict count] > 0) {
                            [relArr addObject:relDict];
                        }
                        isValidRelation = YES;
                    }
                    
                    if ([relArr count] > 0 && isValidRelation) {
                        if ([relations objectForKey:relation]) {
                            NSMutableArray* tempRelArr = [relations objectForKey:relation];
                            [relArr addObjectsFromArray: tempRelArr];
                            [relations setObject:relArr forKey:relation];
                        } else
                        {
                            [relations setObject:relArr forKey:relation];
                        }
                    }
                }

            }
            NSMutableArray *dataArray = [[NSMutableArray alloc]init];
            for (int j = 0; j < [fetchArray count]; j++) {
                NSManagedObject *mo = [fetchArray objectAtIndex:j];
                NSDictionary *relationships = [[mo entity] relationshipsByName];
                NSString* relation;
                BOOL isValidRelation = NO;
                for(NSString *key in [relationships allKeys]) {
                    id relationship = [relationships objectForKey: key];
                    relation = [relationship name];
                    NSMutableArray *relArr = [[NSMutableArray alloc]init];
                    if ([self isValidRelation : relation]) {
                        NSArray* relationEntities = [relation componentsSeparatedByString: @"To"];
                        NSString* fromEntity = [relationEntities objectAtIndex:0];
                        NSString* toEntity = [relationEntities objectAtIndex:1];
                        NSString* parentPrimaryKey = [self getPrimaryKeyAttribute:fromEntity];
                        NSLog(@"From ID .... : %@", [mo valueForKey:parentPrimaryKey]);
                        NSMutableArray *toIds = [[NSMutableArray alloc]init];
                        NSString* childPrimaryKey = [self getPrimaryKeyAttribute:toEntity];
                        NSString *className = NSStringFromClass([[mo valueForKey:relation]  class]);
                        if (![className isEqualToString:toEntity]) {
                        for (NSManagedObject* mo1 in [mo valueForKey:relation]) {
                            [toIds addObject:[mo1 valueForKey:childPrimaryKey]];
                            NSLog(@"TO ID .... : %@", [mo1 valueForKey:childPrimaryKey]);
                        }
                        }
                        else{
                            [toIds addObject:[mo valueForKey:childPrimaryKey]];
                            NSLog(@"ELSE TO ID .... : %@", [mo valueForKey:childPrimaryKey]);
                        }
                        NSMutableDictionary *relDict = [[NSMutableDictionary alloc]init];
//                        if ([toIds count] > 0) {
                            [relDict setObject:toIds forKey:childPrimaryKey];
                            [relDict setObject:[mo valueForKey:parentPrimaryKey] forKey:parentPrimaryKey];
//                        }
                        if ([relDict count] > 0) {
                            [relArr addObject:relDict];
                        }
                        isValidRelation = YES;
                    }
                    
                    if ([relArr count] > 0 && isValidRelation) {
                        if ([relations objectForKey:relation]) {
                            NSMutableArray* tempRelArr = [relations objectForKey:relation];
                            [relArr addObjectsFromArray: tempRelArr];
                            [relations setObject:relArr forKey:relation];
                        } else
                        {
                            [relations setObject:relArr forKey:relation];
                        }
                    }
                }
                
                NSArray *keys = [[[mo entity] attributesByName] allKeys];
                NSMutableDictionary *objdict = [[NSMutableDictionary alloc] initWithDictionary:[mo dictionaryWithValuesForKeys:keys]];
                [self removeByAttribute:objdict]; // removes date attributes
                if ([objdict count] > 0) {
                    [dataArray addObject:objdict];
                }
            }
            
            
            if ([dataArray count] > 0) {
                [dict setObject:dataArray forKey:[entityNames objectAtIndex:i]];
            }
        }
    }
    if ([relations count] > 0) {
         NSLog(@"relations .... : %@",[relations allKeys]);
        [allRelations addObject:relations];
    }
    
    [dict setObject:allRelations forKey:@"Relations"];
    
    
    CheckPaths *cp = [[CheckPaths alloc] init];
    [cp checkForPaths :dict];
    
    NSLog(@"enities:%@",dict);
    return dict;
}

- (BOOL) isValidRelation : (NSString*) relationName {
    
    relationName = [relationName lowercaseString];
    
    if ([relationName isEqualToString:[REL_SPECIALITYTOPROCEDURE lowercaseString]] ||
        [relationName isEqualToString:[REL_PROCEDURETOSPECIALITY lowercaseString]]||
        [relationName isEqualToString:[REL_PRODUCTTOPROCEDURE lowercaseString]] ||
        [relationName isEqualToString:[REL_PROCEDURETOPRODUCT lowercaseString]] ||
        [relationName isEqualToString:[REL_MARKETTOPRODUCT lowercaseString]] ||
        [relationName isEqualToString:[REL_PRODUCTTOMARKET lowercaseString]]||
        [relationName isEqualToString:[REL_PROCEDURETOPROCEDURESTEP lowercaseString]] ||
        [relationName isEqualToString:[REL_PROCEDURESTEPTOPROCEDURE lowercaseString]] ||
        [relationName isEqualToString:[REL_PROCEDURESTEPTOPRODUCT lowercaseString]] ||
        [relationName isEqualToString:[REL_PRODUCTTOPROCEDURESTEP lowercaseString]] ||
        [relationName isEqualToString:[REL_PROCEDURESTEPTOCONCERN lowercaseString]] ||
        [relationName isEqualToString:[REL_CONCERNTOPROCEDURESTEP lowercaseString]] ||
        [relationName isEqualToString:[REL_CONCERNTOPRODUCT lowercaseString]] ||
        [relationName isEqualToString:[REL_PRODUCTTOCONCERN lowercaseString]] ||
        [relationName isEqualToString:[REL_COMPPRODUCTTOPRODUCT lowercaseString]]||
        [relationName isEqualToString:[REL_PRODUCTTOCOMPPRODUCT lowercaseString]]
        )
    {
        return TRUE;
    }
    return FALSE;
}

- (NSString*) getPrimaryKeyAttribute : (NSString*) entity {
    
    entity = [entity lowercaseString];
    if ([entity isEqualToString:[@"Product" lowercaseString]])
        return @"prodId";
    else if ([entity isEqualToString:[@"Procedure" lowercaseString]])
        return @"procId";
    else if ([entity isEqualToString:[@"ProcedureStep" lowercaseString]])
        return @"procStepId";
    else if ([entity isEqualToString:[@"ContentCategory" lowercaseString]])
        return @"contentCatId";
    else if ([entity isEqualToString:[@"ArcCategory" lowercaseString]])
        return @"arcCatId";
    else if ([entity isEqualToString:[@"Speciality" lowercaseString]])
        return @"splId";
    else if ([entity isEqualToString:[@"Content" lowercaseString]])
        return @"cntId";
    else if ([entity isEqualToString:[@"MedicalCategory" lowercaseString]])
        return @"medCatId";
    else if ([entity isEqualToString:[@"ContentMapping" lowercaseString]])
        return @"cntMapId";
    else if ([entity isEqualToString:[@"CompProduct" lowercaseString]])
        return @"compProdId";
    else if ([entity isEqualToString:[@"Market" lowercaseString]])
        return @"mktId";
    else if ([entity isEqualToString:[@"SpecialityCategory" lowercaseString]])
        return @"splCatId";
    else if ([entity isEqualToString:[@"ProductCategory" lowercaseString]])
        return @"prodCatId";
    else if ([entity isEqualToString:[@"Concern" lowercaseString]])
        return @"concernId";
    else if ([entity isEqualToString:[@"ExtendedMetadata" lowercaseString]])
        return @"cntExtFieldId";
    else if ([entity isEqualToString:[@"FileContent" lowercaseString]])
        return @"path";
    else if ([entity isEqualToString:[@"ProcedureStepToProductNew" lowercaseString]])
        return @"prodProcStepId";
    
    return nil;
}

- (NSString*) getReport {
    return _report;
}

@end
