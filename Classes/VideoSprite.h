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


#include <iostream>
#include "cocos2d.h"


using cocos2d::SpriteBatchNode;

class VideoSprite : public SpriteBatchNode
{
public:
    ~VideoSprite();
    
    VideoSprite* createWithVideoFile(const std::string& videoFileName);
    bool initWithVideoFile(const std::string& videoFileName);
    void updateTexture();
    
    
    
private:
    VideoSprite();
    CC_DISALLOW_COPY_AND_ASSIGN(VideoSprite);
    AVURLAsset *asset;
    AVAssetTrack *videoTrack;
    AVAssetReader *assetReader;
    AVAssetReaderTrackOutput *trackOutput;
};

#endif /* defined(__MyCppGame__VideoSprite__) */
