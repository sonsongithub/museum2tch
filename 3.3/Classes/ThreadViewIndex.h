//
//  ThreadViewIndex.h
//  2tchfree
//
//  Created by sonson on 08/08/24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThreadViewIndex : UIView {
	UIImageView*		background_;
	NSMutableArray*		labels_;
	NSMutableArray*		indices_;
	NSMutableArray*		clickViews_;
	int					current_index_;
	id					delegate_;
}
- (id)initWithDelegate:(id)delegate;
- (void)prepareForReuseFrom:(int)from to:(int)to;
- (void)evaluateTouch:(CGPoint)p;
@end
