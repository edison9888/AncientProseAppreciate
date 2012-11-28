#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "FMResultSet.h"
#import "FMDatabasePool.h"


#if ! __has_feature(objc_arc)
    #define FMDBAutorelease(__v) ([__v autorelease]);
    #define FMDBReturnAutoreleased FMDBAutorelease

    #define FMDBRetain(__v) ([__v retain]);
    #define FMDBReturnRetained FMDBRetain

    #define FMDBRelease(__v) ([__v release]);
#else
    // -fobjc-arc
    #define FMDBAutorelease(__v)
    #define FMDBReturnAutoreleased(__v) (__v)

    #define FMDBRetain(__v)
    #define FMDBReturnRetained(__v) (__v)

    #define FMDBRelease(__v)
#endif


@interface FMDatabase : NSObject  {
    
    sqlite3*            _db;
    NSString*           _databasePath;
    BOOL                _logsErrors;
    BOOL                _crashOnErrors;
    BOOL                _traceExecution;
    BOOL                _checkedOut;
    BOOL                _shouldCacheStatements;
    BOOL                _isExecutingStatement;
    BOOL                _inTransaction;
    int                 _busyRetryTimeout;
    
    NSMutableDictionary *_cachedStatements;
    NSMutableSet        *_openResultSets;
    NSMutableSet        *_openFunctions;

}


@property (assign) BOOL traceExecution;
@property (assign) BOOL checkedOut;
@property (assign) int busyRetryTimeout;
@property (assign) BOOL crashOnErrors;
@property (assign) BOOL logsErrors;
@property (retain) NSMutableDictionary *cachedStatements;

//数据库的实例
//---------------------------------------------------------------------------------------------
+ (id)databaseWithPath:(NSString*)inPath;
- (id)initWithPath:(NSString*)inPath;
//---------------------------------------------------------------------------------------------


//数据库的基本操作
//---------------------------------------------------------------------------------------------
- (NSString *)databasePath;
- (BOOL)open;//
#if SQLITE_VERSION_NUMBER >= 3005000
- (BOOL)openWithFlags:(int)flags;
#endif
- (BOOL)close;
- (BOOL)goodConnection;//判断数据库是不是正常的链接
- (void)clearCachedStatements;//清除所有的缓存sql
- (void)closeOpenResultSets;//关闭已经打开了的结果集
- (BOOL)hasOpenResultSets;//是不是有打开的结果集
//---------------------------------------------------------------------------------------------

//加密方法  你需要购买一个数据库加密扩展来实现这项工作
// encryption methods.  You need to have purchased the sqlite encryption extensions for these to work.
- (BOOL)setKey:(NSString*)key;
- (BOOL)rekey:(NSString*)key;

//错误处理
//---------------------------------------------------------------------------------------------
- (int)lastErrorCode;   //错误码
- (BOOL)hadError;       //判断数据哭是不是有错误
- (NSError*)lastError;
- (NSString*)lastErrorMessage;
//---------------------------------------------------------------------------------------------


- (sqlite_int64)lastInsertRowId;
- (sqlite3*)sqliteHandle;

//更新操作 包括update insert delete 等等
//---------------------------------------------------------------------------------------------
- (BOOL)update:(NSString*)sql withErrorAndBindings:(NSError**)outErr, ...;
- (BOOL)executeUpdate:(NSString*)sql, ...;
- (BOOL)executeUpdateWithFormat:(NSString *)format, ...;
- (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments;
- (BOOL)executeUpdate:(NSString*)sql withParameterDictionary:(NSDictionary *)arguments;
//---------------------------------------------------------------------------------------------


//查询
//---------------------------------------------------------------------------------------------
- (FMResultSet *)executeQuery:(NSString*)sql, ...;
- (FMResultSet *)executeQueryWithFormat:(NSString*)format, ...;
- (FMResultSet *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;
- (FMResultSet *)executeQuery:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments;
//---------------------------------------------------------------------------------------------

//事物
//---------------------------------------------------------------------------------------------
- (BOOL)rollback; //回滚
- (BOOL)commit;//开始提交事物
- (BOOL)beginTransaction;//开启事物
- (BOOL)beginDeferredTransaction;//延迟开启事物
- (BOOL)inTransaction;//是不是在事物中
- (BOOL)shouldCacheStatements;//是不是缓存了状态
- (void)setShouldCacheStatements:(BOOL)value;//设置是不是要缓存状态
//---------------------------------------------------------------------------------------------

#if SQLITE_VERSION_NUMBER >= 3007000
//????
//---------------------------------------------------------------------------------------------
- (BOOL)startSavePointWithName:(NSString*)name error:(NSError**)outErr;
- (BOOL)releaseSavePointWithName:(NSString*)name error:(NSError**)outErr;
- (BOOL)rollbackToSavePointWithName:(NSString*)name error:(NSError**)outErr;
- (NSError*)inSavePoint:(void (^)(BOOL *rollback))block;
//---------------------------------------------------------------------------------------------
#endif

//是不是线程安全
+ (BOOL)isSQLiteThreadSafe;

//数据库的版本
+ (NSString*)sqliteLibVersion;//返回数据库的版本

//???
- (int)changes;

//???
- (void)makeFunctionNamed:(NSString*)name maximumArguments:(int)count withBlock:(void (^)(sqlite3_context *context, int argc, sqlite3_value **argv))block;

@end

@interface FMStatement : NSObject {
    sqlite3_stmt *_statement;
    NSString *_query;
    long _useCount;
}

@property (assign) long useCount;
@property (retain) NSString *query;
@property (assign) sqlite3_stmt *statement;

- (void)close;
- (void)reset;

@end

