//
//  TangPoetry.m
//  AncientProseAppreciate
//
//  Created by user on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TangPoetry.h"
#import "Utility.h"
#import "AuthoDetailView.h"
@implementation TangPoetry

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
//    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 320, 40)];
//    lb.text = @"哈哈，自定义字体";
//    lb.font = [UIFont fontWithName:@"DFPShaoNvW5-GB" size:30.0f];
//    [self.view addSubview:lb];
//    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"u=3017461583,3229673319&fm=51&gp=0.jpg"]];
//    self.navigationItem.titleView = logoImageView;
//    [logoImageView release];
    
    
    self.view.backgroundColor = [UIColor clearColor];
    CGRect bounds = [[UIScreen mainScreen] bounds];
	int screenWidth =  bounds.size.width;
	int screenHeight =  bounds.size.height;
	
	CGRect frame = CGRectMake((screenWidth-312)/2, (screenHeight-312)/2, 312, 312);
	UIImageView *animationView = [[UIImageView alloc] initWithFrame:frame];
	
	animationView.animationImages = [NSArray arrayWithObjects:	
									 [UIImage imageNamed:@"1.gif"],
									 [UIImage imageNamed:@"2.gif"],
									 [UIImage imageNamed:@"3.gif"],
									 [UIImage imageNamed:@"4.gif"],
									 [UIImage imageNamed:@"5.gif"], 
									 [UIImage imageNamed:@"6.gif"], nil];
	
	animationView.animationDuration = 1.25;
	animationView.animationRepeatCount = 0;
	[animationView startAnimating];
    //self.navigationController.t
    [self.view addSubview:animationView];
    [animationView release];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Right", @selector(rightAction:));
    self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"BackBtn.png"];
}

-(void)rightAction:(id)sender
{
    AuthoDetailView* adv = [[AuthoDetailView alloc] init];
    [self.navigationController pushViewController:adv animated:YES];
    [adv release];
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

@end
