//
//  global.h
//  2tch
//
//  Created by sonson on 08/05/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef	_DEBUG
	#define	DNSLog(...);	NSLog(__VA_ARGS__);
#else
	#define DNSLog(...);	// NSLog(__VA_ARGS__);
#endif

#pragma mark For decoding html source
void initDictionariesForHTMLDecode();
NSString* getConvertedSpecialChar (NSString* input);

#pragma mark For arranging 2ch dat or subject.txt file
NSString* getDat( NSString* dat );
NSString* getThreadTitle (NSString* input);
NSString* getThreadNumber (NSString* input);
NSString* extractLink(NSString* input);
NSString* eliminateBoldTagFromString(NSString*input );
NSMutableString* eliminateHTMLTag(NSString* input);

#pragma mark For auto text decoding
NSString* decodeNSData(NSData* data);
void readyForDecoding();
void readyForDecodingTypeString();
void initDataCode();