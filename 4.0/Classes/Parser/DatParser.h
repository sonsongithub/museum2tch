//
//  DatParser.h
//  parser
//
//  Created by sonson on 08/12/11.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Dat;

@interface DatParser : NSObject {
}
+ (NSArray*)getNumbers:(NSString*)anchor_string;
+ (void) parse:(NSMutableData*)data appendTo:(Dat*)dat;
@end
