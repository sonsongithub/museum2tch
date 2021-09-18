//
//  SNProgressSheetController.m
//  hudTest
//
//  Created by sonson on 08/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SNProgressSheetController.h"
#import "SubjectDataBase.h"
#import "_tchAppDelegate.h"

@implementation SNProgressSheetController

#pragma mark Accessor

@dynamic title;
@dynamic progress;

- (NSString*) title {
	return actionSheet_.title;
}

- (void) setTitle:(NSString*)newValue {
	actionSheet_.title = newValue;
}

- (NSNumber*) progress {
	return [NSNumber numberWithFloat:progressBar_.progress];
}

- (void) setProgress:(NSNumber*)progress {
	progressBar_.progress = [progress floatValue];
}

- (void) setProgressWithFloat:(id)obj {
	SubjectDataBase* p = (SubjectDataBase*)obj;
	progressBar_.progress =p.parse_progress;
}

#pragma mark Override

- (id) init {
	self = [super init];
	actionSheet_ = [[UIActionSheet alloc] initWithTitle:@"Loading..."
											   delegate:self
									  cancelButtonTitle:nil
								 destructiveButtonTitle:nil
									  otherButtonTitles:nil];
	progressBar_ = [[UIProgressView alloc] initWithFrame:CGRectMake(0,0,100,9)];	// rect is default size
	return self;
}

- (void) dealloc {
	[actionSheet_ release];
	[progressBar_ release];
	[super dealloc];
}

#pragma mark Original

- (void) dismiss {
	[actionSheet_ dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) showSheet {
	progressBar_.progressViewStyle =  UIProgressViewStyleBar;
	
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	
	[actionSheet_ addSubview:progressBar_];
	[actionSheet_ showInView:app.mainNavigationController.visibleViewController.view];
	
	
	CGRect actionSheetBounds = actionSheet_.bounds;
	CGRect progressFrame = progressBar_.frame;
	
	progressFrame.size.width = actionSheetBounds.size.width - 50;
	progressFrame.origin.x = actionSheetBounds.size.width/2 - progressFrame.size.width/2;
	progressFrame.origin.y = actionSheetBounds.size.height - progressFrame.size.height;
	
	actionSheetBounds.size.height += ( progressFrame.size.height + 20 );
	
	actionSheet_.bounds = actionSheetBounds;
	progressBar_.frame = progressFrame;

}

@end
