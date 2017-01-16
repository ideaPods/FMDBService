//
//  FMDBSProperty+KeyMapping.m
//  FMDBService
//
//  Created by williamqiu on 2017/1/9.
//  Copyright (c) 2017年 TVM All rights reserved.
//

#import "FMDBService+Mapping.h"
#import "NSObject+FMDBSModel.h"

@interface FMDBSModelInfos () {
    __strong NSMutableDictionary *_proNameDic;
    __strong NSMutableDictionary *_sqlNameDic;
    __strong NSArray *_primaryKeys;
}
- (void)removeWithColumnName:(NSString *)columnName;
- (void)addDBPropertyWithType:(NSString *)type cname:(NSString *)column_name ctype:(NSString *)ctype pname:(NSString *)pname ptype:(NSString *)ptype;

- (void)updateProperty:(FMDBSProperty *)property sqlColumnName:(NSString *)columnName;
- (void)updateProperty:(FMDBSProperty *)property propertyName:(NSString *)propertyName;
@end

#pragma mark - 声明属性
@interface FMDBSProperty ()
@property (nonatomic, copy) NSString *type;

@property (nonatomic, copy) NSString *sqlColumnName;
@property (nonatomic, copy) NSString *sqlColumnType;

@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, copy) NSString *propertyType;

- (id)initWithType:(NSString *)type cname:(NSString *)cname ctype:(NSString *)ctype pname:(NSString *)pname ptype:(NSString *)ptype;
@end
#pragma mark - FMDBSProperty
@implementation FMDBSProperty

- (id)initWithType:(NSString *)type cname:(NSString *)cname ctype:(NSString *)ctype pname:(NSString *)pname ptype:(NSString *)ptype
{
    self = [super init];
    if (self) {
        _type = [type copy];
        _sqlColumnName = [cname copy];
        _sqlColumnType = [ctype copy];
        _propertyName = [pname copy];
        _propertyType = [ptype copy];
    }
    return self;
}
- (void)enableUserCalculate
{
    _type = FMSQL_Mapping_UserCalculate;
}
- (BOOL)isUserCalculate
{
    return ([_type isEqualToString:FMSQL_Mapping_UserCalculate] || _propertyName == nil || [_propertyName isEqualToString:FMSQL_Mapping_UserCalculate]);
}
@end
#pragma mark - NSObject - TableMapping
@implementation NSObject (TableMapping)
+ (NSDictionary *)getTableMapping
{
    return nil;
}
+ (void)setUserCalculateForCN:(NSString *)columnName
{
    if ([FMDBSUtils checkStringIsEmpty:columnName]) {
        FMErrorLog(@"columnName is null");
        return;
    }

    FMDBSModelInfos *infos = [self getModelInfos];
    FMDBSProperty *property = [infos objectWithSqlColumnName:columnName];
    if (property) {
        [property enableUserCalculate];
    }
    else {
        [infos addDBPropertyWithType:FMSQL_Mapping_UserCalculate cname:columnName ctype:FMSQL_Type_Text pname:columnName ptype:@"NSString"];
    }
}
+ (void)setUserCalculateForPTN:(NSString *)propertyTypeName
{
    if ([FMDBSUtils checkStringIsEmpty:propertyTypeName]) {
        FMErrorLog(@"propertyTypeName is null");
        return;
    }

    Class clazz = NSClassFromString(propertyTypeName);
    FMDBSModelInfos *infos = [self getModelInfos];
    for (NSInteger i = 0; i < infos.count; i++) {
        FMDBSProperty *property = [infos objectWithIndex:i];

        Class p_cls = NSClassFromString(property.propertyType);
        BOOL isSubClass = ((p_cls && clazz) && [p_cls isSubclassOfClass:clazz]);
        BOOL isNameEqual = [property.propertyType isEqualToString:propertyTypeName];
        if (isSubClass || isNameEqual) {
            [property enableUserCalculate];
        }
    }
}
+ (void)setTableColumnName:(NSString *)columnName bindingPropertyName:(NSString *)propertyName
{
    if ([FMDBSUtils checkStringIsEmpty:columnName] || [FMDBSUtils checkStringIsEmpty:propertyName])
        return;

    FMDBSModelInfos *infos = [self getModelInfos];

    FMDBSProperty *property = [infos objectWithPropertyName:propertyName];
    if (property == nil) {
        return;
    }

    FMDBSProperty *column = [infos objectWithSqlColumnName:columnName];
    if (column) {
        [infos updateProperty:column propertyName:propertyName];
        column.propertyType = property.propertyType;
    }
    else if ([property.sqlColumnName isEqualToString:property.propertyName]) {
        [infos updateProperty:property sqlColumnName:columnName];
    }
    else {
        [infos addDBPropertyWithType:FMSQL_Mapping_Binding cname:columnName ctype:FMSQL_Type_Text pname:propertyName ptype:property.propertyType];
    }
}
+ (void)removePropertyWithColumnNameArray:(NSArray *)columnNameArray
{
    FMDBSModelInfos *infos = [self getModelInfos];
    for (NSString *columnName in columnNameArray) {
        [infos removeWithColumnName:columnName];
    }
}
+ (void)removePropertyWithColumnName:(NSString *)columnName
{
    [[self getModelInfos] removeWithColumnName:columnName];
}
@end

#pragma mark - FMDBSModelInfos

