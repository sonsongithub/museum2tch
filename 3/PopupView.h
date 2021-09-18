//
//  PopupView.h
//  popupTest
//
//  Created by sonson on 08/07/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Downloader.h"

@interface CancelView : UIView {
	id delegate;
}
@property (nonatomic, assign) id delegate;
@end

@interface PopupView : UIView {
	CancelView* cancelView_;
	UITextView* text_;
	UILabel*	label_;
	UIImageView* background_;
	UIImageView* contentImage_;
	CGRect targetRect_;
	Downloader* downloader_;
	UIActivityIndicatorView* indicator_;
}

@end
