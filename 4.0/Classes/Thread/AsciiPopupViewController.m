//
//  AsciiPopupViewController.m
//  2tch
//
//  Created by sonson on 09/01/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AsciiPopupViewController.h"
#import "ThreadResData.h"
#import "ThreadLayoutComponent.h"

UIFont *AsciiFont = nil;

@implementation ResView

@synthesize resData = resData_;
@synthesize resString = resString_;

+ (void)initialize {
	if( AsciiFont == nil ) {
		float ascii_size = [[NSUserDefaults standardUserDefaults] floatForKey:@"asciiFontSize"];
		ascii_size = ascii_size < 1 ? 100 : ascii_size;
		AsciiFont = [[UIFont systemFontOfSize:ascii_size/100.0f*10] retain];
	}
}

- (CGSize)makeSize {
	self.resString = [NSMutableString string];	
	for( ThreadLayoutComponent* p in resData_.body ) {
		[self.resString appendString:p.text];
		[self.resString appendString:@"\r"];
	}
	CGSize size = [self.resString sizeWithFont:AsciiFont constrainedToSize:CGSizeMake( 1600, 800 ) lineBreakMode:UILineBreakModeClip];
	DNSLog( @"%f,%f", size.width, size.height );
	return size;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor( context, 1.0f, 1.0f, 1.0f, 1.f );
	CGContextFillRect( context, rect );
	CGContextSetRGBFillColor(context, 0/255.0f, 0/255.0f, 0/255.0f, 1.f);	
	[self.resString drawInRect:rect withFont:AsciiFont];
}

- (void)dealloc {
	DNSLogMethod
	[resString_ release];
	[resData_ release];
	[super dealloc];
}

@end


@implementation AsciiPopupViewController

@synthesize resData = resData_;

- (id)init {
	DNSLogMethod
    if (self = [super init]) {
		CGRect rect = contentView.bounds;
		rect.size.width *= 0.85;
		rect.size.height *= 0.85;
		scrollView_ = [[UIScrollView alloc] initWithFrame:rect];
		scrollView_.center = CGPointMake( contentView.bounds.size.width*0.5, contentView.bounds.size.height*0.5 );
		[contentView addSubview:scrollView_];
		[scrollView_ release];
    }
    return self;
}

- (void)adjustSize:(CGSize)size {
	float width = size.width / 0.8 > 256 ? 256 : size.width / 0.8;
	width = width < 200 ? 200 : width;
	float height = size.height / 0.8 > 384 ? 384 : size.height / 0.8;
	height = height < 200 ? 200 : height;
	contentView.frame = CGRectMake( 0, 0, width, height );
	background.frame = CGRectMake( 0, 0, width, height );
	background.center = CGPointMake( width / 2, height / 2 );
	contentView.center = CGPointMake( 320 / 2, 480 / 2 );
	
	CGRect rect = contentView.bounds;
	rect.size.width *= 0.8;
	rect.size.height *= 0.8;
	scrollView_.frame = rect;
	scrollView_.center = CGPointMake( width / 2, height / 2 );
	
	scrollView_.delegate = self;
	scrollView_.canCancelContentTouches = YES;
	scrollView_.scrollEnabled = YES;
	scrollView_.delaysContentTouches = NO;
}

- (void)showInView:(UIView*)view {
	DNSLogMethod
	
	resView_ = [[ResView alloc] initWithFrame:CGRectZero];
	[scrollView_ addSubview:resView_];
	
	resView_.resData = resData_;
	CGSize size = [resView_ makeSize];
	scrollView_.contentSize = size;
	
	CGSize ssize = scrollView_.frame.size;
	CGSize ivsize = size;
	float scalex = ssize.width / ivsize.width;
	float scaley = ssize.height / ivsize.height;
	
	scrollView_.maximumZoomScale = 2.0;
	scrollView_.minimumZoomScale = fmin(scalex, scaley);
	scrollView_.contentOffset = CGPointMake( 0, 0 );
	
	if( scrollView_.minimumZoomScale > 0.5 )
		scrollView_.minimumZoomScale = 0.5f;
	
	resView_.frame = CGRectMake( 0, 0, size.width, size.height );
	[self adjustSize:size];
//	[self adjustSize:CGSizeMake( 256, 384 )];
	[resView_ setNeedsDisplay];
	[super showInView:view];
/*	
	DNSLogMethod
	resView_.resData = resData_;
	CGSize size = [resView_ makeSize];
	scrollView_.contentSize = size;
	resView_.frame = CGRectMake( 0, 0, size.width, size.height );
	[self adjustSize:size];
	[resView_ setNeedsDisplay];
	[super showInView:view];
*/
}

- (void)cancel {
	[super cancel];
	[resView_ removeFromSuperview];
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return resView_;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
}

#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[resData_ release];
	[super dealloc];
}

@end
