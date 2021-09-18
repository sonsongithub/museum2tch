//
//  ThreadDatParser.h
//  threadParser
//
//  Created by sonson on 09/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Dat;

@interface ThreadDatParser : NSObject {
	char			*stack_;
	int				stackPointer_;
	int				currentCode_;
	Dat				*dat_;
	
	char*			currentEntryHead_;
	int				currentEntryLength_;
	NSMutableArray	*array_;
	NSMutableArray	*currentComponents_;
}
+ (void)getNumberFromDividedComma:(NSString*)string appendTo:(NSMutableArray*)res;
+ (NSMutableArray*)getNumber:(NSString*)anchor_string;
- (int)currentCode;
- (int)parseAnchor:(char*)headPointer length:(int)length pointer:(int*)pointer;
- (int)parseTag:(char*)headPointer length:(int)length pointer:(int*)pointer;
- (int)parseHTTP:(char*)headPointer length:(int)length pointer:(int*)pointer;
- (int)parseHTMLChar:(char*)headPointer length:(int)length pointer:(int*)pointer;
- (int)skipHeadNewline;
- (void)skipTailNewline;
- (void)popStackIntoComponents:(int)componentMode;
- (void)copyIntoComponents:(char*)headPointer length:(int)length components:(int)componentMode;
- (void)bodyParseWithEmoji:(char*)headPointer length:(int)length;
- (void)bodyParse:(char*)headPointer length:(int)length;
- (id)parseAnEntry:(char*)headPointer length:(int)length;
- (void)parse:(NSMutableData*)data appendToDat:(Dat*)dat;
- (void)layout:(NSMutableArray*)array width:(int)width;
- (void)parse:(NSMutableData*)data appendTo:(NSMutableArray*)array;
@end
