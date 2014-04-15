//
//  VideoSprite.cpp
//  MyCppGame
//
//  Created by guanghui on 4/15/14.
//
//

#include "VideoSprite.h"
#import <AVFoundation/AVMediaFormat.h>
#import <AVFoundation/AVAssetTrack.h>
#import <AVFoundation/AVAudioSettings.h>
using namespace cocos2d;

VideoSprite::VideoSprite()
{
    
}

VideoSprite::~VideoSprite()
{
    [player release];
    player = nil;
    [asset release];
    asset = nil;
    [videoTrack release];
    videoTrack = nil;
}


VideoSprite* VideoSprite::createWithFile(const std::string &videoFileName)
{
    VideoSprite* sprite = new VideoSprite;
    if (sprite && sprite->initWithFile(videoFileName)) {
        sprite->autorelease();
        return sprite;
    }
    CC_SAFE_DELETE(sprite);
    return sprite;
}

bool VideoSprite::initWithFile(const std::string &videoFileName)
{
    bool ret = true;
    do {
        if (!Sprite::init()) {
            ret = false;
            break;
        }
        
        NSString *name = [NSString stringWithUTF8String:videoFileName.c_str()];
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:name withExtension:nil];
        asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
        videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        NSError *error  = [[NSError alloc] autorelease];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
        player.numberOfLoops = 0;
        
        this->rewindAssetReader();
        
        CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer,0);
        /*Get information about the image*/
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        Texture2D *texture = new Texture2D;
        texture->initWithData(baseAddress,
                              bytesPerRow * height,
                              Texture2D::PixelFormat::BGRA8888,
                              (GLint)width,
                              (GLint)height,
                              cocos2d::Size(width,height));
        texture->autorelease();
        
        /*We unlock the  image buffer*/
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
         [(id)sampleBuffer release];
        
        this->initWithTexture(texture, cocos2d::Rect(0,0,width,height));
        
        
        float nominalFrameRate = videoTrack.nominalFrameRate;
        

        this->schedule(schedule_selector(VideoSprite::updateTexture), 1.0 / nominalFrameRate);
    } while (0);
    return ret;
}

void VideoSprite::updateTexture(float dt)
{
   
    if (assetReader.status == AVAssetReaderStatusCompleted) {
        // this texture should repeat from the beginning
        this->rewindAssetReader();
    }
    
    CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    /*Get information about the image*/
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);

//    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // update the texture
    glBindTexture(GL_TEXTURE_2D, this->getTexture()->getName());
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,
                 (GLint)width, (GLint)height,
                 0, GL_BGRA,
                 GL_UNSIGNED_BYTE, baseAddress);
    /*We unlock the  image buffer*/
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    [(id)sampleBuffer release];
    

    if (![player isPlaying]) {
            [player play];
    }
    
}

void VideoSprite::rewindAssetReader()
{
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],
                              (NSString*)kCVPixelBufferPixelFormatTypeKey,
                              nil];
    trackOutput = nil;
    trackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack
                                                             outputSettings:settings];
    
    NSError *error  = [[NSError alloc] autorelease];
    assetReader = nil;
    assetReader = [AVAssetReader assetReaderWithAsset:asset error:&error];
    if (error) {
        NSLog(@"init AVAssetReader failed:%@", [error localizedDescription]);
    }
    [assetReader addOutput:trackOutput];
    [assetReader startReading];
    [assetReader retain];
    [videoTrack retain];
    
}