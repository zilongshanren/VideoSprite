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
using namespace cocos2d;

VideoSprite::VideoSprite()
{
    
}

VideoSprite::~VideoSprite()
{
    
}


VideoSprite* VideoSprite::createWithVideoFile(const std::string &videoFileName)
{
    VideoSprite* sprite = new VideoSprite;
    if (sprite && sprite->initWithVideoFile(videoFileName)) {
        sprite->autorelease();
        return sprite;
    }
    CC_SAFE_DELETE(sprite);
    return sprite;
}

bool VideoSprite::initWithVideoFile(const std::string &videoFileName)
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
        
        this->rewindAssetReader();
        
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer([trackOutput copyNextSampleBuffer]);
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
                              width,
                              height,
                              cocos2d::Size(width,height));
        texture->autorelease();
        
        /*We unlock the  image buffer*/
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        
        this->initWithTexture(texture, cocos2d::Rect(0,0,width,height));
        // schedule texture updates for the frame duration (1/freq)
//        float nominalFrameRate = videoTrack.nominalFrameRate;
//        this->schedule(schedule_selector(VideoSprite::updateTexture), 1.0 / nominalFrameRate);
    } while (0);
    return ret;
}


void VideoSprite::draw(cocos2d::Renderer *renderer, const kmMat4 &transform, bool transformUpdated)
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
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, baseAddress);
    /*We unlock the  image buffer*/
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    //    [sampleBuffer release];
    
    Sprite::draw(renderer, transform, transformUpdated);
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
    if(!baseAddress) {
        
        this->cocos2d::Node::draw();
        
        return ;
        
    }
//    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // update the texture
    glBindTexture(GL_TEXTURE_2D, this->getTexture()->getName());
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, baseAddress);
    /*We unlock the  image buffer*/
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
//    [sampleBuffer release];
}

void VideoSprite::rewindAssetReader()
{
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],
                              (NSString*)kCVPixelBufferPixelFormatTypeKey,
                              nil];
    trackOutput = nil;
    trackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:settings];
    
    NSError *error  = [[NSError alloc] autorelease];
    assetReader = nil;
    assetReader = [AVAssetReader assetReaderWithAsset:asset error:&error];
    [assetReader addOutput:trackOutput];
    [assetReader startReading];
}