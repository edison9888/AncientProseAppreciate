//
//  MusicListSearch.h
//  AncientProseAppreciate
//
//  Created by linlin on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "SongDetailInfo.h"
@protocol MusicSearchStatus;
@interface MusicListSearchHelper : NSObject<NSXMLParserDelegate>
{
    id<MusicSearchStatus>    delegate;
    ASIHTTPRequest          *musicRequest;
    NSString                *musicName;
    NSMutableArray          *musicList;
#pragma xml解析
    NSString                *rootElement;  
    NSString                *currentElement;
    NSString                *currentUrl;//当前进行拼凑的下载地址
    SongDetailInfo          *AudioFile;//获取搜索到一首歌曲
    int                     count;//用来检查加载歌曲信息是否完成
}
@property(nonatomic,retain)NSString         *musicName;
@property(nonatomic,retain)NSString         *rootElement;
@property(nonatomic,retain)NSString         *currentElement;
@property(nonatomic,retain)NSString         *currentUrl;
@property(nonatomic,retain)NSMutableArray   *musicList;
@property(nonatomic,retain)SongDetailInfo   *AudioFile;
@property(nonatomic,retain)id<MusicSearchStatus>    delegate;
- (id)initWithDelegate:(id<MusicSearchStatus>)      delegate;
-(void)beginSearchMusicByName;
@end

@protocol MusicSearchStatus <NSObject>
-(void)didMusicSearchBegin;
-(void)didMusicSearchfinishedWithMusicList:(NSMutableArray*)MusicList;
@end