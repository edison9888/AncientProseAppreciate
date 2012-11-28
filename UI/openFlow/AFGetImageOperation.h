#import <UIKit/UIKit.h>
#import "CoverFlowViewController.h"

@interface AFGetImageOperation : NSOperation {
	CoverFlowViewController *mainViewController;
	int photoIndex;
}

- (id)initWithIndex:(int)imageIndex viewController:(CoverFlowViewController *)viewController;

@end