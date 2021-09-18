//
//  PopupViewController.h
//  2tch
//
//  Created by sonson on 09/01/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface PopupViewController : NSObject {
	CancelView				*backgroundCancelView;
	ContentView				*contentView;
	UIImageView				*background;
}
#pragma mark Original method
- (void)cancel;
- (void)showInView:(UIView*)view;
@end
