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
#ifndef __SUPPORT_CC_UTILS_H__
#define __SUPPORT_CC_UTILS_H__

#include <vector>
#include <string>
#include "2d/CCNode.h"
#include "base/ccMacros.h"
#include "base/CCData.h"


/** @file ccUtils.h
Misc free functions
*/

namespace cocos2d {
/*
ccNextPOT function is licensed under the same license that is used in Texture2D.m.
*/

/** returns the Next Power of Two value.

Examples:
- If "value" is 15, it will return 16.
- If "value" is 16, it will return 16.
- If "value" is 17, it will return 32.

@since v0.99.5
*/

int ccNextPOT(int value);

namespace utils
{
    /** Capture the entire screen.
     * To ensure the snapshot is applied after everything is updated and rendered in the current frame,
     * we need to wrap the operation with a custom command which is then inserted into the tail of the render queue.
     * @param afterCaptured specify the callback function which will be invoked after the snapshot is done.
     * @param filename specify a filename where the snapshot is stored. This parameter can be either an absolute path or a simple
     * base filename ("hello.png" etc.), don't use a relative path containing directory names.("mydir/hello.png" etc.).
     * @since v3.2
     */
    CC_DLL void  captureScreen(const std::function<void(bool, const std::string&)>& afterCaptured, const std::string& filename);

    /** Capture a specific Node.
    * @param startNode specify the snapshot Node. It should be cocos2d::Scene
    * @param scale
    * @returns: return a Image, then can call saveToFile to save the image as "xxx.png or xxx.jpg".
    * @since v3.11
    * !!! remark: Caller is responsible for releasing it by calling delete.
    */
    CC_DLL Image* captureNode(Node* startNode, float scale = 1.0f);

    /** Capture a specific Node and Save to file. (@kwkang 21-07-20 captureNode 참고해서 추가)
    * @param startNode specify the snapshot Node. It should be cocos2d::Scene
    * @param fileName specify the file name which will be saved.
    * @param scale
    */
    CC_DLL void captureNodeToFile(Node* startNode, const std::string& fileName, float scale = 1.0f);

    /** Get current exact time, accurate to nanoseconds.
    * @return Returns the time in seconds since the Epoch.
    */
    CC_DLL double  gettime();
}

}

#endif // __SUPPORT_CC_UTILS_H__
