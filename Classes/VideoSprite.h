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


using cocos2d::Sprite;

class VideoSprite : public Sprite
{
public:
    ~VideoSprite();
    
    static VideoSprite* createWithVideoFile(const std::string& videoFileName);
    bool initWithVideoFile(const std::string& videoFileName);
    void updateTexture(float dt);
    
    virtual void draw(cocos2d::Renderer *renderer, const kmMat4 &transform, bool transformUpdated) override;

protected:
    void rewindAssetReader();
    
private:
    VideoSprite();
    CC_DISALLOW_COPY_AND_ASSIGN(VideoSprite);
    AVURLAsset *asset;
    AVAssetTrack *videoTrack;
    AVAssetReader *assetReader;
    AVAssetReaderTrackOutput *trackOutput;
};

#endif /* defined(__MyCppGame__VideoSprite__) */
