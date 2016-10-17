#include "CCPerpSpriter.h"

int PerpSpriter::s_fps = 30;
int PerpSpriter::s_totalSpriterCount = 0;
bool PerpSpriter::s_cacheEnabled = true;
PerpSpriter::TYPE_CACHED_FILES PerpSpriter::s_cachedFiles;

//#define DEBUG_SCML

typedef struct
{
	typedef struct
	{
		int id;
		int name_offset;
		float width;
		float height;
		float pivot_x;
		float pivot_y;
	} FILE;
	typedef struct
	{
		int count;
		int file_offset[2];
	} FILE_LIST;
	typedef struct
	{
		int id;
		int file_list_offset;
	} FOLDER;
	typedef struct
	{
		int count;
		int folder_offset[2];
	} FOLDER_LIST;
	typedef struct 
	{
		int folder;
		int file;
		float x;
		float y;
		float angle;
		float pivot_x;
		float pivot_y;
		float scale_x;
		float scale_y;
		int z_index;
		float alpha;
	} OBJECT;
	typedef struct 
	{
		int count;
		int object_offset[2];
	} OBJECT_LIST;
	typedef struct 
	{
		int id;
		int timeline;
		int key;
		int z_index;
	} OBJECTREF;
	typedef struct 
	{
		int count;
		int objectref_offset[2];
	} OBJECTREF_LIST;
	typedef struct  
	{
		int id;
		float time;
		int spin;
		int objectref_list_offset;
		int object_list_offset;
	} KEY;
	typedef struct  
	{
		int count;
		int key_offset[2];
	} KEY_LIST;
	typedef struct  
	{
		int id;
		int key_list_offset;
	} TIMELINE;
	typedef struct  
	{
		int count;
		int timeline_offset[2];
	} TIMELINE_LIST;
	typedef struct  
	{
		int id;
		int name_offset;
		float length;
		int mainline_offset;
		int timeline_list_offset;
	} ANIMATION;
	typedef struct 
	{
		int count;
		int animation_offset[2];
	} ANIMATION_LIST;
	typedef struct
	{
		int id;
		int name_offset;
		int animation_list_offset;
	} ENTITY;
	typedef struct
	{
		int count;
		int entity_offset[2];
	} ENTITY_LIST;

	static const char* getFileName(char *ptr, FILE *file) {
		if (!file) return 0;
		return (const char*)(ptr + file->name_offset);
	}
	static FILE *getFile(char *ptr, FOLDER *folder, int i) {
		if (!folder) return 0;
		FILE_LIST *file_list = (FILE_LIST*)(ptr + folder->file_list_offset);
		return (FILE*)(ptr + file_list->file_offset[i]);
	}
	static int getFileCount(char *ptr, FOLDER *folder) {
		if (!folder) return 0;
		FILE_LIST *file_list = (FILE_LIST*)(ptr + folder->file_list_offset);
		return file_list->count;
	}
	static int getFolderCount(char *ptr) {
		FOLDER_LIST *folder_list = (FOLDER_LIST*)(ptr + getHeader(ptr)->folder_list_offset);
		return folder_list->count;
	}
	static FOLDER *getFolder(char *ptr, int i) {
		FOLDER_LIST *folder_list = (FOLDER_LIST*)(ptr + getHeader(ptr)->folder_list_offset);
		return (FOLDER*)(ptr + folder_list->folder_offset[i]);
	}
	static OBJECT *getObject(char *ptr, KEY *key, int i) {
		if (!key) return 0;
		OBJECT_LIST *object_list = (OBJECT_LIST*)(ptr + key->object_list_offset);
		if (i < 0 ||  i >= object_list->count) return 0;
		return (OBJECT*)(ptr + object_list->object_offset[i]);
	}
	static int getObjectCount(char *ptr, KEY *key) {
		if (!key) return 0;
		OBJECT_LIST *object_list = (OBJECT_LIST*)(ptr + key->object_list_offset);
		return object_list->count;
	}
	static OBJECTREF *getObjectRef(char *ptr, KEY *key, int i) {
		if (!key) return 0;
		OBJECTREF_LIST *objectref_list = (OBJECTREF_LIST*)(ptr + key->objectref_list_offset);
		if (i < 0 ||  i >= objectref_list->count) return 0;
		return (OBJECTREF*)(ptr + objectref_list->objectref_offset[i]);
	}
	static OBJECTREF *getObjectRefByTimeline(char *ptr, KEY *key, int timeline) {
		if (!key) return 0;
		OBJECTREF_LIST *objectref_list = (OBJECTREF_LIST*)(ptr + key->objectref_list_offset);
		for (int i = 0; i < objectref_list->count; i ++) {
			OBJECTREF *ref = (OBJECTREF*)(ptr + objectref_list->objectref_offset[i]);
			if (ref->timeline == timeline) return ref;
		}
		return 0;
	}
	static int getObjectRefCount(char *ptr, KEY *key) {
		if (!key) return 0;
		OBJECTREF_LIST *objectref_list = (OBJECTREF_LIST*)(ptr + key->objectref_list_offset);
		return objectref_list->count;
	}
	static KEY *getKey(char *ptr, TIMELINE *timeline, int i) {
		if (!timeline) return 0;
		KEY_LIST *key_list = (KEY_LIST*)(ptr + timeline->key_list_offset);
		if (i < 0 || i >= key_list->count) return 0;
		KEY *key = (KEY*)(ptr + key_list->key_offset[i]);
		return key;
	}
	static int getKeyCount(char *ptr, TIMELINE *timeline) {
		if (!timeline) return 0;
		KEY_LIST *key_list = (KEY_LIST*)(ptr + timeline->key_list_offset);
		return key_list->count;
	}
	static TIMELINE *getTimeline(char *ptr, ANIMATION *animation, int i) {
		if (!animation) return 0;
		TIMELINE_LIST *timeline_list = (TIMELINE_LIST*)(ptr + animation->timeline_list_offset);
		if (i < 0 || i >= timeline_list->count) return 0;
		return (TIMELINE*)(ptr + timeline_list->timeline_offset[i]);
	}
	static int getTimelineCount(char *ptr, ANIMATION *animation) {
		if (!animation) return 0;
		TIMELINE_LIST *timeline_list = (TIMELINE_LIST*)(ptr + animation->timeline_list_offset);
		return timeline_list->count;
	}
	static TIMELINE *getMainline(char *ptr, ANIMATION *animation) {
		if (!animation) return 0;
		return (TIMELINE*)(ptr + animation->mainline_offset);
	}
	static const char* getAnimationName(char *ptr, ANIMATION *animation) {
		if (!animation) return 0;
		return (const char*)(ptr + animation->name_offset);
	}
	static ANIMATION *getAnimationByIndex(char *ptr, ENTITY *entity, int i) {
		if (!entity) return 0;
		ANIMATION_LIST *animation_list = (ANIMATION_LIST*)(ptr + entity->animation_list_offset);
		if (i < 0 || i >= animation_list->count) return 0;
		return (ANIMATION*)(ptr + animation_list->animation_offset[i]);
	}
	static int getAnimationIndexByName(char *ptr, ENTITY *entity, const char *name) {
		if (!entity) return -1;

		ANIMATION_LIST *animation_list = (ANIMATION_LIST*)(ptr + entity->animation_list_offset);
		ANIMATION *animation = 0;
		for (int i = 0; i < animation_list->count; i ++) {
			animation = getAnimationByIndex(ptr, entity, i);
			if (strcmp(getAnimationName(ptr, animation), name) == 0) return i;
		}
		return -1;
	}
	static ANIMATION *getAnimationByName(char *ptr, ENTITY *entity, const char *name) {
		int i = getAnimationIndexByName(ptr, entity, name);
		if (i < 0) return 0;
		return getAnimationByIndex(ptr, entity, i);
	}
	static const char* getEntityName(char *ptr, ENTITY *entity) {
		if (!entity) return 0;
		return (const char*)(ptr + entity->name_offset);
	}
	static ENTITY *getEntity(char *ptr, int i) {
		ENTITY_LIST *entity_list = (ENTITY_LIST*)(ptr + getHeader(ptr)->entity_list_offset);
		if (i < 0 || i >= entity_list->count) return 0;
		return (ENTITY*)(ptr + entity_list->entity_offset[i]);
	}

	typedef struct
	{
		int folder_list_offset;
		int entity_list_offset;
	} HEADER;

	static HEADER *getHeader(char *ptr) { return (HEADER*)ptr; }

} res_getter;

