//
//  FMDBSUtils.h
//  FMDBService
//
//  Created by williamqiu on 2017/1/9.
//  Copyright (c) 2017年 TVM All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMDBSUtils : NSObject
///返回根目录路径 "document"
+ (NSString *)getDocumentPath;
///返回 "document/dir/" 文件夹路径
+ (NSString *)getDirectoryForDocuments:(NSString *)dir;
///返回 "document/filename" 路径
+ (NSString *)getPathForDocuments:(NSString *)filename;
///返回 "document/dir/filename" 路径
+ (NSString *)getPathForDocuments:(NSString *)filename inDir:(NSString *)dir;
///文件是否存在
+ (BOOL)isFileExists:(NSString *)filepath;
///删除文件
+ (BOOL)deleteWithFilepath:(NSString *)filepath;
///返回该文件目录下 所有文件名
+ (nullable NSArray *)getFilenamesWithDir:(NSString *)dir;

///检测字符串是否为空
+ (BOOL)checkStringIsEmpty:(NSString *)string;
+ (nullable NSString *)getTrimStringWithString:(nullable NSString *)string;

///把Date 转换成String
+ (NSString *)stringWithDate:(NSDate *)date;
///把String 转换成Date
+ (NSDate *)dateWithString:(NSString *)str;
///单例formatter
+ (NSNumberFormatter *)numberFormatter;

@end

#ifdef DEBUG
#ifdef NSLog
#define FMErrorLog(fmt, ...) NSLog(@"#FMDBService ERROR:\n" fmt, ##__VA_ARGS__);
#else
#define FMErrorLog(fmt, ...) NSLog(@"\n#FMDBService ERROR: %s  [Line %d] \n" fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#endif
#else
#define FMErrorLog(...)
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0 || __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_7
#define FMDBSWeak weak
#define __FMDBSWeak __weak
#else
#define FMDBSWeak unsafe_unretained
#define __FMDBSWeak
#endif

static NSString * const FMSQL_Type_Text = @"text";
static NSString * const FMSQL_Type_Int = @"integer";
static NSString * const FMSQL_Type_Double = @"double";
static NSString * const FMSQL_Type_Blob = @"blob";

static NSString * const FMSQL_Attribute_NotNull = @"NOT NULL";
static NSString * const FMSQL_Attribute_PrimaryKey = @"PRIMARY KEY";
static NSString * const FMSQL_Attribute_Default = @"DEFAULT";
static NSString * const FMSQL_Attribute_Unique = @"UNIQUE";
static NSString * const FMSQL_Attribute_Check = @"CHECK";
static NSString * const FMSQL_Attribute_ForeignKey = @"FOREIGN KEY";

static NSString * const FMSQL_Convert_FloatType = @"float_double_decimal";
static NSString * const FMSQL_Convert_IntType = @"int_char_short_long";
static NSString * const FMSQL_Convert_BlobType = @"";

static NSString * const FMSQL_Mapping_Inherit = @"FMDBSInherit";
static NSString * const FMSQL_Mapping_Binding = @"FMDBSBinding";
static NSString * const FMSQL_Mapping_UserCalculate = @"FMDBSUserCalculate";

static NSString * const FMDBS_TypeKey = @"DB_Type";

static NSString * const FMDBS_TypeKey_Model = @"DB_Type_Model";
static NSString * const FMDBS_TypeKey_JSON = @"DB_Type_JSON";
static NSString * const FMDBS_TypeKey_Combo = @"DB_Type_Combo";
static NSString * const FMDBS_TypeKey_Date = @"DB_Type_Date";

static NSString * const FMDBS_ValueKey = @"DB_Value";

static NSString * const FMDBS_TableNameKey = @"DB_TableName";
static NSString * const FMDBS_ClassKey = @"DB_Class";
static NSString * const FMDBS_RowIdKey = @"DB_RowId";
static NSString * const FMDBS_PValueKey = @"DB_PKeyValue";

///Object-c type converted to SQLite type  把Object-c 类型 转换为sqlite 类型
extern NSString *FMSQLTypeFromObjcType(NSString *objcType);

@interface FMDBSQueryParams : NSObject

///columns or array
@property (nullable, nonatomic, copy) NSString *columns;
@property (nullable, nonatomic, copy) NSArray *columnArray;

@property (nullable, nonatomic, copy) NSString *tableName;

///where or dic
@property (nullable, nonatomic, copy) NSString *where;
@property (nullable, nonatomic, copy) NSDictionary *whereDic;

@property (nullable, nonatomic, copy) NSString *groupBy;
@property (nullable, nonatomic, copy) NSString *orderBy;

@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger count;

@property (nullable, nonatomic, assign) Class toClass;

@property (nullable, nonatomic, copy) void (^callback)(NSMutableArray * _Nullable results);

@end

NS_ASSUME_NONNULL_END
