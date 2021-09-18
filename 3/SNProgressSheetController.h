//
//  SNProgressSheetController.h
//  hudTest
//
//  Created by sonson on 08/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SNProgressSheetController : NSObject <UIActionSheetDelegate> {
	UIActionSheet	*actionSheet_;
	UIProgressView	*progressBar_;
}
@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) NSNumber *progress;
#pragma mark Accessor
- (NSString*) title;
- (void) setTitle:(NSString*)newValue;
- (NSNumber*) progress;
- (void) setProgress:(NSNumber*)progress;
#pragma mark Override
- (id) init;
- (void) dealloc;
#pragma mark Original
- (void) dismiss;
- (void) showSheet;
@end
