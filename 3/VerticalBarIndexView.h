//
//  VarticalBarIndexView.h
//  2tch
//
//  Created by sonson on 08/08/04.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndexElementLabel : UILabel {
}
@end

@interface VerticalBarIndexView : UIView {
	UIImageView*	background_;
	NSMutableArray* elements_;
	int				current_index_;
	id				delegate_;
}

@end
