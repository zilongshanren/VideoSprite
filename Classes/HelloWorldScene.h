#ifndef __HELLOWORLD_SCENE_H__
#define __HELLOWORLD_SCENE_H__

#include "cocos2d.h"
#include "ui/CocosGUI.h"

class VideoSprite;
using cocos2d::ui::TouchEventType;

class HelloWorld : public cocos2d::Layer
{
public:
    // there's no 'id' in cpp, so we recommend returning the class instance pointer
    static cocos2d::Scene* createScene();

    // Here's a difference. Method 'init' in cocos2d-x returns bool, instead of returning 'id' in cocos2d-iphone
    virtual bool init();  
    
    // a selector callback
    void menuCloseCallback(cocos2d::Ref* pSender);
    
    void onPlayVideo(Ref* ref, TouchEventType type);
    
    // implement the "static create()" method manually
    CREATE_FUNC(HelloWorld);
    
private:
    VideoSprite *_videoSprite;
};

#endif // __HELLOWORLD_SCENE_H__
