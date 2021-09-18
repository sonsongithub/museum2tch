//
//  ThreadViewPopupRes.h
//  2tchfree
//
//  Created by sonson on 08/08/25.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThreadViewPopup.h"

@interface ThreadViewPopupRes : ThreadViewPopup <UIWebViewDelegate, UIAlertViewDelegate> {
	UIWebView* webView_;
}
- (void) setRes:(NSArray*)ary;
@end
