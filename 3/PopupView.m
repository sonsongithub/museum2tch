//
//  PopupView.m
//  popupTest
//
//  Created by sonson on 08/07/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PopupView.h"
#import <QuartzCore/QuartzCore.h>


@implementation CancelView
@synthesize delegate;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[delegate cancel];
}
@end

@implementation PopupView

- (void) cancel {
	if( [self superview] != nil ) {
		[cancelView_ removeFromSuperview];
		[self popout];
	}
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if( self != nil ) {
		downloader_ = [[Downloader alloc] initWithDelegate:self];
		
		//
		cancelView_ = [[CancelView alloc] initWithFrame:frame];
		cancelView_.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
		cancelView_.delegate = self;
		
		UIImage *img =  [UIImage imageNamed:@"popupBack.png"];
		UIImage *newImg = [img stretchableImageWithLeftCapWidth:7 topCapHeight:14];
		background_ = [[UIImageView alloc] initWithImage:newImg];
		background_.frame = frame;
		background_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		[self addSubview:background_];
		
		text_ = [[UITextView alloc] initWithFrame:frame];
		[text_ setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
		
		text_.font = [UIFont boldSystemFontOfSize:13.0f];
		text_.textColor = [UIColor whiteColor];
		
		text_.userInteractionEnabled = YES;
		text_.scrollEnabled = NO;
		//text_.showsHorizontalScrollIndicator = YES;
		background_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		text_.editable = NO;
		CGSize rect = text_.contentSize;
		
		contentImage_ = [[UIImageView alloc] initWithFrame:frame];
		
		indicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	}
	
    return self;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	
	if( flag && theAnimation == [self.layer animationForKey:@"animatePopup"] ) {
		CABasicAnimation *transformAnimation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
		transformAnimation2.removedOnCompletion = YES;
		transformAnimation2.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn];
		transformAnimation2.duration = 0.15;
		transformAnimation2.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95,0.95,0.95)];
		[self.layer addAnimation:transformAnimation2 forKey:@"animatePopup2"];
	}
	else if( flag && theAnimation == [self.layer animationForKey:@"animatePopup2"] ) {
		CABasicAnimation *transformAnimation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
		transformAnimation2.removedOnCompletion = YES;
		transformAnimation2.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn];
		transformAnimation2.duration = 0.1;
		transformAnimation2.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0,1.0,1.0)];
		[self.layer addAnimation:transformAnimation2 forKey:@"animatePopup2"];
	}
	else if( flag && theAnimation == [self.layer animationForKey:@"animatePopout"] ) {
		[downloader_ cancel];
		[self removeFromSuperview];
	}
}

- (void) popout {
	
	CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	transformAnimation.removedOnCompletion = NO;
	transformAnimation.duration = 0.1;
	transformAnimation.delegate = self;
	transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8,0.8,0.8)];
	[self.layer addAnimation:transformAnimation forKey:@"animatePopout"];
	
	// Now we need to rotate the restaurant label and fade out the other buttons.
	[UIView beginAnimations:@"rotateRestaurantAndDimOtherButtons" context:nil];
	[UIView setAnimationDuration:0.1];
	[UIView setAnimationDelegate:self];
	[self setAlpha:0.0f];
	[UIView commitAnimations];
}

- (void) popupInView:(UIView*)view {
	cancelView_.frame = view.frame;
	
	float max_width = view.bounds.size.width * 0.8;
	float max_height = view.bounds.size.height * 0.8;
	
	if( [text_ superview] == self ) {
	
	CGRect textOldFrame = text_.frame;
	textOldFrame.size.width = max_width;
	text_.frame = textOldFrame;
	
	float new_height;
	
	if( text_.contentSize.height  > max_height ) {
		text_.scrollEnabled = YES;
		new_height = max_height;
	}
	else
		new_height = text_.contentSize.height;
	
	textOldFrame.size.height = new_height;
	text_.frame = textOldFrame;	
		self.frame = text_.frame;
	}
	else {
		self.frame = CGRectMake(0, 0,max_width,max_height);
		CGRect setRect = CGRectMake( (self.frame.size.width - indicator_.frame.size.width )/2, (self.frame.size.height-indicator_.frame.size.height)/2, indicator_.frame.size.width, indicator_.frame.size.height);
		[self addSubview:indicator_];
		indicator_.frame = setRect;	
	}
	
	[view addSubview:cancelView_];
	[view addSubview:self];
	[self setAlpha:0.0f];
	
	CGPoint newCenter;
	
	CGSize superview_size = view.bounds.size;
	
	
	self.center = CGPointMake( view.bounds.size.width/2, view.bounds.size.height/2 );
	
	CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	transformAnimation.removedOnCompletion = NO;
	transformAnimation.duration = 0.2;
	transformAnimation.delegate = self;
	transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn];
	transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8,0.8,0.8)];
	transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2,1.2,1.2)];
	
	[self.layer addAnimation:transformAnimation forKey:@"animatePopup"];
	
	// Now we need to rotate the restaurant label and fade out the other buttons.
	[UIView beginAnimations:@"rotateRestaurantAndDimOtherButtons" context:nil];
	[UIView setAnimationDuration:0.2];
	[UIView setAnimationDelegate:self];
	[self setAlpha:1.0f];
	[UIView commitAnimations];
}

