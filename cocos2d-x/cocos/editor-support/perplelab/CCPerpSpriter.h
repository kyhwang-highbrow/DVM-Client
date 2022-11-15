#ifndef _PerpSpriter_H_
#define _PerpSpriter_H_

#include <vector>
#include <string>

#include "cocos2d.h"
#include "CCPerpSCB.h"

using namespace cocos2d;
using namespace std;

class PerpSpriter : public Node
{
public:
	PerpSpriter();
	virtual ~PerpSpriter();

	static PerpSpriter *create(const char *filename);
	static PerpSpriter *create(const char *filename, const char *imageFile);

	static void setFPS(int fps);

	bool initWithFile(const char *filename);

	virtual void onEnter() override;
	virtual void onExit() override;

	virtual void draw(Renderer *renderer, const Mat4 &transform, bool transformUpdated) override;
	virtual void update(float dt) override;

	//build
	void buildSprite(const char *baseDir);
	void setSpriteSubstitution(const char *src, const char *tar);

	//action
	void restart();
	bool play(const char *name);
	bool playByIndex(int index);
	void registerLoopHandler(int functionRefID);
	void unregisterLoopHandler(void);
	void registerTriggerHandler(float elapsedTime, int functionRefID);
	void unregisterTriggerHandler(void);

	//getter
	float getCurrentAnimationLength();
	float getOriginalAnimationLength();
	const char *getCurrentAnimationName();
	float getAlpha();

	//setter
	void setAnimationLength(float t);
	void setLooping(bool v);
	void setAlpha(float v);

protected:
	static bool s_cacheEnabled;
	typedef Map<std::string, PerpSCB *> TYPE_CACHED_FILES;
	static TYPE_CACHED_FILES s_cachedFiles;
	static int s_fps;
	static int s_totalSpriterCount;

	int m_loopScriptHandler;
	int m_triggerScriptHandler;
	float m_triggerElapsedTime;

private:
	void adjustPosition();

	PerpSCB *m_scb;

	bool m_useBatchNode;
	SpriteBatchNode *m_batchNode;

	typedef Map<int, Sprite*> TYPE_SPRITE_POOL;
	TYPE_SPRITE_POOL *m_spritesPool;
	typedef std::map<std::string, std::string> TYPE_SPRITE_SUBSTITUTIONS;
	TYPE_SPRITE_SUBSTITUTIONS *m_spriteSubstitutions;

	std::string m_plist;

	int m_curAnimId;
	int m_curKeyFrame;
	float m_elapsedTime;
	float m_animSpeed;
	float m_curAnimationLength;
	float m_globalAlpha;
	bool m_isDone;
	bool m_isLooping;
};

#endif