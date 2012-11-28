//
//  FileManagerController.h
//  SUSHIDO
//
//  Created by WANG Mengke on 10-6-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileManagerController : NSObject {

}

//utilites
+ (NSString *)documentPath;
+ (NSArray *)allFilesInFolder:(NSString *)folderName;
+ (NSArray *)allContentsInPath:(NSString *)directoryPath;
+ (NSArray *)allFilesInPathAndItsSubpaths:(NSString *)directoryPath;

//app 方法
+ (BOOL)isHeaderExist:(NSString*)headerName;
@end
