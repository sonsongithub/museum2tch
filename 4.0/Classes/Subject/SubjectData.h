//
//  SubjectData.h
//  2tch
//
//  Created by sonson on 08/12/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubjectData : NSObject {
	NSString	*title_;
	NSString	*path_;
	int			dat_;
	int			res_;
	int			number_;
	int			read_;
	
	NSString	*resString_;
	NSString	*readString_;
	NSString	*numberString_;
}
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* path;
@property (nonatomic, retain) NSString* resString;
@property (nonatomic, retain) NSString* readString;
@property (nonatomic, retain) NSString* numberString;
@property (nonatomic, assign) int dat;
@property (nonatomic, assign) int res;
@property (nonatomic, assign) int number;
@property (nonatomic, assign) int read;
@end
