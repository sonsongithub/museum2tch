//
//  DatInfoDataBase.h
//  2tch
//
//  Created by sonson on 08/07/18.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DatInfoDataBase : NSObject {
	NSString			*boardPath_;
	NSMutableDictionary	*infoList_;
}
@property (nonatomic, assign) NSMutableDictionary *infoList;
- (id) initWithBoardPath:(NSString*)boardPath;
- (BOOL) load;
- (BOOL) write;
- (void) dealloc;
@end
