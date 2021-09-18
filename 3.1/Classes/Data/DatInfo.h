//
//  DatInfo.h
//  2tchfree
//
//  Created by sonson on 08/08/24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DatInfo : NSObject {
	NSString			*filepath_;
	NSMutableDictionary	*infoDict_;
}
@property (nonatomic, assign) NSMutableDictionary *infoDict;
@property (nonatomic, assign) NSString *filepath;

+ (DatInfo*) DatInfoWithBoardPath:(NSString*)path;
- (BOOL) write;
- (void) setLength:(NSString*)length lastModified:(NSString*)lastModified ofDat:(NSString*)dat;
- (void) removeInfoOfDat:(NSString*)dat;
- (NSMutableDictionary*) dictOfDat:(NSString*) dat;

@end