@implementation FMDBSModelInfos
- (id)initWithKeyMapping:(NSDictionary *)keyMapping propertyNames:(NSArray *)propertyNames propertyType:(NSArray *)propertyType primaryKeys:(NSArray *)primaryKeys
{
    self = [super init];
    if (self) {

        _primaryKeys = [NSArray arrayWithArray:primaryKeys];

        _proNameDic = [[NSMutableDictionary alloc] init];
        _sqlNameDic = [[NSMutableDictionary alloc] init];

        NSString *type, *column_name, *column_type, *property_name, *property_type;
        if (keyMapping.count > 0) {
            NSArray *sql_names = keyMapping.allKeys;

            for (NSInteger i = 0; i < sql_names.count; i++) {

                type = column_name = column_type = property_name = property_type = nil;

                column_name = [sql_names objectAtIndex:i];
                NSString *mappingValue = [keyMapping objectForKey:column_name];

                //如果 设置的 属性名 是空白的  自动转成 使用ColumnName
                if ([FMDBSUtils checkStringIsEmpty:mappingValue]) {
                    NSLog(@"#ERROR sql column name %@ mapping value is empty,automatically converted FMDBSInherit", column_name);
                    mappingValue = FMSQL_Mapping_Inherit;
                }

                if ([mappingValue isEqualToString:FMSQL_Mapping_UserCalculate]) {
                    type = FMSQL_Mapping_UserCalculate;
                    column_type = FMSQL_Type_Text;
                }
                else {

                    if ([mappingValue isEqualToString:FMSQL_Mapping_Inherit] || [mappingValue isEqualToString:FMSQL_Mapping_Binding]) {
                        type = FMSQL_Mapping_Inherit;
                        property_name = column_name;
                    }
                    else {
                        type = FMSQL_Mapping_Binding;
                        property_name = mappingValue;
                    }

                    NSUInteger index = [propertyNames indexOfObject:property_name];

                    NSAssert(index != NSNotFound, @"#ERROR TableMapping SQL column name %@ not fount %@ property name", column_name, property_name);

                    property_type = [propertyType objectAtIndex:index];
                    column_type = FMSQLTypeFromObjcType(property_type);
                }

                [self addDBPropertyWithType:type cname:column_name ctype:column_type pname:property_name ptype:property_type];
            }
        }
        else {
            for (NSInteger i = 0; i < propertyNames.count; i++) {

                type = FMSQL_Mapping_Inherit;

                property_name = [propertyNames objectAtIndex:i];
                column_name = property_name;

                property_type = [propertyType objectAtIndex:i];
                column_type = FMSQLTypeFromObjcType(property_type);

                [self addDBPropertyWithType:type cname:column_name ctype:column_type pname:property_name ptype:property_type];
            }
        }

        if (_primaryKeys.count == 0) {
            _primaryKeys = [NSArray arrayWithObject:@"rowid"];
        }

        for (NSString *pkname in _primaryKeys) {
            if ([pkname.lowercaseString isEqualToString:@"rowid"]) {
                if ([self objectWithSqlColumnName:pkname] == nil) {
                    [self addDBPropertyWithType:FMSQL_Mapping_Inherit cname:pkname ctype:FMSQL_Type_Int pname:pkname ptype:@"int"];
                }
            }
        }
    }
    return self;
}
- (void)addDBPropertyWithType:(NSString *)type cname:(NSString *)column_name ctype:(NSString *)ctype pname:(NSString *)pname ptype:(NSString *)ptype
{
    FMDBSProperty *db_property = [[FMDBSProperty alloc] initWithType:type cname:column_name ctype:ctype pname:pname ptype:ptype];

    if (db_property.propertyName) {
        _proNameDic[db_property.propertyName] = db_property;
    }
    if (db_property.sqlColumnName) {
        _sqlNameDic[db_property.sqlColumnName] = db_property;
    }
}
- (NSArray *)primaryKeys
{
    return _primaryKeys;
}
- (NSUInteger)count
{
    return _sqlNameDic.count;
}
- (FMDBSProperty *)objectWithIndex:(NSInteger)index
{
    if (index < _sqlNameDic.count) {
        id key = [_sqlNameDic.allKeys objectAtIndex:index];
        return [_sqlNameDic objectForKey:key];
    }
    return nil;
}
- (FMDBSProperty *)objectWithPropertyName:(NSString *)propertyName
{
    return [_proNameDic objectForKey:propertyName];
}
- (FMDBSProperty *)objectWithSqlColumnName:(NSString *)columnName
{
    return [_sqlNameDic objectForKey:columnName];
}

- (void)updateProperty:(FMDBSProperty *)property propertyName:(NSString *)propertyName
{
    [_proNameDic removeObjectForKey:property.propertyName];
    property.propertyName = propertyName;
    _proNameDic[propertyName] = property;
}
- (void)updateProperty:(FMDBSProperty *)property sqlColumnName:(NSString *)columnName
{
    [_sqlNameDic removeObjectForKey:property.sqlColumnName];
    property.sqlColumnName = columnName;
    _sqlNameDic[columnName] = property;
}
- (void)removeWithColumnName:(NSString *)columnName
{
    if ([FMDBSUtils checkStringIsEmpty:columnName])
        return;

    FMDBSProperty *property = [_sqlNameDic objectForKey:columnName];
    if (property.propertyName) {
        [_proNameDic removeObjectForKey:property.propertyName];
    }
    [_sqlNameDic removeObjectForKey:columnName];
}
@end
