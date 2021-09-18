//
//  SubjectTxtParser.h
//  parser
//
//  Created by sonson on 08/12/11.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DatParser : NSObject {
}
//+ (void) parse:(NSData*)data;
+ (void) parse:(NSData*)data toArray:(NSMutableArray*)array;
@end
