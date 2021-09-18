//
//  ThreadViewPopupImage.m
//  2tchfree
//
//  Created by sonson on 08/08/26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ThreadViewController.h"
#import "ThreadViewPopupImage.h"
#import "_tchAppDelegate.h"
#import "global.h"

// downloader identifier
NSString *kPopupImageDownload = @"PopupImageDownload";

// while popuping animation identifier
NSString* kThreadViewPopupImageCAAdjustImage = @"kThreadViewPopupImageCAAdjustImage";
NSString* kThreadViewPopupImageCAAdjustError = @"kThreadViewPopupImageCAAdjustError";

@implementation ThreadViewPopupImage

#pragma mark Original Method

- (void) setImageWithURL:(NSString*)url {
	[UIAppDelegate.downloder cancel];
	UIAppDelegate.downloder.delegate = self;
	[UIAppDelegate.downloder startWithURL:url identifier:kPopupImageDownload];
	
	[self addSubview:indicator_];
	
	CGRect indicator_rect = indicator_.frame;
	indicator_rect.origin.x = self.frame.size.width/2 - indicator_rect.size.width/2;
	indicator_rect.origin.y = self.frame.size.height/2 - indicator_rect.size.height/2;
	indicator_.frame = indicator_rect;
	
	[indicator_ startAnimating];
}

- (void) saveImage:(id)sender {
	DNSLog( @"[ThreadViewPopupImage] saveImage:" );
	UIImageWriteToSavedPhotosAlbum( [contentImage_ image], self, @selector(image:didFinishSavingWithError:contextInfo:), nil );
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	if( error == nil ) {
		DNSLog( @"[ThreadViewPopupImage] OK - image:didFinishSavingWithError:contextInfo:" );
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"ImageSaving", nil) message:NSLocalizedString( @"HasSaved", nil )
													   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
	}
	else {
		DNSLog( @"[ThreadViewPopupImage] Error - image:didFinishSavingWithError:contextInfo:" );
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"ImageSaving", nil) message:[error localizedDescription]
													   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
	}
}

- (void)threadViewPopupImageUIViewAnimationDelegate:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[super threadViewPopupUIViewAnimationDelegate:animationID finished:finished context:context];
	if( [animationID isEqualToString:kThreadViewPopupImageCAAdjustImage] ) {
		[self addSubview:contentImage_];
		UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
		[button addTarget:self action:@selector(saveImage:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button];
	}
	else if( [animationID isEqualToString:kThreadViewPopupImageCAAdjustError] ) {
		[self addSubview:contentImage_];
	}
}

#pragma mark Override

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		contentImage_ = [[UIImageView alloc] initWithFrame:frame];
		indicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return self;
}

- (void)dealloc {
	[UIAppDelegate.downloder cancel];
	[contentImage_ release];
	[indicator_ release];
    [super dealloc];
}

#pragma mark DownloaderDelegate

- (void) didFinishLoading:(id)data identifier:(NSString*)identifier {
	if( [identifier isEqualToString:kPopupImageDownload] ) {
		[indicator_ stopAnimating];
		[indicator_ removeFromSuperview];
		
		CGRect rect2 = self.bounds;
		DNSLog( @"%f,%f", rect2.size.width, rect2.size.height );
		
		UIImage *img = [UIImage imageWithData:data];
		BOOL isCorrectImage = YES;
		if( img == nil ) {
			img = [UIImage imageNamed:@"error.png"];
			isCorrectImage = NO;
		}
		[contentImage_ setImage:img];
		
		float ratio = img.size.width / ( self.frame.size.width - 20 );
		
		if( ratio < img.size.height / ( self.frame.size.height - 20 ) ) {
			ratio = img.size.height / ( self.frame.size.height - 20 );
		}
		
		if( ratio < 1 ) {
			ratio = 1.0f;
		}
		DNSLog( @"%f,%f", rect2.size.width, rect2.size.height );
		DNSLog( @"%f,%f", img.size.width, img.size.height );
		DNSLog( @"%f", ratio );
		
		float new_width = img.size.width / ratio;
		float new_height = img.size.height / ratio;
		
		DNSLog( @"%f,%f", new_width, new_height );
		
		if( isCorrectImage )
			[UIView beginAnimations:kThreadViewPopupImageCAAdjustImage context:nil];
		else {
			new_width = 236.0f;
			new_height = 236.0f;
			[UIView beginAnimations:kThreadViewPopupImageCAAdjustError context:nil];
		}
		[UIView setAnimationDuration:0.2];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(threadViewPopupImageUIViewAnimationDelegate:finished:context:)];
		CGRect rect = self.bounds;
		rect.size.width = new_width + 20;
		rect.size.height = new_height + 20;
		DNSLog( @"%f,%f", rect.size.width, rect.size.height );
		self.bounds = rect;
		[UIView commitAnimations];
		
		CGRect setRect = CGRectMake( (self.frame.size.width - new_width )/2, (self.frame.size.height-new_height)/2, new_width, new_height);
		
		if( !isCorrectImage ) {
			setRect.origin.x = 10.0f;
			setRect.origin.y = 10.0f;
		}
		contentImage_.frame = setRect;
		DNSLog( @"%f,%f", setRect.origin.x, setRect.origin.y );
	}
}

- (void) didFailLoadingWithIdentifier:(NSString*)identifier error:(NSError *)error isDifferentURL:(BOOL)isDifferentURL {
	if( [identifier isEqualToString:kPopupImageDownload] ) {
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
		DNSLog( @"%f,%f", new_width, new_height );
		[UIView beginAnimations:kThreadViewPopupImageCAAdjustError context:nil];
		[UIView setAnimationDuration:0.2];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(threadViewPopupImageUIViewAnimationDelegate:finished:context:)];
		CGRect rect = self.bounds;
		rect.size.width = new_width + 20;
		rect.size.height = new_height + 20;
		self.bounds = rect;
		[UIView commitAnimations];
		
		CGRect setRect = CGRectMake( (self.frame.size.width - new_width )/2, (self.frame.size.height-new_height)/2, new_width, new_height);
		contentImage_.frame = setRect;
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error", nil) message:[error localizedDescription]
												   delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString( @"OK", nil), nil];
	[alert show];
	[alert release];
}

@end
