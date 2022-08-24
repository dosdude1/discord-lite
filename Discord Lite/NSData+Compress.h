//
//  NSData+Compress.h
//  SGURLProtocol
//
//  Created by Simon Grätzer on 26.08.12.
//  Copyright (c) 2012 Simon Grätzer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <zlib.h>

@interface NSData (Compress)
// Decompress http deflate encoding
- (NSData *)zlibInflate;

// Compress http deflate encoding
- (NSData *)zlibDeflate;

// Decompress http gzip encoding
- (NSData *)gzipInflate;
// Compress http gzip encoding
- (NSData *)gzipDeflate;
@end
