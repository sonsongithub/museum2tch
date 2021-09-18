//
//  SNTableViewCellDrawRect.h
//  2tch
//
//  Created by sonson on 08/10/24.
//  Copyright 2008 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNCellBackgroundForDrawRectDelegate
- (void)drawBackgroundRect:(CGRect)rect;
@end

@interface SNCellBackgroundForDrawRect : UIView {
	NSObject<SNCellBackgroundForDrawRectDelegate> *delegate_;
}
- (id)initWithDelegate:(NSObject<SNCellBackgroundForDrawRectDelegate>*)delegate;
@end

@interface SNCellForDrawRect : UITableViewCell <SNCellBackgroundForDrawRectDelegate> {
}

@end
