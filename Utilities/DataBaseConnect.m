//
//  NSObject+DataBaseConnect.m
//  CMCMobileSec
//
//  Created by Nam on 12/26/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "DataBaseConnect.h"

@implementation DataBaseConnect{
    
}


-(void)insertUserData:(NSString *) email :(NSString *) password :(int) type :(NSString *)dbPath{
    sqlite3 *database;
    
    //Open db
    sqlite3_open([dbPath UTF8String], &database);
    
    static sqlite3_stmt *insertStmt = nil;
    
    if(insertStmt == nil)
    {
        char* insertSql = "INSERT INTO user_data (email, password, type) VALUES(?,?,?)";
        if(sqlite3_prepare_v2(database, insertSql, -1, &insertStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating insert statement. '%s'", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_text(insertStmt, 1, [email UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStmt, 2, [password UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStmt, 3, type);
    if(SQLITE_DONE != sqlite3_step(insertStmt)) {
        // NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
    }
    else
        NSLog(@"Inserted");
    //Reset the add statement.
    sqlite3_reset(insertStmt);
    insertStmt = nil;
    
    sqlite3_finalize(insertStmt);
    sqlite3_close(database);
}


-(void)updateActivation:(NSString *)dbPath{
    
    sqlite3 *database;
    
    //Open db
    sqlite3_open([dbPath UTF8String], &database);
    
    static sqlite3_stmt *updateStmt = nil;
    
    if(updateStmt == nil)
    {
        char* updateActivationSql = "UPDATE user_data SET type = \"2\" where type = \"1\"";
        if(sqlite3_prepare_v2(database, updateActivationSql, -1, &updateStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while update activatation statement. '%s'", sqlite3_errmsg(database));
    }
    
    if(SQLITE_DONE != sqlite3_step(updateStmt)) {
        // NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
    }
    else
        NSLog(@"Inserted");
    //Reset the add statement.
    sqlite3_reset(updateStmt);
    updateStmt = nil;
    
    sqlite3_finalize(updateStmt);
    sqlite3_close(database);
}

@end
