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

#ifndef SPINE_SKELETONANIMATION_H_
#define SPINE_SKELETONANIMATION_H_

#include <spine/spine.h>
#include <spine/SkeletonRenderer.h>
#include "cocos2d.h"

namespace spine {

class SkeletonAnimation;
typedef std::function<void(int trackIndex)> StartListener;
typedef std::function<void(int trackIndex)> EndListener;
typedef std::function<void(int trackIndex, int loopCount)> CompleteListener;
typedef std::function<void(int trackIndex, spEvent* event)> EventListener;
typedef std::unordered_map<std::string, SkeletonAnimation*> TYPE_SPINE_BINDER_LIST;
typedef TYPE_SPINE_BINDER_LIST::iterator TYPE_SPINE_BINDER_LIST_ITERATOR;
typedef std::vector<std::string> TYPE_BONE_NAME_LIST;
typedef std::unordered_map<std::string, TYPE_BONE_NAME_LIST> TYPE_SPINE_SLOT_BONE_LIST;


/** Draws an animated skeleton, providing an AnimationState for applying one or more animations and queuing animations to be
  * played later. */
class SkeletonAnimation: public SkeletonRenderer {

public:
    typedef std::map < std::string, spSkeletonData* > TYPE_SKELETON_DATA_CACHE;
    static TYPE_SKELETON_DATA_CACHE s_skeleton_data_cache;

    static void removeCache(const std::string& filename);
    static void removeCacheAll();

public:
	static SkeletonAnimation* createWithData (spSkeletonData* skeletonData, bool ownsSkeletonData = false);
	static SkeletonAnimation* createWithFile (const std::string& skeletonDataFile, spAtlas* atlas, float scale = 1);
	static SkeletonAnimation* createWithFile (const std::string& skeletonDataFile, const std::string& atlasFile, float scale = 1);

	virtual void update (float deltaTime);

	void setAnimationStateData (spAnimationStateData* stateData);
	void setMix (const std::string& fromAnimation, const std::string& toAnimation, float duration);

	spTrackEntry* setAnimation (int trackIndex, const std::string& name, bool loop);
	spTrackEntry* addAnimation (int trackIndex, const std::string& name, bool loop, float delay = 0);

	std::string getAnimationListLuaTable();
    std::string getEventListLuaTable(std::string& animationName, std::string eventName = "");

	spTrackEntry* getCurrent (int trackIndex = 0);
	void clearTracks ();
	void clearTrack (int trackIndex = 0);

	void setStartListener (const StartListener& listener);
	void setEndListener (const EndListener& listener);
	void setCompleteListener (const CompleteListener& listener);
	void setEventListener (const EventListener& listener);

	void setTrackStartListener (spTrackEntry* entry, const StartListener& listener);
	void setTrackEndListener (spTrackEntry* entry, const EndListener& listener);
	void setTrackCompleteListener (spTrackEntry* entry, const CompleteListener& listener);
	void setTrackEventListener (spTrackEntry* entry, const EventListener& listener);

    float getDuration();

	virtual void onAnimationStateEvent (int trackIndex, spEventType type, spEvent* event, int loopCount);
	virtual void onTrackEntryEvent (int trackIndex, spEventType type, spEvent* event, int loopCount);

	spAnimationState* getState() const;

    // 2016.09.09 Seong-goo Kim
    void setBoneRotation(const std::string& boneName, float rotation, float time = 0);

    // 2016.09.13 Seong-goo Kim
    bool bindSpine(const std::string& boneName, SkeletonAnimation* skeletonAnimation);
    std::string findSlotNameByBoneNmae(const std::string& boneName);
    void insertSlotBoneList(const std::string& slotName, const std::string& boneNmae);
    void eraseSlotBoneList(const std::string& slotName, const std::string& boneNmae);
    void clearBinder();
    virtual void drawBinder(spSlot* slot);

CC_CONSTRUCTOR_ACCESS:
	SkeletonAnimation ();
	SkeletonAnimation (spSkeletonData* skeletonData, bool ownsSkeletonData = false);
	SkeletonAnimation (const std::string&skeletonDataFile, spAtlas* atlas, float scale = 1);
	SkeletonAnimation (const std::string& skeletonDataFile, const std::string& atlasFile, float scale = 1);
	virtual ~SkeletonAnimation ();
	void initialize ();

protected:
	spAnimationState* _state;

	bool _ownsAnimationStateData;

	StartListener _startListener;
	EndListener _endListener;
	CompleteListener _completeListener;
	EventListener _eventListener;
    TYPE_SPINE_BINDER_LIST _spine_binders;
    TYPE_SPINE_SLOT_BONE_LIST _slot_bone_list;

private:
	typedef SkeletonRenderer super;
};

}

#endif /* SPINE_SKELETONANIMATION_H_ */
