//
//  ServerResponePraser.h
//  CMCMobileSec
//
//  Created by Nam on 12/31/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerResponePraser:NSObject <NSXMLParserDelegate>

-(void) startPraser:(NSMutableData*) xmlData;

@end
