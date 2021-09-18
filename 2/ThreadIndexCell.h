//
//  ThreadIndexCell.h
//  2tch
//
//  Created by sonson on 08/03/10.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEFALUT_FONT_SIZE 19.0f

@interface ThreadIndexCell : UIImageAndTextTableCell {
	float height_;
	id delegate_;
}
+ (float) defaultHeight;
- (float) height;
@end