#define GET_SPRITE_KEY(folderId,fileId) ((folderId<<16)|(fileId<<8))

PerpSpriter::PerpSpriter()
: m_curAnimId(0)
, m_curKeyFrame(0)
, m_elapsedTime(0)
, m_isDone(false)
, m_isLooping(false)
, m_useBatchNode(false)
, m_batchNode(0)
, m_scb(0)
, m_animSpeed(1.0)
, m_loopScriptHandler(0)
, m_triggerScriptHandler(0)
, m_globalAlpha(1.0f)
, m_spritesPool(0)
, m_spriteSubstitutions(0)
{
	m_spritesPool = new TYPE_SPRITE_POOL();
	m_spriteSubstitutions = new TYPE_SPRITE_SUBSTITUTIONS();
	s_totalSpriterCount ++;
	//CCLOG("total spriter count : %d", s_totalSpriterCount);
}

PerpSpriter::~PerpSpriter()
{
	s_totalSpriterCount --;
	if (m_scb) m_scb->release();
	//if (m_batchNode) m_batchNode->release();
	
	if (m_spriteSubstitutions)
	{
		m_spriteSubstitutions->clear();
		delete m_spriteSubstitutions;
	}

	if (m_spritesPool)
	{
		for (auto iter : *m_spritesPool)
		{
			auto sprite = iter.second;
			if (!sprite) continue;

			//sprite->release();
		}
		m_spritesPool->clear();
		delete m_spritesPool;
	}
}

