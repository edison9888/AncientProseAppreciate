//
//  MyDB.h
//  AncientProseAppreciate
//
//  Created by linlin on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"
#import "FileDataBase.h"
#import "FMDatabaseAdditions.h"
//数据库的基本操作 非线程安全的
@interface MyDB : NSObject
{
    FMDatabase* db;
}

@property(readonly) FMDatabase* db;

-(int)AidWithAName:(NSString*)authorname;
-(NSString*)ANameWithAid:(NSString*)aid;
@end
