//
//  AuthoDetailView.h
//  AncientProseAppreciate
//
//  Created by 武 帮民 on 12-4-12.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "RatingView.h"
@interface AuthoDetailView : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView* myTableView;
    IBOutlet UIView*      headView;
    IBOutlet UIImageView* headImage;
    IBOutlet UILabel*     PoetryName;
    IBOutlet UIImageView* headgifView;
    IBOutlet RatingView*  ratingView;//评分
    NSArray* article;
    
}

@end