void PerpSpriter::setFPS(int fps)
{
	s_fps = fps;
}

PerpSpriter *PerpSpriter::create(const char *filename)
{
	PerpSpriter *pSpriter = new PerpSpriter();

	if (pSpriter->initWithFile(filename)) {
		//pSpriter->scheduleUpdate();
		pSpriter->autorelease();
		return pSpriter;
	}
	CC_SAFE_RELEASE(pSpriter);
	return 0;
}

PerpSpriter *PerpSpriter::create(const char *filename, const char *imageFile)
{
	PerpSpriter *pSpriter = new PerpSpriter();

	if (pSpriter->initWithFile(filename)) {
		pSpriter->m_useBatchNode = true;
		pSpriter->m_batchNode = SpriteBatchNode::create(imageFile);
		pSpriter->addChild(pSpriter->m_batchNode);
		//pSpriter->scheduleUpdate();
		pSpriter->autorelease();
		return pSpriter;
	}
	CC_SAFE_RELEASE(pSpriter);
	return 0;
}

void PerpSpriter::onEnter() {
	Node::onEnter();
	scheduleUpdate();
}

void PerpSpriter::onExit() {
	Node::onExit();
	unscheduleUpdate();
}

bool PerpSpriter::initWithFile(const char *filename)
{
	PerpSCB *scb = nullptr;
	auto iter_scb = s_cachedFiles.find(filename);
	if (iter_scb != s_cachedFiles.end())
	{
		scb = iter_scb->second;
	}

	char *ptr = nullptr;
	ssize_t size;

	if (scb == nullptr) {
		ptr = (char*)CCFileUtils::getInstance()->getFileData(filename, "rb", &size);
		if (ptr == 0) return 0;
		scb = new PerpSCB(ptr);
		scb->autorelease();
		if (s_cacheEnabled) {
			s_cachedFiles.insert(filename, scb);
		}
	}
	else {
		ptr = scb->ptr();
	}
	scb->retain();

#ifdef DEBUG_SCML
	//for debugging
	res_getter::HEADER *header = res_getter::getHeader(ptr);
	res_getter::FOLDER *folder = res_getter::getFolder(ptr, 0);

	int fileCount = res_getter::getFileCount(ptr, folder);
	for (int i = 0; i < fileCount; i ++) {
		res_getter::FILE *f = res_getter::getFile(ptr, folder, i);
		CCLOG("%d,%s,%f,%f", f->id, res_getter::getFileName(ptr, f), f->width, f->height);
	}
	res_getter::ENTITY *entity = res_getter::getEntity(ptr, 0);
	res_getter::ANIMATION *animation = 0;
	int k = 0;

	while((animation = res_getter::getAnimationByIndex(ptr, entity, k ++)))
	{
		CCLOG("animation(%s):length:%.2f", res_getter::getAnimationName(ptr, animation), animation->length);

		//get mainline
		res_getter::TIMELINE *mainline = res_getter::getMainline(ptr, animation);
		//get key
		for (int i = 0; i < res_getter::getKeyCount(ptr, mainline); i ++) {
			//get object ref
			res_getter::KEY *key = res_getter::getKey(ptr, mainline, i);
			CCLOG("KEY(%d):time(%.2f),spin(%d)", key->id, key->time, key->spin);
			for (int j = 0; j < res_getter::getObjectRefCount(ptr, key); j ++) {
				res_getter::OBJECTREF *obj = res_getter::getObjectRef(ptr, key, j);
				CCLOG("OBJECT_REF(%d):timeline(%d),key(%d),z_index(%d)", obj->id, obj->timeline, obj->key, obj->z_index);
			}
		}
		//get timeline
		for (int t = 0; t < res_getter::getTimelineCount(ptr, animation); t ++) {
			res_getter::TIMELINE *timeline = res_getter::getTimeline(ptr, animation, t);
			CCLOG("timeline(%d)", timeline->id);

			//get key
			for (int i = 0; i < res_getter::getKeyCount(ptr, timeline); i ++) {
				//get object ref
				res_getter::KEY *key = res_getter::getKey(ptr, timeline, i);
				CCLOG("KEY(%d):time(%.2f),spin(%d)", key->id, key->time, key->spin);
				for (int j = 0; j < res_getter::getObjectCount(ptr, key); j ++) {
					res_getter::OBJECT *obj = res_getter::getObject(ptr, key, j);
					CCLOG("OBJECT:folder(%d),file(%d),pos(%.2f,%.2f),angle(%.2f),pivot(%.2f,%.2f),scale(%.2f,%.2f),z_index(%d)"
						, obj->folder, obj->file, obj->x, obj->y
						, obj->angle, obj->pivot_x, obj->pivot_y, obj->scale_x, obj->scale_y, obj->z_index);
				}
			}
		}
	}
#endif
	this->m_scb = scb;

	return true;
}

