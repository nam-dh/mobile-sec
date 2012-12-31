//
//  DataBaseConnect.h
//  CMCMobileSec
//
//  Created by Nam on 12/26/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DataBaseConnect: NSObject

-(void)insertUserData:(NSString *) email :(NSString *) password :(int) type :(NSString *)dbPath;
-(void)updateActivation:(NSString *)dbPath;
+ (void) copyDatabaseIfNeeded;
+ (NSString *) getDBPath;
+(int) checkUserData:(NSString *)dbPath ;
+(void) getUserData:(NSString *)dbPath;
+(NSString*) getEmail:(NSString *)dbPath ;
+(NSString*) getPassword:(NSString *)dbPath ;

@end
