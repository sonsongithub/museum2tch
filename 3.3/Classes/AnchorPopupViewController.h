//
//  AnchorPopupViewController.h
//  2tch
//
//  Created by sonson on 08/12/03.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThreadViewController;

@interface CancelView : UIView {
	id delegate_;
}
@property (nonatomic, assign) id delegate;
@end

@interface ContentView : UIView {
	id delegate_;
}
@property (nonatomic, assign) id delegate;
@end

@interface AnchorPopupViewController : NSObject <UIWebViewDelegate> {
	UIWebView				*webView_;
	CancelView				*backgroundCancelView;
	ContentView				*contentView;
	UIImageView				*background;
	
	UIButton *backButton;
	ThreadViewController	*delegate_;
	int						historyCounter_;
	NSMutableArray			*resStringBuff_;
}
@property (nonatomic, assign) ThreadViewController* delegate;
- (void)cancel;
- (void)showInView:(UIView*)view withHTMLSource:(NSString*)htmlString;
- (BOOL)isIt2ch:(NSString*)input toDictionary:(NSDictionary**)dict;
- (void)back:(id)sender;
- (void)updateBackButton;
@end
