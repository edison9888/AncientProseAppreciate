//
//  Utility.m
//  AncientProseAppreciate
//
//  Created by 武 帮民 on 12-4-13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Utility.h"
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define showAlert(format, ...) myShowAlert(__LINE__, (char *)__FUNCTION__, format, ##__VA_ARGS__)

// Simple Alert Utility
void myShowAlert(int line, char *functname, id formatstring,...)
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	id outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	
	NSString *filename = [[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lastPathComponent];
	NSString *debugInfo = [NSString stringWithFormat:@"%@:%d\n%s", filename, line, functname];
    
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:outstring message:debugInfo delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil] autorelease];
	[av show];
}

CGAffineTransform aspectFit(CGRect innerRect, CGRect outerRect) {
	CGFloat scaleFactor = MIN(outerRect.size.width/innerRect.size.width, outerRect.size.height/innerRect.size.height);
	CGAffineTransform scale = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
	CGRect scaledInnerRect = CGRectApplyAffineTransform(innerRect, scale);
	CGAffineTransform translation = 
	CGAffineTransformMakeTranslation((outerRect.size.width - scaledInnerRect.size.width) / 2 - scaledInnerRect.origin.x, 
									 (outerRect.size.height - scaledInnerRect.size.height) / 2 - scaledInnerRect.origin.y);
	return CGAffineTransformConcat(scale, translation);
}

@implementation Utility

@end
