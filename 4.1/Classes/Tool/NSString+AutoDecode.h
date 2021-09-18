//
//  NSString+AutoDecode.h
//  2tch
//
//  Created by sonson on 09/02/14.
//  Copyright 2009 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(AutoDecode)
+ (NSString*)stringFromBytes:(char*)p length:(int)length encodingResult:(int*)encodingResult;
+ (NSString*)stringFromBytes:(char*)p length:(int)length;
+ (NSString*)stringFromBytes:(char*)p offset:(int)offset tail:(int)tail encodingResult:(int*)encodingResult;
+ (NSString*)stringFromBytes:(char*)p offset:(int)offset tail:(int)tail;
+ (NSString*)stringFromBytes:(char*)p range:(NSRange)range encodingResult:(int*)encodingResult;
+ (NSString*)stringFromBytes:(char*)p range:(NSRange)range;
@end
