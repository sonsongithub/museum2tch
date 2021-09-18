//
//  CellForDrawRect.h
//  scroller
//
//  Created by sonson on 08/12/15.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThreadResData;
@class ThreadViewController;

@interface ThreadCell : UITableViewCell {
	ThreadResData			*resObject_;
	float					height_;
	CGRect					infoRect_;
	CGRect					buttonRect_;
	ThreadViewController	*delegate_;
}
@property (nonatomic, assign) ThreadResData* resObject;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) ThreadViewController* delegate;
#pragma mark Original Method
+ (float)offsetHeight;
+ (float)offsetHeightOfPopup;
- (BOOL)isIt2ch:(NSString*)input toDictionary:(NSDictionary**)dict;
@end
