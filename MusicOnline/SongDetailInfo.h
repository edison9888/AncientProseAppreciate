//
//  SongDetailInfo.h
//  AncientProseAppreciate
//
//  Created by linlin on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SongDetailInfo : NSObject
@property(nonatomic,retain)NSString* MusicName;
@property(nonatomic,retain)NSString* MusicURL;
@property(nonatomic,retain)NSString* MusicSize;
@property(nonatomic)BOOL isP2P;//是否是p2p下载
@end
