//
//  NSObject+CyptoHelper.m
//  CMCMobileSec
//
//  Created by Nam on 12/30/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "CryptoHelper.h"

@implementation CryptoHelper

#pragma mark -
#pragma mark Init Methods
- (id)init
{
    if(self = [super init])
    {
        
    }
    return self;
}

#pragma mark -
#pragma mark String Specific Methods

/**
 *  Encrypts a string for social blast service.
 *
 *  @param  plainString The string to encrypt;
 *
 *  @return NSString    The encrypted string.
 */
- (NSString *)encryptString: (NSString *) plainString{
    
    // Convert string to data and encrypt
    NSData *data = [self encryptPBEWithMD5AndDESData:[plainString dataUsingEncoding:NSUTF8StringEncoding] password:@"1111"];
    
    
    
    // Get encrypted string from data
    return [data base64EncodingWithLineLength:1024];
    
}


/**
 *  Descrypts a string from social blast service.
 *
 *  @param  plainString The string to decrypt;
 *
 *  @return NSString    The decrypted string.
 */
- (NSString *)decryptString: (NSString *) encryptedString{
    
    // decrypt the data
    NSData * data = [self decryptPBEWithMD5AndDESData:[NSData dataWithBase64EncodedString:encryptedString] password:@"1111"];
    
    // extract and return string
    return [NSString stringWithUTF8String:[data bytes]];
    
}


#pragma mark -
#pragma mark Crypto Methods

- (NSData *)encryptPBEWithMD5AndDESData:(NSData *)inData password:(NSString *)password {
    return [self encodePBEWithMD5AndDESData:inData password:password direction:1];
}

- (NSData *)decryptPBEWithMD5AndDESData:(NSData *)inData password:(NSString *)password {
    return [self encodePBEWithMD5AndDESData:inData password:password direction:0];
}

- (NSData *)encodePBEWithMD5AndDESData:(NSData *)inData password:(NSString *)password direction:(int)direction
{
    NSLog(@"helper data = %@", inData);
    
    static const char gSalt[] =
    {
        (unsigned char)0xAA, (unsigned char)0xAA, (unsigned char)0xAA, (unsigned char)0xAA,
        (unsigned char)0xAA, (unsigned char)0xAA, (unsigned char)0xAA, (unsigned char)0xAA,
        (unsigned char)0x00
    };
    
    unsigned char *salt = (unsigned char *)gSalt;
    int saltLen = strlen(gSalt);
    int iterations = 15;
    
    EVP_CIPHER_CTX cipherCtx;
    
    
    unsigned char *mResults; // allocated storage of results
    int mResultsLen = 0;
    
    const char *cPassword = [password UTF8String];
    
    unsigned char *mData = (unsigned char *)[inData bytes];
    int mDataLen = [inData length];
    
    
    SSLeay_add_all_algorithms();
    X509_ALGOR *algorithm = PKCS5_pbe_set(NID_pbeWithMD5AndDES_CBC,
                                          iterations, salt, saltLen);
    
    
    
    memset(&cipherCtx, 0, sizeof(cipherCtx));
    
    if (algorithm != NULL)
    {
        EVP_CIPHER_CTX_init(&(cipherCtx));
        
        
        
        if (EVP_PBE_CipherInit(algorithm->algorithm, cPassword, strlen(cPassword),
                               algorithm->parameter, &(cipherCtx), direction))
        {
            
            EVP_CIPHER_CTX_set_padding(&cipherCtx, 1);
            
            int blockSize = EVP_CIPHER_CTX_block_size(&cipherCtx);
            int allocLen = mDataLen + blockSize + 1; // plus 1 for null terminator on decrypt
            mResults = (unsigned char *)OPENSSL_malloc(allocLen);
            
            
            unsigned char *in_bytes = mData;
            int inLen = mDataLen;
            unsigned char *out_bytes = mResults;
            int outLen = 0;
            
            
            
            int outLenPart1 = 0;
            if (EVP_CipherUpdate(&(cipherCtx), out_bytes, &outLenPart1, in_bytes, inLen))
            {
                out_bytes += outLenPart1;
                int outLenPart2 = 0;
                if (EVP_CipherFinal(&(cipherCtx), out_bytes, &outLenPart2))
                {
                    outLen += outLenPart1 + outLenPart2;
                    mResults[outLen] = 0;
                    mResultsLen = outLen;
                }
            } else {
                unsigned long err = ERR_get_error();
                
                ERR_load_crypto_strings();
                ERR_load_ERR_strings();
                char errbuff[256];
                errbuff[0] = 0;
                ERR_error_string_n(err, errbuff, sizeof(errbuff));
                NSLog(@"OpenSLL ERROR:\n\tlib:%s\n\tfunction:%s\n\treason:%s\n",
                      ERR_lib_error_string(err),
                      ERR_func_error_string(err),
                      ERR_reason_error_string(err));
                ERR_free_strings();
            }
            
            
            NSData *encryptedData = [NSData dataWithBytes:mResults length:mResultsLen]; //(NSData *)encr_buf;
            
            
            //NSLog(@"encryption result: %@\n", [encryptedData base64EncodingWithLineLength:1024]);
            
            EVP_cleanup();
            
            return encryptedData;
        }
    }
    EVP_cleanup();
    return nil;
    
}

@endd
