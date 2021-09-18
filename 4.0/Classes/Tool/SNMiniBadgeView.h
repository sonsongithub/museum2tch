//
//  MiniBadgeView.h
//  2tch
//
//  Created by sonson on 08/12/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SNMiniBadgeView : UIImageView {
	UILabel		*label_;
	CGPoint		rightTop_;
}
@property ( nonatomic, assign ) CGPoint rightTop;
#pragma mark Original Method
- (void)set:(int)remained;
@end
