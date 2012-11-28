//
//  MusicListSearch.m
//  AncientProseAppreciate
//
//  Created by linlin on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MusicListSearchHelper.h"
#import "Utility.h"
#import "CommonHelper.h"
@implementation MusicListSearchHelper
@synthesize musicName,delegate,currentElement,rootElement,AudioFile,currentUrl,musicList;
- (id)initWithDelegate:(id<MusicSearchStatus>) theDelegate
{
    self = [super init];
    if (self) {
        self.delegate = theDelegate;
        self.rootElement = [[NSString alloc] init];
        self.currentElement = [[NSString alloc] init];
        self.musicList = [[NSMutableArray alloc] init];
        count = 0;
    }
    return self;
}

-(void)beginSearchMusicByName
{
    NSString *requestUrl=BAIDUMUSIC_API(@"心湖雨又风");
    NSLog(@"requestUrl = %@",requestUrl);
    ASIHTTPRequest *theRequest=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [theRequest setDefaultResponseEncoding:NSUTF8StringEncoding];//完美解决中文编码乱码的问题
    [theRequest addRequestHeader:@"Content-Type" value:@"text/xml"];
    [theRequest setUsername:@"Search"];
    [theRequest setRequestMethod:@"GET"];
    [theRequest setDelegate:self];
    [theRequest startAsynchronous];
    [self.delegate didMusicSearchBegin];
}

#pragma mark - ASIHTTPRequestDelegate
//请求过程中出现错误 这里先执行系统的函数
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"errorCode:%d",[error code]);
    switch ([error code]) {
        case ASIConnectionFailureErrorType:
            NSLog(@"ASIConnectionFailureErrorType");
            break;
        case ASIRequestTimedOutErrorType:
            NSLog(@"ASIRequestTimedOutErrorType");
            break;
        case ASIAuthenticationErrorType:
            NSLog(@"ASIAuthenticationErrorType");
            break;      
        case ASIRequestCancelledErrorType:
            break;
        case ASIUnableToCreateRequestErrorType:
            NSLog(@"ASIUnableToCreateRequestErrorType");
            break;
        default:
            break;
    }
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"requestStarted");
}

- (void)requestReceivedResponseHeaders:(ASIHTTPRequest *)request
{
    if ([request.username isEqualToString:@"SIZE"]) 
    {
        count++;
        SongDetailInfo *MusicFile =  [request.userInfo objectForKey:@"File"];
        for(SongDetailInfo *file in self.musicList)
        {
            if([file.MusicURL isEqualToString:[MusicFile MusicURL]])
            {
                //把文件名称提取出来,这里返回的文件名称是乱码，用UTF-8和gb2312和网上的其它方法都不行，有的朋友说是文件的问题，文件是在Windows上创建的放到mac下，自动的文件名称就成乱码了，这个真不清楚，我只是提取了文件类型，有明白的朋友告诉我一下哈，谢谢
                NSString *fileName=[[request responseHeaders] objectForKey:@"Content-Disposition"];
                CFShow([request responseHeaders]);
                NSLog(@"fileName = %@",fileName);
                NSInteger firstIndex=[fileName rangeOfString:@"."].location;
                fileName=[fileName substringFromIndex:firstIndex];
                NSInteger lastIndex=[fileName rangeOfString:@"\""].location;
                fileName=[fileName substringToIndex:lastIndex];
                file.MusicName=[file.MusicName stringByAppendingString:fileName];
                NSLog(@"MusicName = %@",file.MusicName);
                file.MusicSize=[CommonHelper getFileSizeString:[[request responseHeaders] objectForKey:@"Content-Length"]];
                NSLog(@"MusicSize = %@",file.MusicSize);
            }
        }
        if (count == [self.musicList count]) {
            NSLog(@"%d",count);
            [self.delegate didMusicSearchfinishedWithMusicList:self.musicList];
            count = 0;
        }
        [request clearDelegatesAndCancel];
        [request cancel];
    }

}

