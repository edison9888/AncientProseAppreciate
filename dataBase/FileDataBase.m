//
//  FileDataBase.m
//  AncientProseAppreciate
//
//  Created by 武 帮民 on 12-4-14.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "FileDataBase.h"
static sqlite3 *dataBase = nil;

@implementation Poem
@synthesize PContent,PName,PNote,PRemark,PAid,PNum;
@end

@implementation Author
@synthesize AID,AHeader,AInfo,AName,ARemark;
@end

@implementation FileDataBase
+ (NSString *)dataBasePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"poem.db"];
}

+ (BOOL)openDb
{
    if (sqlite3_open([[self dataBasePath] UTF8String], &dataBase) != SQLITE_OK){
        NSLog(@"openDatabaseError:%s",sqlite3_errmsg(dataBase));
        sqlite3_close(dataBase);
        return NO;
    }
    return YES;
}
#pragma mark - Author
+(BOOL)CreateAuthorTable
{
    NSString *createSQL = [NSString stringWithFormat:@"create table  if not exists %@\
                           (\
                           AID                 integer     primary key autoincrement not null,\
                           ANAME               text,\
                           AINFO               text,\
                           AHEAD               text,\
                           AREMARK             text\
                           );",@"T_AUTHOR"];
    char *error = NULL;
    [self openDb];
    if (sqlite3_exec(dataBase, [createSQL UTF8String], 0, 0, &error) != SQLITE_OK) {
        NSLog(@"create table %@ error:%s",@"T_AUTHOR",error);
        sqlite3_close(dataBase);
        return NO;
    }
    sqlite3_close(dataBase);
    return YES;
}

+ (BOOL)insertAuthor:(Author*)author
{
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO %@ (ANAME, AINFO,AHEAD,AREMARK) VALUES ('%@','%@','%@','%@');", @"T_AUTHOR",author.AName, author.AInfo,author.AHeader, author.ARemark];
    char *error;
    [self openDb];
    if (sqlite3_exec(dataBase, [insertSQL UTF8String], 0, 0, &error) != SQLITE_OK) {
        NSLog(@"insert info into %@ error:%s",@"T_AUTHOR",error);
        sqlite3_close(dataBase);
        return NO;
    }
    return  YES;
}

+(NSInteger)getAidWithAname:(NSString*)aname
{
    NSString *selectSQL = [NSString stringWithFormat:@"select AID from %@ where ANAME = '%@';",@"T_AUTHOR",aname];
    NSMutableArray *dataArray = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self openDb];
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare(dataBase, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK) 
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            Author* a = [Author new];
            a.AID =  [[NSNumber numberWithInt:sqlite3_column_int(stmt, 0)] intValue];
            a.AName =  [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)];
            a.AInfo =  [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 2)];
            a.AHeader  = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 3)];
            a.ARemark  = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 4)];
            [dataArray addObject:a];
            [a release];
        }
    }
    sqlite3_finalize(stmt);
    sqlite3_close(dataBase);
    if ([dataArray count] < 1) {
        NSLog(@" data is nil");
        return -1;
    }
    [pool release];
    return [(Author*)[dataArray objectAtIndex:0] AID];
}

+(NSString*)geAnameWithAID:(NSInteger)aid
{
    NSString *selectSQL = [NSString stringWithFormat:@"select ANAME from %@ where AID = %d;",@"T_AUTHOR",aid];
    NSMutableArray *dataArray = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self openDb];
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare(dataBase, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK) 
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            Author* a = [Author new];
            a.AID =  [[NSNumber numberWithInt:sqlite3_column_int(stmt, 0)] intValue];
            a.AName =  [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)];
            a.AInfo =  [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 2)];
            a.AHeader  = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 3)];
            a.ARemark  = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 4)];
            [dataArray addObject:a];
            [a release];
        }
    }
    sqlite3_finalize(stmt);
    sqlite3_close(dataBase);
    if ([dataArray count] < 1) {
        NSLog(@" data is nil");
        return nil;
    }
    [pool release];
    return [(Author*)[dataArray objectAtIndex:0] AName];
}

+(NSArray*)AllAuthor
{
    NSString *selectSQL = [NSString stringWithFormat:@"select * from %@;",@"T_AUTHOR"];
    NSMutableArray *dataArray = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self openDb];
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare(dataBase, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK) 
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            Author* a = [Author new];
            a.AID =  [[NSNumber numberWithInt:sqlite3_column_int(stmt, 0)] intValue];
            a.AName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)];
            a.AInfo  = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 2)];
            a.AHeader  = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 3)];
            a.ARemark  = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 4)];
            [dataArray addObject:a];
            [a release];
        }
    }
    sqlite3_finalize(stmt);
    sqlite3_close(dataBase);
    if (!dataArray) {
        NSLog(@"department data is nil");
        return nil;
    }
    [pool release];
    return dataArray;
}

