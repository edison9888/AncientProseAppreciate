//
//  ShortStory.m
//  AncientProseAppreciate
//
//  Created by user on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShortStory.h"

@implementation ShortStory

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;   
    //self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookcase1.png"]];
    
    UIImageView* imageview = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"bookcase1.png"] rescaleImageToSize:CGSizeMake(320, 480)]];
    [self.tableView addSubview:imageview];
    //self.tableView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"bookcase1.png"] rescaleImageToSize:CGSizeMake(320, 100)]];
    //self.tableView.
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

#pragma mark - UITableViewDelegate
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    //cell.backgroundColor = [UIColor clearColor];
    //cell.selectionStyle  = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}

@end
