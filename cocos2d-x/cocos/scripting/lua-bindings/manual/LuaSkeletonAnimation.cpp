 /****************************************************************************
 Copyright (c) 2013      Edward Zhou
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

#include "LuaSkeletonAnimation.h"
#include "cocos2d.h"
#include "LuaScriptHandlerMgr.h"
#include "CCLuaStack.h"
#include "CCLuaEngine.h"

using namespace spine;
USING_NS_CC;

LuaSkeletonAnimation::LuaSkeletonAnimation(spSkeletonData* skeletonData)
    : spine::SkeletonAnimation(skeletonData)
{
	
}


LuaSkeletonAnimation::~LuaSkeletonAnimation()
{
    ScriptHandlerMgr::getInstance()->removeObjectAllHandlers((void*)this);
}

LuaSkeletonAnimation* LuaSkeletonAnimation::createWithFile (const char* skeletonDataFile, const char* atlasFile, float scale)
{
    spSkeletonData* skeletonData;
    auto cache_iter = spine::SkeletonAnimation::s_skeleton_data_cache.find(skeletonDataFile);
    if (cache_iter != spine::SkeletonAnimation::s_skeleton_data_cache.end())
    {
        skeletonData = cache_iter->second;
    }
    else
    {
        spAtlas* atlas = spAtlas_createFromFile(atlasFile, 0);
        CCASSERT(atlas, "Error reading atlas file.");

        spSkeletonJson* json = spSkeletonJson_create(atlas);
        json->scale = scale;
        skeletonData = spSkeletonJson_readSkeletonDataFile(json, skeletonDataFile);

        if (skeletonData == NULL)
        {
            spSkeletonJson_dispose(json);
            return NULL;
        }
        CCASSERT(skeletonData, json->error ? json->error : "Error reading skeleton data file.");
        spSkeletonJson_dispose(json);

        spine::SkeletonAnimation::s_skeleton_data_cache.insert(TYPE_SKELETON_DATA_CACHE::value_type(skeletonDataFile, skeletonData));
        CCLOG("LuaSkeletonAnimation add cache : %s", skeletonDataFile);
    }

    LuaSkeletonAnimation* node = new (std::nothrow) LuaSkeletonAnimation(skeletonData);
	node->autorelease();
	return node;
}