+(Author*)AuthorByAName:(NSString*)AName
{
    NSString *selectSQL = [NSString stringWithFormat:@"select * from %@ where ANAME = '%@';",@"T_AUTHOR",AName];
    NSMutableArray *dataArray = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self openDb];
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare(dataBase, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK) 
    {   
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            Author* a = [Author new];
            a.AID =  [[NSNumber numberWithInt:sqlite3_column_int(stmt, 0)] intValue];
            a.AName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)];
            a.AInfo  = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 2)];
            a.AHeader  = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 3)];
            a.ARemark  = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 4)];
            [dataArray addObject:a];
            [a release];
        }
    }
    sqlite3_finalize(stmt);
    sqlite3_close(dataBase);
    if (![dataArray count] < 0) {
        NSLog(@"department data is nil");
        return nil;
    }
    [pool release];
    return (Author*)[dataArray objectAtIndex:0];
}

#pragma mark - Poem
+(BOOL)CreatePoemTable
{
    NSString *createSQL = [NSString stringWithFormat:@"create table  if not exists %@\
                        (\
                        PID                 integer     primary key autoincrement not null,\
                        PAID                integer,\
                        PNAME               text,\
                        PCONTENT            text,\
                        PNOTE               text,\
                        PREMARK             text\
                        );",@"T_POEM"];
    char *error = NULL;
    [self openDb];
    if (sqlite3_exec(dataBase, [createSQL UTF8String], 0, 0, &error) != SQLITE_OK) {
        NSLog(@"create table %@ error:%s",@"T_POEM",error);
       sqlite3_close(dataBase);
        return NO;
    }
    sqlite3_close(dataBase);
    return YES;
}

+ (BOOL)insertPoem:(Poem*)poem
{
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO %@ (PAID, PNAME, PCONTENT,PNOTE,PREMARK) VALUES ('%d','%@','%@','%@','%@');", @"T_POEM",poem.PAid, poem.PName,poem.PContent, poem.PNote,poem.PRemark];
    char *error;
    [self openDb];
    if (sqlite3_exec(dataBase, [insertSQL UTF8String], 0, 0, &error) != SQLITE_OK) {
        NSLog(@"insert info into %@ error:%s",@"T_POEM",error);
        sqlite3_close(dataBase);
        return NO;
    }
    return  YES;
}

+(NSArray*)getPoemInfoWithPName:(NSString*)pname
{
    NSString *selectSQL = [NSString stringWithFormat:@"select * from %@ order by PNAME;",@"T_POEM"];
    NSMutableArray *dataArray = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self openDb];
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare(dataBase, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK) 
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            Poem* p = [Poem new];
            p.PNum =  [[NSNumber numberWithInt:sqlite3_column_int(stmt, 0)] intValue];
            p.PAid =  [[NSNumber numberWithInt:sqlite3_column_int(stmt, 1)] intValue];
            p.PName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 2)];
            p.PContent  = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 3)];
            p.PNote  = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 4)];
            p.PRemark  = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 5)];
            [dataArray addObject:p];
            [p release];
        }
    }
    sqlite3_finalize(stmt);
    sqlite3_close(dataBase);
    if (!dataArray) {
        NSLog(@"department data is nil");
        return nil;
    }
    [pool release];
    return dataArray;
}

+(BOOL)deletePoemInfoWithPName:(NSString*)pname
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ WHERE PID = '%d';",@"T_POEM",2];
    [self openDb];
    if(sqlite3_exec(dataBase, [sql UTF8String], 0, 0, NULL) != SQLITE_OK) 
    {
        sqlite3_close(dataBase);
        NSLog(@"error :%s",sqlite3_errmsg(dataBase)); 
		return NO;
	}    
    sqlite3_close(dataBase);
    return YES;

}

+(BOOL)deleteAllPoemWithTableName:(NSString*)tname
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@",tname];
    [self openDb];
    if(sqlite3_exec(dataBase, [sql UTF8String], 0, 0, NULL) != SQLITE_OK) 
    {
        sqlite3_close(dataBase);
        NSLog(@"error :%s",sqlite3_errmsg(dataBase)); 
		return NO;
	}    
    sqlite3_close(dataBase);
    return YES;
}



@end
