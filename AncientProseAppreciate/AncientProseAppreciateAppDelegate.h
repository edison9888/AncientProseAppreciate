//
//  AncientProseAppreciateAppDelegate.h
//  AncientProseAppreciate
//
//  Created by 武 帮民 on 12-4-7.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationBar+CustomImage.h"
#import "UICustomTabController.h"
@class AncientProseAppreciateViewController;

@interface AncientProseAppreciateAppDelegate : NSObject <UIApplicationDelegate> {
    UICustomTabController *tabbar_controller;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet AncientProseAppreciateViewController *viewController;

@property (nonatomic, retain) IBOutlet UICustomTabController *tabbar_controller;
@end
