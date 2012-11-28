//
//  UICustomTabController.h
//  myCustomTabbarController
//
//  Created by user on 12-3-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICustomTabController : UITabBarController
{
    UIImage* unselected_image;
    UIImage* selected_image;
    UIImage* tabbar_bg_image;
    UIFont*  font;
    UIColor* color;
    NSMutableArray* tab_btnArray; //button;
}

@property(nonatomic,retain)UIImage* unselected_image;
@property(nonatomic,retain)UIImage* selected_image;
@property(nonatomic,retain)UIImage* tabbar_bg_image;
@property(nonatomic,retain)UIFont*  font;
@property(nonatomic)BOOL showCustomStyle;

//@property(nonatomic,retain)
//@property(nonatomic,retain)
//@property(nonatomic,retain)

//-(void)setTabbarHidden:(BOOL)isHidden;
-(void)hideSelfTabbar;
-(void)hideTabbar;
-(void)showTabbar;
@end
