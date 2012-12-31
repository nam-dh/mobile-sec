//
//  ServerCmdPraser.h
//  CMCMobileSec
//
//  Created by Nam on 12/31/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ServerCmdPraser : NSObject <NSXMLParserDelegate>


-(void) startPraser:(NSString*) xmlString;
@end
