//
//  MyDBQueue.m
//  AncientProseAppreciate
//
//  Created by linlin on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyDBQueue.h"
#import "FMDatabase.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"
#import "FMDatabaseAdditions.h"

static MyDBQueue *gSharedInstance = nil;
@implementation MyDBQueue
@synthesize dbQueue;
-(id)init
{
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"poem.db"]];
    }
    return self;
}

-(void)dealloc
{
    [dbQueue release];// add by me
    self.dbQueue = nil;
    [super dealloc];
}

+(MyDBQueue*)sharedMydbQueue
{
    if (gSharedInstance == nil) {
        gSharedInstance = [[MyDBQueue alloc] init];
    }
    return gSharedInstance;
}

-(void)insertPoem:(NSArray*)poems
{
    [self.dbQueue inTransaction:^(FMDatabase *db,BOOL *roolBack){
        if (![db open]) 
        {
            NSLog(@"%@",[db lastErrorMessage]);
            return ;
        }
        else
        {
            for (Poem* poem in poems)
            {
                NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO %@ (PAID, PNAME, PCONTENT,PNOTE,PREMARK) VALUES (?,?,?,?,?');",@"T_POEM"];
                [db executeUpdate:insertSQL,poem.PAid, poem.PName,poem.PContent, poem.PNote,poem.PRemark];
            }
        }
    }];
}

-(void)insertAuthor:(NSArray*)authors
{
    [self.dbQueue inTransaction:^(FMDatabase *db,BOOL *roolBack){
        if (![db open]) 
        {
            NSLog(@"%@",[db lastErrorMessage]);
            return ;
        }
        else
        {
            for (Author* author in authors)
            {
                NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO %@ (ANAME, AINFO,AHEAD,AREMARK) VALUES (?,?,?,?);", @"T_AUTHOR"];
                [db executeUpdate:insertSQL,author.AName, author.AInfo,author.AHeader, author.ARemark];
            }
        }
    }];
}
@end
