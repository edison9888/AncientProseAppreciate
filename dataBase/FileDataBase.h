//
//  FileDataBase.h
//  AncientProseAppreciate
//
//  Created by 武 帮民 on 12-4-14.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
@interface Poem :NSObject
{
    NSInteger   PNum;
    NSString*   PName;
    NSString*   PContent;
    NSString*   PNote;
    NSString*   PRemark; 
    NSInteger  PAid;//作者
}
@property(nonatomic,retain)NSString*   PName;
@property(nonatomic,retain)NSString*   PContent;
@property(nonatomic,retain)NSString*   PNote;
@property(nonatomic,retain)NSString*   PRemark; 
@property NSInteger   PAid;
@property NSInteger   PNum;
@end


@interface Author :NSObject
{
    NSInteger  AID;
    NSString*   AName;
    NSString*   AInfo;
    NSString*   ARemark;
    NSString*   AHeader;  
}
@property NSInteger   AID;
@property(nonatomic,retain)NSString*   AName;
@property(nonatomic,retain)NSString*   AInfo;
@property(nonatomic,retain)NSString*   ARemark;
@property(nonatomic,retain)NSString*   AHeader;
@end

@interface FileDataBase : NSObject {
    
}

+ (NSString *)dataBasePath;

+(BOOL)CreatePoemTable;
+(BOOL)CreateAuthorTable;

+ (BOOL)insertAuthor:(Author*)author;
+ (BOOL)insertPoem:(Poem*)poem;

+(NSArray*)AllAuthor;
+(Author*)AuthorByAName:(NSString*)AName;
+(NSInteger)getAidWithAname:(NSString*)aname;

+(NSArray*)getPoemInfoWithPName:(NSString*)pname;

+(BOOL)deletePoemInfoWithPName:(NSString*)pname;

+(BOOL)deleteAllPoemWithTableName:(NSString*)tname;
@end