void PerpSpriter::draw(Renderer *renderer, const Mat4 &transform, bool transformUpdated)
{
	char *ptr = m_scb->ptr();
	res_getter::ENTITY *entity = res_getter::getEntity(ptr, 0);
	res_getter::ANIMATION *animation = res_getter::getAnimationByIndex(ptr, entity, m_curAnimId);
	res_getter::TIMELINE *mainline = res_getter::getMainline(ptr, animation);
	res_getter::KEY *keyframe = res_getter::getKey(ptr, mainline, m_curKeyFrame);

	int count = res_getter::getObjectRefCount(ptr, keyframe);

	if (m_batchNode) {
		for (auto child : m_batchNode->getChildren())
		{
			CCSprite* sprite = dynamic_cast<CCSprite*>(child);
			if (sprite)
			{
				sprite->setVisible(false);
			}
		}
	}

	for (int i=0; i < count; i ++)
	{
		res_getter::OBJECTREF *ref = res_getter::getObjectRef(ptr, keyframe, i);
		if (ref)
		{
			res_getter::TIMELINE *timeline = res_getter::getTimeline(ptr, animation, ref->timeline);
			res_getter::KEY *keyRef = res_getter::getKey(ptr, timeline, ref->key);
			res_getter::OBJECT *obj = res_getter::getObject(ptr, keyRef, 0); // should be only 1 object

			if (timeline == 0 || keyRef == 0 || obj == 0) {
				continue;
			}

			int key = GET_SPRITE_KEY(obj->folder, obj->file);
			auto sprite_iter = m_spritesPool->find(key);
			if (sprite_iter == m_spritesPool->end()) continue;

			CCSprite *spr = sprite_iter->second;
			if (m_useBatchNode == false) {
				if (spr) {
					spr->visit();
				}
			}
			else {
				if (spr) {
					spr->setVisible(true);
					m_batchNode->reorderChild(spr, i);
					CCPoint anp = spr->getAnchorPoint();
#ifdef DEBUG_SCML
					CCLOG("update:key=%d,x=%.2f,y=%.2f,px=%.2f,py=%.2f,angle=%.2f,sx=%.2f,sy=%.2f",
						key, spr->getPositionX(), spr->getPositionY(), anp.x, anp.y, -spr->getRotation(), spr->getScaleX(), spr->getScaleY());
#endif
				}
			}
		}
	}
}

