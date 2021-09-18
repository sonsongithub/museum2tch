//
//  DatParser.h
//  parser
//
//  Created by sonson on 08/12/11.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

int utf8codeOfHTMLSpecialCharacter( char*p, int length );
NSMutableString* parseTitle( char*p, int head, int tail );

@interface SubjectParser : NSObject {
}
+ (void)parse:(NSData*)data appendTarget:(NSMutableArray*)array;
@end
