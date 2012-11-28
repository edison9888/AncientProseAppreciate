//
//  FileManagerController.m
//  SUSHIDO
//
//  Created by WANG Mengke on 10-6-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileManagerController.h"


@implementation FileManagerController

+ (NSString *)documentPath{
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Documents"];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

+ (NSArray *)allFilesInFolder:(NSString *)folderName{
	return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[self documentPath] stringByAppendingPathComponent:folderName] error:nil];
}

+ (NSArray *)allContentsInPath:(NSString *)directoryPath{
	return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
}

+ (NSArray *)allFilesInPathAndItsSubpaths:(NSString *)directoryPath{
	NSMutableArray *allContentsPathArray = [[[NSFileManager defaultManager] subpathsAtPath:directoryPath] mutableCopy];
	BOOL isDir = NO;
	for (int i = [allContentsPathArray count] - 1;i>=0;i--) {
		NSString *path = [allContentsPathArray objectAtIndex:i];
		if (![[NSFileManager defaultManager] fileExistsAtPath:[directoryPath stringByAppendingPathComponent:path] isDirectory:&isDir] || isDir) {
			[allContentsPathArray removeObject:path];
			//isDir = NO;
		}
	}
	return allContentsPathArray;
}

+ (BOOL)isHeaderExist:(NSString*)headerName
{
    if (![[NSBundle mainBundle] pathForResource:headerName ofType:@"jpg"]) 
    {
        return NO;
    }
    return YES;
}
@end
