//
//  Entertainment.m
//  AncientProseAppreciate
//
//  Created by user on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Entertainment.h"
#import "MusicList+search.h"
#import "testBaiduMusicBox.h"
#define MUSIC       10000 
#define RADIO       10001 
#define VIDEO       10002
#define TCODE       10003
#define WEIBO       10004

#define CELL_TOP_LABEL_TAB      1111
#define CELL_BOTTOM_LABEL_TAB   1112
@implementation Entertainment

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        entertainmentItem = [[NSArray alloc] initWithObjects:@"在线音乐",@"在线视频",@"收听广播",@"玩转二维码",nil];
        //headView
        UIView   *headView  = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.f, 40.f)] autorelease];
        UILabel  *headLabel = [[[UILabel alloc] initWithFrame:CGRectMake(8.0f, 3.0f, 320.0f, 40.0f)] autorelease];
        [headLabel setText:@"娱乐生活"];
        [headLabel setTextAlignment:UITextAlignmentCenter];
        [headLabel setTextColor:[UIColor whiteColor]];
        [headLabel setBackgroundColor:[UIColor clearColor]];
        [headLabel setShadowColor:[UIColor blackColor]];
        [headLabel setShadowOffset:CGSizeMake(-3, -3)];
        [headLabel setFont:[UIFont boldSystemFontOfSize:22]];
        [headView addSubview:headLabel];
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.rowHeight = 80.0f;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradientBackground.png"]];
        self.tableView.tableHeaderView = headView;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - TableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [entertainmentItem count];
}

//在这里关注内存泄露的问题 主要是涉及到Cell 的重复使用
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];

    }
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicator.png"]];
    cell.accessoryView.frame = CGRectMake(cell.accessoryView.frame.origin.x - 15, cell.accessoryView.frame.origin.y, cell.accessoryView.frame.size.width, cell.accessoryView.frame.size.height-15);
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.text = [entertainmentItem objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = @"音乐！放松你的心情";
    if (indexPath.row == 0) {
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topRow.png"]] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topRowSelected.png"]] autorelease];
    }else if(indexPath.row == [entertainmentItem count] - 1){
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottomRow.png"]] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottomRowSelected.png"]] autorelease];
    }else{
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"middleRow.png"]] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"middleRowSelected.png"]] autorelease];
    }
    
    NSString* imageName = [NSString stringWithFormat:@"AP_Cell%d",indexPath.row];
    cell.imageView.image = [UIImage imageNamed:imageName];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row +10000) {
        case MUSIC:
        {
            MusicList_search* listView = [[MusicList_search alloc] init];
            [self.navigationController pushViewController:listView animated:YES];
            [listView release];
            break;
        }
        case RADIO:
        {
            break;
        }
        case VIDEO:
        {
            break;
        }
        case WEIBO:
        {
            break;
        }
        case TCODE:
        {
            break;
        }
        default:
            break;
    }
}
@end
