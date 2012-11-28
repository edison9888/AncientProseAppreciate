//
//  testBaiduMusicBox.h
//  AncientProseAppreciate
//
//  Created by linlin on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
@interface testBaiduMusicBox : NSObject
{
    ASIHTTPRequest          *musicRequest;
    
    NSMutableArray *listName;
	NSMutableArray *listSinger;
	NSMutableArray *listAlbum;
	NSMutableArray *listURL;
	NSMutableArray *listSpeed;
	NSMutableArray *listSize;
}

-(NSArray*) KeyWordsForSongs:(NSString*)myKeyWords pageNavi:(int)myPageNavi;
-(NSString*)decodeBaiduURL:(NSString*)myEncodeURL;
-(NSString*) DownPageURLToMusicFileURL:(NSString *)myDownpage;
-(void)DataListInit:(NSString *)songs PageNav:(int)page;
@end
