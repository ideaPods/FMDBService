//
//  FMDBService+Mapping.h
//  FMDBService
//
//  Created by williamqiu on 2017/1/9.
//  Copyright (c) 2017年 TVM All rights reserved.
//

#import "FMDBSUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (TableMapping)

/**
 *	@brief Overwrite in your models if your property names don't match your Table Column names.
 also use for set create table columns.
 
 @{ sql column name : ( model property name ) or FMDBSInherit or FMDBSUserCalculate}
 
 */
+ (nullable NSDictionary *)getTableMapping;

/***
 simple set a column as "FMSQL_Mapping_UserCalculate"
 column name
*/
+ (void)setUserCalculateForCN:(NSString *)columnName;

///property type name
+ (void)setUserCalculateForPTN:(NSString *)propertyTypeName;

///binding columnName to PropertyName
+ (void)setTableColumnName:(NSString *)columnName bindingPropertyName:(NSString *)propertyName;

///remove unwanted binding property
+ (void)removePropertyWithColumnName:(NSString *)columnName;
+ (void)removePropertyWithColumnNameArray:(NSArray *)columnNameArray;

@end

@interface FMDBSProperty : NSObject

///保存的方式
@property (nonatomic, copy, readonly) NSString *type;

///保存到数据的  列名
@property (nonatomic, copy, readonly) NSString *sqlColumnName;
///保存到数据的类型
@property (nonatomic, copy, readonly) NSString *sqlColumnType;

///属性名
@property (nonatomic, copy, readonly) NSString *propertyName;
///属性的类型
@property (nonatomic, copy, readonly) NSString *propertyType;

///属性的Protocol
//@property(readonly,copy,nonatomic)NSString *propertyProtocol;

///creating table's column
@property (nonatomic, assign) BOOL isUnique;
@property (nonatomic, assign) BOOL isNotNull;
@property (nullable, nonatomic, copy) NSString *defaultValue;
@property (nullable, nonatomic, copy) NSString *checkValue;
@property (nonatomic, assign) NSInteger length;

- (BOOL)isUserCalculate;
@end

@interface FMDBSModelInfos : NSObject

- (id)initWithKeyMapping:(nullable NSDictionary *)keyMapping
           propertyNames:(NSArray *)propertyNames
            propertyType:(NSArray *)propertyType
             primaryKeys:(nullable NSArray *)primaryKeys;

@property (nonatomic, readonly) NSUInteger count;
@property (nullable, nonatomic, readonly) NSArray *primaryKeys;

- (nullable FMDBSProperty *)objectWithIndex:(NSInteger)index;
- (nullable FMDBSProperty *)objectWithPropertyName:(NSString *)propertyName;
- (nullable FMDBSProperty *)objectWithSqlColumnName:(NSString *)columnName;

@end

NS_ASSUME_NONNULL_END
