//
//  ResObject.h
//  scroller
//
//  Created by sonson on 08/12/19.
//  Copyright 2008 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThreadResData : NSObject {
	int				number_;
	NSString		*numberString_;
	NSString		*name_;
	NSString		*email_;
	NSString		*date_;
	NSMutableArray	*body_;
	float			height_;
	BOOL			isSelected_;
	BOOL			isPopup_;
}
@property (nonatomic, assign) int number;
@property (nonatomic, retain) NSString* numberString;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* email;
@property (nonatomic, retain) NSString* date;
@property (nonatomic, retain) NSMutableArray* body;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isPopup;
@end