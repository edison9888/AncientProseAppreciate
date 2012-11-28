//
//  MyDB.m
//  AncientProseAppreciate
//
//  Created by linlin on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyDB.h"


@implementation MyDB
@synthesize db;
-(id)init
{
    self = [super init];
    if (self) {
        db = [[FMDatabase alloc] initWithPath:[FileDataBase dataBasePath]];
        if (![db open]) {
            NSLog(@"Could not open db:%@  %@",[db lastErrorCode],[db lastErrorMessage]);
        }else{
            [db setShouldCacheStatements:YES];
        }
    }
    return self;
}

-(void)dealloc
{
    [db close];
    [db release];
    db = nil;
    [super dealloc];
}

-(int)AidWithAName:(NSString*)authorname
{
    NSString* sql = [NSString stringWithFormat:@"SELECT AID FROM T_AUTHOR WHERE ANAME = ?"];
    FMResultSet *rs = [db executeQuery:sql,authorname];
    if ([db hadError]) {
        return 0;
    }else{
        [rs next];
        return [rs intForColumnIndex:0];
    }
}

-(NSString*)ANameWithAid:(NSString*)aid
{
    NSString* sql = [NSString stringWithFormat:@"SELECT ANAME FROM T_AUTHOR WHERE AID = ?"];
    FMResultSet *rs = [db executeQuery:sql,aid];
    if ([db hadError]) {
        return nil;
    }else{
        [rs next];
        return [rs objectForColumnIndex:0];
    }
}
@end
