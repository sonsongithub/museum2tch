//
//  ReplyViewController.h
//  2tch
//
//  Created by sonson on 08/08/29.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReplyController.h"
#import "ReplyViewCell.h"

@interface ReplyViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate> {
	UITableView				*tableView_;
	ReplyViewCell			*nameCell_;
	ReplyViewCell			*emailCell_;
	float					bodyHeight_;
	BodyCell				*bodyCell_;
	
	UIAlertView				*cookieConfirm_;
	NSString				*server_;
	NSString				*boardPath_;
	NSString				*dat_;
	NSString				*sharedPon_;
	NSString				*result_body_;
	
	ReplyController			*replyCon_;
}
@property (nonatomic, assign) UITableView *tableView;

#pragma mark Class method
+ (ReplyViewController*) defaultController;
#pragma mark Original
- (void) setAnchor:(int)anchor_number;
- (void) makeCells;
- (void)pushCloseButton:(id)sender;
- (void)pushSendButton:(id)sender;

@end
