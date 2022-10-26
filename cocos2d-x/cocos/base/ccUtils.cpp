/****************************************************************************
Copyright (c) 2010      cocos2d-x.org
Copyright (c) 2013-2014 Chukong Technologies Inc.

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/

#include "base/ccUtils.h"

#include <cmath>
#include <stdlib.h>
//#include "md5/md5.h"
#include <chrono>

#include "base/CCDirector.h"
#include "base/CCAsyncTaskPool.h"
#include "base/CCEventDispatcher.h"
#include "base/base64.h"
#include "base/ccUTF8.h"
#include "renderer/CCCustomCommand.h"
#include "renderer/CCRenderer.h"
#include "renderer/CCTextureCache.h"
#include "CCGLView.h"

#include "platform/CCImage.h"
#include "platform/CCFileUtils.h"
#include "2d/CCSprite.h"
#include "2d/CCRenderTexture.h"

namespace cocos2d {

int ccNextPOT(int x)
{
    x = x - 1;
    x = x | (x >> 1);
    x = x | (x >> 2);
    x = x | (x >> 4);
    x = x | (x >> 8);
    x = x | (x >>16);
    return x + 1;
}

namespace utils
{
    /**
    * Capture screen implementation, don't use it directly.
    */
    void onCaptureScreen(const std::function<void(bool, const std::string&)>& afterCaptured, const std::string& filename)
    {
        static bool startedCapture = false;

        if (startedCapture)
        {
            CCLOG("Screen capture is already working");
            if (afterCaptured)
            {
                afterCaptured(false, filename);
            }
            return;
        }
        else
        {
            startedCapture = true;
        }


        auto glView = Director::getInstance()->getOpenGLView();
        auto frameSize = glView->getFrameSize();
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_MAC) || (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)
//        frameSize = frameSize * glView->getFrameZoomFactor() * glView->isRetinaEnabled();
//#endif

        int width = static_cast<int>(frameSize.width);
        int height = static_cast<int>(frameSize.height);

        bool succeed = false;
        std::string outputFile = "";

        do
        {
            std::shared_ptr<GLubyte> buffer(new GLubyte[width * height * 4], [](GLubyte* p) { CC_SAFE_DELETE_ARRAY(p); });
            if (!buffer)
            {
                break;
            }

            glPixelStorei(GL_PACK_ALIGNMENT, 1);
            glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer.get());

            std::shared_ptr<GLubyte> flippedBuffer(new GLubyte[width * height * 4], [](GLubyte* p) { CC_SAFE_DELETE_ARRAY(p); });
            if (!flippedBuffer)
            {
                break;
            }

            for (int row = 0; row < height; ++row)
            {
                memcpy(flippedBuffer.get() + (height - row - 1) * width * 4, buffer.get() + row * width * 4, width * 4);
            }

            Image* image = new (std::nothrow) Image;
            if (image)
            {
                image->initWithRawData(flippedBuffer.get(), width * height * 4, width, height, 8);
                if (FileUtils::getInstance()->isAbsolutePath(filename))
                {
                    outputFile = filename;
                }
                else
                {
                    CCASSERT(filename.find('/') == std::string::npos, "The existence of a relative path is not guaranteed!");
                    outputFile = FileUtils::getInstance()->getWritablePath() + filename;
                }

                // Save image in AsyncTaskPool::TaskType::TASK_IO thread, and call afterCaptured in mainThread
                static bool succeedSaveToFile = false;
                std::function<void(void*)> mainThread = [afterCaptured, outputFile](void* /*param*/)
                {
                    if (afterCaptured)
                    {
                        afterCaptured(succeedSaveToFile, outputFile);
                    }
                    startedCapture = false;
                };

                AsyncTaskPool::getInstance()->enqueue(AsyncTaskPool::TaskType::TASK_IO, std::move(mainThread), nullptr, [image, outputFile]()
                    {
                        succeedSaveToFile = image->saveToFile(outputFile);

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
                        int width = image->getWidth();
                        int height = image->getHeight();
                        int bitPerPixel = image->getBitPerPixel();
                        unsigned char* bytes = image->getData();
                        unsigned char* temp = new unsigned char[4];

                        int len = image->getDataLen();
                        for (int i = 0; i < len; i++)
                        {
                            if (i % 4 == 0)
                            {
                                int idx = (i / 4);
                                unsigned char* pixel = (bytes + i);

                                // r, g, b, a -> b, g, r, a
                                unsigned char temp = *(pixel);
                                *(pixel) = *(pixel + 2);
                                *(pixel + 2) = temp;
                            }
                        }

                        HBITMAP hbitmap = CreateBitmap(width, height, 1, bitPerPixel, (void*)bytes);
                        HWND hwnd = GetDesktopWindow();
                        OpenClipboard(hwnd);
                        EmptyClipboard();
                        SetClipboardData(CF_BITMAP, hbitmap);
                        CloseClipboard();

                        DeleteObject(hbitmap);
#endif      
                        delete image;
                    });
            }
            else
            {
                CCLOG("Malloc Image memory failed!");
                if (afterCaptured)
                {
                    afterCaptured(succeed, outputFile);
                }
                startedCapture = false;
            }
        } while (0);
    }

    /*
     * Capture screen interface
     */
    static EventListenerCustom* s_captureScreenListener;
    static CustomCommand s_captureScreenCommand;
    void captureScreen(const std::function<void(bool, const std::string&)>& afterCaptured, const std::string& filename)
    {
        if (s_captureScreenListener)
        {
            CCLOG("Warning: CaptureScreen has been called already, don't call more than once in one frame.");
            return;
        }
        s_captureScreenCommand.init(std::numeric_limits<float>::max());
        s_captureScreenCommand.func = std::bind(onCaptureScreen, afterCaptured, filename);
        s_captureScreenListener = Director::getInstance()->getEventDispatcher()->addCustomEventListener(Director::EVENT_AFTER_DRAW, [](EventCustom* /*event*/) {
            auto director = Director::getInstance();
            director->getEventDispatcher()->removeEventListener((EventListener*)(s_captureScreenListener));
            s_captureScreenListener = nullptr;
            director->getRenderer()->addCommand(&s_captureScreenCommand);
            director->getRenderer()->render();
            });
    }

    Image* captureNode(Node* startNode, float scale)
    { // The best snapshot API, support Scene and any Node
        auto& size = startNode->getContentSize();

        Director::getInstance()->setNextDeltaTimeZero(true);

        RenderTexture* finalRtx = nullptr;

        auto rtx = RenderTexture::create(size.width, size.height, Texture2D::PixelFormat::RGBA8888, GL_DEPTH24_STENCIL8);
        // rtx->setKeepMatrix(true);
        Point savedPos = startNode->getPosition();
        Point anchor;
        if (!startNode->isIgnoreAnchorPointForPosition()) {
            anchor = startNode->getAnchorPoint();
        }
        startNode->setPosition(Point(size.width * anchor.x, size.height * anchor.y));
        rtx->begin();
        startNode->visit();
        rtx->end();
        startNode->setPosition(savedPos);

        if (std::abs(scale - 1.0f) < 1e-6f/* no scale */)
            finalRtx = rtx;
        else {
            /* scale */
            auto finalRect = Rect(0, 0, size.width, size.height);
            Sprite* sprite = Sprite::createWithTexture(rtx->getSprite()->getTexture(), finalRect);
            sprite->setAnchorPoint(Point(0, 0));
            sprite->setFlippedY(true);

            finalRtx = RenderTexture::create(size.width * scale, size.height * scale, Texture2D::PixelFormat::RGBA8888, GL_DEPTH24_STENCIL8);

            sprite->setScale(scale); // or use finalRtx->setKeepMatrix(true);
            finalRtx->begin();
            sprite->visit();
            finalRtx->end();
        }

        Director::getInstance()->getRenderer()->render();

        return finalRtx->newImage();
    }

    void captureNodeToFile(Node* startNode, const std::string& filename, float scale)
    { // The best snapshot API, support Scene and any Node
        auto& size = startNode->getContentSize();
        auto parent = startNode->getParent();
        auto& parent_size = parent->getContentSize();

        Director::getInstance()->setNextDeltaTimeZero(true);

        RenderTexture* finalRtx = nullptr;

        auto rtx = RenderTexture::create(size.width, size.height, Texture2D::PixelFormat::RGBA8888, GL_DEPTH24_STENCIL8);
        // rtx->setKeepMatrix(true);
        Point savedPos = startNode->getPosition();
        Point savedDock = startNode->getDockPoint();

        Point anchor;
        if (!startNode->isIgnoreAnchorPointForPosition()) {
            anchor = startNode->getAnchorPoint();
        }

        startNode->setDockPoint(Point(0, 0));
        startNode->setPosition(Point(size.width * anchor.x, size.height * anchor.y));
        rtx->begin();
        startNode->visit();
        rtx->end();
        startNode->setDockPoint(savedDock);
        startNode->setPosition(savedPos);

        if (std::abs(scale - 1.0f) < 1e-6f/* no scale */)
            finalRtx = rtx;
        else {
            /* scale */
            auto finalRect = Rect(0, 0, size.width, size.height);
            Sprite* sprite = Sprite::createWithTexture(rtx->getSprite()->getTexture(), finalRect);
            sprite->setAnchorPoint(Point(0, 0));
            sprite->setFlippedY(true);

            finalRtx = RenderTexture::create(size.width * scale, size.height * scale, Texture2D::PixelFormat::RGBA8888, GL_DEPTH24_STENCIL8);

            sprite->setScale(scale); // or use finalRtx->setKeepMatrix(true);
            finalRtx->begin();
            sprite->visit();
            finalRtx->end();
        }

        Director::getInstance()->getRenderer()->render();

        Image* newImage = finalRtx->newImage();
        newImage->saveToFile(filename, false); 

        CC_SAFE_DELETE(newImage);
    }

    double gettime()
    {
        struct timeval tv;
        gettimeofday(&tv, nullptr);

        return (double)tv.tv_sec + (double)tv.tv_usec / 1000000;
    }
}

}