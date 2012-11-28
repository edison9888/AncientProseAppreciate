//
//  AncientProseAppreciateAppDelegate.m
//  AncientProseAppreciate
//
//  Created by 武 帮民 on 12-4-7.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "AncientProseAppreciateAppDelegate.h"
#import "AncientProseAppreciateViewController.h"
#import "TangPoetry.h"
#import "SongPoems.h"
#import "FamousQuotation.h"
#import "ShortStory.h"
#import "Entertainment.h"
#import "FileDataBase.h"
#import "FileManagerController.h"
@implementation AncientProseAppreciateAppDelegate
@synthesize tabbar_controller;

@synthesize window=_window;

@synthesize viewController=_viewController;

-(void)test
{
    [FileDataBase CreatePoemTable];
    [FileDataBase CreateAuthorTable];
    [FileDataBase deleteAllPoemWithTableName:@"T_POEM"];
//    Poem* p = [Poem new];
//    p.PAid = 1;
//    p.PName = @"静夜思";
//    p.PContent = @" 窗前明月光，\n 疑是地上霜。";
//    p.PNote = @"注解";
//    p.PRemark = @"备注";
//    //[FileDataBase insertPoem:p];
//    [p release];
//    [FileDataBase deletePoemInfoWithPName:0];
    NSArray* array = [FileDataBase getPoemInfoWithPName:0];
    for (Poem* p in array) {
        NSLog(@"\n%d\n%d\n%@\n%@\n%@\n%@\n",p.PNum, p.PAid,p.PName,p.PContent,p.PNote,p.PRemark);
    }
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
    [self test];
    [UINavigationBar initImageDictionary];
    
    NSMutableArray *view_manager = [[NSMutableArray alloc] initWithCapacity:0];
    //第一视图
    FamousQuotation *famousQuoate = [[FamousQuotation alloc] init];
    [famousQuoate setTitle:@"唐诗鉴赏"];
    UINavigationController*famousQuoate_nav = [[UINavigationController alloc] initWithRootViewController:famousQuoate];
    [famousQuoate_nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
    [famousQuoate_nav.tabBarItem setTitle:@"名言"];
    [famousQuoate_nav.tabBarItem setImage:[UIImage imageNamed:@"change_it.png"]];
    [view_manager addObject:famousQuoate_nav];
    [famousQuoate release];
    [famousQuoate_nav release];
    
    //第二视图
    TangPoetry *tangshiController = [[TangPoetry alloc] init];
    UINavigationController*tangshi_nav = [[UINavigationController alloc] initWithRootViewController:tangshiController];//自定义导航条
    [tangshi_nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
    [tangshi_nav.tabBarItem setTitle:@"唐诗"];
    [tangshi_nav.tabBarItem setImage:[UIImage imageNamed:@"change_it.png"]];
    [view_manager addObject:tangshi_nav];
    [tangshiController release];
    [tangshi_nav release];
    
    //第三视图
    SongPoems *songciController = [[SongPoems alloc] init];
    UINavigationController*songci_nav = [[UINavigationController alloc] initWithRootViewController:songciController];//自定义导航条
    [songci_nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
    [songci_nav.tabBarItem setTitle:@"宋词"];
    [songci_nav.tabBarItem setImage:[UIImage imageNamed:@"change_it.png"]];
    [view_manager addObject:songci_nav];
    [songciController release];
    [songci_nav release];
    
    //第四视图
    ShortStory *shortstoryController = [[ShortStory alloc] init];
    UINavigationController*shortstory_nav = [[UINavigationController alloc] initWithRootViewController:shortstoryController];//自定义导航条
    [shortstory_nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
    [shortstory_nav.tabBarItem setTitle:@"文学"];
    [shortstory_nav.tabBarItem setImage:[UIImage imageNamed:@"change_it.png"]];
    [view_manager addObject:shortstory_nav];
    [shortstoryController release];
    [shortstory_nav release];
    
    //第五视图
    Entertainment *yuleController = [[Entertainment alloc] init];
    UINavigationController*yule_nav = [[UINavigationController alloc] initWithRootViewController:yuleController];//自定义导航条
    [yule_nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
    [yule_nav.tabBarItem setTitle:@"娱乐"];
    [yule_nav.tabBarItem setImage:[UIImage imageNamed:@"change_it.png"]];
    [view_manager addObject:yule_nav];
    [yuleController release];
    [yule_nav release];
    
    tabbar_controller= [[UICustomTabController alloc] init];
    [tabbar_controller setTabbar_bg_image:[UIImage imageNamed:@"background11.png"]];
    [tabbar_controller setSelected_image:[UIImage imageNamed:@"tab_selected_p_icon.png"]];
    [tabbar_controller setUnselected_image:[UIImage imageNamed:@"tab_selected_icon.png"]];
    [tabbar_controller setShowCustomStyle:YES];
    [tabbar_controller setViewControllers:view_manager];
    [tabbar_controller setHidesBottomBarWhenPushed:YES];
    [tabbar_controller setFont:[UIFont fontWithName:@"DFPShaoNvW5-GB" size:14.0f]];
    [view_manager release];
    [self.window addSubview:tabbar_controller.view];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [tabbar_controller release];
    [super dealloc];
}

@end
