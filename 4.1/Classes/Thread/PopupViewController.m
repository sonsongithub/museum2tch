//
//  PopupViewController.m
//  2tch
//
//  Created by sonson on 09/01/03.
//  Copyright 2009 sonson. All rights reserved.
//

#import "PopupViewController.h"
#import "ThreadViewController.h"
#import "ThreadResData.h"
#import "ThreadCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ThreadLayoutComponent.h"
#import "Dat.h"

#define POPOUT_IN_DURATION 0.15

NSString* kThreadViewPopupUIViewPopup = @"kThreadViewPopupUIViewPopup";
NSString* kThreadViewPopupUIViewPopout = @"kThreadViewPopupUIViewPopout";

@implementation CancelView
@synthesize delegate = delegate_;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	DNSLogMethod
	[delegate_ cancel];
}
- (void) dealloc {
	DNSLogMethod
	[super dealloc];
}
@end

@implementation ContentView
@synthesize delegate = delegate_;

- (void)dealloc {
	DNSLogMethod
	[super dealloc];
}

@end

@implementation PopupViewController

#pragma mark Original method

- (void)cancel {
	DNSLogMethod
	[UIView beginAnimations:kThreadViewPopupUIViewPopout context:nil];
	[UIView setAnimationDidStopSelector:@selector(animationDelegate:finished:context:)];
	[UIView setAnimationDuration:POPOUT_IN_DURATION];
	[UIView setAnimationDelegate:self];
	[contentView setAlpha:0.0f];
	[UIView commitAnimations];
	
	[backgroundCancelView removeFromSuperview];
	[contentView removeFromSuperview];
}

- (void)showInView:(UIView*)view {
	DNSLogMethod
	if( backgroundCancelView.superview == nil ) {
		DNSLog( @"Popup" );
		[view addSubview:backgroundCancelView];
		[view addSubview:contentView];
	}
	[UIView beginAnimations:kThreadViewPopupUIViewPopup context:nil];
	[UIView setAnimationDuration:POPOUT_IN_DURATION];
	[UIView setAnimationDelegate:self];
	[contentView setAlpha:1.0f];
	[UIView commitAnimations];
}

#pragma mark CoreAnimation Delegate

- (void)animationDelegate:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	DNSLogMethod
	if( [animationID isEqualToString:kThreadViewPopupUIViewPopout] ) {
		[backgroundCancelView removeFromSuperview];
		[contentView removeFromSuperview];
	}
}

- (id)init {
	DNSLogMethod
    if (self = [super init]) {
		backgroundCancelView = [[CancelView alloc] initWithFrame:CGRectMake( 0, 0, 320, 480)];
		backgroundCancelView.delegate = self;
		backgroundCancelView.backgroundColor = [UIColor clearColor];
		
		contentView = [[ContentView alloc] initWithFrame:CGRectMake( 0, 0, 200, 300)];
		contentView = [[ContentView alloc] initWithFrame:CGRectZero];
		contentView.delegate = self;
		contentView.backgroundColor = [UIColor clearColor];
//		contentView.backgroundColor = [UIColor redColor];
		
		contentView.frame = CGRectMake(0,0, 320*0.8, 460*0.8);
		contentView.center = CGPointMake( 160, 230 );
		
		UIImage *img =  [UIImage imageNamed:@"anchorBack.png"];
		UIImage *newImg = [img stretchableImageWithLeftCapWidth:27 topCapHeight:27];
		background = [[UIImageView alloc] initWithImage:newImg];
		background.frame = contentView.bounds;
		background.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		[contentView addSubview:background];
		[contentView setAlpha:1.0f];
    }
    return self;
}

#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[backgroundCancelView release];
	[contentView release];
    [super dealloc];
}


@end
