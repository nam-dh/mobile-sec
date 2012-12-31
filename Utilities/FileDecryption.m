//
//  FileDecryption.m
//  CMCMobileSec
//
//  Created by Nam on 12/27/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "FileDecryption.h"

@implementation FileDecryption {
    
}

+(NSData*) cryptPBEWithMD5AndDES:(CCOperation)op usingData:(NSData*)data withPassword:(NSString*)password andSalt:(NSData*)salt andIterating:(int)numIterations {
    
    unsigned char md5[CC_MD5_DIGEST_LENGTH];
    memset(md5, 0, CC_MD5_DIGEST_LENGTH);
    NSData* passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    
    CC_MD5_CTX ctx;
    CC_MD5_Init(&ctx);
    CC_MD5_Update(&ctx, [passwordData bytes], [passwordData length]);
    CC_MD5_Update(&ctx, [salt bytes], [salt length]);
    CC_MD5_Final(md5, &ctx);
    
    for (int i=1; i<numIterations; i++) {
        CC_MD5(md5, CC_MD5_DIGEST_LENGTH, md5);
    }
    
    size_t cryptoResultDataBufferSize = [data length] + kCCBlockSizeDES;
    unsigned char cryptoResultDataBuffer[cryptoResultDataBufferSize];
    size_t dataMoved = 0;
    
    unsigned char iv[kCCBlockSizeDES];
    memcpy(iv, md5 + (CC_MD5_DIGEST_LENGTH/2), sizeof(iv)); //iv is the second half of the MD5 from building the key
    
    CCCryptorStatus status =
    CCCrypt(op, kCCAlgorithmDES, kCCOptionPKCS7Padding, md5, (CC_MD5_DIGEST_LENGTH/2), iv, [data bytes], [data length],
            cryptoResultDataBuffer, cryptoResultDataBufferSize, &dataMoved);
    
    if(0 == status) {
        return [NSData dataWithBytes:cryptoResultDataBuffer length:dataMoved];
    } else {
        return NULL;
    }
}

@end
