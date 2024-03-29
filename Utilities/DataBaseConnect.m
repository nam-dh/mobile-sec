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

-(void)insertScanStatistic:(NSString *) time :(NSString *) filenumber :(NSString *) dectectedNumber :(NSString*) virus :(NSString *)dbPath{
    sqlite3 *database;
    
    //Open db
    sqlite3_open([dbPath UTF8String], &database);
    
    static sqlite3_stmt *insertStmt = nil;
    
    if(insertStmt == nil)
    {
        char* insertSql = "INSERT INTO scanstatistic (time, filenumber, detectednumber , havevirus) VALUES(?,?,?,?)";
        if(sqlite3_prepare_v2(database, insertSql, -1, &insertStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating insert statement. '%s'", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_text(insertStmt, 1, [time UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStmt, 2, [filenumber UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStmt, 3, [dectectedNumber UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStmt, 4, [virus UTF8String], -1, SQLITE_TRANSIENT);
    
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

-(void)insertDetected:(NSString *) filename :(NSString*) virus :(NSString *)dbPath{
    sqlite3 *database;
    
    //Open db
    sqlite3_open([dbPath UTF8String], &database);
    
    static sqlite3_stmt *insertStmt = nil;
    
    if(insertStmt == nil)
    {
        char* insertSql = "INSERT INTO detected (filename, virus) VALUES(?,?)";
        if(sqlite3_prepare_v2(database, insertSql, -1, &insertStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating insert statement. '%s'", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_text(insertStmt, 1, [filename UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStmt, 2, [virus UTF8String], -1, SQLITE_TRANSIENT);
    
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

+(NSMutableArray *) getScanStatistic:(NSString *)dbPath {
    
    NSMutableArray* data = [NSMutableArray array];
    
    NSString *time = @"";
    NSString *filenumber = @"";
    NSString *detectednumber = @"";
    NSString *havevirus = @"";
    
    sqlite3 *database;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *statement;
        
        const char *sql = "select time, filenumber, detectednumber, havevirus from scanstatistic";
        
        sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
        
        // Use the while loop if you want more than just the most recent message
        while (sqlite3_step(statement) == SQLITE_ROW) {
        
        //if (sqlite3_step(statement) == SQLITE_ROW) {
            char *content = (char *)sqlite3_column_text(statement, 0);
            time = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
            content = (char *)sqlite3_column_text(statement, 1);
            filenumber = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
            content = (char *)sqlite3_column_text(statement, 1);
            detectednumber = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
            content = (char *)sqlite3_column_text(statement, 1);
            havevirus = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
            
            NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
            [item setObject:time forKey:@"time"];
            [item setObject:filenumber forKey:@"totalScanned"];
            [item setObject:detectednumber forKey:@"totalDetected"];
            [item setObject:havevirus forKey:@"havevirus"];
            [data addObject:item];
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
        
        //NSLog(@"email=%@", text);
        
    }
    else
        sqlite3_close(database); //Even though the open call failed, close the database connection to release all the memory.
    return data;
}

+(void) doWhenReceivingNewMess {
    
    NSString *number = @"";
    NSString *text = @"";
    
    sqlite3 *database;
    NSString *path=@"/private/var/mobile/Library/SMS/sms.db";
    
    // if(sqlite3_open([@"/private/var/mobile/Library/Voicemail/voicemail.db" UTF8String], &database) == SQLITE_OK) {
    if(sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt *statement;
        // iOS 4 and 5 may require different SQL, as the .db format may change
        const char *sql4 = "SELECT text, address from message ORDER BY rowid DESC";  // TODO: different for iOS 4.* ???
        const char *sql5 = "SELECT text, address from message ORDER BY rowid DESC";
        
        NSString *osVersion =[[UIDevice currentDevice] systemVersion];
        
        if([osVersion hasPrefix:@"5"]) {
            // iOS 5.* -> tested
            
            sqlite3_prepare_v2(database, sql5, -1, &statement, NULL);
            
        } else {
            // iOS != 5.* -> untested!!!
            sqlite3_prepare_v2(database, sql4, -1, &statement, NULL);
        }
        
        // Use the while loop if you want more than just the most recent message
        //while (sqlite3_step(statement) == SQLITE_ROW) {
        
        if (sqlite3_step(statement) == SQLITE_ROW) {
            char *content = (char *)sqlite3_column_text(statement, 0);
            text = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
            
            content = (char *)sqlite3_column_text(statement, 1);
            number = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
            
            sqlite3_finalize(statement);
            NSLog(@"text=%@", number);
        }
        
        sqlite3_close(database);
    } else {
        NSLog(@"Not Open");
    }
    
    NSString *prefix=[number substringToIndex:1];
    NSString *newNumber = nil;
    
    if([prefix isEqualToString: @"+"]) {
        newNumber = [number substringFromIndex:1];
    }
    
    
    //Search in blacklist number or not
    //Open db
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"cmc.db"];
    
    NSString *result = nil;
    
    sqlite3_open([dbPath UTF8String], &database);
    
    static sqlite3_stmt *searchNumber = nil;
    
    if(searchNumber == nil)
    {
        char* insertSql = "select count(*) from message where address = ?";
        if(sqlite3_prepare_v2(database, insertSql, -1, &searchNumber, NULL) != SQLITE_OK) {
            //NSAssert1(0, @"Error while creating insert statement. '%s'", sqlite3_errmsg(database));
        }
    }
    
    sqlite3_bind_text(searchNumber, 1, [newNumber UTF8String], -1, SQLITE_TRANSIENT);
    
    if (sqlite3_step(searchNumber) == SQLITE_ROW) {
        char *content = (char *)sqlite3_column_text(searchNumber, 0);
        result = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
        sqlite3_finalize(searchNumber);
        
    }
    sqlite3_close(database);
    NSString *outText = nil;
    
    if([result isEqualToString: @"0"]) {
        NSLog(@"OK");
        outText = @"OK";
    } else {
        NSLog(@"Spam");
        outText = @"Spam";
        
        //remove
        if(sqlite3_open([path UTF8String], &database) == SQLITE_OK)
        {
            sqlite3_stmt *deleteStmt = nil;
            
            if(deleteStmt == nil)
            {
                char* insertSql = "DELETE FROM message WHERE address = ? and text =?";
                if(sqlite3_prepare_v2(database, insertSql, -1, &deleteStmt, NULL) != SQLITE_OK) {
                    //  NSAssert1(0, @"Error while creating insert statement. '%s'", sqlite3_errmsg(database));
                }
            }
            
            sqlite3_bind_text(deleteStmt, 1, [number UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(deleteStmt, 2, [text UTF8String], -1, SQLITE_TRANSIENT);
            if(SQLITE_DONE != sqlite3_step(deleteStmt)) {
                //  NSAssert1(0, @"Error while deleting data. '%s'", sqlite3_errmsg(database));
                
            }else
                NSLog(@"Deleted");
            //Reset the add statement.
            sqlite3_reset(deleteStmt);
            deleteStmt = nil;
            
            sqlite3_finalize(deleteStmt);
            sqlite3_close(database);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:number
                                                            message:outText
                                                           delegate:nil
                                                  cancelButtonTitle:@"Deleted!"
                                                  otherButtonTitles:nil];
            [alert show];
            
            
        } else {
            NSLog(@"Not Open");
        }
        
    }
}

+(NSMutableArray *) getSMSfromDB {
    
    NSMutableArray* sms_db = [NSMutableArray array];
    
    NSString *number = @"";
    NSString *text = @"";
    NSString *date = @"";
    NSString *type = @"";
    
    sqlite3 *database;
    NSString *path=@"/private/var/mobile/Library/SMS/sms.db";
    
    // if(sqlite3_open([@"/private/var/mobile/Library/Voicemail/voicemail.db" UTF8String], &database) == SQLITE_OK) {
    if(sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt *statement;
        // iOS 4 and 5 may require different SQL, as the .db format may change
        const char *sql = "SELECT date, text, address, madrid_flags  from message ORDER BY rowid DESC";  // TODO: different for iOS 4.* ???
        sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
            
        // Use the while loop if you want more than just the most recent message
        while (sqlite3_step(statement) == SQLITE_ROW) {
        
        //if (sqlite3_step(statement) == SQLITE_ROW) {
            char *content = (char *)sqlite3_column_text(statement, 0);
            date= [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
            
            content = (char *)sqlite3_column_text(statement, 1);
            text = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
            
            content = (char *)sqlite3_column_text(statement, 2);
            number = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
            
            content = (char *)sqlite3_column_text(statement, 3);
            type = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
            
            sqlite3_finalize(statement);
            //NSLog(@"text=%@", number);
            
            NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
            [item setObject:date forKey:@"date"];
            [item setObject:number forKey:@"address"];
            [item setObject:type forKey:@"type"];
            [item setObject:text forKey:@"body"];
            [sms_db addObject:item];

        }
        
        sqlite3_close(database);
    } else {
        NSLog(@"Not Open");
    }

    
    
    return sms_db;
    
}

@end
