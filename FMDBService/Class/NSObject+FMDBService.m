//
//  NSObject+FMDBService.m
//  FMDBService
//
//  Created by williamqiu on 2017/1/9.
//  Copyright (c) 2017年 TVM All rights reserved.
//

#import "NSObject+FMDBService.h"

@implementation NSObject (FMDBService_Delegate)

+ (void)dbDidCreateTable:(FMDBService *)helper tableName:(NSString *)tableName {}
+ (void)dbDidAlterTable:(FMDBService *)helper tableName:(NSString *)tableName addColumns:(NSArray *)columns {}

+ (void)dbDidInserted:(NSObject *)entity result:(BOOL)result {}
+ (void)dbDidDeleted:(NSObject *)entity result:(BOOL)result {}
+ (void)dbDidUpdated:(NSObject *)entity result:(BOOL)result {}
+ (void)dbDidSeleted:(NSObject *)entity {}

+ (BOOL)dbWillDelete:(NSObject *)entity
{
    return YES;
}
+ (BOOL)dbWillInsert:(NSObject *)entity
{
    return YES;
}
+ (BOOL)dbWillUpdate:(NSObject *)entity
{
    return YES;
}
@end

@implementation NSObject (FMDBService)

#pragma mark - simplify synchronous function
+ (BOOL)checkModelClass:(NSObject *)model
{
    if ([model isMemberOfClass:self])
        return YES;

    NSLog(@"%@ can not use %@", NSStringFromClass(self), NSStringFromClass(model.class));
    return NO;
}
+ (NSInteger)rowCountWithWhereFormat:(id)where, ...
{
    if ([where isKindOfClass:[NSString class]]) {
        va_list list;
        va_start(list, where);
        where = [[NSString alloc] initWithFormat:where arguments:list];
        va_end(list);
    }
    return [[self getUsingFMDBService] rowCount:self where:where];
}
+ (NSInteger)rowCountWithWhere:(id)where, ...
{
    if ([where isKindOfClass:[NSString class]]) {
        va_list list;
        va_start(list, where);
        where = [[NSString alloc] initWithFormat:where arguments:list];
        va_end(list);
    }
    return [[self getUsingFMDBService] rowCount:self where:where];
}
+ (NSMutableArray *)searchColumn:(id)columns where:(id)where orderBy:(NSString *)orderBy offset:(NSInteger)offset count:(NSInteger)count
{
    return [[self getUsingFMDBService] search:self column:columns where:where orderBy:orderBy offset:offset count:count];
}
+ (NSMutableArray *)searchWithWhere:(id)where orderBy:(NSString *)orderBy offset:(NSInteger)offset count:(NSInteger)count
{
    return [[self getUsingFMDBService] search:self where:where orderBy:orderBy offset:offset count:count];
}
+ (NSMutableArray *)searchWithWhere:(id)where
{
    return [[self getUsingFMDBService] search:self where:where orderBy:nil offset:0 count:0];
}
+ (NSMutableArray *)searchWithSQL:(NSString *)sql
{
    return [[self getUsingFMDBService] searchWithSQL:sql toClass:self];
}
+ (id)searchSingleWithWhere:(id)where orderBy:(NSString *)orderBy
{
    return [[self getUsingFMDBService] searchSingle:self where:where orderBy:orderBy];
}

+ (BOOL)insertToDB:(NSObject *)model
{

    if ([self checkModelClass:model]) {
        return [[self getUsingFMDBService] insertToDB:model];
    }
    return NO;
}
+ (BOOL)insertWhenNotExists:(NSObject *)model
{
    if ([self checkModelClass:model]) {
        return [[self getUsingFMDBService] insertWhenNotExists:model];
    }
    return NO;
}
+ (BOOL)updateToDB:(NSObject *)model where:(id)where, ...
{
    if ([self checkModelClass:model]) {
        if ([where isKindOfClass:[NSString class]]) {
            va_list list;
            va_start(list, where);
            where = [[NSString alloc] initWithFormat:where arguments:list];
            va_end(list);
        }
        return [[self getUsingFMDBService] updateToDB:model where:where];
    }
    return NO;
}
+ (BOOL)updateToDBWithSet:(NSString *)sets where:(id)where, ...
{
    if ([where isKindOfClass:[NSString class]]) {
        va_list list;
        va_start(list, where);
        where = [[NSString alloc] initWithFormat:where arguments:list];
        va_end(list);
    }
    return [[self getUsingFMDBService] updateToDB:self set:sets where:where];
}
+ (BOOL)deleteToDB:(NSObject *)model
{
    if ([self checkModelClass:model]) {
        return [[self getUsingFMDBService] deleteToDB:model];
    }
    return NO;
}
+ (BOOL)deleteWithWhere:(id)where, ...
{
    if ([where isKindOfClass:[NSString class]]) {
        va_list list;
        va_start(list, where);
        where = [[NSString alloc] initWithFormat:where arguments:list];
        va_end(list);
    }
    return [[self getUsingFMDBService] deleteWithClass:self where:where];
}
+ (BOOL)isExistsWithModel:(NSObject *)model
{
    if ([self checkModelClass:model]) {
        return [[self getUsingFMDBService] isExistsModel:model];
    }
    return NO;
}

- (BOOL)updateToDB
{
    if (self.rowid > 0) {
        return [self.class updateToDB:self where:nil];
    }
    else {
        return [self saveToDB];
    }
}
- (BOOL)saveToDB
{
    return [self.class insertToDB:self];
}
- (BOOL)deleteToDB
{
    return [self.class deleteToDB:self];
}
- (BOOL)isExistsFromDB
{
    return [self.class isExistsWithModel:self];
}

+ (void)insertArrayByAsyncToDB:(NSArray *)models
{
    [self insertArrayByAsyncToDB:models completed:nil];
}
+ (void)insertArrayByAsyncToDB:(NSArray *)models completed:(void (^)(BOOL))completedBlock
{
    if (models.count > 0) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self insertToDBWithArray:models filter:nil completed:completedBlock];
        });
    }
}

+ (void)insertToDBWithArray:(NSArray *)models filter:(void (^)(id model, BOOL inserted, BOOL *rollback))filter
{
    [self insertToDBWithArray:models filter:filter completed:nil];
}

+ (void)insertToDBWithArray:(NSArray *)models filter:(void (^)(id model, BOOL inserted, BOOL *rollback))filter completed:(void (^)(BOOL))completedBlock
{
    __block BOOL allInserted = YES;
    [[self getUsingFMDBService] executeForTransaction:^BOOL(FMDBService *helper) {
        BOOL isRollback = NO;
        for (int i = 0; i < models.count; i++) {
            id obj = [models objectAtIndex:i];
            BOOL inserted = [helper insertToDB:obj];
            allInserted &= inserted;
            if (filter) {
                filter(obj, inserted, &isRollback);
            }
            if (isRollback) {
                allInserted = NO;
                break;
            }
        }
        return (isRollback == NO);
    }];
    
    if (completedBlock) {
        completedBlock(allInserted);
    }
}

@end
