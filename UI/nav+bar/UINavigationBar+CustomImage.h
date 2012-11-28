//
//  UINavigationBar+CustomImage.h
//  test_navigationbar
//
//  Created by user on 12-3-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (CustomImage)

+ (void) initImageDictionary;
- (void) drawRect:(CGRect)rect;
- (void) setImage:(UIImage*)image;


@end
