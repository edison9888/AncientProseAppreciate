//
//  MyDBQueue.h
//  AncientProseAppreciate
//
//  Created by linlin on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileDataBase.h"
@class FMDatabaseQueue;
//线程安全部分的操作
@interface MyDBQueue : NSObject
{
    FMDatabaseQueue* dbQueue;
}

@property (nonatomic, retain)FMDatabaseQueue *dbQueue;

+(MyDBQueue*)sharedMydbQueue;

-(void)insertPoem:(NSArray*)poems;

-(void)insertAuthor:(NSArray*)authors;
@end