void PerpSpriter::update(float dt)
{
	char *ptr = m_scb->ptr();
	float cur_length = this->getOriginalAnimationLength();

	if (dt > (1.0f / s_fps)) dt = (1.0f / s_fps);
	dt = dt * m_animSpeed;

	if (m_isDone) {
		if (m_isLooping == false) return;
		else m_isDone = false;
	}

	m_elapsedTime += dt * 1.0f;
	if (m_triggerScriptHandler && m_elapsedTime >= m_triggerElapsedTime) {
		if (ScriptEngineManager::getInstance()->getScriptEngine()) {
			int tmpHandler = m_triggerScriptHandler;
			if (m_triggerScriptHandler != 0) {
				CommonScriptData data(m_triggerScriptHandler, "trigger", this);
				ScriptEvent event(kCommonEvent, (void*)&data);
				m_triggerScriptHandler = 0; //두번 연속 호출되지 않도록 처리
				ScriptEngineManager::getInstance()->getScriptEngine()->sendEvent(&event);
				m_triggerScriptHandler = tmpHandler;
			}
		}
		unregisterTriggerHandler();
	}
	if (m_elapsedTime >= cur_length) {
		m_isDone = true;
		if (m_isLooping) {
			restart();

			if (m_loopScriptHandler) {
				if (ScriptEngineManager::getInstance()->getScriptEngine()) {
					int tmpHandler = m_loopScriptHandler;
					if (m_loopScriptHandler != 0) {
						CommonScriptData data(m_loopScriptHandler, "end", this);
						ScriptEvent event(kCommonEvent, (void*)&data);
						m_loopScriptHandler = 0; //두번 연속 호출되지 않도록 처리
						ScriptEngineManager::getInstance()->getScriptEngine()->sendEvent(&event);
						m_loopScriptHandler = tmpHandler;
					}
				}
			}
		}
		else {
			m_elapsedTime = cur_length;
			if (m_loopScriptHandler) {
				if (ScriptEngineManager::getInstance()->getScriptEngine()) {
					int tmpHandler = m_loopScriptHandler;
					if (m_loopScriptHandler != 0) {
						CommonScriptData data(m_loopScriptHandler, "end", this);
						ScriptEvent event(kCommonEvent, (void*)&data);
						m_loopScriptHandler = 0; //두번 연속 호출되지 않도록 처리
						ScriptEngineManager::getInstance()->getScriptEngine()->sendEvent(&event);
						m_loopScriptHandler = tmpHandler;
					}
				}
				unregisterLoopHandler();
			}
		}
	}

	res_getter::ENTITY *entity = res_getter::getEntity(ptr, 0);
	res_getter::ANIMATION *animation = res_getter::getAnimationByIndex(ptr, entity, m_curAnimId);
	res_getter::TIMELINE *mainline = res_getter::getMainline(ptr, animation);

	if (entity == 0 || animation == 0 || mainline == 0) return;

	int keycount = res_getter::getKeyCount(ptr, mainline);
	res_getter::KEY *keyframe = res_getter::getKey(ptr, mainline, m_curKeyFrame);
	if (keyframe == 0) return;
	
	res_getter::KEY *keyframeNext = NULL;
	int next = m_curKeyFrame+1;
	if (next > keycount-1) {
		if (m_isLooping) next = 0; //always looping for now
		else next = m_curKeyFrame;
	}
	keyframeNext = res_getter::getKey(ptr, mainline, next);
	if (keyframeNext)
	{
		float nextTime = keyframeNext->time * 0.001f;
		if (next == 0) nextTime = cur_length;

		if (m_elapsedTime >= nextTime)
		{
			m_curKeyFrame = next;

			keyframe = keyframeNext;
			next = m_curKeyFrame + 1;
			if (next > keycount - 1) {
				if (m_isLooping) next = 0;
				else next = m_curKeyFrame;
			}

			keyframeNext = res_getter::getKey(ptr, mainline, next);
			if (keyframeNext == 0) return;
		}
	}

	int count = res_getter::getObjectRefCount(ptr, keyframe);
	for (int i = 0; i < count; i ++)
	{
		float _t = 0.0f;

		res_getter::OBJECTREF *ref = res_getter::getObjectRef(ptr, keyframe, i);
		if (ref)
		{
			res_getter::TIMELINE *timeline = res_getter::getTimeline(ptr, animation, ref->timeline);
			res_getter::KEY *keyRef = res_getter::getKey(ptr, timeline, ref->key);
			if (timeline == 0 || keyRef == 0) continue;

			
			res_getter::KEY *keyRefNext = 0;
			int keyCurr = ref->key;
			while(1) {
				keyRefNext = res_getter::getKey(ptr, timeline, keyCurr + 1);
				if (keyRefNext) { 
					if(keyRefNext->time - keyRef->time < FLT_EPSILON) {
						keyRef = keyRefNext;
						keyCurr ++;
						continue;
					}
				}
				break;
			}

			res_getter::OBJECT *obj = res_getter::getObject(ptr, keyRef, 0); // should be only 1 object
			res_getter::OBJECT *objNext = res_getter::getObject(ptr, keyRefNext, 0); // should be only 1 object

			if (objNext == 0 || keyRefNext == 0) {
				objNext = obj;
				_t = 0;
			}
			else {
				float _t1 = keyRef->time * 0.001f;
				float _t2 = keyRefNext->time * 0.001f;
				if (_t2 - _t1 < FLT_EPSILON) _t = 1.0;
				else _t = (m_elapsedTime - _t1) / (_t2 - _t1);
			}

			if (_t > 1) _t = 1.0f;

			//liner interpolation
			float x = obj->x + (objNext->x -obj->x) * _t;
			float y = obj->y + (objNext->y -obj->y) * _t;
			float angle = objNext->angle - obj->angle;
			if (keyRef->spin != -1)
			{
				if (angle < 0) angle = (objNext->angle + 360) - obj->angle;
			}
			else
			{
				if (angle > 0) angle = (objNext->angle - 360) - obj->angle;
			}

			angle = obj->angle + (angle) * _t;
			if (angle >= 360) angle -= 360;

			//liner interpolation
			float px = obj->pivot_x +(objNext->pivot_x - obj->pivot_x) * _t;
			float py = obj->pivot_y +(objNext->pivot_y - obj->pivot_y) * _t;
			float sx = obj->scale_x +(objNext->scale_x - obj->scale_x) * _t;
			float sy = obj->scale_y +(objNext->scale_y - obj->scale_y) * _t;
			float alpha = obj->alpha +(objNext->alpha - obj->alpha) * _t;
			GLubyte var = (GLubyte)(alpha * 255.0f * m_globalAlpha);

			int sprkey = GET_SPRITE_KEY(obj->folder, obj->file);
			auto sprite_iter = m_spritesPool->find(sprkey);
			if (sprite_iter == m_spritesPool->end()) continue;

			CCSprite *spr = sprite_iter->second;
			if (spr) {
				res_getter::FILE *f = res_getter::getFile(ptr
					, res_getter::getFolder(ptr, obj->folder), obj->file);

				if (f->pivot_x > -2.0f && f->pivot_y > -2.0f) {
					px = f->pivot_x;
					py = f->pivot_y;
				}

				CCPoint newPos = ccp(x, y);
				spr->setPosition(newPos);
				spr->setRotation(-angle);
				spr->setScaleX(sx);
				spr->setScaleY(sy);
				spr->setAnchorPoint(ccp(px, py));
				spr->setOpacity(var);

#ifdef DEBUG_SCML
				CCLOG("update:key=%d,x=%.2f,y=%.2f,px=%.2f,py=%.2f,angle=%.2f,sx=%.2f,sy=%.2f",
					sprkey, x, y, px, py, angle, sx, sy);
#endif
			}
		}
	}
}

