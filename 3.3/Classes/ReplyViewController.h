//
//  ReplyViewController.h
//  composeView
//
//  Created by sonson on 08/12/04.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

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
}
@end
