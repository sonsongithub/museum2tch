//
//  ThreadRenderingView.h
//  2tch
//
//  Created by sonson on 08/12/01.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThreadViewController;

@interface ThreadRenderingView : UIWebView <UIWebViewDelegate> {
	ThreadViewController* mainDelegate_;
}
@property (nonatomic, assign) id mainDelegate;
@end
