//
//  VideoSprite.h
//  MyCppGame
//
//  Created by guanghui on 4/15/14.
//
//

#ifndef __MyCppGame__VideoSprite__
#define __MyCppGame__VideoSprite__

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetReader.h>
#import <AVFoundation/AVAssetReaderOutput.h>
#import <AVFoundation/AVAudioPlayer.h>


#include <iostream>
#include "cocos2d.h"


using cocos2d::Sprite;

class VideoSprite : public Sprite
{
public:
    ~VideoSprite();
    
    static VideoSprite* createWithFile(const std::string& videoFileName);
    bool initWithFile(const std::string& videoFileName);
    void updateTexture(float dt);
    
protected:
    void rewindAssetReader();
    
private:
    VideoSprite();
    CC_DISALLOW_COPY_AND_ASSIGN(VideoSprite);
    AVURLAsset *asset;
    AVAssetTrack *videoTrack;
    AVAssetReader *assetReader;
    AVAssetReaderTrackOutput *trackOutput;
    AVAudioPlayer *player;
};

#endif /* defined(__MyCppGame__VideoSprite__) */
