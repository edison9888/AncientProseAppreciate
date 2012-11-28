//
//  SongPoems.h
//  AncientProseAppreciate
//
//  Created by user on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeavesViewController.h"
#import "LeavesView.h"
@interface SongPoems : UIViewController<LeavesViewDelegate,LeavesViewDataSource>
{
    CGPDFDocumentRef pdf;
    NSArray*         images;
    LeavesView *leavesView;
    //书签功能
    //书架
    //
}
@end
