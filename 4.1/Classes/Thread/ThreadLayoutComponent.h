//
//  StringRect.h
//  scroller
//
//  Created by sonson on 08/12/19.
//  Copyright 2008 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kThreadLayoutText,
	kThreadLayoutHTTPLink,
	kThreadLayoutAnchor,
	kThreadLayoutNewLine
}kThreadLayoutComponentIdentifier;

@interface ThreadLayoutComponent : NSObject {
	NSString	*text_;
	CGRect		rect_;
	int			textInfo_;
}
@property (nonatomic, retain) NSString* text;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) int textInfo;
@end


