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
        
        this->initVideoTrack(videoFileName);
        
        this->initAudioTrack(videoFileName);
        
        this->rewindAssetReader();
        
        VideoSampler sampler = this->getVideoNextSampleBuffer();
        
        
        Texture2D *texture = new Texture2D;
        texture->initWithData(sampler.data,
                              sampler.dataLen,
                              Texture2D::PixelFormat::BGRA8888,
                              sampler.width,
                              sampler.height,
                              cocos2d::Size(sampler.width,sampler.height));
        texture->autorelease();
        
      
        
        this->initWithTexture(texture, cocos2d::Rect(0,0,sampler.width,sampler.height));
        
        
        float videoFrameRate = this->getVideoFrameRate();
        
        this->playAudio(1.0f / videoFrameRate);
        this->schedule(schedule_selector(VideoSprite::updateTexture), 1.0 / videoFrameRate);
    } while (0);
    return ret;
}

float VideoSprite::getVideoFrameRate()
{
    float frameRate = videoTrack.nominalFrameRate + 2;
    return frameRate;
}

void VideoSprite::rewindVideo()
{
    if (assetReader.status == AVAssetReaderStatusCompleted) {
        // this texture should repeat from the beginning
        this->rewindAssetReader();
        this->getVideoNextSampleBuffer();
        this->playAudio(0);
    }
}

void VideoSprite::updateTexture(float dt)
{
   
    this->rewindVideo();
    
    VideoSampler sampler = this->getVideoNextSampleBuffer();
    
    // update the texture
    glBindTexture(GL_TEXTURE_2D, this->getTexture()->getName());
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_RGBA,
                 sampler.width,
                 sampler.height,
                 0,
                 GL_BGRA,
                 GL_UNSIGNED_BYTE,
                 sampler.data);
    

    
}

void VideoSprite::playAudio(float delay)
{
    if (![player isPlaying]) {
        NSTimeInterval now = player.deviceCurrentTime;
        now = now + delay;
        [player playAtTime:now];
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

void VideoSprite::initVideoTrack(const std::string& videoFileName)
{
    NSString *name = [NSString stringWithUTF8String:videoFileName.c_str()];
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:name withExtension:nil];
    asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
}

void VideoSprite::initAudioTrack(const std::string& videoFileName)
{
    NSString *name = [NSString stringWithUTF8String:videoFileName.c_str()];
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:name withExtension:nil];
    NSError *error  = [[NSError alloc] autorelease];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    player.numberOfLoops = 0;
    
    _audioStartTime = player.currentTime;
    _audioDuration = player.duration;
}

VideoSampler VideoSprite::getVideoNextSampleBuffer()
{
    CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    /*Get information about the image*/
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    VideoSampler sampler;
    sampler.data = baseAddress;
    sampler.dataLen = bytesPerRow * height;
    sampler.width = (GLint)width;
    sampler.height = (GLint)height;
    
    /*We unlock the  image buffer*/
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    [(id)sampleBuffer release];
    
    return sampler;
}