//
//  SubjectTxtParser.h
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubjectTxtParser : NSObject {

}
+ (BOOL) writeSubjectTxt:(NSData*)data withPath:(NSString*)path;
- (void) deletePreviousData;
- (void) parse:(NSData*)data;
@end
