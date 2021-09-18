//
//  DatParser.h
//  2tch
//
//  Created by sonson on 09/02/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThreadLayoutComponent.h"

@class Dat;
@class ThreadResData;

@interface DatParser : NSObject {
	Dat				*dat_;
	ThreadResData	*currentThreadRes_;
	NSMutableString	*container_;
	NSMutableArray	*stringContainer_;
	
	int				stack_;
	unichar			*stackData_;
}
@property ( nonatomic, retain ) Dat *dat;
@property ( nonatomic, retain ) ThreadResData *currentThreadRes;
@property ( nonatomic, retain ) NSMutableString *container;
@property ( nonatomic, retain ) NSMutableArray *stringContainer;
@end
