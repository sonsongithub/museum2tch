//
//  DatParser.h
//  parser
//
//  Created by sonson on 08/12/11.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubjectData : NSObject {
	NSString	*title_;
	NSString	*path_;
	int			dat_;
	int			res_;
}
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* path;
@property (nonatomic, assign) int dat;
@property (nonatomic, assign) int res;
@end

@interface SubjectParser : NSObject {
}
+ (void)parse:(NSData*)data;
+ (void)parse:(NSData*)data appendTarget:(NSMutableArray*)array;
@end
