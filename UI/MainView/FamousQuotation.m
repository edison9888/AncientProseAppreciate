//
//  FamousQuotation.m
//  AncientProseAppreciate
//
//  Created by user on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FamousQuotation.h"
#import "AnimatedGif.h"
#import "FileDataBase.h"
#import "MyDBQueue.h"
#import "MyDB.h"
@implementation FamousQuotation

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSString* path =[[NSBundle mainBundle] pathForResource:@"mingju" ofType:@"txt"];
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);  
        NSString* retStr = [NSString stringWithContentsOfFile:path encoding:enc error:0]; 
        NSLog(@"mingju====%@====",[retStr substringWithRange:NSMakeRange(26,2)]);
        //NSLog(@"\n%@",retStr);
        NSMutableArray* mingjuArray = [NSMutableArray arrayWithArray:[retStr componentsSeparatedByString:[retStr substringWithRange:NSMakeRange(26, 2)]]];
        //[mingjuArray removeLastObject];
        NSLog(@"cnt = %d",[mingjuArray count]);
        NSMutableArray* authorArray = [[NSMutableArray alloc] init];
        NSMutableArray* poemArray =  [[NSMutableArray alloc] init];
        for (NSString* s in mingjuArray) {
            //NSLog(@"s = %@",s);
            //NSLog(@"%@",[s substringFromIndex:2]);

            NSArray* item = [s componentsSeparatedByString:@"."];
            //NSLog(@"ct = %d",[item count]);
            //NSLog(@"%@",[item objectAtIndex:1]);
         
            NSRange range = [[item objectAtIndex:1] rangeOfString:@"("];
            NSString* p = [NSString stringWithString:[[item objectAtIndex:1] substringToIndex:range.location]];
            NSString* a = [NSString stringWithString:[[item objectAtIndex:1] substringFromIndex:range.location]];
            p = [p stringByReplacingOccurrencesOfString:@"，" withString:@"，\n"];
            p = [p stringByReplacingOccurrencesOfString:@"。" withString:@"。\n"];
            
            a = [a stringByReplacingOccurrencesOfString:@"(" withString:@""];
            a = [a stringByReplacingOccurrencesOfString:@")" withString:@""];
//            NSLog(@"---\n%@",p);
//            NSLog(@"---\n%@",a);
//            NSLog(@"---%d",a.length);
            if (a.length == 8) {
                a = @"陆游";
            }

            [authorArray addObject:a];
            [poemArray addObject:p];
//            Poem* poem = [Poem new];
//            poem.PAid = 1;
//            poem.PName = @"静夜思";
//            poem.PContent = @" 窗前明月光，\n 疑是地上霜。";
//            poem.PNote = @"注解";
//            poem.PRemark = @"备注";
//            [FileDataBase insertPoem:poem];
//            [poem release];
        }
        
        //array 去重
        //NSArray *test = [NSArray arrayWithObjects:@"a",@"b",@"c",@"a",@"b",nil];
        NSDictionary *dd = [NSDictionary dictionaryWithObjects:authorArray forKeys:authorArray];
        NSArray *result =  [dd allKeys];
        NSMutableArray* authorinfo = [[NSMutableArray alloc] init];
        for (NSString* a in result)
        {
            Author * author = [[Author alloc] init];
            author.AName = a;
            author.AInfo = @"";
            author.AHeader = [NSString stringWithFormat:@"%@.jpg",a];
            author.ARemark = @"";
            [authorinfo addObject:author];
            [author release];
        }
    
        MyDBQueue* dbQueue = [MyDBQueue sharedMydbQueue];
        //[dbQueue insertAuthor:authorinfo];
        
        MyDB* dbhandle = [[MyDB alloc] init];
        FMDatabase* db = dbhandle.db;
        NSMutableArray* poeminfo = [[NSMutableArray alloc] init];
        for (int i = 0;i < [poemArray count];i++) {
            NSString* p = [poemArray objectAtIndex:i];
            Poem* poem = [Poem new];
            poem.PAid = [dbhandle AidWithAName:[authorArray objectAtIndex:i]];
            poem.PName = @"";
            poem.PContent = p;
            poem.PNote = @"注解";
            poem.PRemark = @"备注";
            [poeminfo addObject:poem];
            [poem release];
        }
        [dbQueue insertPoem:poeminfo];
        //数据库的结构
        FMResultSet* rs = [db getSchema];
        while ([rs next]) {
            //result colums: type[STRING], name[STRING],tbl_name[STRING],rootpage[INTEGER],sql[STRING]
//            NSLog(@"type: %@",[rs stringForColumn:@"type"]);
//            NSLog(@"name:%@",[rs stringForColumn:@"name"]);
//            NSLog(@"tbl_name:%@",[rs stringForColumn:@"tbl_name"]);
//            NSLog(@"rootpage:%@",[rs stringForColumn:@"rootpage"]);
//            NSLog(@"sql: %@",[rs stringForColumn:@"sql"]);
            
            for (int i = 0; i < [rs columnCount]; i++) {
                NSLog(@"%@",[rs objectForColumnIndex:i]);
            }
        }
        [db closeOpenResultSets];
        
        //表结构
        rs = [db getTableSchema:@"T_POEM"];
        while ([rs next]) {
            //result colums: cid[INTEGER], name,type [STRING], notnull[INTEGER], dflt_value[],pk[INTEGER]
            for (int i = 0; i < [rs columnCount]; i++) {
                NSLog(@"%@",[rs objectForColumnIndex:i]);
            }
        }
        [db closeOpenResultSets];
        //判断sql是不是有效
        NSError* error;
        NSString* sql = [NSString stringWithFormat:@"select * from T_POEM;"];
        if (![db validateSQL:@"aaa aaa" error:&error]) {
            NSLog(@"%d  %@",[db lastErrorCode],[db lastErrorMessage]);
        }
        
        if (![db validateSQL:sql error:&error]) {
            NSLog(@"%d  %@",[db lastErrorCode],[db lastErrorMessage]);
        }
        
        if ([db columnExists:@"T_POEM" columnName:@"PID"]) {
            NSLog(@"存在");
        }
        
        if ([db columnExists:@"T_POEM" columnName:@"PaaID"]) {
            NSLog(@"不存在");
        }
        
        
       NSLog(@"databasePath = %@",[db databasePath]);
        
        
        NSLog(@"%d",[FMDatabase isSQLiteThreadSafe]);
        
        NSLog(@"%@",[FMDatabase sqliteLibVersion]);
        
        result = [FileDataBase AllAuthor];
        for (Author* a in result) {
             NSLog(@"\n%d\n%@\n%@\n%@\n%@\n",a.AID, a.AName,a.AInfo,a.AHeader,a.ARemark);
        }
        
        
