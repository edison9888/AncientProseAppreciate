//
//  MusicList+search.m
//  AncientProseAppreciate
//
//  Created by linlin on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MusicList+search.h"
//2个session 
//一个是网络歌曲列表  
//一个是本地歌曲列表
//一个searchBar主要用于在线搜索音乐
@implementation MusicList_search
-(id)init
{
    self = [super init];
    if (self) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;   
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MusicPlay+SearchBg.jpg"]];
        self.tableView.rowHeight = 80.0f;
        
        musicSearchHelper = [[MusicListSearchHelper alloc] initWithDelegate:self];
        [musicSearchHelper setMusicName:@"爱的供养"];
        [musicSearchHelper beginSearchMusicByName];
    }
    return self;
}

#pragma mark - TableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == 0) {
        return [netMusicList count];
    }else{
        return 10;
    }
}

//在这里关注内存泄露的问题 主要是涉及到Cell 的重复使用
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        cell.imageView.image = [UIImage imageNamed:@"AP_baidu.png"];
        cell.textLabel.text = [(SongDetailInfo*)[netMusicList objectAtIndex:indexPath.row] MusicName];
    }else{
        cell.imageView.image = [UIImage imageNamed:@"Multimedia.png"];
    }
    

    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    iPhoneStreamingPlayerViewController* player = [[iPhoneStreamingPlayerViewController alloc] init];
    player.musicurl = [(SongDetailInfo*)[netMusicList objectAtIndex:indexPath.row] MusicURL];
    NSLog(@"%@",player.downloadSourceField.text);
    [self.navigationController pushViewController:player animated:YES];
    [player release];
}

#pragma mark - MusicSearchStatusDelegate
-(void)didMusicSearchBegin
{
    NSLog(@"didMusicSearchBegin");
}
-(void)didMusicSearchfinishedWithMusicList:(NSMutableArray*)MusicList
{
    netMusicList = [[NSArray alloc] initWithArray:MusicList];
    [self.tableView reloadData];
}
@end
