//
//  ReplyViewController.h
//  composeView
//
//  Created by sonson on 08/12/04.
//  Copyright 2008 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReplyController;

@interface ScrollableTextView : UITextView {
	UIScrollView *parentScrollView;
}
@property (nonatomic, assign) UIScrollView *parentScrollView;
@end

@interface ReplyViewController : UIViewController <UITextViewDelegate> {
	UIScrollView		*scrollView_;
	UITextField			*name_;
	UITextField			*email_;
	ScrollableTextView	*body_;
	NSString			*cacheFilePath_;
	ReplyController		*replyController_;
}
@property (nonatomic, retain) ReplyController *replyController;
#pragma mark Push UIButton
- (void)pushCloseButton:(id)sender;
- (void)pushSendButton:(id)sender;
#pragma mark Original
- (void)setAnchor:(NSMutableString*)anchorString;
- (void)dismiss:(BOOL)sendingSuccess;
- (NSString*)serverFromPath:(NSString*)path;
- (NSString*)readFromCache;
- (void)prepareCache;
- (void)saveReplayText:(NSString*)input;
- (void)clearCache;
@end