void PerpSpriter::restart()
{
	m_curKeyFrame = 0;
	m_elapsedTime = 0;
	m_isDone = false;
}

bool PerpSpriter::play(const char *name)
{
	char *ptr = m_scb->ptr();
	res_getter::ENTITY *entity = res_getter::getEntity(ptr, 0);
	int index = res_getter::getAnimationIndexByName(ptr, entity, name);
	if (index < 0) return false;

	res_getter::ANIMATION *animation = res_getter::getAnimationByIndex(ptr, entity, index);
	if (animation == 0) return false;

	//set sprite position
	m_curAnimId = index;
	m_isLooping = false;
	m_animSpeed = 1.0f;
	m_curAnimationLength = animation->length * 0.001f;

	m_elapsedTime = 0;
	m_curKeyFrame = 0;
	m_isDone = false;

	this->adjustPosition();
	this->unregisterLoopHandler();
	this->unregisterTriggerHandler();

	return true;
}

bool PerpSpriter::playByIndex(int index)
{
	char *ptr = m_scb->ptr();
	res_getter::ENTITY *entity = res_getter::getEntity(ptr, 0);
	res_getter::ANIMATION *animation = res_getter::getAnimationByIndex(ptr, entity, index);
	if (animation == 0) return false;

	//set sprite position
	m_curAnimId = index;
	m_isLooping = false;
	m_animSpeed = 1.0f;
	m_curAnimationLength = animation->length * 0.001f;

	m_elapsedTime = 0;
	m_curKeyFrame = 0;
	m_isDone = false;

	this->adjustPosition();
	this->unregisterLoopHandler();
	this->unregisterTriggerHandler();

	return true;
}

