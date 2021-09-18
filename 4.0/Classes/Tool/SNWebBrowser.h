//
//  SNWebBrowser.h
//  2tch
//
//  Created by sonson on 08/12/01.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SNWebBrowser : UINavigationController <UIWebViewDelegate> {
	UIWebView			*webView_;

	UIBarButtonItem		*backButton_;
	UIBarButtonItem		*forwardButton_;
	UIBarButtonItem		*imageButton_;
	UIBarButtonItem		*safariButton_;
}
- (void)openURLString:(NSString*)url;
- (id) initWithoutRootViewController;
@end
