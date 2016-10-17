/******************************************************************************
 * Spine Runtimes Software License
 * Version 2.3
 *
 * Copyright (c) 2013-2015, Esoteric Software
 * All rights reserved.
 *
 * You are granted a perpetual, non-exclusive, non-sublicensable and
 * non-transferable license to use, install, execute and perform the Spine
 * Runtimes Software (the "Software") and derivative works solely for personal
 * or internal use. Without the written permission of Esoteric Software (see
 * Section 2 of the Spine Software License Agreement), you may not (a) modify,
 * translate, adapt or otherwise create derivative works, improvements of the
 * Software or develop new applications using the Software or (b) remove,
 * delete, alter or obscure any trademarks or any copyright, trademark, patent
 * or other intellectual property or proprietary rights notices on or in the
 * Software, including any copy thereof. Redistributions in binary or source
 * form must include this license and terms.
 *
 * THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL ESOTERIC SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

#include <spine/SkeletonAnimation.h>
#include <spine/spine-cocos2dx.h>
#include <spine/extension.h>
#include <spine/PolygonBatch.h>
#include <algorithm>

USING_NS_CC;
using std::min;
using std::max;
using std::vector;

namespace spine {

SkeletonAnimation::TYPE_SKELETON_DATA_CACHE SkeletonAnimation::s_skeleton_data_cache;
void animationCallback (spAnimationState* state, int trackIndex, spEventType type, spEvent* event, int loopCount) {
	((SkeletonAnimation*)state->rendererObject)->onAnimationStateEvent(trackIndex, type, event, loopCount);
}

void trackEntryCallback (spAnimationState* state, int trackIndex, spEventType type, spEvent* event, int loopCount) {
	((SkeletonAnimation*)state->rendererObject)->onTrackEntryEvent(trackIndex, type, event, loopCount);
}

typedef struct _TrackEntryListeners {
	StartListener startListener;
	EndListener endListener;
	CompleteListener completeListener;
	EventListener eventListener;
} _TrackEntryListeners;

static _TrackEntryListeners* getListeners (spTrackEntry* entry) {
	if (!entry->rendererObject) {
		entry->rendererObject = NEW(spine::_TrackEntryListeners);
		entry->listener = trackEntryCallback;
	}
	return (_TrackEntryListeners*)entry->rendererObject;
}

void disposeTrackEntry (spTrackEntry* entry) {
	if (entry->rendererObject) FREE(entry->rendererObject);
	_spTrackEntry_dispose(entry);
}

//

SkeletonAnimation* SkeletonAnimation::createWithData (spSkeletonData* skeletonData, bool ownsSkeletonData) {
	SkeletonAnimation* node = new SkeletonAnimation(skeletonData, ownsSkeletonData);
	node->autorelease();
	return node;
}

SkeletonAnimation* SkeletonAnimation::createWithFile (const std::string& skeletonDataFile, spAtlas* atlas, float scale) {
	SkeletonAnimation* node = new SkeletonAnimation(skeletonDataFile, atlas, scale);
	node->autorelease();
	return node;
}

SkeletonAnimation* SkeletonAnimation::createWithFile (const std::string& skeletonDataFile, const std::string& atlasFile, float scale) {
	SkeletonAnimation* node = new SkeletonAnimation(skeletonDataFile, atlasFile, scale);
	node->autorelease();
	return node;
}

void SkeletonAnimation::initialize () {
	_ownsAnimationStateData = true;
	_state = spAnimationState_create(spAnimationStateData_create(_skeleton->data));
	_state->rendererObject = this;
	_state->listener = animationCallback;

	_spAnimationState* stateInternal = (_spAnimationState*)_state;
	stateInternal->disposeTrackEntry = disposeTrackEntry;
}

SkeletonAnimation::SkeletonAnimation ()
		: SkeletonRenderer() {
}

SkeletonAnimation::SkeletonAnimation (spSkeletonData *skeletonData, bool ownsSkeletonData)
		: SkeletonRenderer(skeletonData, ownsSkeletonData) {
	initialize();
}

SkeletonAnimation::SkeletonAnimation (const std::string& skeletonDataFile, spAtlas* atlas, float scale)
		: SkeletonRenderer(skeletonDataFile, atlas, scale) {
	initialize();
}

SkeletonAnimation::SkeletonAnimation (const std::string& skeletonDataFile, const std::string& atlasFile, float scale)
		: SkeletonRenderer(skeletonDataFile, atlasFile, scale) {
	initialize();
}

SkeletonAnimation::~SkeletonAnimation () {
	if (_ownsAnimationStateData) spAnimationStateData_dispose(_state->data);
	spAnimationState_dispose(_state);
    clearBinder();
}

void SkeletonAnimation::update (float deltaTime) {
	super::update(deltaTime);

	deltaTime *= _timeScale;
	spAnimationState_update(_state, deltaTime);
	spAnimationState_apply(_state, _skeleton);
    spSkeleton_updateWorldTransform(_skeleton, deltaTime);

    for (auto binded_vrp : _spine_binders)
    {
        SkeletonAnimation* skeletonAnimation = binded_vrp.second;
        skeletonAnimation->update(deltaTime);
    }
}

void SkeletonAnimation::setAnimationStateData (spAnimationStateData* stateData) {
	CCASSERT(stateData, "stateData cannot be null.");

	if (_ownsAnimationStateData) spAnimationStateData_dispose(_state->data);
	spAnimationState_dispose(_state);

	_ownsAnimationStateData = false;
	_state = spAnimationState_create(stateData);
	_state->rendererObject = this;
	_state->listener = animationCallback;
}

void SkeletonAnimation::setMix (const std::string& fromAnimation, const std::string& toAnimation, float duration) {
	spAnimationStateData_setMixByName(_state->data, fromAnimation.c_str(), toAnimation.c_str(), duration);
}

spTrackEntry* SkeletonAnimation::setAnimation (int trackIndex, const std::string& name, bool loop) {
	spAnimation* animation = spSkeletonData_findAnimation(_skeleton->data, name.c_str());
	if (!animation) {
		//log("Spine: Animation not found: %s", name.c_str());
		return 0;
	}
	return spAnimationState_setAnimation(_state, trackIndex, animation, loop);
}

spTrackEntry* SkeletonAnimation::addAnimation (int trackIndex, const std::string& name, bool loop, float delay) {
	spAnimation* animation = spSkeletonData_findAnimation(_skeleton->data, name.c_str());
	if (!animation) {
		//log("Spine: Animation not found: %s", name.c_str());
		return 0;
	}
	return spAnimationState_addAnimation(_state, trackIndex, animation, loop, delay);
}

std::string SkeletonAnimation::getAnimationListLuaTable() {
	int count;

	spAnimation** animations = spSkeletonData_getAnimations(_skeleton->data, count);

	std::stringstream s;

	s << "{" << std::endl;
	std::string name;

	for (int i = 0; i < count; ++i)
	{
		s << "[" << i + 1 << "] = { name = '" << animations[i]->name << "'; };" << std::endl;
	}
	s << "}" << std::endl;

	return s.str();
}

std::string SkeletonAnimation::getEventListLuaTable(std::string& animationName, std::string eventName) {
    spAnimation* animation = spSkeletonData_findAnimation(_skeleton->data, animationName.c_str());
    if (!animation) return "{}";

    std::stringstream s;
    s << "{" << std::endl;

    int i;
    int idx = 0;
    for (i = 0; i < animation->timelinesCount; ++i) {
        spTimeline* timeline = animation->timelines[i];

        if (timeline->type == SP_TIMELINE_EVENT) {
            spEventTimeline* eventTimeline = (spEventTimeline*)timeline;

            int ii;
            for (ii = 0; ii < eventTimeline->framesCount; ++ii) {
                spEvent* event = eventTimeline->events[ii];
                event = eventTimeline->events[ii];

                if ((eventName.compare("") == 0) || (eventName.compare(event->data->name)==0)) {
                    // name, frames, intVal, floatVal, StrVal
                    // ex) [1] = {'attack', 0.6, 0, 0, '160,32'}
                    ++idx;
					s << "[" << idx << "] = {";
					s << "name='" << event->data->name << "'";
					s << ", frames=" << *(eventTimeline->frames);
					s << ", intValue=" << event->intValue;
					s << ", floatValue=" << event->floatValue;
					if (event->stringValue == NULL)
						s << ", stringValue='""'";
					else
						s << ", stringValue='" << event->stringValue << "'";
					s << "};";
					s << std::endl;
                }
            }
        }
    }

    s << "}" << std::endl;

    return s.str();
}

spTrackEntry* SkeletonAnimation::getCurrent (int trackIndex) {
	return spAnimationState_getCurrent(_state, trackIndex);
}

void SkeletonAnimation::clearTracks () {
	spAnimationState_clearTracks(_state);
}

void SkeletonAnimation::clearTrack (int trackIndex) {
	spAnimationState_clearTrack(_state, trackIndex);
}

void SkeletonAnimation::onAnimationStateEvent (int trackIndex, spEventType type, spEvent* event, int loopCount) {
	switch (type) {
	case SP_ANIMATION_START:
		if (_startListener) _startListener(trackIndex);
		break;
	case SP_ANIMATION_END:
		if (_endListener) _endListener(trackIndex);
		break;
	case SP_ANIMATION_COMPLETE:
		if (_completeListener) _completeListener(trackIndex, loopCount);
		break;
	case SP_ANIMATION_EVENT:
		if (_eventListener) _eventListener(trackIndex, event);
		break;
	}
}

void SkeletonAnimation::onTrackEntryEvent (int trackIndex, spEventType type, spEvent* event, int loopCount) {
	spTrackEntry* entry = spAnimationState_getCurrent(_state, trackIndex);
	if (!entry->rendererObject) return;
	_TrackEntryListeners* listeners = (_TrackEntryListeners*)entry->rendererObject;
	switch (type) {
	case SP_ANIMATION_START:
		if (listeners->startListener) listeners->startListener(trackIndex);
		break;
	case SP_ANIMATION_END:
		if (listeners->endListener) listeners->endListener(trackIndex);
		break;
	case SP_ANIMATION_COMPLETE:
		if (listeners->completeListener) listeners->completeListener(trackIndex, loopCount);
		break;
	case SP_ANIMATION_EVENT:
		if (listeners->eventListener) listeners->eventListener(trackIndex, event);
		break;
	}
}

void SkeletonAnimation::setStartListener (const StartListener& listener) {
	_startListener = listener;
}

void SkeletonAnimation::setEndListener (const EndListener& listener) {
	_endListener = listener;
}

void SkeletonAnimation::setCompleteListener (const CompleteListener& listener) {
	_completeListener = listener;
}

void SkeletonAnimation::setEventListener (const EventListener& listener) {
	_eventListener = listener;
}

void SkeletonAnimation::setTrackStartListener (spTrackEntry* entry, const StartListener& listener) {
	getListeners(entry)->startListener = listener;
}

void SkeletonAnimation::setTrackEndListener (spTrackEntry* entry, const EndListener& listener) {
	getListeners(entry)->endListener = listener;
}

void SkeletonAnimation::setTrackCompleteListener (spTrackEntry* entry, const CompleteListener& listener) {
	getListeners(entry)->completeListener = listener;
}

void SkeletonAnimation::setTrackEventListener (spTrackEntry* entry, const EventListener& listener) {
	getListeners(entry)->eventListener = listener;
}

float SkeletonAnimation::getDuration()
{
    spTrackEntry* trackEntry = getCurrent();
    if (trackEntry == NULL)
        return 0;

    if (trackEntry->animation == NULL)
        return 0;

    return trackEntry->animation->duration;
}

spAnimationState* SkeletonAnimation::getState() const {
	return _state;
}

void SkeletonAnimation::setBoneRotation(const std::string& boneName, float rotation, float time)
{
    spBone* pBone = spSkeleton_findBone(_skeleton, boneName.c_str());

    if (pBone == NULL)
        return;
    
    if (time == 0)
    {
        pBone->addRotationTime = 0;
        pBone->rotationPerSec = 0;
        pBone->addRotation = rotation;
    }
    else
    {
        float gap = rotation - pBone->addRotation;
        pBone->addRotationTime = time;
        pBone->rotationPerSec = gap / time;
    }
}

bool SkeletonAnimation::bindSpine(const std::string& boneName, SkeletonAnimation* skeletonAnimation)
{
    spBone* pBone = spSkeleton_findBone(_skeleton, boneName.c_str());

    if (pBone == NULL)
    {
        CCLOG("\"%s\" not exist", boneName.c_str());
        return false;
    }

    std::string slotName = findSlotNameByBoneNmae(boneName);

    TYPE_SPINE_BINDER_LIST_ITERATOR iterator = _spine_binders.find(boneName);
    if (iterator != _spine_binders.end())
    {
        SkeletonAnimation* beforeSkeletonAnimation = iterator->second;
        beforeSkeletonAnimation->release();
        _spine_binders.erase(boneName);
        eraseSlotBoneList(slotName, boneName);
    }

    if (skeletonAnimation == NULL)
    {
        return true;
    }

    skeletonAnimation->retain();
    //_spine_binders.insert(TYPE_SPINE_BINDER_LIST::value_type(boneName, skeletonAnimation));
    _spine_binders[boneName] = skeletonAnimation; // [] operator�??�용?�서 간단?�게 추�????�도 ?�음
    insertSlotBoneList(slotName, boneName);

    return true;
}

std::string SkeletonAnimation::findSlotNameByBoneNmae(const std::string& boneName)
{
    for (int i = 0; i < _skeleton->slotsCount; ++i)
    {
        spSlot* slot = _skeleton->slots[i];
        if (slot->attachment && slot->attachment->type == SP_ATTACHMENT_SKINNED_MESH)
        {
            spSkinnedMeshAttachment* attachment = (spSkinnedMeshAttachment*)slot->attachment;
            spBone** skeletonBones = slot->bone->skeleton->bones;
            for (int j = 0; j < attachment->bonesCount; j++)
            {
                int idx = attachment->bones[j];
                const spBone* bone = skeletonBones[idx];

                if (strcmp(bone->data->name, boneName.c_str()) == 0)
                {
                    return slot->data->name;
                }
            }
        }
    }

    return "";
}

void SkeletonAnimation::insertSlotBoneList(const std::string& slotName, const std::string& boneNmae)
{
    TYPE_SPINE_SLOT_BONE_LIST::iterator iter = _slot_bone_list.find(slotName);
    if (iter == _slot_bone_list.end())
    {
        _slot_bone_list[slotName] = TYPE_BONE_NAME_LIST();
    }

    _slot_bone_list[slotName].push_back(boneNmae);
}

void SkeletonAnimation::eraseSlotBoneList(const std::string& slotName, const std::string& boneNmae)
{
    TYPE_SPINE_SLOT_BONE_LIST::iterator iter = _slot_bone_list.find(slotName);
    if (iter == _slot_bone_list.end())
    {
        return;
    }

    for (auto iter = _slot_bone_list[slotName].begin(); iter != _slot_bone_list[slotName].end(); ++iter)
    {
        if (strcmp((*iter).c_str(), boneNmae.c_str()) == 0)
        {
            _slot_bone_list[slotName].erase(iter);
            break;
        }
    }
}

void SkeletonAnimation::clearBinder()
{
    for (auto iter = _spine_binders.begin(); iter != _spine_binders.end(); ++iter)
    {
        iter->second->release();
    }
    _spine_binders.clear();
    _slot_bone_list.clear();
}

void SkeletonAnimation::drawBinder(spSlot* slot)
{
    std::string slotName = slot->data->name;

    TYPE_SPINE_SLOT_BONE_LIST::iterator iter = _slot_bone_list.find(slotName);
    if (iter == _slot_bone_list.end())
        return;

    bool firstBinder = true;

    for (auto boneName : _slot_bone_list[slotName])
    {
        if (firstBinder == true)
        {
            _batch->flush();
            firstBinder = false;
        }

        spBone*bone = findBone(boneName);
        SkeletonAnimation* skeletonAnimation = _spine_binders[boneName];
        skeletonAnimation->setPosition(bone->worldX, bone->worldY);
        skeletonAnimation->setRotation(-bone->worldRotation);
        float scaleX = bone->worldScaleX;
        float scaleY = bone->worldScaleY;
        if (bone->worldFlipX == true) scaleX *= (-1);
        if (bone->worldFlipY == true) scaleY *= (-1);
        skeletonAnimation->setScale(scaleX, scaleY);

        skeletonAnimation->setUpdateTransform();
        skeletonAnimation->_modelViewTransform = skeletonAnimation->transform(this->_modelViewTransform);
        skeletonAnimation->drawSkeleton(skeletonAnimation->_modelViewTransform, true);
    }

    // reset blendMode
    if (firstBinder == false)
    {
        switch (slot->data->blendMode) {
        case SP_BLEND_MODE_ADDITIVE:
            GL::blendFunc(_premultipliedAlpha ? GL_ONE : GL_SRC_ALPHA, GL_ONE);
            break;
        case SP_BLEND_MODE_MULTIPLY:
            GL::blendFunc(GL_DST_COLOR, GL_ONE_MINUS_SRC_ALPHA);
            break;
        case SP_BLEND_MODE_SCREEN:
            GL::blendFunc(GL_ONE, GL_ONE_MINUS_SRC_COLOR);
            break;
        default:
            GL::blendFunc(_blendFunc.src, _blendFunc.dst);
        }
        getGLProgramState()->apply(this->_modelViewTransform);
    }
}

void SkeletonAnimation::removeCache(const std::string& filename)
{
    auto cache_iter = s_skeleton_data_cache.find(filename);
    if (cache_iter == s_skeleton_data_cache.end()) return;

    spSkeletonData_dispose(cache_iter->second);
    s_skeleton_data_cache.erase(cache_iter);
}

void SkeletonAnimation::removeCacheAll()
{
    for (auto cache_iter = s_skeleton_data_cache.begin(); cache_iter != s_skeleton_data_cache.end();)
    {
        spSkeletonData_dispose(cache_iter->second);
        ++cache_iter;
    }


    s_skeleton_data_cache.clear();
}

}