void PerpSpriter::registerLoopHandler(int functionRefID)
{
	unregisterLoopHandler();
	m_loopScriptHandler = functionRefID;
}

void PerpSpriter::unregisterLoopHandler(void)
{
	if (0 != m_loopScriptHandler)
	{
		ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(m_loopScriptHandler);
		m_loopScriptHandler = 0;
	}
}

void PerpSpriter::registerTriggerHandler(float elapsedTime, int functionRefID)
{
	unregisterTriggerHandler();
	m_triggerElapsedTime = elapsedTime;
	m_triggerScriptHandler = functionRefID;
}

void PerpSpriter::unregisterTriggerHandler(void)
{
	if (m_triggerScriptHandler) {
		if (ScriptEngineManager::getInstance()->getScriptEngine()) {
			ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(m_triggerScriptHandler);
		}
		m_triggerScriptHandler = 0;
	}
}

void PerpSpriter::setLooping(bool v) 
{
	m_isLooping = v; 
}

void PerpSpriter::setAlpha(float v)
{
	m_globalAlpha = v;
}

float PerpSpriter::getAlpha()
{
	return m_globalAlpha;
}

float PerpSpriter::getOriginalAnimationLength()
{
	char *ptr = m_scb->ptr();
	res_getter::ENTITY *entity = res_getter::getEntity(ptr, 0);
	res_getter::ANIMATION *animation = res_getter::getAnimationByIndex(ptr, entity, m_curAnimId);
	if (entity == 0 || animation == 0) return 0;

	return animation->length * 0.001f;
}

float PerpSpriter::getCurrentAnimationLength()
{
	return m_curAnimationLength;
}

void PerpSpriter::setAnimationLength(float t)
{
	float cur_length = this->getCurrentAnimationLength();
	m_animSpeed = cur_length / t;
	m_curAnimationLength = t;
}

const char *PerpSpriter::getCurrentAnimationName()
{
	char *ptr = m_scb->ptr();
	res_getter::ENTITY *entity = res_getter::getEntity(ptr, 0);
	res_getter::ANIMATION *animation = res_getter::getAnimationByIndex(ptr, entity, m_curAnimId);
	if (entity == 0 || animation == 0) return 0;

	return res_getter::getAnimationName(ptr, animation);
}

