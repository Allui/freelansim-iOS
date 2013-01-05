//
//  FLHTMLUtils.m
//  freelansim-client
//
//  Created by Кирилл on 18.12.12.
//  Copyright (c) 2012 Kirill Kunst. All rights reserved.
//

#import "FLHTMLUtils.h"

@implementation FLHTMLUtils

+(NSString *)CSS {
    NSString *css = [NSString stringWithFormat:@"\n"
                     "body {font-family: AppleGothic; background-color:transparent; font-size:14px;}"
                     "\n"];
    return css;
}


+(NSString *)formattedDescription:(NSString *)HTML {
    NSString *htmlCode = [NSString stringWithFormat:@" \n"
                          "<html> \n"
                          "     <head> \n"
                          "     <title></title> \n"
                          "     <style>%@</style></head> \n" //CSS
                          "     <body> \n"
                          "         %@   "
                          "     </body> \n"
                          "</html>  \n",[self CSS], HTML];
    return htmlCode;
}


@end
