//
//  UICustomTabController.m
//  myCustomTabbarController
//
//  Created by user on 12-3-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UICustomTabController.h"
@implementation UICustomTabController
@synthesize selected_image;
@synthesize unselected_image;
@synthesize showCustomStyle;
@synthesize tabbar_bg_image;
@synthesize font;
-(void)dealloc
{
    [unselected_image release];
    [selected_image release];
    [tabbar_bg_image release];
    [tab_btnArray release];
    [super dealloc];
    
}

-(void)init_tabbar
{
    if (unselected_image == nil) {
        unselected_image = [UIImage imageNamed:@"NavBar_01.png"];
    }
    if (selected_image == nil) {
        selected_image   = [UIImage imageNamed:@"NavBar_01_s.png"];
    }
    UIImageView* tabbarBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 431, 320, 50)];
    [tabbarBgImageView setTag:1001];
    if (tabbar_bg_image) {
        [tabbarBgImageView setImage:tabbar_bg_image];
    }else{
        [tabbarBgImageView setImage:[UIImage imageNamed:@"tools_bar_bg.png"]];
    }
    
    [self .view addSubview:tabbarBgImageView];
    [tabbarBgImageView release];
}

-(void)hideSelfTabbar
{
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[UITabBar class]])
        {
            view.hidden = YES;
            break;
        }
    }
}

-(void)handleButtonSelectedEventWith:(int)buttonTag
{
    for (int i = 0; i < [tab_btnArray count]; i++)
    {
        if (i == buttonTag)
        {
            [[tab_btnArray objectAtIndex:i] setSelected:true];
        }
        else
        {
            [[tab_btnArray objectAtIndex:i] setSelected:false];
        }
    }
}

-(NSString*)getTabBarItemTitleWithIndex:(NSInteger)index
{
    return [[(UIViewController*)[[self viewControllers] objectAtIndex:index] tabBarItem] title];
}


-(void)button_clicked_tag:(id)sender
{
    [self handleButtonSelectedEventWith:[sender tag]];
    self.selectedIndex = [sender tag];
}

-(void)add_custom_tabbar_elements
{
    int tab_num = [self.viewControllers count];
    tab_btnArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i=0; i < tab_num; i++) 
    {
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(i*(320.0f/tab_num), 432, 320.0f/tab_num, 50)];
        [btn setBackgroundImage:unselected_image forState:UIControlStateNormal];
        [btn setBackgroundImage:selected_image forState:UIControlStateSelected];
        [btn setTitle:[self getTabBarItemTitleWithIndex:i] forState:UIControlStateNormal]; 
        [btn.titleLabel setFont:[UIFont fontWithName:@"DFPShaoNvW5-GB" size:14.0f]];
        if (i == 0)
        {
            [btn setSelected:YES];   
        }
        [btn setTag:i];
        [tab_btnArray addObject:btn];
        [btn addTarget:self action:@selector(button_clicked_tag:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    if (showCustomStyle) {
        [super viewWillAppear:animated];
        [self init_tabbar];
        [self hideSelfTabbar];
        [self add_custom_tabbar_elements];
    }
}


-(void)hideTabbar
{
    [self hideSelfTabbar];
    [(UIImageView*)[self .view viewWithTag:1001] setHidden:YES];
    for (int i=0; i < [self.viewControllers count]; i++) 
    {
        [[tab_btnArray objectAtIndex:i] setHidden:YES];
    }
}

-(void)showTabbar
{
    [self hideSelfTabbar];
    [(UIImageView*)[self .view viewWithTag:1001] setHidden:NO];
    for (int i=0; i < [self.viewControllers count]; i++) 
    {
        [[tab_btnArray objectAtIndex:i] setHidden:NO];
    }
}
@end