//        
//        NSString* path1 =[[NSBundle mainBundle] pathForResource:@"tangshi" ofType:@"txt"];
//        NSString* retStr1 = [NSString stringWithContentsOfFile:path1 encoding:enc error:0]; 
//        NSArray* arrayt = [retStr1 componentsSeparatedByString:@"+"];
//        //NSLog(@"\n%@",retStr1);
//        for (NSString* s in arrayt) {
//            NSLog(@"\n===========================================================\n%@",s);
//        }
//        
//        NSString* path2 =[[NSBundle mainBundle] pathForResource:@"ci" ofType:@"txt"];
//        NSString* retStr2 = [NSString stringWithContentsOfFile:path2 encoding:enc error:0]; 
//        NSLog(@"\n%@",retStr2);
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


-(void)disappearGifView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [[self.view viewWithTag:1001] setFrame:CGRectMake(160, 180, 1, 1)];
    [[self.view viewWithTag:1002] setFrame:CGRectMake(160, 180, 1, 1)];

    [UIView commitAnimations];

}

-(void)removeGifView
{
    [[self.view viewWithTag:1001] removeFromSuperview];
    [[self.view viewWithTag:1002] removeFromSuperview];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad]; 
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;   
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg1.png"]];
    NSURL 		* TitleImageUrl  = 	[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"TitleImage" ofType:@"gif"]];
    UIImageView * TitleImageView = 	[AnimatedGif getAnimationForGifAtUrl: TitleImageUrl];
    UIImageView * backgroundView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gifbgImage.jpg"]];
    [backgroundView setTag:1001];
    [TitleImageView setTag:1002];
    [self.view  addSubview:backgroundView];
    [self.view  addSubview:TitleImageView];
    [backgroundView release];
    
    [self performSelector:@selector(disappearGifView) withObject:nil afterDelay:2];
    [self performSelector:@selector(removeGifView) withObject:nil afterDelay:7];
    
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

#pragma mark- UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle  = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}
@end
