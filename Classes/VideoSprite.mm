//
//  VideoSprite.cpp
//  MyCppGame
//
//  Created by guanghui on 4/15/14.
//
//

#include "VideoSprite.h"


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
        if (!SpriteBatchNode::init()) {
            ret = false;
            break;
        }
    } while (0);
    return ret;
}