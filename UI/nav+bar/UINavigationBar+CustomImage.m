//
//  UINavigationBar+CustomImage.m
//  test_navigationbar
//
//  Created by user on 12-3-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UINavigationBar+CustomImage.h"
static NSMutableDictionary *navigationBarImages = NULL;
@implementation UINavigationBar(CustomImage)
//Overrider to draw a custom image

+ (void)initImageDictionary
{
    if(navigationBarImages==NULL){
        navigationBarImages=[[NSMutableDictionary alloc] init];
    }  
}

- (void)drawRect:(CGRect)rect
{
    UIImage *imageName=[navigationBarImages objectForKey:[NSValue valueWithNonretainedObject: self]];
    if (imageName==nil) {
        //imageName=@"nav";
    }
    //UIImage *image = [UIImage imageNamed: imageName];
    [imageName drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

//Allow the setting of an image for the navigation bar
- (void)setImage:(UIImage*)image
{
    [navigationBarImages setObject:image forKey:[NSValue valueWithNonretainedObject: self]];
}
@end
