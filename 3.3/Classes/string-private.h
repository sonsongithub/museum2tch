//
//  global.h
//  2tch
//
//  Created by sonson on 08/05/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

NSDictionary* isURLOf2ch( NSString*url );

#pragma mark For auto text decoding
NSString* decodeNSData(NSData* data);
void releaseDecoding();
void readyForDecoding();
void readyForDecodingTypeString();
void initDataCode();

@interface NSString (URLencode)
- (NSString*) URLencode;
- (NSString*) URLdecode;
@end
/*
@interface NSDate (RFC1123)
- (NSString*) descriptionInRFC1123;
@end
*/