//
//  Tools.m
//  MobileFaceNet-iOS
//
//  Created by 周文鹏 on 2020/1/15.
//  Copyright © 2020 周文鹏. All rights reserved.
//

#import "Tools.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>

@implementation Tools

+ (NSString *)filePathForResourceName:(NSString *)name extension:(NSString *)extension {
    NSString *file_path = [[NSBundle mainBundle] pathForResource:name ofType:extension];
    if (file_path == NULL) {
        NSLog(@"在bundle中没有找到 '%@.%@'.", name, extension);
    }
    return file_path;
}

+ (UInt8 *)convertUIImageToBitmapRGBA8:(UIImage *)image {

    CGImageRef imageRef = image.CGImage;

    // Create a bitmap context to draw the uiimage into
    CGContextRef context = [self newBitmapRGBA8ContextFromImage:imageRef];

    if(!context) {
        return NULL;
    }

    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);

    CGRect rect = CGRectMake(0, 0, width, height);

    // Draw image into the context to get the raw image data
    CGContextDrawImage(context, rect, imageRef);

    // Get a pointer to the data
    unsigned char *bitmapData = (unsigned char *)CGBitmapContextGetData(context);

    // Copy the data and release the memory (return memory allocated with new)
    size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);
    size_t bufferLength = bytesPerRow * height;

    unsigned char *newBitmap = NULL;

    if(bitmapData) {
        newBitmap = (unsigned char *)malloc(sizeof(unsigned char) * bytesPerRow * height);

        if(newBitmap) {    // Copy the data
            for(int i = 0; i < bufferLength; ++i) {
                newBitmap[i] = bitmapData[i];
            }
        }

        free(bitmapData);

    } else {
        NSLog(@"Error getting bitmap pixel data\n");
    }

    CGContextRelease(context);

    return newBitmap;
}

+ (CGContextRef)newBitmapRGBA8ContextFromImage:(CGImageRef)image {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    uint32_t *bitmapData;

    size_t bitsPerPixel = 32;
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;

    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);

    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferLength = bytesPerRow * height;

    colorSpace = CGColorSpaceCreateDeviceRGB();

    if(!colorSpace) {
        NSLog(@"Error allocating color space RGB\n");
        return NULL;
    }

    // Allocate memory for image data
    bitmapData = (uint32_t *)malloc(bufferLength);

    if(!bitmapData) {
        NSLog(@"Error allocating memory for bitmap\n");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }

    //Create bitmap context

    context = CGBitmapContextCreate(bitmapData,
                                    width,
                                    height,
                                    bitsPerComponent,
                                    bytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedLast);    // RGBA
    if(!context) {
        free(bitmapData);
        NSLog(@"Bitmap context not created");
    }

    CGColorSpaceRelease(colorSpace);

    return context;
}

+ (UIImage *)convertBitmapRGBA8ToUIImage:(uint8_t *)buffer withWidth:(int) width withHeight:(int) height {

    size_t bufferLength = width * height * 4;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 32;
    size_t bytesPerRow = 4 * width;

    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    if(colorSpaceRef == NULL) {
        NSLog(@"Error allocating color space");
        CGDataProviderRelease(provider);
        return nil;
    }

    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;

    CGImageRef iref = CGImageCreate(width,
                                    height,
                                    bitsPerComponent,
                                    bitsPerPixel,
                                    bytesPerRow,
                                    colorSpaceRef,
                                    bitmapInfo,
                                    provider,    // data provider
                                    NULL,        // decode
                                    YES,            // should interpolate
                                    renderingIntent);

    uint32_t* pixels = (uint32_t*)malloc(bufferLength);

    if(pixels == NULL) {
        NSLog(@"Error: Memory not allocated for bitmap");
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(colorSpaceRef);
        CGImageRelease(iref);
        return nil;
    }

    CGContextRef context = CGBitmapContextCreate(pixels,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpaceRef,
                                                 kCGImageAlphaPremultipliedLast);

    if(context == NULL) {
        NSLog(@"Error context not created");
        free(pixels);
    }

    UIImage *image = nil;
    if(context) {

        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), iref);

        CGImageRef imageRef = CGBitmapContextCreateImage(context);

        // Support both iPad 3.2 and iPhone 4 Retina displays with the correct scale
        if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
            float scale = [[UIScreen mainScreen] scale];
            image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
        } else {
            image = [UIImage imageWithCGImage:imageRef];
        }

        CGImageRelease(imageRef);
        CGContextRelease(context);
    }

    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(iref);
    CGDataProviderRelease(provider);

    if(pixels) {
        free(pixels);
    }
    return image;
}

+ (UInt8 *)convertUIImageToBitmapGray:(UIImage *)image {

    CGImageRef imageRef = image.CGImage;

    // Create a bitmap context to draw the uiimage into
    CGContextRef context = [self newBitmapGrayContextFromImage:imageRef];

    if(!context) {
        return NULL;
    }

    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);

    CGRect rect = CGRectMake(0, 0, width, height);

    // Draw image into the context to get the raw image data
    CGContextDrawImage(context, rect, imageRef);

    // Get a pointer to the data
    unsigned char *bitmapData = (unsigned char *)CGBitmapContextGetData(context);

    // Copy the data and release the memory (return memory allocated with new)
    size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);
    size_t bufferLength = bytesPerRow * height;

    unsigned char *newBitmap = NULL;

    if(bitmapData) {
        newBitmap = (unsigned char *)malloc(sizeof(unsigned char) * bytesPerRow * height);

        if(newBitmap) {    // Copy the data
            for(int i = 0; i < bufferLength; ++i) {
                newBitmap[i] = bitmapData[i];
            }
        }

        free(bitmapData);

    } else {
        NSLog(@"Error getting bitmap pixel data\n");
    }

    CGContextRelease(context);

    return newBitmap;
}

+ (CGContextRef)newBitmapGrayContextFromImage:(CGImageRef)image {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    uint32_t *bitmapData;

    size_t bitsPerPixel = 8;
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;

    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);

    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferLength = bytesPerRow * height;

    colorSpace = CGColorSpaceCreateDeviceGray();

    if(!colorSpace) {
        NSLog(@"Error allocating color space Gray\n");
        return NULL;
    }

    // Allocate memory for image data
    bitmapData = (uint32_t *)malloc(bufferLength);

    if(!bitmapData) {
        NSLog(@"Error allocating memory for bitmap\n");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }

    //Create bitmap context

    context = CGBitmapContextCreate(bitmapData,
                                    width,
                                    height,
                                    bitsPerComponent,
                                    bytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaNone);
    if(!context) {
        free(bitmapData);
        NSLog(@"Bitmap context not created");
    }

    CGColorSpaceRelease(colorSpace);

    return context;
}

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scale {
    CGSize size = CGSizeMake(image.size.width * scale, image.size.height * scale);
    return [self scaleImage:image toSize:size];
}

+ (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

@end