- (void) setMessage:(NSString*)message {
	[indicator_ removeFromSuperview];
	[contentImage_ removeFromSuperview];
	[self addSubview:text_];
	text_.text = message;
}

- (void) setImageWithURL:(NSString*)url {
	[text_ removeFromSuperview];
	[contentImage_ removeFromSuperview];
	
	[downloader_ cancel];
	[downloader_ startWithURL:url identifier:@"DownloadImageAtThreadView"];
	
	[indicator_ startAnimating];
}

- (void)dealloc {
    [super dealloc];
}


#pragma mark Downloader delegates

- (void) didFailLoadingWithIdentifier:(NSString*)identifier error:(NSError *)error isDifferentURL:(BOOL)isDifferentURL {
	if( [identifier isEqualToString:@"DownloadImageAtThreadView"] ) {
		[indicator_ stopAnimating];
		[indicator_ removeFromSuperview];
		
		
		UIImage *img = [UIImage imageNamed:@"error.png"];
		[contentImage_ setImage:img];
		
		float ratio = img.size.width / ( self.frame.size.width - 20 );
		
		if( ratio < img.size.height / ( self.frame.size.height - 20 ) ) {
			ratio = img.size.height / ( self.frame.size.height - 20 );
		}
		
		if( ratio < 1 ) {
			ratio = 1.0f;
		}
		
		float new_width = img.size.width / ratio;
		float new_height = img.size.height / ratio;
		
		[UIView beginAnimations:@"adjustRect" context:nil];
		[UIView setAnimationDuration:0.2];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(adjustRectAnimationDidStop:finished:context:)];
		CGRect rect = self.bounds;
		rect.size.width = new_width + 20;
		rect.size.height = new_height + 20;
		self.bounds = rect;
		[UIView commitAnimations];
		
		CGRect setRect = CGRectMake( (self.frame.size.width - new_width )/2, (self.frame.size.height-new_height)/2, new_width, new_height);
		contentImage_.frame = setRect;
	}
}

- (void) didFinishLoading:(id)data identifier:(NSString*)identifier {
	if( [identifier isEqualToString:@"DownloadImageAtThreadView"] ) {
		
		[indicator_ stopAnimating];
		[indicator_ removeFromSuperview];
		
		
		UIImage *img = [UIImage imageWithData:data];
		
		if( img == nil )
			img = [UIImage imageNamed:@"error.png"];
		
		[contentImage_ setImage:img];
		
		
		
		float ratio = img.size.width / ( self.frame.size.width - 20 );
		
		if( ratio < img.size.height / ( self.frame.size.height - 20 ) ) {
			ratio = img.size.height / ( self.frame.size.height - 20 );
		}
		
		if( ratio < 1 ) {
			ratio = 1.0f;
		}
		
		float new_width = img.size.width / ratio;
		float new_height = img.size.height / ratio;
		
		[UIView beginAnimations:@"adjustRect" context:nil];
		[UIView setAnimationDuration:0.2];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(adjustRectAnimationDidStop:finished:context:)];
		CGRect rect = self.bounds;
		rect.size.width = new_width + 20;
		rect.size.height = new_height + 20;
		self.bounds = rect;
		[UIView commitAnimations];
		
		CGRect setRect = CGRectMake( (self.frame.size.width - new_width )/2, (self.frame.size.height-new_height)/2, new_width, new_height);
		contentImage_.frame = setRect;
		
	}
}

- (void)adjustRectAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if( [animationID isEqualToString:@"adjustRect"] ) {
		[self addSubview:contentImage_];
	}
}

@end
