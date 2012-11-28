//
//  AuthoDetailView.m
//  AncientProseAppreciate
//
//  Created by 武 帮民 on 12-4-12.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "AuthoDetailView.h"

#define POETRYINTRODUCE 0
#define RELATIVEARTICAL 1
@implementation AuthoDetailView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        article = [[NSArray alloc] initWithObjects:@"静夜思",@"蜀道难",@"将进酒",@"望庐山瀑布",@"春思", nil];
    }
    return self;
}

- (void)dealloc
{
    [headgifView stopAnimating];
    [super dealloc];
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
    //self.navigationItem.leftBarButtonItem = BARBUTTON(@"11", @selector(rightAction:));
    //self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"BackBtn.png"];
    
	headgifView.animationImages = [NSArray arrayWithObjects:	
									 [UIImage imageNamed:@"1.gif"],
									 [UIImage imageNamed:@"2.gif"],
									 [UIImage imageNamed:@"3.gif"],
									 [UIImage imageNamed:@"4.gif"],
									 [UIImage imageNamed:@"5.gif"], 
									 [UIImage imageNamed:@"6.gif"], nil];
	
	headgifView.animationDuration = 1.25;
	headgifView.animationRepeatCount = 0;
	[headgifView startAnimating];
    [headView addSubview:headgifView];
    [headgifView release];
    
    ratingView.rating = 4.5;
    
    myTableView.tableHeaderView = headView;
    UIImageView* bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"authorbg.jpg"]];
    myTableView.backgroundView = bg;
    [bg release];
    self.title = @"诗人介绍";
    PoetryName.text = @"李白";
    //这里应该从数据库读取
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

#pragma mark - TableView Delegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == POETRYINTRODUCE) {
        return @"人物介绍:";
    }else {
        return @"相关作品:";
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == POETRYINTRODUCE) {
        return 1;
    }else{
        return [article count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle  = UITableViewCellSelectionStyleNone;

    
    if (indexPath.section == POETRYINTRODUCE) {
        for (UIView* view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        UITextView* introText = [[UITextView alloc] init];
        [introText setText:@"李白\n（701-762），字太白，号青莲居士。生于绵州彰明县青莲乡。李白青年时即漫游全国各地，天宝初年，因吴筠及贺知章推荐，唐玄宗召为翰林供奉承，但不久又赐金放还。安\史之乱后，被牵连累，长流放于夜郎。晚年漂泊东南一带，依附当涂令李阳冰，公元762年病死于当涂。李白才华横溢，性格豪放，刻苦向前人学习，善于从民间文学中汲取营养和素材。他的诗风格豪放，雄奇壮丽，表现了浪漫主义色彩，是继屈原之后我国古代最伟大的浪漫主义诗人。被后人称之为“诗仙”。"];
        introText.frame = CGRectMake(0, 0, 300, 100);
        introText.font = [UIFont systemFontOfSize:14];
        introText.backgroundColor = [UIColor clearColor];
        introText.editable = NO;
        [cell.contentView addSubview:introText];
        [introText release];
    }else{
        NSString *name = [article objectAtIndex:indexPath.row];
        cell.textLabel.text = name; 
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }


    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == POETRYINTRODUCE) {
        return 100;
    }else{
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
}

@end
