//
//  FileDecryption.h
//  CMCMobileSec
//
//  Created by Nam on 12/27/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonCryptor.h>

@interface  FileDecryption :NSObject

+(NSData*) cryptPBEWithMD5AndDES:(CCOperation)op usingData:(NSData*)data withPassword:(NSString*)password andSalt:(NSData*)salt andIterating:(int)numIterations;

@end
