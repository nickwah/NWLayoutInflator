//
//  NWXMLDictionary.h
//
//  Version 1.4
//
//  Created by Nick Lockwood on 15/11/2010.
//  Copyright 2010 Charcoal Design. All rights reserved.
//
//  Get the latest version of NWXMLDictionary from here:
//
//  https://github.com/nicklockwood/NWXMLDictionary
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <Foundation/Foundation.h>
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"


typedef NS_ENUM(NSInteger, NWXMLDictionaryAttributesMode)
{
    NWXMLDictionaryAttributesModePrefixed = 0, //default
    NWXMLDictionaryAttributesModeDictionary,
    NWXMLDictionaryAttributesModeUnprefixed,
    NWXMLDictionaryAttributesModeDiscard
};


typedef NS_ENUM(NSInteger, NWXMLDictionaryNodeNameMode)
{
    NWXMLDictionaryNodeNameModeRootOnly = 0, //default
    NWXMLDictionaryNodeNameModeAlways,
    NWXMLDictionaryNodeNameModeNever
};


static NSString *const NWXMLDictionaryAttributesKey   = @"__attributes";
static NSString *const NWXMLDictionaryCommentsKey     = @"__comments";
static NSString *const NWXMLDictionaryTextKey         = @"__text";
static NSString *const NWXMLDictionaryNodeNameKey     = @"__name";
static NSString *const NWXMLDictionaryAttributePrefix = @"_";
static NSString *const NWXMLDictionaryChildNodesKey   = @"__childNodes";


@interface NWXMLDictionaryParser : NSObject <NSCopying>

+ (NWXMLDictionaryParser *)sharedInstance;

@property (nonatomic, assign) BOOL collapseTextNodes; // defaults to YES
@property (nonatomic, assign) BOOL stripEmptyNodes;   // defaults to YES
@property (nonatomic, assign) BOOL trimWhiteSpace;    // defaults to YES
@property (nonatomic, assign) BOOL alwaysUseArrays;   // defaults to NO
@property (nonatomic, assign) BOOL preserveComments;  // defaults to NO
@property (nonatomic, assign) BOOL wrapRootNode;      // defaults to NO

@property (nonatomic, assign) NWXMLDictionaryAttributesMode attributesMode;
@property (nonatomic, assign) NWXMLDictionaryNodeNameMode nodeNameMode;

- (NSDictionary *)dictionaryWithParser:(NSXMLParser *)parser;
- (NSDictionary *)dictionaryWithData:(NSData *)data;
- (NSDictionary *)dictionaryWithString:(NSString *)string;
- (NSDictionary *)dictionaryWithFile:(NSString *)path;

@end


@interface NSDictionary (NWXMLDictionary)

+ (NSDictionary *)NWdictionaryWithXMLParser:(NSXMLParser *)parser;
+ (NSDictionary *)NWdictionaryWithXMLData:(NSData *)data;
+ (NSDictionary *)NWdictionaryWithXMLString:(NSString *)string;
+ (NSDictionary *)NWdictionaryWithXMLFile:(NSString *)path;

- (NSDictionary *)attributesNW;
- (NSDictionary *)safeAttributesNW;
- (NSArray *)childNodesNW;
- (NSArray *)commentsNW;
- (NSString *)nodeNameNW;
- (NSString *)innerText;
- (NSString *)innerXML;
- (NSString *)XMLString;

- (NSArray *)arrayValueForKeyPath:(NSString *)keyPath;
- (NSString *)stringValueForKeyPath:(NSString *)keyPath;
- (NSDictionary *)dictionaryValueForKeyPath:(NSString *)keyPath;

@end


@interface NSString (NWXMLDictionary)

- (NSString *)XMLEncodedString;

@end


#pragma GCC diagnostic pop
