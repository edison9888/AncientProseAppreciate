//
//  MusicList+search.h
//  AncientProseAppreciate
//
//  Created by linlin on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicListSearchHelper.h"
#import "iPhoneStreamingPlayerViewController.h"
@interface MusicList_search : UITableViewController<MusicSearchStatus>
{
    MusicListSearchHelper* musicSearchHelper;
    
    NSArray* netMusicList;
}
@end