//////////////////////////////////////////////////////////////////////////
// private function
//////////////////////////////////////////////////////////////////////////
void PerpSpriter::adjustPosition()
{
	char *ptr = m_scb->ptr();
	res_getter::ENTITY *entity = res_getter::getEntity(ptr, 0);
	res_getter::ANIMATION *animation = res_getter::getAnimationByIndex(ptr, entity, m_curAnimId);
	res_getter::TIMELINE *mainline = res_getter::getMainline(ptr, animation);
	res_getter::KEY *keyframe = res_getter::getKey(ptr, mainline, 0);
	int count = res_getter::getObjectRefCount(ptr, keyframe);
	for (int i = 0; i < count; i ++) {
		res_getter::OBJECTREF *objRef = res_getter::getObjectRef(ptr, keyframe, i);
		res_getter::TIMELINE *timeline = res_getter::getTimeline(ptr, animation, objRef->timeline);
		res_getter::KEY *keyRef = res_getter::getKey(ptr, timeline, objRef->key);
		res_getter::OBJECT *obj = res_getter::getObject(ptr, keyRef, 0);
		int key = GET_SPRITE_KEY(obj->folder, obj->file);
		auto sprite_iter = m_spritesPool->find(key);
		if (sprite_iter == m_spritesPool->end()) continue;

		CCSprite *spr = sprite_iter->second;
		if (spr) {
			float angle = obj->angle;
			float px = obj->pivot_x;
			float py = obj->pivot_y;
			float alpha = obj->alpha;
			GLubyte var = (GLubyte)(alpha * 255.0f * m_globalAlpha);

			if (angle >= 360) angle -= 360;
			if (angle < 0) angle += 360;

			res_getter::FILE *f = res_getter::getFile(ptr
						, res_getter::getFolder(ptr, obj->folder), obj->file);
			if (f->pivot_x > -2.0f && f->pivot_y > -2.0f) {
				px = f->pivot_x;
				py = f->pivot_y;
			}

			spr->setPosition(ccp(obj->x, obj->y));
			spr->setRotation(-angle);
			spr->setScaleX(obj->scale_x);
			spr->setScaleY(obj->scale_y);
			spr->setAnchorPoint(ccp(px, py));
			spr->setOpacity(var);

#ifdef DEBUG_SCML
			CCLOG("adjust:key=%d,x=%.2f,y=%.2f,px=%.2f,py=%.2f,angle=%.2f,sx=%.2f,sy=%.2f",
				key, obj->x, obj->y, px, py, angle, obj->scale_x, obj->scale_y);
#endif
		}
	}
}

void PerpSpriter::setSpriteSubstitution(const char *src, const char *tar)
{
	auto sprite_iter = m_spriteSubstitutions->find(src);
	if (sprite_iter != m_spriteSubstitutions->end()) {
		CCLog("already set substitution.");
		return;
	}
	m_spriteSubstitutions->insert(TYPE_SPRITE_SUBSTITUTIONS::value_type(src, tar));
}

void PerpSpriter::buildSprite(const char *baseDir)
{
	char *ptr = m_scb->ptr();

	int count = res_getter::getFolderCount(ptr);
	for (int i = 0; i < count; i ++) {
		res_getter::FOLDER *folder = res_getter::getFolder(ptr, i);
		int fileCount = res_getter::getFileCount(ptr, folder);
		for (int j = 0; j < fileCount; j ++) {
			res_getter::FILE *f = res_getter::getFile(ptr, folder, j);
			int key = GET_SPRITE_KEY(folder->id, f->id);
			auto sprite_iter = m_spritesPool->find(key);
			if (sprite_iter != m_spritesPool->end()) continue;

			std::string filename(res_getter::getFileName(ptr, f));
			//skip unused
			if (filename.at(0) == '!') {
				continue;
			}
			if (filename.at(0) == '/') {
				filename = filename.substr(1, filename.length() - 1);
			}

			auto sprite_substitutions_iter = m_spriteSubstitutions->find(filename);
			if (sprite_substitutions_iter != m_spriteSubstitutions->end())
			{
				filename = sprite_substitutions_iter->second;
			}

			if (m_useBatchNode) {
				SpriteFrame* spriteframe = SpriteFrameCache::getInstance()->getSpriteFrameByName(filename);
				if (spriteframe)
				{
					CCSprite *spr = CCSprite::createWithSpriteFrame(spriteframe);
					if (spr) {
						m_spritesPool->insert(key, spr);
						m_batchNode->addChild(spr);
					}
				}
					
			}
			else {
				CCSprite *spr = CCSprite::create(baseDir + filename);
				if (spr) {
					m_spritesPool->insert(key, spr);
				}
			}

#ifdef DEBUG_SCML
			CCLOG("loaded sprite: %s -> %d", filename.c_str(), key);
#endif
		}
	}
	this->adjustPosition();
}