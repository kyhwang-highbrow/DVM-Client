#pragma once

#include "MakerScene.h"

class CEntitySelectedHelper : public cocos2d::Node
{
public:
	CEntitySelectedHelper(CMakerScene::TYPE_NODE_BIND_MAP& node_bind);
	~CEntitySelectedHelper();

	static CEntitySelectedHelper* create(CMakerScene::TYPE_NODE_BIND_MAP& node_bind);

	virtual void draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& transform, bool transformUpdated);

private:
	CMakerScene::TYPE_NODE_BIND_MAP& m_node_bind;
};

