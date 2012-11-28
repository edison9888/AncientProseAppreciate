//
//  AncientProseAppreciateViewController.m
//  AncientProseAppreciate
//
//  Created by 武 帮民 on 12-4-7.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "AncientProseAppreciateViewController.h"

@implementation AncientProseAppreciateViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(void)test
{
    NSString* path =[[NSBundle mainBundle] pathForResource:@"mingju" ofType:@"txt"];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);  
    NSString* retStr = [NSString stringWithContentsOfFile:path encoding:enc error:0]; 
    NSLog(@"\n%@",retStr);
    
    NSString* path1 =[[NSBundle mainBundle] pathForResource:@"tangshi" ofType:@"txt"];
    NSString* retStr1 = [NSString stringWithContentsOfFile:path1 encoding:enc error:0]; 
    NSLog(@"\n%@",retStr1);
    
    NSString* path2 =[[NSBundle mainBundle] pathForResource:@"ci" ofType:@"txt"];
    NSString* retStr2 = [NSString stringWithContentsOfFile:path2 encoding:enc error:0]; 
    NSLog(@"\n%@",retStr2);
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self test];
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
