//
//  NSData+Base64.h
//  base64
//
//  Created by Matt Gallagher on 2009/06/03.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import <Foundation/Foundation.h>

void *NewBase64Decode(
	const char *inputBuffer,
	size_t length,
	size_t *outputLength);

char *NewBase64Encode(
	const void *inputBuffer,
	size_t length,
	bool separateLines,
	size_t *outputLength);

@interface NSData (Base64)

+ (NSData *)dataFromBase64String:(NSString *)aString;
- (NSString *)base64EncodedString;

// added by Hiroshi Hashiguchi
- (NSString *)base64EncodedStringWithSeparateLines:(BOOL)separateLines;

/*! @function +dataWithBase64EncodedString:
 @discussion This method returns an autoreleased NSData object. The NSData object is initialized with the
 contents of the Base 64 encoded string. This is a convenience method.
 @param inBase64String An NSString object that contains only Base 64 encoded data.
 @result The NSData object. */
+ (NSData *) dataWithBase64EncodedString:(NSString *) string;

/*! @function -initWithBase64EncodedString:
 @discussion The NSData object is initialized with the contents of the Base 64 encoded string.
 This method returns self as a convenience.
 @param inBase64String An NSString object that contains only Base 64 encoded data.
 @result This method returns self. */
- (id) initWithBase64EncodedString:(NSString *) string;

/*! @function -base64EncodingWithLineLength:
 @discussion This method returns a Base 64 encoded string representation of the data object.
 @param inLineLength A value of zero means no line breaks. This is crunched to a multiple of 4 (the next
 one greater than inLineLength).
 @result The base 64 encoded data. */
- (NSString *) base64EncodingWithLineLength:(unsigned int) lineLength;

@end
