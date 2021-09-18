//
//  html-tool.h
//  2tch
//
//  Created by sonson on 08/08/29.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

void releaseDictionariesForHTMLDecode();
void initDictionariesForHTMLDecode();
NSString* getConvertedSpecialChar (NSString* input);
NSString* extractLink(NSString* input);
NSString* eliminateBoldTagFromString(NSString*input );
NSMutableString* eliminateHTMLTag(NSString* input);