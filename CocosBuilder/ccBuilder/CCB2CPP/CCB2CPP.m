//
//  CCB2CPP.m
//  CocosBuilder
//
//  Created by yanbin on 13-11-14.
//
//

#import "CCB2CPP.h"
#import "GRMustacheTemplate.h"

@implementation CCB2CPP



+ (void) convertFromDictionaryDoc:(NSDictionary*)doc from:(NSString*)srcFile to:(NSString*)toFile
{
    NSDictionary* nodeGraph = [doc objectForKey:@"nodeGraph"];
    NSString* baseClass = [nodeGraph objectForKey:@"baseClass"];
    NSString* customClass = [nodeGraph objectForKey:@"customClass"];
    NSString* className = NULL;
    NSString* ccbname = [[srcFile componentsSeparatedByString:@"/"] lastObject];
    NSString* outputPath = [toFile substringToIndex:[toFile rangeOfString:@"/" options:NSBackwardsSearch].location];
    outputPath = [outputPath stringByAppendingString:@"/cpp/"];
    [[NSFileManager defaultManager] createDirectoryAtPath:outputPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    
    if ([customClass length] != 0) {
        className = customClass;
    }
    else{
        className = [ccbname substringToIndex:[ccbname rangeOfString:@"."].location];
    }
    NSMutableArray* objectsArr = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    [CCB2CPP writeNodeGraph:nodeGraph toArray:objectsArr];

    
    NSLog(@"%@",[objectsArr description]);

    NSMutableArray* variables = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSMutableArray* menuitem_callbacks = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    for (NSDictionary *dict in objectsArr) {
        if ([dict objectForKey:@"memberVarAssignmentName"] != nil &&
            [[dict objectForKey:@"memberVarAssignmentName"] length] > 0) {
            [variables addObject:@{@"type": [dict objectForKey:@"baseClass"],
                                  @"name": [dict objectForKey:@"memberVarAssignmentName"]
                                   }];
        }
        if ([dict objectForKey:@"callback"] != nil &&
            [[dict objectForKey:@"callback"] length] > 0) {
            [menuitem_callbacks addObject:@{@"callback": [dict objectForKey:@"callback"]}];
        }
        
    }

    
    NSDictionary* params = @{@"variables": variables,
                             @"classname":className,
                             @"menuitem_callbacks":menuitem_callbacks,
                             @"ccbname":ccbname,
                             @"baseclass":baseClass
                             };
    
    NSLog(@"%@",[params description]);
    
    NSStringEncoding encoding;
    NSError *error;
    
    NSFileManager *filemgr;
    NSString *currentpath;
    
    filemgr = [[NSFileManager alloc] init];
    
    currentpath = [filemgr currentDirectoryPath];

    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *template_hFileContents = [[[NSString alloc] initWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:@"ccb2cpp/template.h.tpl"]
                                                             usedEncoding:&encoding
                                                                    error:&error]
                                 autorelease];

    
    NSLog(@"templatepath:%@ %lu" , [documentsDirectory stringByAppendingPathComponent:@"template.h.tpl"], (unsigned long)[template_hFileContents length] );
    NSString *hFileContents = [GRMustacheTemplate renderObject:params fromString:template_hFileContents error:NULL];
    NSString *outfpath = [[NSString alloc ] initWithFormat:@"%@%@%@", outputPath, className, @".h" ];
    [hFileContents writeToFile:outfpath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    

    NSString *template_cppFileContents = [[[NSString alloc] initWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:@"ccb2cpp/template.cpp.tpl"]
                                                           usedEncoding:&encoding
                                                                  error:&error]
                               autorelease];
    
    NSLog(@"templatepath:%@ %lu" , [documentsDirectory stringByAppendingPathComponent:@"template.cpp.tpl"], (unsigned long)[template_cppFileContents length]);
    NSString *cppFileContents = [GRMustacheTemplate renderObject:params fromString:template_cppFileContents error:NULL];
    outfpath = [[NSString alloc ] initWithFormat:@"%@%@%@", outputPath, className, @".cpp" ];
    [cppFileContents writeToFile:outfpath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


+ (void) writeNodeGraph:(NSDictionary*)node toArray:(NSMutableArray*)resultArr
{
    // Write class
    NSString* baseClass = [node objectForKey:@"baseClass"];
    NSString* customClass = [node objectForKey:@"customClass"];
    NSString* memberVarAssignmentName = [node objectForKey:@"memberVarAssignmentName"];
    NSString* memberVarAssignmentType = [node objectForKey:@"memberVarAssignmentType"];
    
    NSMutableDictionary* resultObjectDict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    [resultArr addObject:resultObjectDict];
    
    [resultObjectDict setObject:baseClass forKey:@"baseClass"];
    [resultObjectDict setObject:customClass forKey:@"customClass"];
    [resultObjectDict setObject:memberVarAssignmentName forKey:@"memberVarAssignmentName"];
    [resultObjectDict setObject:memberVarAssignmentType forKey:@"memberVarAssignmentType"];
    
    // Write properties
    NSArray* props = [node objectForKey:@"properties"];

    for (int i = 0; i < [props count]; i++)
    {
        NSDictionary* prop = [props objectAtIndex:i];
        
        id value = [prop objectForKey:@"value"];
        NSString* type = [prop objectForKey:@"type"];
//        NSString* name = [prop objectForKey:@"name"];
        
        NSLog(@"%@",type);
        if (value)
        {
            if ([type isEqualToString:@"Block"])
            {
                NSString* callback = [value objectAtIndex:0];
                [resultObjectDict setObject:callback forKey:@"callback"];
            }
        }
        
    }
    
    
    // Write children
    NSArray* children = [node objectForKey:@"children"];

    for (int i = 0; i < [children count]; i++)
    {
        [self writeNodeGraph:[children objectAtIndex:i] toArray:resultArr];
    }
}

@end
