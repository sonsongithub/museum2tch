//
//  SNToolbarController.h
//  2tch
//
//  Created by sonson on 08/11/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SNToolbarController : NSObject {
	NSMutableArray	*items_;
	UIToolbar		*parentToolbar_;
	id				delegate_;
}
@property (nonatomic, assign) NSMutableArray	*items;
@property (nonatomic, assign) UIToolbar			*parentToolbar;
- (id)initWithDelegate:(id)delegate;
- (void)update;
@end
