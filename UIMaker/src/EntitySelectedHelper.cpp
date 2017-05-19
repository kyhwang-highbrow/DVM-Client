#include "EntitySelectedHelper.h"
#include "EntityHelper.h"

USING_NS_CC;

CEntitySelectedHelper::CEntitySelectedHelper(CMakerScene::TYPE_NODE_BIND_MAP& node_bind)
	: m_node_bind(node_bind)
{
}
CEntitySelectedHelper::~CEntitySelectedHelper()
{
}

CEntitySelectedHelper* CEntitySelectedHelper::create(CMakerScene::TYPE_NODE_BIND_MAP& node_bind)
{
	auto *selected_info = new CEntitySelectedHelper(node_bind);
	if (selected_info && selected_info->init())
	{
		selected_info->setGlobalZOrder(1.0f);
		selected_info->autorelease();
		return selected_info;
	}
	CC_SAFE_DELETE(selected_info);
	return nullptr;
}

void CEntitySelectedHelper::draw(Renderer *renderer, const Mat4& transform, bool transformUpdated)
{
	for (auto& iter_node : m_node_bind)
	{
		auto node = iter_node.second;
		if (!node) continue;

		auto entity_helper = reinterpret_cast<CEntityHelper*>(node->getUserData());
		if (!entity_helper) continue;
		if (node->getTag() != CMakerScene::EDIT_ROOT_TAG && !entity_helper->isSelected()) continue;

		entity_helper->appendDrawCommand(renderer, _globalZOrder);
	}
}
