//
//  ThreadDataBase.h
//  2tch
//
//  Created by sonson on 08/07/19.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ThreadDataBase : NSObject {
	NSString* dat_;
	NSString* boardPath_;
	
	NSMutableArray *resList_;
}

@property (nonatomic, assign) NSMutableArray *resList;
- (id) initWithBoardPath:(NSString*)boardPath dat:(NSString*)dat;
- (void) dealloc;
- (BOOL) load;
- (BOOL) write;
- (NSString*) extractLink:(NSString*) input;
- (BOOL) append:(NSData*) data;
@end
