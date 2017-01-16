//
//  NSObject+FMDBSModel.h
//  FMDBService
//
//  Created by williamqiu on 2017/1/9.
//  Copyright (c) 2017年 TVM All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@class FMDBSProperty;
@class FMDBSModelInfos;
@class FMDBService;

#pragma mark - 表结构
@interface NSObject (FMTabelStructure)

/**
 *  overwrite in your models(option)
 *
 *  @return # table name #
 */
+ (NSString *)getTableName;

/**
 *  if you set it will use it as a table name
 */
@property (nullable, nonatomic, copy) NSString *db_tableName;

/**
 *  the model is inserting ..
 */
@property (nonatomic, readonly) BOOL db_inserting;

/**
 *  sqlite comes with rowid
 */
@property (nonatomic, assign) NSInteger rowid;

/**
 *  overwrite in your models, if your table has primary key
 
 *  主键列名 如果rowid<0 则跟据此名称update 和delete
 
 *  @return # column name  #
 */
+ (nullable NSString *)getPrimaryKey;

/**
 *  multi primary key
 *  联合主键
 *  @return
 */
+ (nullable  NSArray *)getPrimaryKeyUnionArray;

/**
 *  overwrite in your models set column attribute
 *
 *  @param property infos
 */
+ (void)columnAttributeWithProperty:(FMDBSProperty *)property;

/**
 *	@brief   get saved pictures and data file path,can overwirte
 
    获取保存的 图片和数据的文件路径
 */
+ (NSString *)getDBImagePathWithName:(NSString *)filename;
+ (NSString *)getDBDataPathWithName:(NSString *)filename;

@end

#pragma mark - 表数据操作
@interface NSObject (FMTableData)

/***
 *	@brief      overwrite in your models,return insert sqlite table data
 *
 *
 *	@return     property the data after conversion
 */
- (nullable  id)userGetValueForModel:(FMDBSProperty *)property;

/***
 *	@brief	overwrite in your models,return insert sqlite table data
 *
 *	@param 	property        will set property
 *	@param 	value           sqlite value (NSString(NSData UTF8 Coding) or NSData)
 */
- (void)userSetValueForModel:(FMDBSProperty *)property value:(nullable id)value;

///overwrite
+ (NSDateFormatter *)getModelDateFormatter;

//FMDBService use
- (nullable id)modelGetValue:(FMDBSProperty *)property;
- (void)modelSetValue:(FMDBSProperty *)property value:(nullable NSString *)value;

- (nullable id)singlePrimaryKeyValue;
- (BOOL)singlePrimaryKeyValueIsEmpty;
- (nullable FMDBSProperty *)singlePrimaryKeyProperty;
+ (nullable NSString *)db_rowidAliasName;

@end

@interface NSObject (FMDBSModel)

/**
 *  return model use FMDBService , default return global FMDBService;
 *
 *  @return FMDBService
 */
+ (FMDBService *)getUsingFMDBService;

/**
 *  class attributes
 *
 *  @return FMDBSModelInfos
 */
+ (FMDBSModelInfos *)getModelInfos;

/**
 *	@brief Containing the super class attributes	设置是否包含 父类 的属性
 */
+ (BOOL)isContainParent;

/**
 *  当前表中的列是否包含自身的属性。
 *
 *  @return BOOL
 */
+ (BOOL)isContainSelf;

/**
 *	@brief log all property 	打印所有的属性名称和数据
 */
- (NSString *)printAllPropertys;
- (NSString *)printAllPropertysIsContainParent:(BOOL)containParent;

- (NSMutableString *)getAllPropertysString;

@end

NS_ASSUME_NONNULL_END
