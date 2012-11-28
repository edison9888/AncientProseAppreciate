//
//  testBaiduMusicBox.m
//  AncientProseAppreciate
//
//  Created by linlin on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "testBaiduMusicBox.h"

@implementation testBaiduMusicBox
//方法类型：自定义方法
//编   写：安细军
//方法功能：从百度网站上搜索指定关键字的音乐，获取音乐链接网址url和相关的音乐信息
-(NSArray*) KeyWordsForSongs:(NSString*)myKeyWords pageNavi:(int)myPageNavi
{	
	int pageNavi = myPageNavi; //页码
    NSString * keyWords = myKeyWords; //关键字	
	//返回数组定义
    NSMutableArray * mySongs = [NSMutableArray arrayWithCapacity:15];	
    
    //创建字符串
    NSString * myURL = [NSString stringWithFormat:@"http://mp3.baidu.com/m?f=ms&rf=idx&tn=baidump3&ct=134217728&lf=&rn=&word=%@&lm=0&pn=%d",keyWords,pageNavi];
    NSLog(@"myURL = %@",myURL);
    
	//UTF8 to gb2312
    myURL = [myURL stringByAddingPercentEscapesUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    NSLog(@"myURL = %@",myURL);
    
    ASIHTTPRequest *myRequest = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:myURL]] autorelease];
    [myRequest startSynchronous];
	
    //如果发生错误，返回nil
    if ([myRequest error]) return nil;    
	
    //编码转换 gb2313 to UTF
    NSData * myResponseData = [myRequest responseData];
	
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
    
    NSString * myResponseStr = [[NSString alloc] initWithData:myResponseData encoding:enc];	
	NSLog(@"myResponseStr = %@",myResponseStr);
    
    
    //如果百度告诉我没有找到？
    NSRange myRange;
    myRange = [myResponseStr rangeOfString:@"抱歉，没有找到与"];
    if (myRange.location != NSNotFound) {
		
		UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" 
													 message:@"对不起，没有找到你需要的音乐!" 
													delegate:self cancelButtonTitle:@"确定" 
										   otherButtonTitles:nil];
		[alert show];
		[alert release];
		
        return nil;
    }	
    //将 源代码按 ” <td class=d><a href= “ 切割
    NSMutableArray * myResponseArrForSinger = (NSMutableArray *)[myResponseStr componentsSeparatedByString:@"<td class=d><a href="];
    
    NSLog(@"%d",[myResponseArrForSinger count]);
    for (NSString* s in myResponseArrForSinger) {
        NSLog(@"s = %@",s);
    }
    //去头去尾
    if ([myResponseArrForSinger count]>=2) {
        [myResponseArrForSinger removeObjectAtIndex:0];
        [myResponseArrForSinger removeObjectAtIndex:[myResponseArrForSinger count]-1];
    }
	
    //按段处理
    for (int i=0; i<[myResponseArrForSinger count]; i++) {
        //
        @try {
			
            //把段按 “ .html" target="_blank"> ” 切割
            NSMutableArray * mySubArr = (NSMutableArray *)[[myResponseArrForSinger objectAtIndex:i] componentsSeparatedByString:@".html\" target=\"_blank\">"];
			
            //处理歌曲下载页面的URL
            NSArray * myURLTmpArr = [[mySubArr objectAtIndex:0] componentsSeparatedByString:@"\" title=\"请点击左键！来源网址：  "];
            for (NSString* s in myURLTmpArr) {
                NSLog(@"s = %@",s);
            }
            myURLTmpArr = [[mySubArr objectAtIndex:0] componentsSeparatedByString:@"\""];
			
            for (NSString* s in myURLTmpArr) {
                NSLog(@"s = %@",s);
            }
            
            NSMutableString * SongsURL = [myURLTmpArr objectAtIndex:1]; 			
            NSLog(@"SongsURL = %@",SongsURL);
            //常量定义 段的意义
            const int Const_Songs = 0;
            const int Const_Singer = 1;
            const int Const_Album = 4;
            //变量定义
            NSMutableString * SongsName = (NSMutableString*)@"";
            NSString * SongsSinger = @"";
            NSString * SongsAlbum = @"";
            NSString * SongsSpeed = @"";
            NSString * SongsSize = @"";
			
            //处理 歌曲大小
            NSMutableArray * mySizeArr = (NSMutableArray*)[[mySubArr objectAtIndex:([mySubArr count]-1)] componentsSeparatedByString:@"<td>"];
            if ([mySizeArr count]>=2)
			{
                SongsSize = [mySizeArr objectAtIndex:([mySizeArr count]-2)];     
                NSLog(@"SongsSize %@",SongsSize);
            }
			
            //处理 歌曲链接速度图片
            @try {
				
                if ([mySubArr count]>=3) {
                    if ([mySubArr objectAtIndex:([mySubArr count]-1)]!=nil) {
						
                        NSMutableArray * mySpeedArr = (NSMutableArray*)[[mySubArr objectAtIndex:([mySubArr count]-1)]    componentsSeparatedByString:@"<td class=spd><img src=\"http://img.baidu.com/img/mp3/"];
						
                        if ([mySpeedArr count]>0) 
                            if ([mySpeedArr objectAtIndex:1]!=nil) 
                                mySpeedArr = (NSMutableArray*)[[mySpeedArr objectAtIndex:1]    componentsSeparatedByString:@"\"></td>"];
						
                        if ([mySpeedArr objectAtIndex:0]!=nil)
                            SongsSpeed = [mySpeedArr objectAtIndex:0];		
                        
                    }
                }
				
            }
            @catch (NSException * e) {
                //none
            }
            @finally {
                //none
            }
			
            //处理 歌曲名
            NSMutableArray * myTmpArr = (NSMutableArray *)[[mySubArr objectAtIndex:Const_Songs] componentsSeparatedByString:@"\"return ow(event,this)\"  target=\"_blank\">"];
            myTmpArr = (NSMutableArray *)[[myTmpArr objectAtIndex:1] componentsSeparatedByString:@"</a></td>"];
            SongsName = [myTmpArr objectAtIndex:0];
            NSString * mySubStr;
			
            //处理 歌手名
            if ([mySubArr count]>1) {
                mySubStr = [mySubArr objectAtIndex:Const_Singer];
                SongsSinger = mySubStr;
                NSLog(@"mySubStr %@",mySubStr);
            };
			
            //处理 专辑名
            if ([mySubArr count]>=5) {
                mySubStr = [mySubArr objectAtIndex:Const_Album];
                NSMutableArray * mySubSubArr = (NSMutableArray *)[mySubStr componentsSeparatedByString:@"</a>"];
                mySubStr = [mySubSubArr objectAtIndex:0];
                SongsAlbum = mySubStr;
                NSLog(@"SongsAlbum %@",SongsAlbum);
				
            } else {
                SongsAlbum = @"";
            };
			
            //处理: 歌曲名中如果包含歌词
            NSMutableString *tmp = [NSMutableString stringWithString:SongsName];
            NSRange range = [tmp rangeOfString:@"<br><font color=\"#999999\" class=f10>"];
            if (range.location != NSNotFound)
			{
                range.length = SongsName.length - range.location;
                
                [tmp deleteCharactersInRange:range];
				SongsName = tmp;
            }             			
            
            NSString * FinalStr = [[[NSString alloc] initWithFormat:@"<头>%@<分割>%@<分 割>%@<分割>%@<分割>%@<分割>%@",
                                    SongsName,SongsSinger,SongsAlbum,SongsURL,SongsSpeed,SongsSize] autorelease];				
            FinalStr = [FinalStr stringByReplacingOccurrencesOfString:@"<font color=\"#c60a00\">" withString:@""];    			
			FinalStr = [FinalStr stringByReplacingOccurrencesOfString:@"</font>" withString:@""];            
			FinalStr = [FinalStr stringByReplacingOccurrencesOfString:@"</a>" withString:@""];            
			FinalStr = [FinalStr stringByReplacingOccurrencesOfString:@"<a href=\"http://mp3.baidu.com/singerlist/" withString:@""];            
			FinalStr = [FinalStr stringByReplacingOccurrencesOfString:@" " withString:@""];            
			FinalStr = [FinalStr stringByReplacingOccurrencesOfString:@"'" withString:@"'"];            
			FinalStr = [FinalStr stringByReplacingOccurrencesOfString:@"<头>  " withString:@"<头>"];            
			FinalStr = [FinalStr stringByReplacingOccurrencesOfString:@"<头>" withString:@""];            
			FinalStr = [FinalStr stringByReplacingOccurrencesOfString:@"&" withString:@"&"];            
			FinalStr = [FinalStr stringByReplacingOccurrencesOfString:@"</td>" withString:@""];            
			FinalStr = [FinalStr stringByReplacingPercentEscapesUsingEncoding:enc];
            
            NSLog(@"FinalStr = %@",FinalStr);
            [mySongs addObject:FinalStr];            
        }
        @catch (NSException * e) {
            //    没有错误处理， 发生错误就直接丢掉
        }
        @finally {
            //    none
        }		
    }			
    [myResponseStr release];
    
	return mySongs;
}

@end
