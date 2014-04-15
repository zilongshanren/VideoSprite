#include "HelloWorldScene.h"
#include "VideoSprite.h"

USING_NS_CC;

Scene* HelloWorld::createScene()
{
    // 'scene' is an autorelease object
    auto scene = Scene::create();
    
    // 'layer' is an autorelease object
    auto layer = HelloWorld::create();

    // add layer as a child to scene
    scene->addChild(layer);

    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
bool HelloWorld::init()
{
    //////////////////////////////
    // 1. super init first
    if ( !Layer::init() )
    {
        return false;
    }
    auto winsize = Director::getInstance()->getVisibleSize();
    VideoSprite* sprite = VideoSprite::createWithFile("nnnn.mp4");
    sprite->setPosition(cocos2d::Point(winsize.width/2, winsize.height/2));
    sprite->setScale(0.5);
    this->addChild(sprite);
    
    auto moveBy = MoveBy::create(1.0, cocos2d::Point(0,100));
    auto scale = ScaleBy::create(1.0, 1.0);
    auto spawn = Spawn::create(moveBy, scale,  nil);
    auto spawn_reverse = spawn->reverse();
    auto sequence = Sequence::create(spawn, spawn_reverse, nil);
    auto repeat = RepeatForever::create(sequence);
    sprite->runAction(repeat);
    
    
    
    return true;
}


void HelloWorld::menuCloseCallback(Ref* pSender)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WP8) || (CC_TARGET_PLATFORM == CC_PLATFORM_WINRT)
	MessageBox("You pressed the close button. Windows Store Apps do not implement a close button.","Alert");
    return;
#endif

    Director::getInstance()->end();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    exit(0);
#endif
}