//请求结束后的返回的字符串字符串
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"request.username = %@",request.username);
    NSMutableString *newXML=[[NSMutableString alloc] initWithData:[request responseData] encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    NSLog(@"newXML1 = %@",newXML);
    [newXML replaceCharactersInRange:[newXML rangeOfString:@"gb2312"] withString:@"utf-8"];
    //NSLog(@"newXML2 = %@",newXML);
    
    //NSXMLParser *musicParser=[[NSXMLParser alloc] initWithData:[newXML dataUsingEncoding:NSUTF8StringEncoding]];
    NSXMLParser *musicParser=[[NSXMLParser alloc] initWithData:[request responseData]];
    [musicParser setDelegate:self];
    [musicParser parse];
    [musicParser release];
    [newXML release];
}

#pragma mark - XML解析
//解析错误
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"%d",[parseError code]);
}

//开始解析
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"didStartElement");
    //NSLog(@"elementName = %@",elementName);
    self.currentElement=elementName;
    if([elementName isEqualToString:@"durl"]||[elementName isEqualToString:@"p2p"])
    {
        self.rootElement=elementName;
        self.AudioFile=[[SongDetailInfo alloc] init];
        self.AudioFile.MusicSize=@"未知";
        self.AudioFile.MusicName=self.musicName;
        self.AudioFile.MusicURL=@"";
        self.AudioFile.isP2P=NO;
    }
}

//3种对象URL DURL P2P,
//一般durl没有内容的连接不能用，所以就解析durl
-(void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    NSString *tmpurl=[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    NSLog(@"++++++++++++%@",self.rootElement);
    if([self.rootElement isEqualToString:@"durl"])
    {
        if([self.currentElement isEqualToString:@"encode"])
        {
            self.currentUrl=tmpurl;
            NSRange range=[self.currentUrl rangeOfString:[self.currentUrl lastPathComponent]];
            self.currentUrl=[self.currentUrl substringToIndex:range.location];
        }
        if([self.currentElement isEqualToString:@"decode"])
        {
            self.currentUrl=[self.currentUrl stringByAppendingString:tmpurl];
        }
        self.AudioFile.MusicURL=self.currentUrl;
    }
    if([self.rootElement isEqualToString:@"p2p"])
    {
        if([self.currentElement isEqualToString:@"url"])
        {
            self.currentUrl=tmpurl;
            self.AudioFile.MusicURL=self.currentUrl;
        }
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSLog(@"didEndElement");
    if([elementName isEqualToString:@"durl"]||[elementName isEqualToString:@"p2p"])
    {
        if((![self.AudioFile.MusicURL isEqualToString:@""])&&self.AudioFile.MusicURL!=nil)
        {
            [self.musicList addObject:self.AudioFile];
        }
        [self.AudioFile release];
        self.AudioFile = nil;
        self.rootElement=@"";
        self.currentElement=@"";
    }
}

//得到可下载音乐地址列表后，对每个下载文件地址进行一次请求，获取每个文件的名字和大小
-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    for(SongDetailInfo *file in self.musicList)
    {
        NSLog(@"===============%@=================",file.MusicSize);
        if([file.MusicSize isEqualToString:@"未知"] || file.MusicSize==nil)
        {
            NSLog(@"MusicURL = %@",file.MusicURL);
            ASIHTTPRequest *urlRequest=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:file.MusicURL]];
            [urlRequest setDefaultResponseEncoding:NSUTF8StringEncoding];//完美解决中文编码乱码的问题
            [urlRequest setDefaultResponseEncoding:NSUTF8StringEncoding];
            [urlRequest setDelegate:self];
            [urlRequest setDidReceiveResponseHeadersSelector:@selector(requestReceivedResponseHeaders:)];
            [urlRequest setUserInfo:[NSDictionary dictionaryWithObject:file forKey:@"File"]];
            [urlRequest setUsername:@"SIZE"];
            [urlRequest startAsynchronous];
        }
    }
}
@end
