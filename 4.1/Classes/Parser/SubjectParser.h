//
//  DatParser.h
//  parser
//
//  Created by sonson on 08/12/11.
//  Copyright 2008 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SUBJECT_BUFFER_LENGTH 128

@interface SubjectParser : NSObject {
}
+ (void)parse:(NSData*)data appendTarget:(NSMutableArray*)array;
@end
