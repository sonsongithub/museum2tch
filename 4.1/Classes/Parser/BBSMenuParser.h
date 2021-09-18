//
//  BBSMenuParser.h
//  parser
//
//  Created by sonson on 08/12/11.
//  Copyright 2008 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BBSMenuParser : NSObject {
}
+ (NSString*)categoryTitleWithCategoryID:(int)category_id;
+ (void)parse:(NSData*)data;
@end
