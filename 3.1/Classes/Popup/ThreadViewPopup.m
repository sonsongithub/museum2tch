//
//  ThreadViewPopup.m
//  2tchfree
//
//  Created by sonson on 08/08/25.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ThreadViewPopup.h"
#import "global.h"
#import "_tchAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "ThreadViewController.h"

#pragma mark CancelView

// Notification identifier
NSString* kDismissBookmarkViewMsg = @"kDismissBookmarkViewMsg";

// while popuping animation identifier
NSString* kThreadViewPopupCAPopup1 = @"kThreadViewPopupCAPopup1";
NSString* kThreadViewPopupUIViewPopup1 = @"kThreadViewPopupUIViewPopup1";
NSString* kThreadViewPopupCAPopup2 = @"kThreadViewPopupCAPopup2";
NSString* kThreadViewPopupUIViewPopup2 = @"kThreadViewPopupCAPopup2";
NSString* kThreadViewPopupCAPopup3 = @"kThreadViewPopupCAPopup3";
NSString* kThreadViewPopupUIViewPopup3 = @"kThreadViewPopupCAPopup3";

// while popouting animation identifier
NSString* kThreadViewPopupCAPopout = @"kThreadViewPopupCAPopout";
NSString* kThreadViewPopupUIViewPopout = @"kThreadViewPopupUIViewPopout";

@implementation CancelView

@synthesize delegate;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[delegate cancel];
}
- (void) dealloc {
	DNSLog( @"[CancelView] dealloc" );
	[super dealloc];
}
@end

#pragma mark ThreadViewPopup

@implementation ThreadViewPopup

- (void) cancel {
	if( [self superview] != nil ) {
		[cancelView_ removeFromSuperview];
		[self popout];
	}
}

- (void) popout {
	
	CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	transformAnimation.removedOnCompletion = YES;
	transformAnimation.duration = 0.1;
	transformAnimation.delegate = self;
	transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8,0.8,0.8)];
	[self.layer addAnimation:transformAnimation forKey:kThreadViewPopupCAPopout];
	
	// Now we need to rotate the restaurant label and fade out the other buttons.
	[UIView beginAnimations:kThreadViewPopupUIViewPopout context:nil];
	[UIView setAnimationDuration:0.1];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(threadViewPopupUIViewAnimationDelegate:finished:context:)];
	[self setAlpha:0.0f];
	[UIView commitAnimations];
}

- (void) popupInView:(UIView*)view {
	UIViewController *con = UIAppDelegate.navigationController.visibleViewController;
	
	if( [con isKindOfClass:[ThreadViewController class]] ) {
		ThreadViewController *con2 = (ThreadViewController*)con;
		con2.isPopupOpened = YES;
	}
	
	cancelView_.frame = view.frame;
	[view addSubview:cancelView_];
	[view addSubview:self];
	[self setAlpha:0.0f];
	
	self.center = CGPointMake( view.bounds.size.width/2+0.5, view.bounds.size.height/2+0.5 );
	
	// Now we need to rotate the restaurant label and fade out the other buttons.
	[UIView beginAnimations:kThreadViewPopupUIViewPopup1 context:nil];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationDelegate:self];
	self.transform = CGAffineTransformMakeScale(1.1, 1.1);
	[UIView setAnimationDidStopSelector:@selector(threadViewPopupUIViewAnimationDelegate:finished:context:)];
	[self setAlpha:1.0f];
	[UIView commitAnimations];
}

- (void)didReceiveMemoryWarning:(NSNotification*)obj {
	[self removeFromSuperview];
	[cancelView_ removeFromSuperview];
}

- (void)threadViewPopupUIViewAnimationDelegate:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if( finished && [animationID isEqualToString:kThreadViewPopupUIViewPopup1] ) {
		// Now we need to rotate the restaurant label and fade out the other buttons.
		[UIView beginAnimations:kThreadViewPopupUIViewPopup2 context:nil];
		[UIView setAnimationDuration:0.05];
		[UIView setAnimationDelegate:self];
		self.transform = CGAffineTransformIdentity;
		[UIView setAnimationDidStopSelector:@selector(threadViewPopupUIViewAnimationDelegate:finished:context:)];
		[UIView commitAnimations];
	}
	if( finished && [animationID isEqualToString:kThreadViewPopupUIViewPopout] ) {
		DNSLog( kThreadViewPopupUIViewPopout );
		[self removeFromSuperview];
	}
}

#pragma mark Override

// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(didReceiveMemoryWarning:)
													 name:kDismissBookmarkViewMsg
												   object:nil];
		//
		cancelView_ = [[CancelView alloc] initWithFrame:frame];
		cancelView_.backgroundColor = [UIColor clearColor];
		cancelView_.delegate = self;
		// 
		UIImage *img =  [UIImage imageNamed:@"popupBack.png"];
		UIImage *newImg = [img stretchableImageWithLeftCapWidth:7 topCapHeight:14];
		background_ = [[UIImageView alloc] initWithImage:newImg];
		background_.frame = frame;
		background_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		[self addSubview:background_];
    }
    return self;
}

- (void)dealloc {
	UIViewController *con = UIAppDelegate.navigationController.visibleViewController;
	if( [con isKindOfClass:[ThreadViewController class]] ) {
		ThreadViewController *con2 = (ThreadViewController*)con;
		con2.isPopupOpened = YES;
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	DNSLog( @"[ThreadViewPopup] dealloc" );
	[cancelView_ release];
	[background_ release];
    [super dealloc];
}

@end
