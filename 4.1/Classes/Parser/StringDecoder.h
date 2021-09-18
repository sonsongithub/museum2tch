//
//  string_tool.h
//  ch2ParserTest
//
//  Created by sonson on 08/12/10.
//  Copyright 2008 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringDecoder : NSObject {
}
+ (unsigned int)encodeingFromBytes:(char*)p length:(int)length;
+ (NSString*)decodeBytesFrom:(char*)p length:(int)length;
+ (NSString*)decodeBytesFrom:(char*)p length:(int)length encoding:(int*)encoding;
+ (NSString*)decodeBytes:(char*)p from:(int)from to:(int)to;
@end
