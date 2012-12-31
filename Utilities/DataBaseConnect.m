//
//  DataBaseConnect.m
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

+ (NSString *) getDBPath {
    //Search for standard documents using NSSearchPathForDirectoriesInDomains
    //First Param = Searching the documents directory
    //Second Param = Searching the Users directory and not the System
    //Expand any tildes and identify home directories.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"cmc.db"];
}

+(int) checkUserData:(NSString *)dbPath {
    NSString *text = @"";
    int i = 0;
    sqlite3 *database;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *statement;
        
        const char *sql = "SELECT type from user_data";
        
        sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
        
        // Use the while loop if you want more than just the most recent message
        //while (sqlite3_step(statement) == SQLITE_ROW) {
        
        if (sqlite3_step(statement) == SQLITE_ROW) {
            char *content = (char *)sqlite3_column_text(statement, 0);
            text = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
        i = [text intValue];
        
        NSLog(@"data=%d", i);
        
    }
    else
        sqlite3_close(database); //Even though the open call failed, close the database connection to release all the memory.
    
    return i;
}

+(NSString*) getEmail:(NSString *)dbPath {
    NSString *text = @"";
    sqlite3 *database;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *statement;
        
        const char *sql = "SELECT email from user_data";
        
        sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
        
        // Use the while loop if you want more than just the most recent message
        //while (sqlite3_step(statement) == SQLITE_ROW) {
        
        if (sqlite3_step(statement) == SQLITE_ROW) {
            char *content = (char *)sqlite3_column_text(statement, 0);
            text = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
        
        NSLog(@"email=%@", text);
        
    }
    else
        sqlite3_close(database); //Even though the open call failed, close the database connection to release all the memory.
    return text;
}

+(NSString*) getPassword:(NSString *)dbPath {
    NSString *text = @"";
    sqlite3 *database;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *statement;
        
        const char *sql = "SELECT password from user_data";
        
        sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
        
        // Use the while loop if you want more than just the most recent message
        //while (sqlite3_step(statement) == SQLITE_ROW) {
        
        if (sqlite3_step(statement) == SQLITE_ROW) {
            char *content = (char *)sqlite3_column_text(statement, 0);
            text = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
        
        NSLog(@"password=%@", text);
        
    }
    else
        sqlite3_close(database); //Even though the open call failed, close the database connection to release all the memory.
    return text;
}
+ (void) copyDatabaseIfNeeded {
    //Using NSFileManager we can perform many file system operations.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *dbPath = [DataBaseConnect getDBPath];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if(!success) {
        
        NSLog(@"not success");
        
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"cmc.db"];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        
        if (!success){
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
            NSLog(@"failed");
        }
    }
}

@end
