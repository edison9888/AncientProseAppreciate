//
//  SongPoems.m
//  AncientProseAppreciate
//
//  Created by user on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SongPoems.h"
#import "Utility.h"
@implementation SongPoems

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        leavesView = [[LeavesView alloc] initWithFrame:CGRectZero];
        
        //pdf
        CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("paper.pdf"), NULL, NULL);
		pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
		CFRelease(pdfURL);
        
        //image
        images = [[NSArray alloc] initWithObjects:
				  [UIImage imageNamed:@"kitten.jpg"],
				  [UIImage imageNamed:@"kitten2.jpg"],
				  [UIImage imageNamed:@"kitten3.jpg"],
				  nil];
    }
    return self;
}

- (void)dealloc
{
    [leavesView release];
	CGPDFDocumentRelease(pdf);
    [images release];
    [super dealloc];
}

- (void) displayPageNumber:(NSUInteger)pageNumber 
{
	self.navigationItem.title = [NSString stringWithFormat:
								 @"Page %u of %lu", 
								 pageNumber, 
								 CGPDFDocumentGetNumberOfPages(pdf) + [images count] + 10];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark  LeavesViewDelegate methods

- (void) leavesView:(LeavesView *)leavesView willTurnToPageAtIndex:(NSUInteger)pageIndex 
{
    NSLog(@"pageIndex = %d",pageIndex);
	[self displayPageNumber:pageIndex + 1];
}

#pragma mark LeavesViewDataSource methods

- (NSUInteger) numberOfPagesInLeavesView:(LeavesView*)leavesView 
{
	return CGPDFDocumentGetNumberOfPages(pdf) + [images count] + 10;
}

- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx
{
    if (index < CGPDFDocumentGetNumberOfPages(pdf))
    {
        CGPDFPageRef page = CGPDFDocumentGetPage(pdf, index + 1);
        CGAffineTransform transform = aspectFit(CGPDFPageGetBoxRect(page, kCGPDFMediaBox),
                                                CGContextGetClipBoundingBox(ctx));
        CGContextConcatCTM(ctx, transform);
        CGContextDrawPDFPage(ctx, page);
    }
    else if(index < CGPDFDocumentGetNumberOfPages(pdf) + [images count])
    {
        UIImage *image = [images objectAtIndex:index - CGPDFDocumentGetNumberOfPages(pdf)];
        CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
        CGAffineTransform transform = aspectFit(imageRect,
                                                CGContextGetClipBoundingBox(ctx));
        CGContextConcatCTM(ctx, transform);
        CGContextDrawImage(ctx, imageRect, [image CGImage]);
    }
    else
    {
        CGRect bounds = CGContextGetClipBoundingBox(ctx);
        CGContextSetFillColorWithColor(ctx, [[UIColor colorWithHue:(index - CGPDFDocumentGetNumberOfPages(pdf) + [images count])/10.0 
                                                        saturation:0.8
                                                        brightness:0.8 
                                                             alpha:1.0] CGColor]);
        CGContextFillRect(ctx, CGRectInset(bounds, 100, 100));
    }

}

#pragma mark - View lifecycle

- (void)loadView
{
    NSLog(@"loadView");
	[super loadView];
	leavesView.frame = self.view.bounds;
	leavesView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:leavesView];
}

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    leavesView.dataSource = self;
	leavesView.delegate = self;
	[leavesView reloadData];
	[self displayPageNumber:1];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
