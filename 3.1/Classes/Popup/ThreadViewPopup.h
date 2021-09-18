//
//  ThreadViewPopup.h
//  2tchfree
//
//  Created by sonson on 08/08/25.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// Notification identifier
extern NSString* kDismissBookmarkViewMsg;

// while popuping animation identifier
extern NSString* kThreadViewPopupCAPopup1;
extern NSString* kThreadViewPopupUIViewPopup1;
extern NSString* kThreadViewPopupCAPopup2;
extern NSString* kThreadViewPopupUIViewPopup2;
extern NSString* kThreadViewPopupCAPopup3;
extern NSString* kThreadViewPopupUIViewPopup3;

// while popouting animation identifier
extern NSString* kThreadViewPopupCAPopout;
extern NSString* kThreadViewPopupUIViewPopout;

@interface CancelView : UIView {
	id delegate;
}
@property (nonatomic, assign) id delegate;
@end

@interface ThreadViewPopup : UIView {
	UIView					*view_;
	CancelView				*cancelView_;
	UIImageView				*background_;
}
- (void) cancel;
- (void) popout;
- (void) popupInView:(UIView*)view;
- (void) didReceiveMemoryWarning:(NSNotification*)obj;
- (void) threadViewPopupUIViewAnimationDelegate:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
@end
