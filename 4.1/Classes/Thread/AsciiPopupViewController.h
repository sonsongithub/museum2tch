//
//  AsciiPopupViewController.h
//  2tch
//
//  Created by sonson on 09/01/03.
//  Copyright 2009 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PopupViewController.h"

@class ThreadResData;

@interface ResView : UIView {
	NSMutableString	*resString_;
	ThreadResData	*resData_;
}
@property (nonatomic, retain) NSMutableString *resString;
@property (nonatomic, retain) ThreadResData *resData;
@end

@interface AsciiPopupViewController : PopupViewController <UIScrollViewDelegate> {
	UIScrollView	*scrollView_;
	ResView			*resView_;
	ThreadResData	*resData_;
}
@property (nonatomic, retain) ThreadResData *resData;
@end
