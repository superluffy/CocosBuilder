//
//  CCB2CPP.h
//  CocosBuilder
//
//  Created by yanbin on 13-11-14.
//  http://www.mobile-mafia.com
//

#import <Foundation/Foundation.h>

@interface CCB2CPP : NSObject



+ (void) convertFromDictionaryDoc:(NSDictionary*)doc from:(NSString*)srcFile to:(NSString*)toFile;
+ (void) writeNodeGraph:(NSDictionary*)node toArray:(NSMutableArray*)resultArr;


@end


