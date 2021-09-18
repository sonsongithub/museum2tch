//
//  ToolbarController.h
//  2tchfree
//
//  Created by sonson on 08/08/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupMenuController.h"

@interface ToolbarController : UIViewController {
    UIToolbar			*toolbar;
	UILabel				*centerLabel_;
	UIBarButtonItem		*messageSpace_;
	UILabel				*threadTitleLabel_;
	UIBarButtonItem		*messageThreadTitleSpace_;
	UILabel				*threadViewLabel_;
	UIBarButtonItem		*messageThreadViewSpace_;
	PopupMenuController	*popupController_;
	
	NSMutableArray		*backupItems_;
}
@property (nonatomic, assign) UILabel *centerMessage;
@property (nonatomic, assign) UILabel *threadViewLabel;

#pragma mark Original Method
- (void) updateMessageSpace:(NSString*)string;
- (void) setCategoryViewMode:(id)delegate;
- (void) setBoardViewMode:(id)delegate;
- (void) setTitleViewMode:(id)delegate;
- (void) clear:(id)delegate;
- (void) back;
- (void) updateTitleViewMessageWithString:(NSString*)message;
- (void) setTitleViewWithSearchButtonMode:(id)delegate;
- (void) setTitleViewWithCancelButtonMode:(id)delegate;
- (void) setThreadViewMode:(id)delegate numberOfRes:(int)numberOfRes isLimitedNewTo200:(BOOL)isLimitedNewTo200 mode:(int)mode;

@end
