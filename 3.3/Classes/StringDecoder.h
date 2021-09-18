//
//  string_tool.h
//  ch2ParserTest
//
//  Created by sonson on 08/12/10.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringDecoder : NSObject {
}
+ (void)initialize;
+ (NSString*)decodeBytesFrom:(char*)p length:(int)length;
+ (NSString*)decodeBytes:(char*)p from:(int)from to:(int)to;
@end
