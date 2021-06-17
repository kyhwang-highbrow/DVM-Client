#include "MakerScene.h"

#include "CCLuaEngine.h"
#include "EntitySelectedHelper.h"
#include "EntityHelper.h"
#include "Grid.h"
#include "SelectBox.h"
#include "glfw3native.h"

#include "CMDPipe.h"

void SendOpenViewer();

USING_NS_CC;
USING_NS_CC_EXT;

const std::string VISUAL_GROUP__VISUAL(";");


std::string g_prevLabelSystemFont_name("Helvetica");
int g_prevLabelSystemFont_size = 20;
std::string g_prevLabelTTF_name = "font/common_font_01.ttf";
int g_prevLabelTTF_size = 20;

bool g_onAlt = false;

extern "C" void shutdownCocos2d()
{
	ScriptEngineManager::destroyInstance();
	Configuration::destroyInstance();
	PoolManager::destroyInstance();
}
void SendOpenPopupNotifycation(maker::CMD& cmd);

static void dumpNodes(Node* node, std::string indent = "")
{
	CCLOG("%s - %s%s", __FUNCTION__, indent.c_str(), typeid(*node).name());

	auto& entities = node->getChildren();
	for(auto child = entities.begin(); child != entities.end(); ++ child)
	{
		Node* child_node = *child;
		dumpNodes(child_node, indent + "  ");
	}
}

static std::string ReplaceString(std::string subject, const std::string& search, const std::string& replace)
{
    size_t pos = 0;
    while ((pos = subject.find(search, pos)) != std::string::npos)
    {
        subject.replace(pos, search.length(), replace);
        pos += replace.length();
    }
    return subject;
}

CMakerScene::CMakerScene(float scale)
	: m_root(nullptr)
	, m_pick_part(maker::PICK_PART__NONE)
	, m_pick_node(nullptr)
	, _zoom_step(0)
	, _select_box(nullptr)
	, _edit_root(nullptr)
	, _grid(nullptr)
    , _view_scale(scale)
{
}
CMakerScene::~CMakerScene()
{
}
CMakerScene * CMakerScene::create(float scale)
{
    CMakerScene * ret = new CMakerScene(scale);
    if (ret && ret->init())
    {
        ret->autorelease();
	}
	else
	{
		CC_SAFE_DELETE(ret);
    }
	return ret;
}
std::string CMakerScene::getDescription() const
{
    return "CMakerScene";
}

bool CMakerScene::init()
{
	CCMDPipe::getInstance()->clearCmdQueueForView();

	SendOpenViewer();

	FileUtils::getInstance()->addSearchPath("../run/res");

	if (Scene::init())
    {
//		schedule(schedule_selector(CMakerScene::updateSceneInfo), 1.0f);

        return true;
    }
    else
    {
        return false;
    }
}
void CMakerScene::onEnter()
{
	auto engine = LuaEngine::getInstance();
	ScriptEngineManager::getInstance()->setScriptEngine(engine);
//	engine->executeScriptFile("src/ui_main.lua");

	scheduleUpdate();

	m_touch_listener = EventListenerTouchOneByOne::create();
	m_touch_listener->setSwallowTouches(true);

/*	m_touch_listener->onTouchBegan = CC_CALLBACK_2(CMakerScene::onTouchBegan, this);
	m_touch_listener->onTouchMoved = CC_CALLBACK_2(CMakerScene::onTouchMoved, this);
	m_touch_listener->onTouchEnded = CC_CALLBACK_2(CMakerScene::onTouchEnded, this);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(m_touch_listener, this);*/

	m_key_listener = EventListenerKeyboard::create();
	m_key_listener->onKeyPressed = CC_CALLBACK_2(CMakerScene::onkeyPressed, this);
	m_key_listener->onKeyReleased = CC_CALLBACK_2(CMakerScene::onkeyReleased, this);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(m_key_listener, this);

	m_mouse_listener = EventListenerMouse::create();
	m_mouse_listener->onMouseDown = CC_CALLBACK_1(CMakerScene::onMouseDown, this);
	m_mouse_listener->onMouseUp = CC_CALLBACK_1(CMakerScene::onMouseUp, this);
	m_mouse_listener->onMouseMove = CC_CALLBACK_1(CMakerScene::onMouseMove, this);
	m_mouse_listener->onMouseScroll = CC_CALLBACK_1(CMakerScene::onMouseScroll, this);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(m_mouse_listener, this);

	Scene::onEnter();
}

void CMakerScene::setCursor(maker::PICK_PART pick) const
{
	switch (pick)
	{
	case maker::PICK_PART__BOTTOM:
	case maker::PICK_PART__TOP: SetCursor(LoadCursor(0, IDC_SIZENS)); break;
	case maker::PICK_PART__LEFT:
	case maker::PICK_PART__RIGHT: SetCursor(LoadCursor(0, IDC_SIZEWE)); break;
	case maker::PICK_PART__LEFT_BOTTOM:
	case maker::PICK_PART__RIGHT_TOP: SetCursor(LoadCursor(0, IDC_SIZENESW)); break;
	case maker::PICK_PART__RIGHT_BOTTOM:
	case maker::PICK_PART__LEFT_TOP: SetCursor(LoadCursor(0, IDC_SIZENWSE)); break;
	case maker::PICK_PART__CENTER: SetCursor(LoadCursor(0, IDC_SIZEALL)); break;
	}
}
bool CMakerScene::checkNode(cocos2d::Touch* touch, cocos2d::Event* event, Node *target)
{
	if (!target) return false;
	if (target == this) return false;

	auto entity_helper = reinterpret_cast<CEntityHelper*>(target->getUserData());
	if (!entity_helper) return false;

	auto pick_pos = getPickPart(target, touch->getLocation());
	if (pick_pos == maker::PICK_PART__NONE) return false;

	if (!entity_helper->isSelected())
	{
		pick_pos = maker::PICK_PART__CENTER;

		maker::CMD cmd;
		CCMDPipe::getInstance()->initSelect(cmd, entity_helper->getEntityID());
		CCMDPipe::getInstance()->send(cmd);
	}

	entity_helper->setDrag(true);
	m_pick_part = pick_pos;

	auto current_entity = CEntityMgr::getInstance()->getCurrent();
	if (!current_entity) return false;

	entity_helper->backupEntityInfo(*current_entity);
	
	m_pick = touch->getLocation();

	setCursor(pick_pos);

	return true;
}
bool CMakerScene::onTouchBegan(Touch* touch, Event  *event)
{
	m_pick_part = maker::PICK_PART__NONE;

	auto on_shift = m_key_map.find(EventKeyboard::KeyCode::KEY_SHIFT) != m_key_map.end() && m_key_map[EventKeyboard::KeyCode::KEY_SHIFT].m_pressing;
	if (on_shift) return false;

	if (CEntityMgr::getInstance()->getCurrentID() != CEntityMgr::INVALID_ID)
	{
		auto iter = m_node_bind.find(CEntityMgr::getInstance()->getCurrentID());
		if (iter != m_node_bind.end() && iter->second != event->getCurrentTarget() && dynamic_cast<ClippingNode*>(iter->second))
		{
			if (checkNode(touch, event, iter->second)) return false;
		}
	}

	return checkNode(touch, event, event->getCurrentTarget());
}
void CMakerScene::onTouchMoved(Touch* touch, Event  *event)
{
	if (m_pick_part == maker::PICK_PART__NONE) return;

	auto target = event->getCurrentTarget();
	if (target == this) return;

	auto current_entity = CEntityMgr::getInstance()->getCurrent();
	auto entity_helper = reinterpret_cast<CEntityHelper*>(target->getUserData());
	if (current_entity && entity_helper && entity_helper->getEntityID() != CEntityMgr::getInstance()->getRoot()->id())
	{
		if (m_pick_part == maker::PICK_PART__CENTER)
		{
			target->setPosition(entity_helper->getPickPos() + (touch->getLocation() - m_pick));
		}
		else
		{
			Size size(entity_helper->getPickSize());
			Point d = touch->getLocation() - m_pick;

			if (m_pick_part == maker::PICK_PART__LEFT) size.width -= d.x;
			else if (m_pick_part == maker::PICK_PART__RIGHT) size.width += d.x;
			else if (m_pick_part == maker::PICK_PART__BOTTOM) size.height -= d.y;
			else if (m_pick_part == maker::PICK_PART__TOP) size.height += d.y;
			else if (m_pick_part == maker::PICK_PART__LEFT_TOP || m_pick_part == maker::PICK_PART__RIGHT_TOP || m_pick_part == maker::PICK_PART__LEFT_BOTTOM || m_pick_part == maker::PICK_PART__RIGHT_BOTTOM)
			{
				size.width += d.x;
				size.height += d.y;
			}

			if (size.width < 0) size.width = 0;
			if (size.height < 0) size.height = 0;

			target->setNormalSize(size);
		}
	}

	setCursor(m_pick_part);
}
void CMakerScene::onTouchEnded(Touch* touch, Event  *event)
{	
	auto target = event->getCurrentTarget();
	if (target == this) return;
	if (target == m_root) return;

	auto current_entity = CEntityMgr::getInstance()->getCurrent();
	auto entity_helper = reinterpret_cast<CEntityHelper*>(target->getUserData());
	if (current_entity && entity_helper && entity_helper->getEntityID() != CEntityMgr::getInstance()->getRoot()->id())
	{
		auto current_entity_id = current_entity->id();
		if (entity_helper->getEntityID() == current_entity_id)
		{
			maker::CMD cmd;
			CCMDPipe::VAR v;

			if (m_pick_part == maker::PICK_PART__CENTER)
			{
				Point position = entity_helper->getPickPos() + (touch->getLocation() - m_pick);

				v.m_type = CCMDPipe::VAR::TYPE::FLOAT;
				v.V.m_float = static_cast<int>(position.x);
				CCMDPipe::getInstance()->initModify(cmd, current_entity_id, "Node", "x", v);
				v.V.m_float = static_cast<int>(position.y);
				CCMDPipe::getInstance()->initModify(cmd, current_entity_id, "Node", "y", v);

				target->setPositionX(static_cast<int>(position.x));
				target->setPositionY(static_cast<int>(position.y));
			}
			else
			{
				Size size(entity_helper->getPickSize());
				Point d = touch->getLocation() - m_pick;

				if (m_pick_part == maker::PICK_PART__LEFT || m_pick_part == maker::PICK_PART__RIGHT)
				{
					size.width += d.x;
				}
				else if (m_pick_part == maker::PICK_PART__TOP || m_pick_part == maker::PICK_PART__BOTTOM)
				{
					size.height += d.y;
				}
				else if (m_pick_part == maker::PICK_PART__LEFT_TOP || m_pick_part == maker::PICK_PART__RIGHT_TOP || m_pick_part == maker::PICK_PART__LEFT_BOTTOM || m_pick_part == maker::PICK_PART__RIGHT_BOTTOM)
				{
					size.width += d.x;
					size.height += d.y;
				}

				if (size.width < 0) size.width = 0;
				if (size.height < 0) size.height = 0;

				target->setNormalSize(size);

				v.m_type = CCMDPipe::VAR::TYPE::INT32;
				v.V.m_int32 = static_cast<int>(size.width);
				CCMDPipe::getInstance()->initModify(cmd, current_entity_id, "Node", "width", v);
				v.V.m_int32 = static_cast<int>(size.height);
				CCMDPipe::getInstance()->initModify(cmd, current_entity_id, "Node", "height", v);
			}

			CCMDPipe::getInstance()->initBackup(cmd, *current_entity);
			CCMDPipe::getInstance()->send(cmd);

			applyToTool_ContentSize(current_entity_id, target);
		}

		entity_helper->setDrag(false);
	}

	m_pick_part = maker::PICK_PART__NONE;
}
void CMakerScene::onkeyPressed(EventKeyboard::KeyCode keyCode, Event *event)
{
	auto& key_info = m_key_map[keyCode];
	key_info.m_pressed = true;
	key_info.m_pressing = true;
	key_info.m_released = false;
	key_info.m_delta = 0.0f;
}
void CMakerScene::onkeyReleased(EventKeyboard::KeyCode keyCode, Event *event)
{
	auto& key_info = m_key_map[keyCode];
	key_info.m_pressing = false;
	key_info.m_released = true;
	key_info.m_delta = 0.0f;
}
void CMakerScene::onMouseDown(Event* event)
{
	if (m_pick_part != maker::PICK_PART__NONE) return;

	auto mouse_event = dynamic_cast<EventMouse*>(event);
	if (!mouse_event) return;

    EventMouse mouse_event_new(EventMouse::MouseEventType::MOUSE_DOWN);
    mouse_event_new.setCursorPosition(mouse_event->getCursorX() / _view_scale, mouse_event->getCursorY() / _view_scale);
    mouse_event_new.setScrollData(mouse_event->getScrollX(), mouse_event->getScrollY());

	auto on_shift = m_key_map.find(EventKeyboard::KeyCode::KEY_SHIFT) != m_key_map.end() && m_key_map[EventKeyboard::KeyCode::KEY_SHIFT].m_pressing;
	auto on_ctrl = m_key_map.find(EventKeyboard::KeyCode::KEY_CTRL) != m_key_map.end() && m_key_map[EventKeyboard::KeyCode::KEY_CTRL].m_pressing;

	switch (mouse_event->getMouseButton())
	{
	case MOUSE_BUTTON_LEFT: {
		if (on_shift)
		{
            onMouseDown_selectBox(&mouse_event_new);
		}
		else
		{
            onMouseDown_editEntity(&mouse_event_new, on_ctrl);
		}
	} break;
	case MOUSE_BUTTON_RIGHT: {
		maker::CMD pick_cmd;
        pickAllNode(_edit_root, Point(mouse_event_new.getCursorX(), mouse_event_new.getCursorY()), pick_cmd);
		SendOpenPopupNotifycation(pick_cmd);
	} break;
	case MOUSE_BUTTON_MIDDLE: {
        onMouseDown_scroll(&mouse_event_new);
	} break;
	}
}
void CMakerScene::onMouseUp(cocos2d::Event* event)
{
	auto mouse_event = dynamic_cast<EventMouse*>(event);
	if (!mouse_event) return;

    EventMouse mouse_event_new(EventMouse::MouseEventType::MOUSE_DOWN);
    mouse_event_new.setCursorPosition(mouse_event->getCursorX() / _view_scale, mouse_event->getCursorY() / _view_scale);
    mouse_event_new.setScrollData(mouse_event->getScrollX(), mouse_event->getScrollY());

	switch (mouse_event->getMouseButton())
	{
	case MOUSE_BUTTON_LEFT: {
		if (m_pick_part == maker::PICK_PART__SELECT_BOX)
		{
            onMouseUp_selectBox(&mouse_event_new);
		}
		else
		{
            onMouseUp_editEntity(&mouse_event_new);
		}
	} break;
	case MOUSE_BUTTON_RIGHT: {
	} break;
	case MOUSE_BUTTON_MIDDLE: {
        onMouseUp_scroll(&mouse_event_new);
	} break;
	}

	m_pick_part = maker::PICK_PART__NONE;
}
void CMakerScene::onMouseMove(Event* event)
{
	auto mouse_event = dynamic_cast<EventMouse*>(event);
	if (!mouse_event) return;

    EventMouse mouse_event_new(EventMouse::MouseEventType::MOUSE_DOWN);
    mouse_event_new.setCursorPosition(mouse_event->getCursorX() / _view_scale, mouse_event->getCursorY() / _view_scale);
    mouse_event_new.setScrollData(mouse_event->getScrollX(), mouse_event->getScrollY());

	auto on_shift = m_key_map.find(EventKeyboard::KeyCode::KEY_SHIFT) != m_key_map.end() && m_key_map[EventKeyboard::KeyCode::KEY_SHIFT].m_pressing;
    g_onAlt = m_key_map.find(EventKeyboard::KeyCode::KEY_ALT) != m_key_map.end() && m_key_map[EventKeyboard::KeyCode::KEY_ALT].m_pressing;

	if (m_pick_part == maker::PICK_PART__SCROLL)
	{
        onMouseMove_scroll(&mouse_event_new);
	}
	else if (m_pick_part == maker::PICK_PART__SELECT_BOX)
	{
        onMouseMove_selectBox(&mouse_event_new);
	}
	else
	{
        onMouseMove_editEntity(&mouse_event_new);
	}
}
void CMakerScene::onMouseScroll(cocos2d::Event* event)
{
	if (m_pick_part != maker::PICK_PART__NONE) return;
	if (!m_root) return;

	auto mouse_event = dynamic_cast<EventMouse*>(event);
	if (!mouse_event) return;

	if ((mouse_event->getScrollY() < 0 && _zoom_step >= 9) ||
		(mouse_event->getScrollY() > 0 && _zoom_step <= -9))
	{
		return;
	}

	if (mouse_event->getScrollY() < 0)
	{
		++_zoom_step;
		if (_zoom_step > 9) _zoom_step = 9;
	}
	else
	{
		--_zoom_step;
		if (_zoom_step < -9) _zoom_step = -9;
	}

	static float zoom_in[9] = { 0.9f, 0.8f, 0.7f, 0.6f, 0.5f, 0.4f, 0.3f, 0.2f, 0.1f };
	static float zoom_out[9] = { 2.0f, 3.0f, 4.0f, 5.0f, 6.0f, 7.0f, 8.0f, 9.0f, 10.0f };

	float zoom;
	if (_zoom_step < 0) zoom = zoom_in[-_zoom_step - 1];
	else if (_zoom_step > 0) zoom = zoom_out[_zoom_step - 1];
	else zoom = 1.0f;

	updateZoom(zoom);
}

void CMakerScene::updateZoom(float zoom)
{
	float prev_zoom = m_root->getScale();

	m_root->setScale(zoom);

	auto center_pos = m_zoom_center_pos;

	auto prev_origin = center_pos * prev_zoom;
	auto curr_origin = center_pos * zoom;

	auto d_pos = prev_origin - curr_origin;
	m_root->setPosition(m_root->getPosition() + d_pos);
}

void CMakerScene::onMouseDown_editEntity(cocos2d::EventMouse* mouse_event, bool on_ctrl)
{
	maker::CMD pick_cmd;
	if (on_ctrl)
	{
		auto pick_part = pickTopNode(_edit_root, Point(mouse_event->getCursorX(), mouse_event->getCursorY()), pick_cmd);
		if (pick_cmd.entities_size() <= 0) return;

		auto& entities = pick_cmd.entities();
		for (auto& entity : entities)
		{
			auto iter_bind = m_node_bind.find(entity.id());
			if (iter_bind == m_node_bind.end()) continue;

			auto node = iter_bind->second;
			if (!node) continue;

			auto entity_helper = reinterpret_cast<CEntityHelper*>(node->getUserData());
			if (!entity_helper) continue;

			entity_helper->setSelected(!entity_helper->isSelected());
		}

		maker::CMD cmd;
		CCMDPipe::getInstance()->initSelectBoxAppend(cmd, false);

		for (auto& iter_bind : m_node_bind)
		{
			auto node = iter_bind.second;
			if (!node) continue;

			auto entity_helper = reinterpret_cast<CEntityHelper*>(node->getUserData());
			if (!entity_helper) continue;

			if (!entity_helper->isSelected()) continue;
	
			auto child = cmd.add_entities();
			if (!child) continue;

			child->set_id(entity_helper->getEntityID());
		}

		CCMDPipe::getInstance()->send(cmd);
	}
	else
	{
		maker::CMD selected_pick_cmd;
		m_pick_part = pickSelectedNode(_edit_root, Point(mouse_event->getCursorX(), mouse_event->getCursorY()), selected_pick_cmd);
		if (m_pick_part != maker::PICK_PART__NONE)
		{
			for (auto& iter_node : m_node_bind)
			{
				auto target = iter_node.second;
				if (!target) continue;
				if (target == this) continue;

				auto entity_helper = reinterpret_cast<CEntityHelper*>(target->getUserData());
				if (!entity_helper) continue;

				entity_helper->setParentSelected(false);
				if (!entity_helper->isSelected()) continue;

				auto current_entity = CEntityMgr::getInstance()->get(entity_helper->getEntityID());
				if (!current_entity) continue;

				entity_helper->backupEntityInfo(*current_entity);

				auto parent = target->getParent();
				while (parent)
				{
					auto parent_helper = reinterpret_cast<CEntityHelper*>(parent->getUserData());
					if (parent_helper)
					{
						if (parent_helper->isSelected())
						{
							entity_helper->setParentSelected(true);
							break;
						}
					}
					parent = parent->getParent();
				}
			}
			return;
		}
		else
		{
			m_pick_part = pickTopNode(_edit_root, Point(mouse_event->getCursorX(), mouse_event->getCursorY()), pick_cmd);
		}

		if (m_pick_part == maker::PICK_PART__CENTER)
		{
			maker::CMD cmd;
			CCMDPipe::getInstance()->initSelectBoxAppend(cmd, true);
			auto& entities = pick_cmd.entities();
			for (auto& entity : entities)
			{
				CCMDPipe::getInstance()->initSelect(cmd, entity.id());
			}
			CCMDPipe::getInstance()->send(cmd);
		}
		else
		{
			maker::CMD cmd;
			CCMDPipe::getInstance()->initSelect(cmd, CEntityMgr::INVALID_ID);
			CCMDPipe::getInstance()->send(cmd);

			m_pick_part = maker::PICK_PART__NONE;
		}
	}
}
void CMakerScene::onMouseUp_editEntity(cocos2d::EventMouse* mouse_event)
{	
	if (m_pick_part == maker::PICK_PART__NONE)
	{ 
	}
	else
	{
		if (m_pick_part == maker::PICK_PART__CENTER)
		{
			maker::CMD cmd;
			CCMDPipe::VAR v;
			CCMDPipe::getInstance()->initModify(cmd, CEntityMgr::INVALID_ID, "", "", v);

			auto pick_pos = Point(mouse_event->getCursorX(), mouse_event->getCursorY());
			for (auto& iter_node : m_node_bind) // 객체 외곽선 피킹
			{
				auto target = iter_node.second;
				if (!target) continue;
				if (target == _edit_root) continue;

				auto entity_helper = reinterpret_cast<CEntityHelper*>(target->getUserData());
				if (!entity_helper || !entity_helper->isSelected() || entity_helper->isParentSelected()) continue;

				auto current_entity = CEntityMgr::getInstance()->get(entity_helper->getEntityID());
				if (!current_entity) continue;

				entity_helper->setDrag(false);

                Vec2 displace = pick_pos - m_pick;
                if (displace != Vec2::ZERO)
                {
                    auto current_entity_id = iter_node.first;
                    auto zoom = m_root->getScale();
                    Point position = entity_helper->getPickPos() + displace / zoom;

                    auto child = cmd.add_entities();
                    if (child)
                    {
                        child->set_id(entity_helper->getEntityID());

                        auto properties = child->mutable_properties();

                        std::string modify_info_x;
                        std::string modify_info_y;

                        v.m_type = CCMDPipe::VAR::TYPE::FLOAT;
                        v.V.m_float = static_cast<int>(position.x);
                        CCMDPipe::getInstance()->initModify(properties, "Node", "x", v, modify_info_x);
                        v.V.m_float = static_cast<int>(position.y);
                        CCMDPipe::getInstance()->initModify(properties, "Node", "y", v, modify_info_y);

                        target->setPositionX(static_cast<int>(position.x));
                        target->setPositionY(static_cast<int>(position.y));

                        if (cmd.description().empty())
                        {
                            cmd.set_description("Modify '" + CCMDPipe::getNodeInfo(current_entity_id) + ", ...': " + modify_info_x + ", " + modify_info_y);
                        }
                        CCMDPipe::getInstance()->initBackup(cmd, *current_entity);
                    }
                }
			}
			if (cmd.entities_size() > 0)
			{
				CCMDPipe::getInstance()->send(cmd);
			}

			setCursor(maker::PICK_PART__NONE);
		}
		else if (m_pick_part <= maker::PICK_PART__RIGHT_TOP)
		{

			maker::CMD cmd;
			CCMDPipe::VAR v;
			CCMDPipe::getInstance()->initModify(cmd, CEntityMgr::INVALID_ID, "", "", v);

			auto pick_pos = Point(mouse_event->getCursorX(), mouse_event->getCursorY());
			for (auto& iter_node : m_node_bind) // 객체 외곽선 피킹
			{
				auto target = iter_node.second;
				if (!target) continue;
				if (target == _edit_root) continue;

				auto entity_helper = reinterpret_cast<CEntityHelper*>(target->getUserData());
				if (!entity_helper || !entity_helper->isSelected() || entity_helper->isParentSelected()) continue;

				auto current_entity = CEntityMgr::getInstance()->get(entity_helper->getEntityID());
				if (!current_entity) continue;

				entity_helper->setDrag(false);

				auto current_entity_id = iter_node.first;
				auto zoom = m_root->getScale();

                Size size(entity_helper->getPickSize());
                Vec2 displace = pick_pos - m_pick;

                calcSizeAndDisplace_editEntity(size, displace, zoom, target);

                Point position = entity_helper->getPickPos() + displace;

				auto child = cmd.add_entities();
				if (child)
				{
					child->set_id(entity_helper->getEntityID());

					auto properties = child->mutable_properties();

					std::string modify_info_x;
					std::string modify_info_y;
					std::string modify_info_w;
					std::string modify_info_h;

					v.m_type = CCMDPipe::VAR::TYPE::FLOAT;
					v.V.m_float = static_cast<int>(position.x);
					CCMDPipe::getInstance()->initModify(properties, "Node", "x", v, modify_info_x);
					v.V.m_float = static_cast<int>(position.y);
					CCMDPipe::getInstance()->initModify(properties, "Node", "y", v, modify_info_y);

                    v.m_type = CCMDPipe::VAR::TYPE::INT32;
                    v.V.m_int32 = size.width;
                    CCMDPipe::getInstance()->initModify(properties, "Node", "width", v, modify_info_w);
                    v.V.m_int32 = size.height;
                    CCMDPipe::getInstance()->initModify(properties, "Node", "height", v, modify_info_h);

					target->setPositionX(static_cast<int>(position.x));
					target->setPositionY(static_cast<int>(position.y));

                    target->setNormalSize(size);

					if (cmd.description().empty())
					{
						cmd.set_description("Modify '" + CCMDPipe::getNodeInfo(current_entity_id) + ", ...': " + modify_info_x + ", " + modify_info_y + ", " + modify_info_w + ", " + modify_info_h);
					}
					CCMDPipe::getInstance()->initBackup(cmd, *current_entity);
				}
			}
			if (cmd.entities_size() > 0)
			{
				CCMDPipe::getInstance()->send(cmd);
			}

			setCursor(maker::PICK_PART__NONE);
		}
	}
	m_pick_part = maker::PICK_PART__NONE;
}
void CMakerScene::onMouseMove_editEntity(cocos2d::EventMouse* mouse_event)
{
	if (m_pick_part == maker::PICK_PART__NONE)
	{
		for (auto& iter_node : m_node_bind) // 객체 외곽선 피킹
		{
			auto target = iter_node.second;
			if (!target) continue;
			if (target == this) continue;

			auto entity_helper = reinterpret_cast<CEntityHelper*>(target->getUserData());
			if (!entity_helper || !entity_helper->isSelected()) continue;

			auto pick_part = getPickPart(target, Point(mouse_event->getCursorX(), mouse_event->getCursorY()));
			setCursor(pick_part);
		}
	}
	else
	{
		auto pick_pos = Point(mouse_event->getCursorX(), mouse_event->getCursorY());
		for (auto& iter_node : m_node_bind) // 객체 외곽선 피킹
		{
			auto target = iter_node.second;
			if (!target) continue;
			if (target == _edit_root) continue;

			auto entity_helper = reinterpret_cast<CEntityHelper*>(target->getUserData());
			if (!entity_helper || !entity_helper->isSelected() || entity_helper->isParentSelected()) continue;

			auto current_entity = CEntityMgr::getInstance()->get(entity_helper->getEntityID());
			if (!current_entity) continue;

			auto zoom = m_root->getScale();
			if (m_pick_part == maker::PICK_PART__CENTER)
			{
				target->setPosition(entity_helper->getPickPos() + ((pick_pos - m_pick) / zoom));
			}
			else
			{
                Size size(entity_helper->getPickSize());
                Vec2 displace = pick_pos - m_pick;

                calcSizeAndDisplace_editEntity(size, displace, zoom, target);

                Point position = entity_helper->getPickPos() + displace;

                // adjust position
                target->setPosition(position);

				// apply size
                target->setNormalSize(size);

				target->setUpdateChildrenTransform();
			}
		}
		setCursor(m_pick_part);
	}
}

bool CMakerScene::isPickedLeftSide(maker::PICK_PART pickPart)
{
    switch (pickPart)
    {
    case maker::PICK_PART__LEFT:
    case maker::PICK_PART__LEFT_TOP:
    case maker::PICK_PART__LEFT_BOTTOM:
        return true;
    }

    return false;
}

bool CMakerScene::isPickedRightSide(maker::PICK_PART pickPart)
{
    switch (pickPart)
    {
    case maker::PICK_PART__RIGHT:
    case maker::PICK_PART__RIGHT_TOP:
    case maker::PICK_PART__RIGHT_BOTTOM:
        return true;
    }

    return false;

}

bool CMakerScene::isPickedTopSide(maker::PICK_PART pickPart)
{
    switch (pickPart)
    {
    case maker::PICK_PART__TOP:
    case maker::PICK_PART__LEFT_TOP:
    case maker::PICK_PART__RIGHT_TOP:
        return true;
    }

    return false;
}

bool CMakerScene::isPickedBottomSide(maker::PICK_PART pickPart)
{
    switch (pickPart)
    {
    case maker::PICK_PART__BOTTOM:
    case maker::PICK_PART__LEFT_BOTTOM:
    case maker::PICK_PART__RIGHT_BOTTOM:
        return true;
    }

    return false;
}

void CMakerScene::calcSizeAndDisplace_editEntity(Size &size, Vec2 &displace, float zoom, Node *target)
{
    Size displaceLimit = size;

    //////////////////////////////
    // 1. Adjust Size

    Point d = displace / zoom;

    if (isPickedLeftSide(m_pick_part))
    {
        size.width -= d.x;
    }
    else if (isPickedRightSide(m_pick_part))
    {
        size.width += d.x;
    }

    if (isPickedTopSide(m_pick_part))
    {
        size.height += d.y;
    }
    else if (isPickedBottomSide(m_pick_part))
    {
        size.height -= d.y;
    }

    // Size Limit
    if (size.width < 0)
    {
        size.width = 0;
    }

    if (size.height < 0)
    {
        size.height = 0;
    }

    //////////////////////////////
    // 2. Adjust Displacement

    displace = Vec2(0, 0);

    if (!g_onAlt)
    {
        Vec2 anchor = target->getAnchorPoint();

        if ((anchor.x == 0.0f && isPickedLeftSide(m_pick_part)) ||
            (anchor.x == 1.0f && isPickedRightSide(m_pick_part)))
        {
            displace.x = d.x;
        }
        else if ((anchor.x > 0.0f && anchor.x < 1.0f) &&
                 (isPickedLeftSide(m_pick_part) || isPickedRightSide(m_pick_part)))
        {
            displace.x = d.x * anchor.x;
            displaceLimit.width *= anchor.x;
        }

        if ((anchor.y == 0.0f && isPickedBottomSide(m_pick_part)) ||
            (anchor.y == 1.0f && isPickedTopSide(m_pick_part)))
        {
            displace.y = d.y;
        }
        else if ((anchor.y > 0.0f && anchor.y < 1.0f) &&
                 (isPickedBottomSide(m_pick_part) || isPickedTopSide(m_pick_part)))
        {
            displace.y = d.y * anchor.y;
            displaceLimit.height *= anchor.y;
        }

        // X Displacement Limit
        if (isPickedLeftSide(m_pick_part) &&
            (displace.x > displaceLimit.width))
        {
            displace.x = displaceLimit.width;
        }
        else if (isPickedRightSide(m_pick_part) &&
                 (displace.x < -displaceLimit.width))
        {
            displace.x = -displaceLimit.width;
        }

        // Y Displacement Limit
        if (isPickedTopSide(m_pick_part) &&
            (displace.y < -displaceLimit.height))
        {
            displace.y = -displaceLimit.height;
        }
        else if (isPickedBottomSide(m_pick_part) &&
                 (displace.y > displaceLimit.height))
        {
            displace.y = displaceLimit.height;
        }
    }
}

void CMakerScene::onMouseDown_scroll(cocos2d::EventMouse* mouse_event)
{
	m_pick_part = maker::PICK_PART__SCROLL;
	m_pick = Point(mouse_event->getCursorX(), mouse_event->getCursorY());
	m_pick_offset = m_root->getPosition();
	m_pick_zoom_center_pos = m_zoom_center_pos;
}
void CMakerScene::onMouseUp_scroll(cocos2d::EventMouse* mouse_event)
{
	onMouseMove_scroll(mouse_event);
	m_pick_part = maker::PICK_PART__NONE;
}
void CMakerScene::onMouseMove_scroll(cocos2d::EventMouse* mouse_event)
{
	Point d = Point(mouse_event->getCursorX(), mouse_event->getCursorY()) - m_pick;
	m_root->setPosition(m_pick_offset + d / getScale());

	m_zoom_center_pos = m_pick_zoom_center_pos - d / getScale();
}

void CMakerScene::onMouseDown_selectBox(cocos2d::EventMouse* mouse_event)
{
	m_pick_part = maker::PICK_PART__SELECT_BOX;
	m_pick = m_root->convertToNodeSpace(Point(mouse_event->getCursorX(), mouse_event->getCursorY()));
	_select_box->begin(m_pick);
	_select_box->end(m_pick);
}
void CMakerScene::onMouseUp_selectBox(cocos2d::EventMouse* mouse_event)
{
	onMouseMove_selectBox(mouse_event);
	m_pick = m_root->convertToNodeSpace(Point(0, 0));
	_select_box->begin(m_pick);
	_select_box->end(m_pick);
	m_pick_part = maker::PICK_PART__NONE;
}
void CMakerScene::onMouseMove_selectBox(cocos2d::EventMouse* mouse_event)
{
	m_pick = m_root->convertToNodeSpace(Point(mouse_event->getCursorX(), mouse_event->getCursorY()));
	_select_box->end(m_pick);

	maker::CMD cmd;
	CCMDPipe::getInstance()->initSelectBoxAppend(cmd, false);

	auto rect_min = m_root->convertToWorldSpace(_select_box->begin());
	auto rect_max = m_root->convertToWorldSpace(_select_box->end());
	if (rect_min.x > rect_max.x) ::swap(rect_min.x, rect_max.x);
	if (rect_min.y > rect_max.y) ::swap(rect_min.y, rect_max.y);

	pickNode_selectBox(_edit_root, rect_min, rect_max, cmd);

	CCMDPipe::getInstance()->send(cmd);
}

maker::PICK_PART CMakerScene::getPickPart(const Node* node, const Point& point) const
{
	if (!node) return maker::PICK_PART__NONE;
	if (node == m_root) return maker::PICK_PART__NONE;

	Point locationInNode = node->convertToNodeSpace(point);

	auto visual = dynamic_cast<const AzVRP*>(node);
	if (visual)
	{
		Rect rect = visual->getValidRect();
		if (!rect.containsPoint(locationInNode)) return maker::PICK_PART__NONE;

		return maker::PICK_PART__CENTER;
	}

	Point o0 = node->convertToNodeSpace(Point(0, 0));
	Point o1 = node->convertToNodeSpace(Point(cm_pick_margin, 0));
	float dist = (o1 - o0).length();

	Size s = node->getNormalSize();

	Rect rect = Rect(-dist, -dist, s.width + dist * 2, s.height + dist * 2);

	if (!rect.containsPoint(locationInNode)) return maker::PICK_PART__NONE;

	Rect rect_bottom = Rect(dist, -dist, s.width - dist * 2, dist * 2);
	if (rect_bottom.containsPoint(locationInNode)) return maker::PICK_PART__BOTTOM;
	Rect rect_top = Rect(dist, s.height - dist, s.width - dist * 2, dist * 2);
	if (rect_top.containsPoint(locationInNode)) return maker::PICK_PART__TOP;
	Rect rect_left = Rect(-dist, dist, dist * 2, s.height - dist * 2);
	if (rect_left.containsPoint(locationInNode)) return maker::PICK_PART__LEFT;
	Rect rect_right = Rect(s.width - dist, dist, dist * 2, s.height - dist * 2);
	if (rect_right.containsPoint(locationInNode)) return maker::PICK_PART__RIGHT;
	Rect rect_left_bottom = Rect(-dist, -dist, dist * 2, dist * 2);
	if (rect_left_bottom.containsPoint(locationInNode)) return maker::PICK_PART__LEFT_BOTTOM;
	Rect rect_left_top = Rect(-dist, s.height - dist, dist * 2, dist * 2);
	if (rect_left_top.containsPoint(locationInNode)) return maker::PICK_PART__LEFT_TOP;
	Rect rect_right_bottom = Rect(s.width - dist, -dist, dist * 2, dist * 2);
	if (rect_right_bottom.containsPoint(locationInNode)) return maker::PICK_PART__RIGHT_BOTTOM;
	Rect rect_right_top = Rect(s.width - dist, s.height - dist, dist * 2, dist * 2);
	if (rect_right_top.containsPoint(locationInNode)) return maker::PICK_PART__RIGHT_TOP;

	return maker::PICK_PART__CENTER;
}
maker::PICK_PART CMakerScene::pickSelectedNode(cocos2d::Node *target, const cocos2d::Point& pick_pos, maker::CMD& cmd)
{
	if (!target) return maker::PICK_PART__NONE;
	if (!target->isVisible()) return maker::PICK_PART__NONE;

	auto reverse_children = target->getChildren();
	reverse_children.reverse();
	for (auto& child : reverse_children)
	{
		auto _pick_part = pickSelectedNode(child, pick_pos, cmd);
		if (_pick_part != maker::PICK_PART__NONE) return _pick_part;
	}

	if (target == _edit_root) return maker::PICK_PART__NONE;

	auto entity_helper = reinterpret_cast<CEntityHelper*>(target->getUserData());
	if (!entity_helper) return maker::PICK_PART__NONE;
	if (!entity_helper->isSelected()) return maker::PICK_PART__NONE;

	auto current_entity = CEntityMgr::getInstance()->get(entity_helper->getEntityID());
	if (!current_entity) return maker::PICK_PART__NONE;

	auto pick_part = getPickPart(target, pick_pos);
	if (pick_part == maker::PICK_PART__NONE) return maker::PICK_PART__NONE;

	auto child = cmd.add_entities();
	if (child)
	{
		child->set_id(entity_helper->getEntityID());
	}

	entity_helper->setDrag(true);
	m_pick = pick_pos;
	m_pick_node = target;

	entity_helper->backupEntityInfo(*current_entity);

	setCursor(pick_part);

	return pick_part;
}
maker::PICK_PART CMakerScene::pickTopNode(cocos2d::Node *target, const cocos2d::Point& pick_pos, maker::CMD& cmd)
{
	if (!target) return maker::PICK_PART__NONE;
	if (!target->isVisible()) return maker::PICK_PART__NONE;

	auto reverse_children = target->getChildren();
	reverse_children.reverse();
	for (auto& child : reverse_children)
	{
		auto _pick_part = pickTopNode(child, pick_pos, cmd);
		if (_pick_part != maker::PICK_PART__NONE) return _pick_part;
	}

	if (target == _edit_root) return maker::PICK_PART__NONE;

	auto entity_helper = reinterpret_cast<CEntityHelper*>(target->getUserData());
	if (!entity_helper) return maker::PICK_PART__NONE;

	auto current_entity = CEntityMgr::getInstance()->get(entity_helper->getEntityID());
	if (!current_entity) return maker::PICK_PART__NONE;

	auto pick_part = getPickPart(target, pick_pos);
	if (pick_part == maker::PICK_PART__NONE) return maker::PICK_PART__NONE;

	auto child = cmd.add_entities();
	if (child)
	{
		child->set_id(entity_helper->getEntityID());
	}

	entity_helper->setDrag(true);
	m_pick = pick_pos;
	m_pick_node = target;

	entity_helper->backupEntityInfo(*current_entity);

	setCursor(pick_part);

	return pick_part;
}
void CMakerScene::pickAllNode(cocos2d::Node *target, const cocos2d::Point& pick_pos, maker::CMD& cmd)
{
	if (!target) return;
	if (!target->isVisible()) return;

	auto reverse_children = target->getChildren();
	reverse_children.reverse();
	for (auto& child : reverse_children)
	{
		pickAllNode(child, pick_pos, cmd);
	}

	if (target == _edit_root) return;

	auto entity_helper = reinterpret_cast<CEntityHelper*>(target->getUserData());
	if (!entity_helper) return;

	auto current_entity = CEntityMgr::getInstance()->get(entity_helper->getEntityID());
	if (!current_entity) return;

	auto pick_part = getPickPart(target, pick_pos);
	if (pick_part == maker::PICK_PART__NONE) return;

	auto child = cmd.add_entities();
	if (child)
	{
		child->set_id(entity_helper->getEntityID());
	}

	entity_helper->setDrag(true);
	m_pick = pick_pos;
	m_pick_node = target;

	entity_helper->backupEntityInfo(*current_entity);
}
bool CMakerScene::isOverlap(const Node* node, const Point& rect_min, const Point& rect_max) const
{
	if (!node) return false;

	Point minInNode = node->convertToNodeSpace(rect_min);
	Point maxInNode = node->convertToNodeSpace(rect_max);
	Rect rect_select_box = Rect(minInNode.x, minInNode.y, maxInNode.x - minInNode.x, maxInNode.y - minInNode.y);

	auto visual = dynamic_cast<const AzVRP*>(node);
	if (visual)
	{
		Rect rect = visual->getValidRect();
		return rect_select_box.intersectsRect(rect);
	}

	Size s = node->getNormalSize();
	if (s.width == 0 || s.height == 0) return false;

	Rect rect = Rect(0, 0, s.width, s.height);

	return rect_select_box.intersectsRect(rect);
}
void CMakerScene::pickNode_selectBox(Node *target, const Point& rect_min, const Point& rect_max, maker::CMD& cmd)
{
	if (!target) return;

	for (auto& child : target->getChildren())
	{
		if (!child->isVisible()) continue;

		if (isOverlap(child, rect_min, rect_max))
		{
			auto entity_helper = reinterpret_cast<CEntityHelper*>(child->getUserData());
			if (entity_helper)
			{
				auto child = cmd.add_entities();
				if (child)
				{
					child->set_id(entity_helper->getEntityID());
				}
			}
		}

		pickNode_selectBox(child, rect_min, rect_max, cmd);
	}
}

void CMakerScene::update(float delta)
{
	updateKeyEvents(delta);

	updateCmd();
}
void CMakerScene::updateCmd()
{
	maker::CMD cmd;
	while (CCMDPipe::getInstance()->recvAtView(cmd))
	{
		switch (cmd.type())
		{
		case maker::CMD__ApplyToViewer:
		case maker::CMD__Create: onCmd_Create(cmd); break;
		case maker::CMD__Paste: break; // Tool에서 객체를 생성하여 CMD__ApplyToViewer를 이용해서 생성
		case maker::CMD__Cut:
		case maker::CMD__Remove: onCmd_Remove(cmd); break;
		case maker::CMD__Move: onCmd_Move(cmd);   break;
		case maker::CMD__Modify: onCmd_Modify(cmd); break;
        case maker::CMD__SizeToContent: onCmd_SizeToContent(cmd); break;
		case maker::CMD__SelectOne: onCmd_SelectOne(cmd); break;
		case maker::CMD__SelectAppend: onCmd_SelectAppend(cmd); break;
		case maker::CMD__SelectBoxAppend: onCmd_SelectBoxAppend(cmd); break;
		case maker::CMD__MoveViewer:
		{
			auto glview = Director::getInstance()->getOpenGLView();
			if (!glview) return;
			auto window = glview->getWindow();
			if (!window) return;
            HWND hWnd = glfwGetWin32Window(window);
            RECT rect;
            GetWindowRect(hWnd, &rect);
            int x = cmd.window_x() - (rect.right - rect.left);
            int y = cmd.window_y();
            SetWindowPos(hWnd, NULL, x, y, 0, 0, SWP_NOSIZE | SWP_NOACTIVATE | SWP_NOZORDER);
		} break;
		case maker::CMD__ClearViewer: clearScene(); break;
		case maker::CMD__EventToViewer: onCmd_EventToViewer(cmd); break;
		}
	}
}
void CMakerScene::updateKeyEvents(float delta)
{
	if (m_key_map.empty()) return;

	for (auto i = m_key_map.begin(); i != m_key_map.end();)
	{
		KEY_INFO& key_info = i->second;
		updateKeyEvent(i->first, key_info);
		key_info.m_delta += delta;
		key_info.m_pressed = false;
		if (key_info.m_released && key_info.m_delta > 2.0f)
		{
			i = m_key_map.erase(i);
		}
		else
		{
			++i;
		}
	}
}
void CMakerScene::updateKeyEvent(cocos2d::EventKeyboard::KeyCode keyCode, const KEY_INFO& key_info)
{
	bool process_pressed_or_key_repeat = key_info.m_pressed || (key_info.m_pressing && key_info.m_delta > 0.5f);

	if (keyCode == EventKeyboard::KeyCode::KEY_LEFT_ARROW ||
		keyCode == EventKeyboard::KeyCode::KEY_RIGHT_ARROW ||
		keyCode == EventKeyboard::KeyCode::KEY_UP_ARROW ||
		keyCode == EventKeyboard::KeyCode::KEY_DOWN_ARROW)
	{
		if (!process_pressed_or_key_repeat) return;

		maker::CMD cmd;
		CCMDPipe::VAR v;
		CCMDPipe::getInstance()->initModify(cmd, CEntityMgr::INVALID_ID, "", "", v);

		if (!key_info.m_pressed) cmd.set_can_merge_prev_cmd(true);

		int dx = 0;
		int dy = 0;
		switch (keyCode)
		{
		case EventKeyboard::KeyCode::KEY_LEFT_ARROW: dx = -1; break;
		case EventKeyboard::KeyCode::KEY_RIGHT_ARROW: dx = 1; break;
		case EventKeyboard::KeyCode::KEY_UP_ARROW: dy = 1; break;
		case EventKeyboard::KeyCode::KEY_DOWN_ARROW: dy = -1; break;
		}

		for (auto& iter_node : m_node_bind) // 객체 외곽선 피킹
		{
			auto target = iter_node.second;
			if (!target) continue;
			if (target == this) continue;

			auto entity_helper = reinterpret_cast<CEntityHelper*>(target->getUserData());
			if (!entity_helper) continue;

			entity_helper->setParentSelected(false);
			if (!entity_helper->isSelected()) continue;

			auto current_entity = CEntityMgr::getInstance()->get(entity_helper->getEntityID());
			if (!current_entity) continue;

			auto node = current_entity->properties().node();
			entity_helper->setPickPos(Point(node.x(), node.y()));

			auto parent = target->getParent();
			while (parent)
			{
				auto parent_helper = reinterpret_cast<CEntityHelper*>(parent->getUserData());
				if (parent_helper)
				{
					if (parent_helper->isSelected())
					{
						entity_helper->setParentSelected(true);
						break;
					}
				}
				parent = parent->getParent();
			}
			if (entity_helper->isParentSelected()) continue;

			auto child = cmd.add_entities();
			if (!child) continue;

			child->set_id(entity_helper->getEntityID());

			auto properties = child->mutable_properties();

			std::string modify_info_x;
			std::string modify_info_y;

			v.m_type = CCMDPipe::VAR::TYPE::FLOAT;
			v.V.m_float = static_cast<int>(node.x()) + dx;
			CCMDPipe::getInstance()->initModify(properties, "Node", "x", v, modify_info_x);
			v.V.m_float = static_cast<int>(node.y()) + dy;
			CCMDPipe::getInstance()->initModify(properties, "Node", "y", v, modify_info_y);

			target->setPositionX(static_cast<int>(node.x()) + dx);
			target->setPositionY(static_cast<int>(node.y()) + dy);

			if (cmd.description().empty())
			{
				cmd.set_description("Modify '" + CCMDPipe::getNodeInfo(entity_helper->getEntityID()) + ", ...': " + modify_info_x + ", " + modify_info_y);
			}

			CCMDPipe::getInstance()->initBackup(cmd, *current_entity);
		}

		if (cmd.entities_size() > 0)
		{
			CCMDPipe::getInstance()->send(cmd);
		}

		return;
	}

	if (!key_info.m_pressed) return;

	auto on_ctrl = m_key_map.find(EventKeyboard::KeyCode::KEY_CTRL) != m_key_map.end() && m_key_map[EventKeyboard::KeyCode::KEY_CTRL].m_pressing;
	auto on_shift = m_key_map.find(EventKeyboard::KeyCode::KEY_SHIFT) != m_key_map.end() && m_key_map[EventKeyboard::KeyCode::KEY_SHIFT].m_pressing;

	maker::CMD event_cmd;
	if (on_ctrl)
	{
		switch (keyCode)
		{
		case EventKeyboard::KeyCode::KEY_Z:
			if (on_shift) CCMDPipe::initRedo(event_cmd);
			else CCMDPipe::initUndo(event_cmd);
			break;
        case EventKeyboard::KeyCode::KEY_Y: CCMDPipe::initRedo(event_cmd); break;
		case EventKeyboard::KeyCode::KEY_C: CCMDPipe::initEventToTool(event_cmd, maker::EVENT__Copy); break;
		case EventKeyboard::KeyCode::KEY_X: CCMDPipe::initEventToTool(event_cmd, maker::EVENT__Cut); break;
		case EventKeyboard::KeyCode::KEY_V: CCMDPipe::initEventToTool(event_cmd, maker::EVENT__Paste); break;
		case EventKeyboard::KeyCode::KEY_S:
			if (on_shift) CCMDPipe::initEventToTool(event_cmd, maker::EVENT__SaveAs);
			else CCMDPipe::initEventToTool(event_cmd, maker::EVENT__Save);
			break;
		case EventKeyboard::KeyCode::KEY_O: CCMDPipe::initEventToTool(event_cmd, maker::EVENT__Open); break;
		case EventKeyboard::KeyCode::KEY_N: CCMDPipe::initEventToTool(event_cmd, maker::EVENT__Close); break;
		case EventKeyboard::KeyCode::KEY_G: _grid->updateOpacity(); break;
		}
	}
	else
	{
		switch (keyCode)
		{
		case EventKeyboard::KeyCode::KEY_ESCAPE:
			CCMDPipe::getInstance()->initSelect(event_cmd, CEntityMgr::INVALID_ID);
			break;
		case EventKeyboard::KeyCode::KEY_DELETE:
			CCMDPipe::initEventToTool(event_cmd, maker::EVENT__Remove);
			break;
		case EventKeyboard::KeyCode::KEY_F2:
			CCMDPipe::initEventToTool(event_cmd, maker::EVENT__SpecResolution);
			break;
        case EventKeyboard::KeyCode::KEY_F3:
            CCMDPipe::initEventToTool(event_cmd, maker::EVENT__ToggleDisplayStats);
            break;
        case EventKeyboard::KeyCode::KEY_F5:
			CCMDPipe::initEventToTool(event_cmd, maker::EVENT__ReopenView);
			break;
		case EventKeyboard::KeyCode::KEY_TAB:
			//tab키 해상도 변경 사용 안함
            //if (on_shift) CCMDPipe::initEventToTool(event_cmd, maker::EVENT__PrevResolution);
			//else CCMDPipe::initEventToTool(event_cmd, maker::EVENT__NextResolution);
            break;
		case EventKeyboard::KeyCode::KEY_GRAVE:
			CCMDPipe::initEventToTool(event_cmd, maker::EVENT__ConfResolution);
			break;
		case EventKeyboard::KeyCode::KEY_G:
            _grid->invertShow();
            break;
		case EventKeyboard::KeyCode::KEY_V:
            CCMDPipe::initEventToTool(event_cmd, maker::EVENT__ToggleVisible);
            break;
		}
	}

	if (event_cmd.id() != CCMDPipe::INVALID_ID)
	{
		CCMDPipe::getInstance()->send(event_cmd);
	}
}

void CMakerScene::onCmd_Create(const maker::CMD& cmd)
{
	bool is_only_apply = cmd.type() == maker::CMD__ApplyToViewer;

	for (auto& entity : cmd.entities())
	{
		auto node = onCmd_Create(entity.id(), entity.parent_id(), entity.properties(), is_only_apply);
		if (!node) continue;
		
		if(entity.has_dest_id())
		{
			onCmd_Move(entity.id(), entity.parent_id(), entity.dest_id(), entity.dest_parent_id());
		}

		if (entity.children_size() > 0)
		{
			appendChildren(node, entity.children(), is_only_apply);
		}
	}

	dumpNodes(this);
}
cocos2d::Node* CMakerScene::onCmd_Create(CEntityMgr::ID entity_id, CEntityMgr::ID parent_id, const maker::Properties& properties, bool is_only_apply)
{
	Node* parent = m_root;
	auto iter_parent = m_node_bind.find(parent_id);
	if (iter_parent != m_node_bind.end())
	{
		parent = iter_parent->second;
	}
	if (m_node_bind.find(entity_id) != m_node_bind.end())
	{
		CCLOG("%s - already exist node [%lld] in m_node_bind", __FUNCTION__, entity_id);
		return nullptr;
	}
	return onCmd_Create(parent, entity_id, properties, is_only_apply);
}
cocos2d::Node* CMakerScene::onCmd_Create(cocos2d::Node* parent, CEntityMgr::ID entity_id, const maker::Properties& properties, bool is_only_apply)
{
	if (!parent) return nullptr;

	if (properties.type() == maker::ENTITY__SocketNode)
	{
		auto visual = dynamic_cast<AzVRP*>(parent);
		if (visual)
		{
			return visual->getSocketNode(properties.socket_node().socket_name());
		}
	}

    bool isSizeToContent = false;

	Node* node = nullptr;
	switch (properties.type())
	{
    case maker::ENTITY__Node: node = Node::create(); break;
    case maker::ENTITY__ClippingNode: node = ClippingNode::create(); break;
	case maker::ENTITY__LayerColor: node = LayerColor::create(); break;
	case maker::ENTITY__LayerGradient: node = LayerGradient::create(); break;
	case maker::ENTITY__LabelSystemFont:
		node = Label::create();
        isSizeToContent = true;
		if (!is_only_apply)
		{
			const_cast<maker::Properties&>(properties).mutable_label_syatem_font()->set_font_name(g_prevLabelSystemFont_name);
			const_cast<maker::Properties&>(properties).mutable_label_syatem_font()->set_font_size(g_prevLabelSystemFont_size);
		}
		break;
	case maker::ENTITY__LabelTTF:
		node = Label::create();
        isSizeToContent = true;
		if (!is_only_apply)
		{
			const_cast<maker::Properties&>(properties).mutable_label_ttf()->mutable_font_name()->set_path(g_prevLabelTTF_name);
			const_cast<maker::Properties&>(properties).mutable_label_ttf()->set_font_size(g_prevLabelTTF_size);
		}
		break;
    /*
    case maker::ENTITY__LabelBMFont:
        node = Label::create();
        if (!properties.label_bmfont().font_name().path().empty())
        {
            auto label = dynamic_cast<Label*>(node);
            label->setBMFontFilePath(properties.label_bmfont().font_name().path());
        }
        if (!properties.label_bmfont().text().empty())
        {
            auto label = dynamic_cast<Label*>(node);
            label->setString(properties.label_bmfont().text());
        }
        break;
    */
	case maker::ENTITY__TextFieldTTF:
		node = TextFieldTTF::textFieldWithPlaceHolder(properties.text_field_ttf().text(), g_prevLabelTTF_name, g_prevLabelTTF_size);
        isSizeToContent = true;
		if (!is_only_apply)
		{
			const_cast<maker::Properties&>(properties).mutable_text_field_ttf()->mutable_font_name()->set_path(g_prevLabelTTF_name);
			const_cast<maker::Properties&>(properties).mutable_text_field_ttf()->set_font_size(g_prevLabelTTF_size);
		}
		break;
    case maker::ENTITY__EditBox: node = EditBox::create(Size(1, 1), Scale9Sprite::create(), nullptr, nullptr); break;
    case maker::ENTITY__TableView: node = TableView::create(new SampleTableViewDataSource, Size(1, 1)); break;
    case maker::ENTITY__RotatePlate: node = RotatePlate::create(1.0f, 1.0f, 1.0f, 1.0f, 0); break;
    case maker::ENTITY__Menu: node = Menu::create(); break;
    case maker::ENTITY__Button: node = MenuItemImage::create(); break;
    case maker::ENTITY__Sprite: node = Sprite::create(); break;
    case maker::ENTITY__Scale9Sprite: node = Scale9Sprite::create(); break;
    case maker::ENTITY__ProgressTimer: node = ProgressTimer::create(Sprite::create()); break;
	case maker::ENTITY__Visual: node = AzVRP::create(); break;
    case maker::ENTITY__Particle: node = ParticleSystemQuad::create(); break;
	}

	if (node == nullptr) return nullptr;

	if (_edit_root == nullptr)
	{
		_edit_root = node;
		node->setTag(EDIT_ROOT_TAG);
	}
	else
	{
		node->setTag(ENTITY_TAG);
	}

	auto entity_helper = new CEntityHelper(node, entity_id, properties.type());
	node->setUserData(entity_helper);

	parent->addChild(node);

	m_node_bind.insert(TYPE_NODE_BIND_MAP::value_type(entity_id, node));

    onCmd_Modify(entity_id, properties, true);

    if (!is_only_apply)
	{
        switch (properties.type())
        {
        case maker::ENTITY__EditBox:
            node->setNormalSize(Size(200, 50));
            break;
        case maker::ENTITY__TableView:
            node->setNormalSize(Size(200, 200));
            break;
        case maker::ENTITY__Sprite:
        case maker::ENTITY__ProgressTimer:
            node->setNormalSize(Size(100, 100));
            break;
        }

        if (isSizeToContent)
        {
            node->updateSizeToContent();
        }

		applyToTool_ContentSize(entity_id, node);

        updateViewSizeInTool(entity_id, node);
        updateDimensionSizeInTool(entity_id, node);
        updateRadiusSizeInTool(entity_id, node);
    }

	return node;
}
void CMakerScene::appendChildren(cocos2d::Node* parent, const ::google::protobuf::RepeatedPtrField< ::maker::Entity >& entities, bool is_only_apply)
{
	if (!parent) return;

	for (auto& entity : entities)
	{
		auto node = onCmd_Create(parent, entity.id(), entity.properties(), is_only_apply);

		if (entity.children_size() > 0)
		{
			appendChildren(node, entity.children(), is_only_apply);
		}
	}
}
void CMakerScene::onCmd_Remove(const maker::CMD& cmd)
{
	for (auto& entity : cmd.entities())
	{
		Node* parent = this;
		auto iter_parent = m_node_bind.find(entity.parent_id());
		if (iter_parent != m_node_bind.end())
		{
			parent = iter_parent->second;
		}

		Node* node = nullptr;
		auto iter = m_node_bind.find(entity.id());
		if (iter == m_node_bind.end()) return;

		node = iter->second;

		auto& entities = parent->getChildren();
		if (!entities.contains(node)) return;

		removeAllChildrenNodeAtNodeBindMap(node);

		parent->removeChild(node, false);
	}
}
void CMakerScene::removeAllChildrenNodeAtNodeBindMap(Node* node)
{
	if (!node) return;

	auto entity_helper = reinterpret_cast<CEntityHelper*>(node->getUserData());
	if (!entity_helper) return;

	auto iter = m_node_bind.find(entity_helper->getEntityID());
	if (iter != m_node_bind.end())
	{
		m_node_bind.erase(iter);
	}

	auto& entities = node->getChildren();
	for (auto child = entities.begin(); child != entities.end(); ++child)
	{
		removeAllChildrenNodeAtNodeBindMap(*child);
	}
}
void CMakerScene::onCmd_Move(const maker::CMD& cmd)
{
	for (auto& entity : cmd.entities())
	{
		onCmd_Move(entity.id(), entity.parent_id(), entity.dest_id(), entity.dest_parent_id());
	}
}
void CMakerScene::onCmd_Move(CEntityMgr::ID entity_id, CEntityMgr::ID parent_id, CEntityMgr::ID dest_id, CEntityMgr::ID dest_parent_id)
{
	auto iter_node = m_node_bind.find(entity_id);
	if (iter_node == m_node_bind.end())
	{
		CCLOG("%s - can't find node [%lld]", __FUNCTION__, entity_id);
		return;
	}

	Node* parent = this;
	auto iter_parent = m_node_bind.find(parent_id);
	if (iter_parent != m_node_bind.end())
	{
		parent = iter_parent->second;
	}

	Node* dest_parent = this;
	auto iter_dest_parent = m_node_bind.find(dest_parent_id);
	if (iter_dest_parent != m_node_bind.end())
	{
		dest_parent = iter_dest_parent->second;
	}

	Node* node = iter_node->second;

	auto& children = parent->getChildren();
	if (!children.contains(node)) return;

	node->retain();
	{
		auto pos = node->getPosition();
		pos = node->convertToWorldSpace(pos);

		parent->removeChild(node, false);

		auto iter_dest = m_node_bind.find(dest_id);
		auto& dest_children = dest_parent->getChildren();
		if (iter_dest == m_node_bind.end())
		{
			if (dest_children.size() > 0)
			{
				bool inserted = false;
				int i = 0;
				for (auto& child : dest_children)
				{
					if (child->getTag() == ENTITY_TAG)
					{
						inserted = true;
						dest_children.insert(i, node);
						break;
					}
					++i;
				}
				if (!inserted)
				{
					dest_children.pushBack(node);
				}
			}
			else
			{
				dest_children.insert(0, node);
			}
		}
		else
		{
			Node* dest = iter_dest->second;

			int i = 0;
			for (auto& child : dest_children)
			{
				++i;
				if (child == dest)
				{
					dest_children.insert(i, node);
					break;
				}
			}
		}

		int i = 0;
		for (auto& child : dest_children) // 정렬 순서 정리
		{
			child->setOrderOfArrival(++i);
		}

		node->setUpdateTransform();
		node->setParent(dest_parent);
		node->onEnter();

		pos = node->convertToNodeSpace(pos);
		node->setPosition(pos);

		applyToTool_Position(entity_id, node);
	}
	node->release();

	dest_parent->sortAllChildren();

	dumpNodes(this);
}
void CMakerScene::onCmd_Modify(const maker::CMD& cmd)
{
	for (auto& entity : cmd.entities())
	{
		onCmd_Modify(entity.id(), entity.properties(), false);
	}
}
void CMakerScene::onCmd_Modify(CEntityMgr::ID entity_id, const maker::Properties& properties, bool is_only_apply)
{
	auto iter_node = m_node_bind.find(entity_id);
	if (iter_node == m_node_bind.end())
	{
		CCLOG("%s - can't find node [%lld]", __FUNCTION__, entity_id);
		return;
	}

	Node* node = iter_node->second;
	if (!node) return;

	auto desc = properties.GetDescriptor();
	auto reflect = properties.GetReflection();
	if (!desc || !reflect) return;

	// setUpdateChildrenTransform 함수를 콜해야 자식 node까지 정상적으로 위치 및 크기가 바뀐다
	node->setUpdateChildrenTransform();

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;
		if (field->type() != ::google::protobuf::FieldDescriptor::TYPE_MESSAGE) continue;

		if (!reflect->HasField(properties, field)) continue;

		const std::string& field_type = field->message_type()->name();
		if (field_type == "Node") apply(entity_id, node, reflect->GetMessage(properties, field), is_only_apply);
		else if (field_type == "ClippingNode") apply(entity_id, dynamic_cast<ClippingNode*>(node), reflect->GetMessage(properties, field));
		else if (field_type == "LayerColor") apply(entity_id, dynamic_cast<LayerColor*>(node), reflect->GetMessage(properties, field));
		else if (field_type == "LayerGradient") apply(entity_id, dynamic_cast<LayerGradient*>(node), reflect->GetMessage(properties, field));
		else if (field_type == "LabelSystemFont") apply(entity_id, dynamic_cast<Label*>(node), reflect->GetMessage(properties, field), is_only_apply);
		else if (field_type == "LabelTTF") apply(entity_id, dynamic_cast<Label*>(node), reflect->GetMessage(properties, field), is_only_apply);
		else if (field_type == "LabelBMFont") apply(entity_id, dynamic_cast<Label*>(node), reflect->GetMessage(properties, field), is_only_apply);
        else if (field_type == "EditBox") apply(entity_id, dynamic_cast<EditBox*>(node), reflect->GetMessage(properties, field), is_only_apply);
		else if (field_type == "TextFieldTTF") apply(entity_id, dynamic_cast<TextFieldTTF*>(node), reflect->GetMessage(properties, field), is_only_apply);
		else if (field_type == "Button") apply(entity_id, dynamic_cast<MenuItemImage*>(node), reflect->GetMessage(properties, field));
		else if (field_type == "Sprite") apply(entity_id, dynamic_cast<Sprite*>(node), reflect->GetMessage(properties, field));
		else if (field_type == "TableView") apply(entity_id, dynamic_cast<TableView*>(node), reflect->GetMessage(properties, field), is_only_apply);
		else if (field_type == "Scale9Sprite") apply(entity_id, dynamic_cast<Scale9Sprite*>(node), reflect->GetMessage(properties, field));
		else if (field_type == "ProgressTimer") apply(entity_id, dynamic_cast<ProgressTimer*>(node), reflect->GetMessage(properties, field));
		else if (field_type == "Guage") apply(entity_id, dynamic_cast<ProgressTimer*>(node), reflect->GetMessage(properties, field));
		else if (field_type == "Visual") apply(entity_id, dynamic_cast<AzVRP*>(node), reflect->GetMessage(properties, field));
		else if (field_type == "Particle") apply(entity_id, dynamic_cast<ParticleSystemQuad*>(node), reflect->GetMessage(properties, field));
        else if (field_type == "RotatePlate") apply(entity_id, dynamic_cast<RotatePlate*>(node), reflect->GetMessage(properties, field));
		else
		{
			CCLOG("%s - unknown field [%s]", __FUNCTION__, field_type.c_str());
			return;
		}
	}
}
void CMakerScene::onCmd_SizeToContent(const maker::CMD& cmd)
{
    for (auto& entity : cmd.entities())
    {
        auto entity_id = entity.id();
        auto iter_node = m_node_bind.find(entity_id);
        if (iter_node == m_node_bind.end())
        {
            CCLOG("%s - can't find node [%lld]", __FUNCTION__, entity_id);
            return;
        }

        Node* node = iter_node->second;
        if (!node) return;

        auto aEntity = CEntityMgr::getInstance()->get(entity_id);

        if (aEntity->properties().type() == maker::ENTITY__Button)
        {
            auto button = dynamic_cast<MenuItemImage*>(node);
            auto normalImage = button->getNormalImage();
            if (normalImage)
            {
                Size size = button->getNormalImageSize();
                button->setNormalSize(size);
                applyToTool_ContentSize(entity_id, button);
            }
        }
        else if (aEntity->properties().type() == maker::ENTITY__LabelTTF ||
                 aEntity->properties().type() == maker::ENTITY__LabelSystemFont)
        {
            node->updateSizeToContent();
            applyToTool_ContentSize(entity_id, node);
            updateDimensionSizeInTool(entity_id, node);
        }
        else if (aEntity->properties().type() == maker::ENTITY__Sprite)
        {
            auto sprite = dynamic_cast<Sprite*>(node);
            auto rect = sprite->getTextureRect();
            sprite->setNormalSize(rect.size);
            applyToTool_ContentSize(entity_id, sprite);
        }
        else if (aEntity->properties().type() == maker::ENTITY__Scale9Sprite)
        {
            auto scale9sprite = dynamic_cast<Scale9Sprite*>(node);
            Size size = scale9sprite->getOriginalSize();
            scale9sprite->setCapInsets(Rect(0, 0, size.width, size.height));
            updateCapInsetsInTool(entity_id, node);
        }
    }
}
void CMakerScene::onCmd_SelectOne(const maker::CMD& cmd)
{
	clearSelectedFlag();

	onCmd_SelectAppend(cmd);
}
void CMakerScene::onCmd_SelectAppend(const maker::CMD& cmd)
{
	for (auto& entity : cmd.entities())
	{
		auto entity_id = entity.id();
		auto iter_node = m_node_bind.find(entity_id);
		if (iter_node == m_node_bind.end())
		{
			CCLOG("%s - can't find node [%lld]", __FUNCTION__, entity_id);
			return;
		}

		Node* node = iter_node->second;
		if (!node) return;

		auto entity_helper = reinterpret_cast<CEntityHelper*>(node->getUserData());
		if (!entity_helper) return;

		entity_helper->setSelected(!entity_helper->isSelected());

		if (entity_helper->isSelected())
		{
			auto visual = dynamic_cast<AzVRP*>(node);
			if (visual)
			{
				applyToTool(entity_id, visual);
			}

			initEditRoot(getEditRoot(node));
		}
	}
}
void CMakerScene::onCmd_SelectBoxAppend(const maker::CMD& cmd)
{
	clearSelectedFlag();

	for (auto& child : cmd.entities())
	{
		auto entity_id = child.id();
		auto iter_node = m_node_bind.find(entity_id);
		if (iter_node == m_node_bind.end()) continue;

		Node* node = iter_node->second;
		if (!node) continue;

		auto entity_helper = reinterpret_cast<CEntityHelper*>(node->getUserData());
		if (!entity_helper) continue;
		
		entity_helper->setSelected(true);
	}
}
void CMakerScene::onCmd_EventToViewer(const maker::CMD& cmd)
{
	switch (cmd.viewer_event_id())
	{
	case maker::VIEWER_EVENT__GridOnOff: _grid->invertShow(); break;
	case maker::VIEWER_EVENT__GridOpacity: _grid->updateOpacity(); break;
	case maker::VIEWER_EVENT__ResetZoom: _zoom_step = 0; updateZoom(1.0f);  break;
	case maker::VIEWER_EVENT__ResetScroll: m_zoom_center_pos = m_root->getNormalSize() / 2 / m_root->getScale(); m_root->setPosition(0, 0); break;
	}
}

cocos2d::Node* CMakerScene::getEditRoot(cocos2d::Node* node)
{
	while (node != this && node != nullptr)
	{
		auto parent = node->getParent();
		if (parent == m_root) return node;
		node = parent;
	}
	return nullptr;
}
void CMakerScene::initEditRoot(cocos2d::Node* node)
{
	_edit_root = node;
}

bool CMakerScene::GetColor(cocos2d::Color3B& color, const::google::protobuf::Message& msg)
{
	if (msg.GetDescriptor()->name() != "COLOR") return false;

	auto desc = msg.GetDescriptor();
	auto reflect = msg.GetReflection();
	if (!desc || !reflect) return false;

	int r = reflect->GetInt32(msg, desc->FindFieldByName("r"));
	int g = reflect->GetInt32(msg, desc->FindFieldByName("g"));
	int b = reflect->GetInt32(msg, desc->FindFieldByName("b"));

	color = Color3B(r, g, b);

	return true;
}
bool CMakerScene::GetFile(std::string& file_name, const::google::protobuf::Message& msg)
{
	if (!CEntityMgr::isFileProperty(msg.GetDescriptor()->name())) return false;

	auto desc = msg.GetDescriptor();
	auto reflect = msg.GetReflection();
	if (!desc || !reflect) return false;

	file_name = reflect->GetString(msg, desc->FindFieldByName("path"));

	return true;
}
bool CMakerScene::GetName(std::string& file_name, const::google::protobuf::Message& msg)
{
	if (!CEntityMgr::isEnumNameProperty(msg.GetDescriptor()->name())) return false;

	auto desc = msg.GetDescriptor();
	auto reflect = msg.GetReflection();
	if (!desc || !reflect) return false;

	file_name = reflect->GetString(msg, desc->FindFieldByName("name"));

	return true;
}

void CMakerScene::apply(CEntityMgr::ID entity_id, Node* node, const ::google::protobuf::Message& msg, bool is_only_apply)
{
	if (!node) return;

	auto entity_helper = reinterpret_cast<CEntityHelper*>(node->getUserData());
	if (!entity_helper) return;

	auto desc = msg.GetDescriptor();
	auto reflect = msg.GetReflection();
	if (!desc || !reflect) return;
	
	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;

		if (!reflect->HasField(msg, field)) continue;

		const std::string& field_name = field->name();
		if (field_name == "x")
		{
			float x = reflect->GetFloat(msg, field);
			node->setPositionX(x);
		}
		else if (field_name == "y")
		{
			float y = reflect->GetFloat(msg, field);
			node->setPositionY(y);
		}
		else if (field_name == "dock_point")
		{
			Point point = node->getDockPoint();
			Point old_point = point;
			switch (reflect->GetEnum(msg, field)->number())
			{
			case maker::DOCK__TOP_LEFT: point = Point(0.0f, 1.0f); break;
			case maker::DOCK__TOP_CENTER: point = Point(0.5f, 1.0f); break;
			case maker::DOCK__TOP_RIGHT: point = Point(1.0f, 1.0f); break;
			case maker::DOCK__MIDDLE_LEFT: point = Point(0.0f, 0.5f); break;
			case maker::DOCK__MIDDLE_CENTER: point = Point(0.5f, 0.5f); break;
			case maker::DOCK__MIDDLE_RIGHT: point = Point(1.0f, 0.5f); break;
			case maker::DOCK__BOTTOM_LEFT: point = Point(0.0f, 0.0f); break;
			case maker::DOCK__BOTTOM_CENTER: point = Point(0.5f, 0.0f); break;
			case maker::DOCK__BOTTOM_RIGHT: point = Point(1.0f, 0.0f); break;
			}

			if (is_only_apply)
			{
				node->setDockPoint(point);
			}
			else
			{
				auto dpoint = point - old_point;
				if (dpoint.x != 0 || dpoint.y != 0)
				{
					auto postion = node->getPosition();
					auto world_postion = node->convertToWorldSpace(postion);

					node->setDockPoint(point);

					auto new_postion = node->convertToNodeSpace(world_postion);
					node->setPosition(new_postion);

					applyToTool_Position(entity_id, node);
				}
			}
		}
		else if (field_name == "anchor_point")
		{
			Point point = node->getAnchorPoint();
			Point old_point = point;
			switch (reflect->GetEnum(msg, field)->number())
			{
			case maker::ANCHOR__TOP_LEFT: point = Point(0.0f, 1.0f); break;
			case maker::ANCHOR__TOP_CENTER: point = Point(0.5f, 1.0f); break;
			case maker::ANCHOR__TOP_RIGHT: point = Point(1.0f, 1.0f); break;
			case maker::ANCHOR__MIDDLE_LEFT: point = Point(0.0f, 0.5f); break;
			case maker::ANCHOR__MIDDLE_CENTER: point = Point(0.5f, 0.5f); break;
			case maker::ANCHOR__MIDDLE_RIGHT: point = Point(1.0f, 0.5f); break;
			case maker::ANCHOR__BOTTOM_LEFT: point = Point(0.0f, 0.0f); break;
			case maker::ANCHOR__BOTTOM_CENTER: point = Point(0.5f, 0.0f); break;
			case maker::ANCHOR__BOTTOM_RIGHT: point = Point(1.0f, 0.0f); break;
			}
			node->setAnchorPoint(point);

			if (!is_only_apply && !node->isIgnoreAnchorPointForPosition())
			{
				auto dpoint = point - old_point;
				if (dpoint.x != 0 || dpoint.y != 0)
				{
					auto size = node->getNormalSize();
					auto postion = node->getPosition();
					postion.x += dpoint.x * size.width;
					postion.y += dpoint.y * size.height;
					node->setPosition(postion);

					applyToTool_Position(entity_id, node);
				}
			}

			auto scale9sprite = dynamic_cast<Scale9Sprite*>(node);
			if (scale9sprite)
			{
				scale9sprite->setCapInsets(scale9sprite->getCapInsets());
			}
		}
        else if (field_name == "relative_size_type")
        {
            int type = reflect->GetEnum(msg, field)->number();
			// @jslors 20.11.23 타입 변경시 수치도 갱신
            node->setRelativeSizeType(type, true);
			applyToTool_ContentSize(entity_id, node);
        }
		else if (field_name == "rel_width")
		{
			if (node->getRelativeSizeType() == kRelativeSizeBoth ||
                node->getRelativeSizeType() == kRelativeSizeHorizontal)
            {
				float width = static_cast<float>(reflect->GetInt32(msg, field));
				node->setRelativeSizeWidth(width, true);

                if (!is_only_apply)
                {
                    updateViewSizeInTool(entity_id, node);
                    updateDimensionSizeInTool(entity_id, node);
                    updateRadiusSizeInTool(entity_id, node);
                }

				Size size = node->getNormalSize();
                updateContentSizeWidthInTool(entity_id, node, size.width);
				updateStencil(dynamic_cast<ClippingNode*>(node)); 

				// @jslors 2020.12.10 화면 크기 변경시 msg에 남아있는 width 수치가 이 후에 반영되어 relative_size를 덮어버리는 현상 수정
				auto width_field = desc->FindFieldByName("width");
				auto no_const_msg = const_cast<::google::protobuf::Message*>(&msg);
				reflect->SetInt32(no_const_msg, width_field, size.width);
			}
		}
		else if (field_name == "rel_height")
		{
			if (node->getRelativeSizeType() == kRelativeSizeBoth ||
                node->getRelativeSizeType() == kRelativeSizeVertical)
            {
                float height = static_cast<float>(reflect->GetInt32(msg, field));
				node->setRelativeSizeHeight(height, true);

                if (!is_only_apply)
                {
                    updateViewSizeInTool(entity_id, node);
                    updateDimensionSizeInTool(entity_id, node);
                    updateRadiusSizeInTool(entity_id, node);
                }

				Size size = node->getNormalSize();
                updateContentSizeHeightInTool(entity_id, node, size.height);

				updateStencil(dynamic_cast<ClippingNode*>(node));

				// @jslors 2020.12.10 화면 크기 변경시 msg에 남아있는 width 수치가 이 후에 반영되어 relative_size를 덮어버리는 현상 수정
				auto height_field = desc->FindFieldByName("height");
				auto no_const_msg = const_cast<::google::protobuf::Message*>(&msg);
				reflect->SetInt32(no_const_msg, height_field, size.height);
			}
		}
        else if (field_name == "width")
        {
            if (node->getRelativeSizeType() == kRelativeSizeNone || 
				node->getRelativeSizeType() == kRelativeSizeVertical ||
				node->getRelativeSizeType() == kRelativeSizeHorizontal)
            {
                Size size = node->getNormalSize();
                size.width = static_cast<float>(reflect->GetInt32(msg, field));
                size.width = size.width < 0 ? 0 : size.width;
                node->setNormalSize(size);

                if (!is_only_apply)
                {
                    updateViewSizeInTool(entity_id, node);
                    updateDimensionSizeInTool(entity_id, node);
                    updateRadiusSizeInTool(entity_id, node);
					// @jslors 20.11.23 버튼 크기 변경시, 버튼 이미지 위치 갱신
					updateButtonImagePos(node);
                }

                updateRelativeSizeWidthInTool(entity_id, node, size.width);
				// @jslors 20.11.23 .ui 파일 로드 했을때 내 크기 표기 안 되는 현상 수정
				updateContentSizeWidthInTool(entity_id, node, size.width);
				updateStencil(dynamic_cast<ClippingNode*>(node));
            }
			else if ((node->getRelativeSizeType() == kRelativeSizeBoth) && !is_only_apply)
			{
				Size size = node->getNormalSize();
				size.width = static_cast<float>(reflect->GetInt32(msg, field));
				size.width = size.width < 0 ? 0 : size.width;
				node->setNormalSize(size);
				updateRelativeSizeWidthInTool(entity_id, node, size.width);
				updateStencil(dynamic_cast<ClippingNode*>(node));
			}
        }
        else if (field_name == "height")
        {
            if (node->getRelativeSizeType() == kRelativeSizeNone ||
				node->getRelativeSizeType() == kRelativeSizeVertical ||
                node->getRelativeSizeType() == kRelativeSizeHorizontal)
            {
                Size size = node->getNormalSize();
                size.height = static_cast<float>(reflect->GetInt32(msg, field));
                size.height = size.height < 0 ? 0 : size.height;
                node->setNormalSize(size);

                if (!is_only_apply)
                {
                    updateViewSizeInTool(entity_id, node);
                    updateDimensionSizeInTool(entity_id, node);
                    updateRadiusSizeInTool(entity_id, node);
					// @jslors 20.11.23 버튼 크기 변경시, 버튼 이미지 위치 갱신
					updateButtonImagePos(node);
                }

                updateRelativeSizeHeightInTool(entity_id, node, size.height);
				// @jslors 20.11.23 .ui 파일 로드 했을때 내 크기 표기 안 되는 현상 수정
				updateContentSizeHeightInTool(entity_id, node, size.height);
				updateStencil(dynamic_cast<ClippingNode*>(node));
            }
			else if ((node->getRelativeSizeType() == kRelativeSizeBoth) & !is_only_apply)
			{
				Size size = node->getNormalSize();
				size.height = static_cast<float>(reflect->GetInt32(msg, field));
				size.height = size.height < 0 ? 0 : size.height;
				node->setNormalSize(size);
				updateRelativeSizeHeightInTool(entity_id, node, size.height);
				updateStencil(dynamic_cast<ClippingNode*>(node));
			}
        }
        else if (field_name == "scale_x") node->setScaleX(reflect->GetFloat(msg, field));
		else if (field_name == "scale_y") node->setScaleY(reflect->GetFloat(msg, field));
		else if (field_name == "skew_y") node->setSkewX(reflect->GetFloat(msg, field)); // @sgkim 2021.02.10 드빌M에서 사용하는 cocos2d-x 3.1.1과 드빌A, 드빌NEW에 사용하는 cocos2d-x 3.17.2 버전의 차이로 x,y가 반대로 적용됨
		else if (field_name == "skew_x") node->setSkewY(reflect->GetFloat(msg, field)); // @sgkim 2021.02.10 드빌M에서 사용하는 cocos2d-x 3.1.1과 드빌A, 드빌NEW에 사용하는 cocos2d-x 3.17.2 버전의 차이로 x,y가 반대로 적용됨
		else if (field_name == "rotation") node->setRotation(reflect->GetFloat(msg, field));
		else if (field_name == "visible") node->setVisible(reflect->GetBool(msg, field));
		else
		{
			CCLOG("%s - unknown field [%s]", __FUNCTION__, field_name.c_str());
		}
	}
}
void CMakerScene::apply(CEntityMgr::ID entity_id, cocos2d::ClippingNode* clipping_node, const ::google::protobuf::Message& msg)
{
	if (!clipping_node) return;

	auto entity_helper = reinterpret_cast<CEntityHelper*>(clipping_node->getUserData());
	if (!entity_helper) return;

	auto desc = msg.GetDescriptor();
	auto reflect = msg.GetReflection();
	if (!desc || !reflect) return;

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;

		if (!reflect->HasField(msg, field)) continue;

		const std::string& field_name = field->name();
		if (field_name == "stencil_type")
		{
			int stencil_type = reflect->GetEnum(msg, field)->number();
			entity_helper->setStencilType(stencil_type);
			updateStencil(clipping_node);
		}
		else if (field_name == "stencil_img") {
			std::string path;
			GetFile(path, reflect->GetMessage(msg, field));
			entity_helper->setStencilSpritePath(path);
			updateStencil(clipping_node);
		}
		else if (field_name == "alpha_threshold")
		{
			if (entity_helper->getStencilType() == 1) // CUSTOM
			{
				clipping_node->setAlphaThreshold(reflect->GetFloat(msg, field));
			}
			else
			{
				// UpdateStencil 에서 처리
			}
		}
		else if (field_name == "is_invert")
		{
			clipping_node->setInverted(reflect->GetBool(msg, field));
		}
		else
		{
			CCLOG("%s - unknown field [%s]", __FUNCTION__, field_name.c_str());
		}
	}
}
void CMakerScene::apply(CEntityMgr::ID entity_id, LayerColor* layer_color, const ::google::protobuf::Message& msg)
{
	if (!layer_color) return;

	auto desc = msg.GetDescriptor();
	auto reflect = msg.GetReflection();
	if (!desc || !reflect) return;

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;

		if (!reflect->HasField(msg, field)) continue;

		const std::string& field_name = field->name();
		if (field_name == "color")
		{
			Color3B color;
			auto& color_msg = reflect->GetMessage(msg, field);
			if (GetColor(color, color_msg))
			{
				layer_color->setColor(color);
			}
		}
		else if (field_name == "opacity") layer_color->setOpacity(reflect->GetInt32(msg, field));
		else if (field_name == "src_blend")
		{
			BlendFunc blend_func;
			blend_func = layer_color->getBlendFunc();
			blend_func.src = reflect->GetEnum(msg, field)->number();
			layer_color->setBlendFunc(blend_func);
		}
		else if (field_name == "dest_blend")
		{
			BlendFunc blend_func;
			blend_func = layer_color->getBlendFunc();
			blend_func.dst = reflect->GetEnum(msg, field)->number();
			layer_color->setBlendFunc(blend_func);
		}
		else
		{
			CCLOG("%s - unknown field [%s]", __FUNCTION__, field_name.c_str());
		}
	}
}
void CMakerScene::apply(CEntityMgr::ID entity_id, LayerGradient* layer_gradient, const ::google::protobuf::Message& msg)
{
	if (!layer_gradient) return;

	auto desc = msg.GetDescriptor();
	auto reflect = msg.GetReflection();
	if (!desc || !reflect) return;

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;

		if (!reflect->HasField(msg, field)) continue;

		const std::string& field_name = field->name();
		if (field_name == "color")
		{
			Color3B color;
			auto& color_msg = reflect->GetMessage(msg, field);
			if (GetColor(color, color_msg))
			{
				layer_gradient->setColor(color);
			}
		}
		else if (field_name == "opacity") layer_gradient->setOpacity(reflect->GetInt32(msg, field));
		else if (field_name == "src_blend")
		{
			BlendFunc blend_func;
			blend_func = layer_gradient->getBlendFunc();
			blend_func.src = reflect->GetEnum(msg, field)->number();
			layer_gradient->setBlendFunc(blend_func);
		}
		else if (field_name == "dest_blend")
		{
			BlendFunc blend_func;
			blend_func = layer_gradient->getBlendFunc();
			blend_func.dst = reflect->GetEnum(msg, field)->number();
			layer_gradient->setBlendFunc(blend_func);
		}
		else if (field_name == "start_color")
		{
			Color3B color;
			auto& color_msg = reflect->GetMessage(msg, field);
			if (GetColor(color, color_msg))
			{
				layer_gradient->setStartColor(color);
			}
		}
		else if (field_name == "end_color")
		{
			Color3B color;
			auto& color_msg = reflect->GetMessage(msg, field);
			if (GetColor(color, color_msg))
			{
				layer_gradient->setEndColor(color);
			}
		}
		else if (field_name == "start_opacity") layer_gradient->setStartOpacity(reflect->GetInt32(msg, field));
		else if (field_name == "end_opacity") layer_gradient->setEndOpacity(reflect->GetInt32(msg, field));
		else if (field_name == "angle")
		{
			float radian = CC_DEGREES_TO_RADIANS(reflect->GetFloat(msg, field));
			Point along_vector(Point::forAngle(radian));
			layer_gradient->setVector(along_vector);
		}
		else
		{
			CCLOG("%s - unknown field [%s]", __FUNCTION__, field_name.c_str());
		}
	}
}
void CMakerScene::apply(CEntityMgr::ID entity_id, Label* label, const ::google::protobuf::Message& msg, bool is_only_apply)
{
	if (!label) return;

	auto entity_helper = reinterpret_cast<CEntityHelper*>(label->getUserData());
	if (!entity_helper) return;

	auto desc = msg.GetDescriptor();
	auto reflect = msg.GetReflection();
	if (!desc || !reflect) return;

	auto type_name = desc->name();

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;

		if (!reflect->HasField(msg, field)) continue;

		const std::string& field_name = field->name();
		if (field_name == "font_name")
		{
			if (type_name == "LabelSystemFont")
			{
				auto font_name = reflect->GetString(msg, field);
				label->setSystemFontName(font_name);

				if (!font_name.empty())
				{
					g_prevLabelSystemFont_name = font_name;
				}
			}
			else if (type_name == "LabelTTF")
			{
				std::string path;
				if (GetFile(path, reflect->GetMessage(msg, field)))
				{
					entity_helper->getTTFConfig().fontFilePath = path;
					label->setTTFConfig(entity_helper->getTTFConfig());

					if (!path.empty())
					{
						g_prevLabelTTF_name = path;
					}

                    if (entity_helper->isOutline())
                    {
                        label->enableOutline(entity_helper->getOutlineColor(), entity_helper->getOutlineSize());
                    }
				}
			}
			else if (type_name == "LabelBMFont")
			{
				std::string path;
				if (GetFile(path, reflect->GetMessage(msg, field)))
				{
					label->setBMFontFilePath(path);
				}
			}
		}
		else if (field_name == "font_size")
		{
			int font_size = reflect->GetInt32(msg, field);
			if (type_name == "LabelSystemFont")
			{
				label->setSystemFontSize(font_size);

				g_prevLabelSystemFont_size = font_size;
			}
			else if (type_name == "LabelTTF")
			{
				entity_helper->getTTFConfig().fontSize = font_size;
				label->setTTFConfig(entity_helper->getTTFConfig());
				if (entity_helper->isOutline())
				{
					label->enableOutline(entity_helper->getOutlineColor(), entity_helper->getOutlineSize());
				}

				g_prevLabelTTF_size = font_size;
			}
			else if (type_name == "LabelBMFont")
			{
			}
		}
        else if (field_name == "text")
        {
            //label->setString(reflect->GetString(msg, field));
            std::string text = reflect->GetString(msg, field);
            label->setString(ReplaceString(text, "\\n", "\n"));
        }
		else if (field_name == "h_alignment")
		{
			label->setHorizontalAlignment(static_cast<TextHAlignment>(reflect->GetEnum(msg, field)->number()));
		}
		else if (field_name == "v_alignment")
		{
			label->setVerticalAlignment(static_cast<TextVAlignment>(reflect->GetEnum(msg, field)->number()));
		}
		else if (field_name == "color")
		{
			Color3B color;
			auto& color_msg = reflect->GetMessage(msg, field);
			if (GetColor(color, color_msg))
			{
				if (type_name == "LabelSystemFont")
				{
					label->setColor(color);
				}
				else if (type_name == "LabelTTF")
				{
					Color4B text_color(color);
					text_color.a = entity_helper->getTextColor().a;
					entity_helper->setTextColor(text_color);
					label->setTextColor(text_color);
				}
				else if (type_name == "LabelBMFont")
				{
					label->setColor(color);
				}
			}
		}
		else if (field_name == "opacity")
		{
			Color4B text_color(entity_helper->getTextColor());
			text_color.a = reflect->GetInt32(msg, field);
			entity_helper->setTextColor(text_color);
			label->setTextColor(text_color);

			Color4B outline_color(entity_helper->getOutlineColor());;
			outline_color.a = text_color.a;
			entity_helper->setOutlineColor(outline_color);
		}
		else if (field_name == "dimension_width")
		{
			// @jslors 20.11.23 상대 크기가 지정 되어있다면
			// 텍스트로 만들어진 크기를 사용하지 않는다.
			if (kRelativeSizeNone == label->getRelativeSizeType() ||
				kRelativeSizeVertical == label->getRelativeSizeType())
			{
				Size size = label->getDimensions();
				size.width = static_cast<float>(reflect->GetInt32(msg, field));
				label->setDimensions(static_cast<unsigned int>(size.width), static_cast<unsigned int>(size.height));

				if (!is_only_apply)
				{
					updateContentSizeInTool(entity_id, label, size);
				}
			}
        }
		else if (field_name == "dimension_height")
		{
			// @jslors 20.11.23 상대 크기가 지정 되어있다면
			// 텍스트로 만들어진 크기를 사용하지 않는다.
			if (kRelativeSizeNone == label->getRelativeSizeType() ||
				kRelativeSizeHorizontal == label->getRelativeSizeType())
			{
				Size size = label->getDimensions();
				size.height = static_cast<float>(reflect->GetInt32(msg, field));
				label->setDimensions(static_cast<unsigned int>(size.width), static_cast<unsigned int>(size.height));

				if (!is_only_apply)
				{
					updateContentSizeInTool(entity_id, label, size);
				}
			}
        }
		else if (field_name == "letter_spacing")
		{
			float letter_spacing = reflect->GetFloat(msg, field);
			label->setAdditionalKerning(letter_spacing);
		}
		else if (field_name == "has_stroke")
		{
			entity_helper->enableOutline(reflect->GetBool(msg, field));
			if (entity_helper->isOutline())
			{
				label->enableOutline(entity_helper->getOutlineColor(), entity_helper->getOutlineSize());
			}
			else 
			{
				label->disableEffect();
				if (entity_helper->isShadow())
				{
					float shadow_distance = entity_helper->getShadowDistance();
					int shadow_direction = entity_helper->getShadowDirection();
					cocos2d::Size shadow_size = _setLabelShadow(shadow_distance, shadow_direction);
					label->enableShadow(entity_helper->getShadowColor(), shadow_size, 1);
				}
			}
		}
        else if (field_name == "stroke_type")
        {
            int strokeType = reflect->GetEnum(msg, field)->number();
            label->setStrokeType(strokeType);
        }
        else if (field_name == "stroke_detail_level")
        {
            int strokeDetailLevel = reflect->GetInt32(msg, field);
            label->setStrokeDetailLevel(strokeDetailLevel);
        }
        else if (field_name == "is_sharp_text")
        {
            bool isSharpText = reflect->GetBool(msg, field);
            label->setSharpTextInCustomStroke(isSharpText);
        }
        else if (field_name == "stroke_tickness")
		{
			float tickness = reflect->GetFloat(msg, field);
			entity_helper->setOutlineSize(tickness);
			if (entity_helper->isOutline())
			{
				label->enableOutline(entity_helper->getOutlineColor(), tickness);
			}
		}
		else if (field_name == "stroke_color")
		{
			Color3B color;
			auto& color_msg = reflect->GetMessage(msg, field);
			if (GetColor(color, color_msg))
			{
				Color4B color4 = Color4B(color);;
				color4.a = entity_helper->getTextColor().a;
				entity_helper->setOutlineColor(color4);
				if (entity_helper->isOutline())
				{
					label->enableOutline(color4, entity_helper->getOutlineSize());
				}
			}
		}
		else if (field_name == "has_shadow")
		{
			entity_helper->enableShadow(reflect->GetBool(msg, field));
			
			float shadow_distance = entity_helper->getShadowDistance();
			int shadow_direction = entity_helper->getShadowDirection();
			cocos2d::Size shadow_size = _setLabelShadow(shadow_distance, shadow_direction);

			if (entity_helper->isShadow())
			{
				label->enableShadow(entity_helper->getShadowColor(), shadow_size, 1);
			}
			else
			{
				label->disableEffect();
				if (entity_helper->isOutline())
				{
					label->enableOutline(entity_helper->getOutlineColor(), entity_helper->getOutlineSize());
				}
			}
		}
		else if (field_name == "shadow_direction")
		{
			float shadow_distance = entity_helper->getShadowDistance();
			int shadow_direction = reflect->GetEnum(msg, field)->number();
			cocos2d::Size shadow_size = _setLabelShadow(shadow_distance, shadow_direction);

			entity_helper->setShadowDirection(shadow_direction);
			if (entity_helper->isShadow())
			{
				label->enableShadow(entity_helper->getShadowColor(), shadow_size, 1);
			}
		}
		else if (field_name == "shadow_distance")
		{
			float shadow_distance = reflect->GetFloat(msg, field);
			int shadow_direction = entity_helper->getShadowDirection();
			cocos2d::Size shadow_size = _setLabelShadow(shadow_distance, shadow_direction);

			entity_helper->setShadowDistance(shadow_distance);
			if (entity_helper->isShadow())
			{
				label->enableShadow(entity_helper->getShadowColor(), shadow_size, 1);
			}
		}
		else if (field_name == "shadow_opacity")
		{
			int shadow_opacity = reflect->GetInt32(msg, field);

			float shadow_distance = entity_helper->getShadowDistance();
			int shadow_direction = entity_helper->getShadowDirection();
			cocos2d::Size shadow_size = _setLabelShadow(shadow_distance, shadow_direction);

			Color4B color4 = entity_helper->getShadowColor();
			color4.a = shadow_opacity;
			entity_helper->setShadowOpacity(shadow_opacity);
			entity_helper->setShadowColor(color4);

			if (entity_helper->isShadow())
			{
				label->enableShadow(color4, shadow_size, 1);
			}
		}
		else if (field_name == "shadow_color")
		{
			Color3B color;
			auto& color_msg = reflect->GetMessage(msg, field);
			if (GetColor(color, color_msg))
			{
				float shadow_distance = entity_helper->getShadowDistance();
				int shadow_direction = entity_helper->getShadowDirection();
				cocos2d::Size shadow_size = _setLabelShadow(shadow_distance, shadow_direction);

				Color4B color4 = Color4B(color);
				color4.a = entity_helper->getShadowOpacity();
				entity_helper->setShadowColor(color4);

				if (entity_helper->isShadow())
				{
					label->enableShadow(entity_helper->getShadowColor(), shadow_size, 1);
				}
			}
		}
		else if (field_name == "has_bold")
		{
			// @jslors 2021.06.17
			// bold 처리는 cocos2d-x 3.172에 있는 Label의 enableBold와 동일하게 처리
			entity_helper->enableBold(reflect->GetBool(msg, field));
			if (entity_helper->isBold())
			{
				label->enableShadow(Color4B::WHITE, Size(0.9, 0), 0);
				label->setAdditionalKerning(label->getAdditionalKerning() + 1);
			}
			else
			{
				label->disableEffect();
				label->setAdditionalKerning(label->getAdditionalKerning() - 1);
			}
		}
		else
		{
			CCLOG("%s - unknown field [%s]", __FUNCTION__, field_name.c_str());
		}
	}

	if (is_only_apply)
	{
		applyToTool_Label(entity_id, label, type_name);
	}
}

cocos2d::Size CMakerScene::_setLabelShadow(float distance, int direction)
{
	cocos2d::Size shadow_size;

	if (direction == 0)
	{
		shadow_size = cocos2d::Size(0, -distance);
	}
	else if (direction == 1)
	{
		shadow_size = cocos2d::Size(distance, -distance);
	}
	else if (direction == 2)
	{
		shadow_size = cocos2d::Size(-distance, -distance);
	}
    else if (direction == 3)
    {
        shadow_size = cocos2d::Size(0, distance);
    }

	return shadow_size;
}

void CMakerScene::apply(CEntityMgr::ID entity_id, cocos2d::extension::EditBox* edit_box, const ::google::protobuf::Message& msg, bool is_only_apply)
{
    if (!edit_box) return;

    auto entity_helper = reinterpret_cast<CEntityHelper*>(edit_box->getUserData());
    if (!entity_helper) return;

    auto desc = msg.GetDescriptor();
    auto reflect = msg.GetReflection();
    if (!desc || !reflect) return;

    for (int i = 0; i < desc->field_count(); ++i)
    {
        auto* field = desc->field(i);

        if (!field) continue;
        if (field->is_repeated()) continue;

        if (!reflect->HasField(msg, field)) continue;

        const std::string& field_name = field->name();
        if (field_name == "enable")
        {
            bool enable = reflect->GetBool(msg, field);
            edit_box->setEnabled(enable);
        }
        else if (field_name == "input_mode")
        {
            int inputMode = reflect->GetEnum(msg, field)->number();
            edit_box->setInputMode((EditBox::InputMode)inputMode);
        }
        else if (field_name == "input_flag")
        {
            int inputFlag = reflect->GetEnum(msg, field)->number();
            edit_box->setInputFlag((EditBox::InputFlag)inputFlag);
        }
        else if (field_name == "return_type")
        {
            int returnType = reflect->GetEnum(msg, field)->number();
            edit_box->setReturnType((EditBox::KeyboardReturnType)returnType);
        }
        else if (field_name == "max_length")
        {
            int length = reflect->GetInt32(msg, field);
            edit_box->setMaxLength(length);
        }
        else if (field_name == "text")
        {
            //edit_box->setText(reflect->GetString(msg, field).c_str());
            std::string text = reflect->GetString(msg, field);
            edit_box->setText(ReplaceString(text, "\\n", "\n").c_str());
        }
        else if (field_name == "font_name")
        {
            edit_box->setFontName(reflect->GetString(msg, field).c_str());
        }
        else if (field_name == "font_size")
        {
            int fontSize = reflect->GetInt32(msg, field);
            edit_box->setFontSize(fontSize);
        }
        else if (field_name == "font_color")
        {
            Color3B color;
            auto& colorMsg = reflect->GetMessage(msg, field);
            if (GetColor(color, colorMsg))
            {
                edit_box->setFontColor(color);
            }
        }
        else if (field_name == "placeholder")
        {
            edit_box->setPlaceHolder(reflect->GetString(msg, field).c_str());
        }
        else if (field_name == "placeholder_font_name")
        {
            edit_box->setPlaceholderFontName(reflect->GetString(msg, field).c_str());
        }
        else if (field_name == "placeholder_font_size")
        {
            int fontSize = reflect->GetInt32(msg, field);
            edit_box->setPlaceholderFontSize(fontSize);
        }
        else if (field_name == "placeholder_font_color")
        {
            Color3B color;
            auto& colorMsg = reflect->GetMessage(msg, field);
            if (GetColor(color, colorMsg))
            {
                edit_box->setPlaceholderFontColor(color);
            }
        }
        else if (field_name == "normal_bg")
        {
            std::string path;
            GetFile(path, reflect->GetMessage(msg, field));
            auto sprite = Scale9Sprite::create(path);
            edit_box->setBackgroundSpriteForState(sprite, Control::State::NORMAL);
        }
        else if (field_name == "pressed_bg")
        {
            std::string path;
            GetFile(path, reflect->GetMessage(msg, field));
            auto sprite = Scale9Sprite::create(path);
            edit_box->setBackgroundSpriteForState(sprite, Control::State::HIGH_LIGHTED);
        }
        else if (field_name == "disabled_bg")
        {
            std::string path;
            GetFile(path, reflect->GetMessage(msg, field));
            auto sprite = Scale9Sprite::create(path);
            edit_box->setBackgroundSpriteForState(sprite, Control::State::DISABLED);
        }
        else
        {
            CCLOG("%s - unknown field [%s]", __FUNCTION__, field_name.c_str());
        }
    }

    if (is_only_apply)
    {
        applyToTool_EditBox(entity_id, edit_box);
    }
}
void CMakerScene::apply(CEntityMgr::ID entity_id, TextFieldTTF* text_field_ttf, const ::google::protobuf::Message& msg, bool is_only_apply)
{
	if (!text_field_ttf) return;

	auto entity_helper = reinterpret_cast<CEntityHelper*>(text_field_ttf->getUserData());
	if (!entity_helper) return;

	auto desc = msg.GetDescriptor();
	auto reflect = msg.GetReflection();
	if (!desc || !reflect) return;

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;

		if (!reflect->HasField(msg, field)) continue;

		const std::string& field_name = field->name();
		if (field_name == "font_name")
		{
			std::string path;
			if (GetFile(path, reflect->GetMessage(msg, field)))
			{
				entity_helper->getTTFConfig().fontFilePath = path;
				text_field_ttf->setTTFConfig(entity_helper->getTTFConfig());

				if (!path.empty())
				{
					g_prevLabelTTF_name = path;
				}
			}
		}
		else if (field_name == "font_size")
		{
			int font_size = reflect->GetInt32(msg, field);

			entity_helper->getTTFConfig().fontSize = font_size;
			text_field_ttf->setTTFConfig(entity_helper->getTTFConfig());
			if (entity_helper->isOutline())
			{
				text_field_ttf->enableOutline(entity_helper->getOutlineColor(), entity_helper->getOutlineSize());
			}

			g_prevLabelTTF_size = font_size;
		}
        else if (field_name == "text")
        {
            //text_field_ttf->setString(reflect->GetString(msg, field).c_str());
            std::string text = reflect->GetString(msg, field);
            text_field_ttf->setString(ReplaceString(text, "\\n", "\n"));
        }
		else if (field_name == "h_alignment")
		{
			text_field_ttf->setHorizontalAlignment(static_cast<TextHAlignment>(reflect->GetEnum(msg, field)->number()));
		}
		else if (field_name == "color")
		{
			Color3B color;
			auto& color_msg = reflect->GetMessage(msg, field);
			if (GetColor(color, color_msg))
			{
				text_field_ttf->setColor(color);
			}
		}
		else if (field_name == "opacity")
		{
			Color4B text_color(entity_helper->getTextColor());
			text_color.a = reflect->GetInt32(msg, field);
			entity_helper->setTextColor(text_color);
			text_field_ttf->setTextColor(text_color);

			Color4B outline_color(entity_helper->getOutlineColor());;
			outline_color.a = text_color.a;
			entity_helper->setOutlineColor(outline_color);
		}
		else if (field_name == "dimension_width")
		{
			Size size = text_field_ttf->getDimensions();
			size.width = static_cast<float>(reflect->GetInt32(msg, field));
			text_field_ttf->setDimensions(static_cast<unsigned int>(size.width), static_cast<unsigned int>(size.height));

            if (!is_only_apply)
            {
                updateContentSizeInTool(entity_id, text_field_ttf, size);
            }
		}
		else if (field_name == "dimension_height")
		{
			Size size = text_field_ttf->getDimensions();
			size.height = static_cast<float>(reflect->GetInt32(msg, field));
			text_field_ttf->setDimensions(static_cast<unsigned int>(size.width), static_cast<unsigned int>(size.height));

            if (!is_only_apply)
            {
                updateContentSizeInTool(entity_id, text_field_ttf, size);
            }
		}
		else if (field_name == "has_stroke")
		{
			entity_helper->enableOutline(reflect->GetBool(msg, field));
			if (entity_helper->isOutline())
			{
				text_field_ttf->enableOutline(entity_helper->getOutlineColor(), entity_helper->getOutlineSize());
			}
			else
			{
				text_field_ttf->disableEffect();
			}
		}
		else if (field_name == "stroke_tickness")
		{
			float tickness = reflect->GetFloat(msg, field);
			entity_helper->setOutlineSize(tickness);
			if (entity_helper->isOutline())
			{
				text_field_ttf->enableOutline(entity_helper->getOutlineColor(), tickness);
			}
		}
		else if (field_name == "stroke_color")
		{
			Color3B color;
			auto& color_msg = reflect->GetMessage(msg, field);
			if (GetColor(color, color_msg))
			{
				Color4B color4 = Color4B(color);
				color4.a = entity_helper->getTextColor().a;
				entity_helper->setOutlineColor(color4);
				if (entity_helper->isOutline())
				{
					text_field_ttf->enableOutline(color4, entity_helper->getOutlineSize());
				}
			}
		}
		else
		{
			CCLOG("%s - unknown field [%s]", __FUNCTION__, field_name.c_str());
		}
	}

	if (is_only_apply)
	{
		applyToTool_TextFieldTTF(entity_id, text_field_ttf);
	}
}
void CMakerScene::apply(CEntityMgr::ID entity_id, MenuItemImage* menu_item_image, const ::google::protobuf::Message& msg)
{
	if (!menu_item_image) return;

	auto desc = msg.GetDescriptor();
	auto reflect = msg.GetReflection();
	if (!desc || !reflect) return;

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;

		if (!reflect->HasField(msg, field)) continue;

		const std::string& field_name = field->name();
        if (field_name == "enable")
        {
            menu_item_image->setEnabled(reflect->GetBool(msg, field));
        }
		else if (field_name == "normal")
		{
			std::string path;
			GetFile(path, reflect->GetMessage(msg, field));
            menu_item_image->setNormalImagePath(path);
            applyButtonImage(entity_id, menu_item_image, path, &MenuItemImage::setNormalImage);
		}
		else if (field_name == "selected")
		{
            std::string path;
            GetFile(path, reflect->GetMessage(msg, field));
            menu_item_image->setSelectedImagePath(path);
            applyButtonImage(entity_id, menu_item_image, path, &MenuItemImage::setSelectedImage);
        }
		else if (field_name == "disable")
		{
            std::string path;
            GetFile(path, reflect->GetMessage(msg, field));
            menu_item_image->setDisabledImagePath(path);
            applyButtonImage(entity_id, menu_item_image, path, &MenuItemImage::setDisabledImage);
        }
        else if (field_name == "image_type")
        {
            int imageType = reflect->GetEnum(msg, field)->number();
            menu_item_image->setImageType(imageType);
			// @jslors 20.11.23 이미지 타입 변경했을때 위치 갱신
			updateButtonImagePos(menu_item_image);
        }
		else
		{
			CCLOG("%s - unknown field [%s]", __FUNCTION__, field_name.c_str());
		}
	}
}
void CMakerScene::apply(CEntityMgr::ID entity_id, cocos2d::extension::TableView* table_view, const ::google::protobuf::Message& msg, bool is_only_apply)
{
	if (!table_view) return;

	auto data_source = dynamic_cast<SampleTableViewDataSource*>(table_view->getDataSource());
	if (!data_source) return;

	auto desc = msg.GetDescriptor();
	auto reflect = msg.GetReflection();
	if (!desc || !reflect) return;

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;

		if (!reflect->HasField(msg, field)) continue;

		const std::string& field_name = field->name();
		if (field_name == "scroll")
		{
			switch (reflect->GetEnum(msg, field)->number())
			{
			case maker::SCROLL__NONE: table_view->setDirection(ScrollView::Direction::NONE); break;
			case maker::SCROLL__VERTICAL: table_view->setDirection(ScrollView::Direction::VERTICAL); break;
			case maker::SCROLL__HORIZONTAL: table_view->setDirection(ScrollView::Direction::HORIZONTAL); break;
			case maker::SCROLL__BOTH: table_view->setDirection(ScrollView::Direction::BOTH); break;
			}
		}
		else if (field_name == "bounce")
		{
			table_view->setBounceable(reflect->GetBool(msg, field));
		}
		else if (field_name == "view_width")
		{
			if (!is_only_apply)
			{
				Size size = table_view->getViewSize();
				size.width = static_cast<float>(reflect->GetInt32(msg, field));
				table_view->setViewSize(size);

                updateContentSizeInTool(entity_id, table_view, size);
			}
		}
		else if (field_name == "view_height")
		{
			if (!is_only_apply)
			{
				Size size = table_view->getViewSize();
				size.height = static_cast<float>(reflect->GetInt32(msg, field));
				table_view->setViewSize(size);

                updateContentSizeInTool(entity_id, table_view, size);
			}
		}
		else if (field_name == "cell_width")
		{
			auto data_source = dynamic_cast<SampleTableViewDataSource*>(table_view->getDataSource());
			if (data_source)
			{
				data_source->setCellWidth(static_cast<float>(reflect->GetInt32(msg, field)));
			}
		}
		else if (field_name == "cell_height")
		{
			auto data_source = dynamic_cast<SampleTableViewDataSource*>(table_view->getDataSource());
			if (data_source)
			{
				data_source->setCellHeight(static_cast<float>(reflect->GetInt32(msg, field)));
			}
		}
/*		else if (field_name == "inner_width")
		{
			auto data_source = dynamic_cast<SampleTableViewDataSource*>(table_view->getDataSource());
			if (data_source)
			{
				data_source->setInnerWidth(static_cast<float>(reflect->GetInt32(msg, field)));
			}
		}
		else if (field_name == "inner_height")
		{
			auto data_source = dynamic_cast<SampleTableViewDataSource*>(table_view->getDataSource());
			if (data_source)
			{
				data_source->setInnerHeight(static_cast<float>(reflect->GetInt32(msg, field)));
			}
		}*/
		else
		{
			CCLOG("%s - unknown field [%s]", __FUNCTION__, field_name.c_str());
		}
	}

    table_view->reloadData();
    table_view->setContentOffset(Vec2(0, 0));
}

void CMakerScene::apply(CEntityMgr::ID entity_id, Sprite* sprite, const ::google::protobuf::Message& msg)
{
	if (!sprite) return;

	auto desc = msg.GetDescriptor();
	auto reflect = msg.GetReflection();
	if (!desc || !reflect) return;

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;

		if (!reflect->HasField(msg, field)) continue;

		const std::string& field_name = field->name();
		if (field_name == "file_name")
		{
			std::string path;
			if (GetFile(path, reflect->GetMessage(msg, field)))
			{
				sprite->setTexture(path);

				applyToTool_ContentSize(entity_id, sprite);
			}
		}
		else if (field_name == "color")
		{
			Color3B color;
			auto& color_msg = reflect->GetMessage(msg, field);
			if (GetColor(color, color_msg))
			{
				sprite->setColor(color);
			}
		}
		else if (field_name == "opacity") sprite->setOpacity(reflect->GetInt32(msg, field));
		else if (field_name == "flip_x") sprite->setFlippedX(reflect->GetBool(msg, field));
		else if (field_name == "flip_y") sprite->setFlippedY(reflect->GetBool(msg, field));
		else if (field_name == "src_blend")
		{
			BlendFunc blend_func;
			blend_func = sprite->getBlendFunc();
			blend_func.src = reflect->GetEnum(msg, field)->number();
			sprite->setBlendFunc(blend_func);
		}
		else if (field_name == "dest_blend")
		{
			BlendFunc blend_func;
			blend_func = sprite->getBlendFunc();
			blend_func.dst = reflect->GetEnum(msg, field)->number();
			sprite->setBlendFunc(blend_func);
		}
		else
		{
			CCLOG("%s - unknown field [%s]", __FUNCTION__, field_name.c_str());
		}
	}
}
void CMakerScene::apply(CEntityMgr::ID entity_id, Scale9Sprite* scale9sprite, const ::google::protobuf::Message& msg)
{
	if (!scale9sprite) return;

	auto desc = msg.GetDescriptor();
	auto reflect = msg.GetReflection();
	if (!desc || !reflect) return;

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;

		if (!reflect->HasField(msg, field)) continue;

		const std::string& field_name = field->name();
		if (field_name == "file_name")
		{
			std::string path;
			if (GetFile(path, reflect->GetMessage(msg, field)))
			{
                auto size = scale9sprite->getNormalSize();
                scale9sprite->initWithFile(path);
                scale9sprite->setNormalSize(size);
                applyToTool_ContentSize(entity_id, scale9sprite);
			}
		}
		else if (field_name == "color")
		{
			Color3B color;
			auto& color_msg = reflect->GetMessage(msg, field);
			if (GetColor(color, color_msg))
			{
				scale9sprite->setColor(color);
			}
		}
		else if (field_name == "opacity") scale9sprite->setOpacity(reflect->GetInt32(msg, field));
		else if (field_name == "center_rect_x")
		{
			auto rect = scale9sprite->getCapInsets();
			rect.origin.x = static_cast<float>(reflect->GetInt32(msg, field));
			scale9sprite->setCapInsets(rect);
		}
		else if (field_name == "center_rect_y")
		{
			auto rect = scale9sprite->getCapInsets();
			rect.origin.y = static_cast<float>(reflect->GetInt32(msg, field));
			scale9sprite->setCapInsets(rect);
		}
		else if (field_name == "center_rect_width")
		{
			auto rect = scale9sprite->getCapInsets();
			rect.size.width = static_cast<float>(reflect->GetInt32(msg, field));
			scale9sprite->setCapInsets(rect);
		}
		else if (field_name == "center_rect_height")
		{
			auto rect = scale9sprite->getCapInsets();
			rect.size.height = static_cast<float>(reflect->GetInt32(msg, field));
			scale9sprite->setCapInsets(rect);
		}
/*		else if (field_name == "src_blend")
		{
			BlendFunc blend_func;
			blend_func = scale9sprite->getBlendFunc();
			blend_func.src = reflect->GetEnum(msg, field)->number();
			scale9sprite->setBlendFunc(blend_func);
		}
		else if (field_name == "dest_blend")
		{
			BlendFunc blend_func;
			blend_func = scale9sprite->getBlendFunc();
			blend_func.dst = reflect->GetEnum(msg, field)->number();
			scale9sprite->setBlendFunc(blend_func);
		}*/
		else
		{
			CCLOG("%s - unknown field [%s]", __FUNCTION__, field_name.c_str());
		}
	}
}
void CMakerScene::apply(CEntityMgr::ID entity_id, ProgressTimer* progress_timer, const ::google::protobuf::Message& msg)
{
	if (!progress_timer) return;

	auto sprite = progress_timer->getSprite();
	if (!sprite) return;

	auto desc = msg.GetDescriptor();
	auto reflect = msg.GetReflection();
	if (!desc || !reflect) return;

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;

		if (!reflect->HasField(msg, field)) continue;

		const std::string& field_name = field->name();
		if (field_name == "file_name")
		{
			std::string path;
			if (GetFile(path, reflect->GetMessage(msg, field)))
			{
				sprite->setTexture(path);
				progress_timer->setNormalSize(sprite->getNormalSize());

				updateProgressTimer(progress_timer);

				applyToTool_ContentSize(entity_id, sprite);
			}
		}
		else if (field_name == "color")
		{
			Color3B color;
			auto& color_msg = reflect->GetMessage(msg, field);
			if (GetColor(color, color_msg))
			{
				progress_timer->setColor(color);
			}
		}
		else if (field_name == "opacity") progress_timer->setOpacity(reflect->GetInt32(msg, field));
		else if (field_name == "flip_x") { sprite->setFlippedX(reflect->GetBool(msg, field)); updateProgressTimer(progress_timer); }
		else if (field_name == "flip_y") { sprite->setFlippedY(reflect->GetBool(msg, field)); updateProgressTimer(progress_timer); }
		else if (field_name == "src_blend")
		{
			BlendFunc blend_func;
			blend_func = sprite->getBlendFunc();
			blend_func.src = reflect->GetEnum(msg, field)->number();
			sprite->setBlendFunc(blend_func);
		}
		else if (field_name == "dest_blend")
		{
			BlendFunc blend_func;
			blend_func = sprite->getBlendFunc();
			blend_func.dst = reflect->GetEnum(msg, field)->number();
			sprite->setBlendFunc(blend_func);
		}
		else if (field_name == "progress_type")
		{
			auto entity_helper = reinterpret_cast<CEntityHelper*>(progress_timer->getUserData());
			if (!entity_helper) break;

			entity_helper->setProgressTimerType(reflect->GetEnum(msg, field)->number());

			updateProgressTimer(progress_timer);
		}
		else if (field_name == "mid_point_x")
		{
			auto entity_helper = reinterpret_cast<CEntityHelper*>(progress_timer->getUserData());
			if (!entity_helper) break;

			auto mid_point = entity_helper->getMidPoint();
			mid_point.x = reflect->GetFloat(msg, field);
			entity_helper->setMidPoint(mid_point);

			updateProgressTimer(progress_timer);
		}
		else if (field_name == "mid_point_y")
		{
			auto entity_helper = reinterpret_cast<CEntityHelper*>(progress_timer->getUserData());
			if (!entity_helper) break;

			auto mid_point = entity_helper->getMidPoint();
			mid_point.y = reflect->GetFloat(msg, field);
			entity_helper->setMidPoint(mid_point);

			updateProgressTimer(progress_timer);
		}
		else if (field_name == "percentage")
		{
			progress_timer->setPercentage(reflect->GetInt32(msg, field));
		}
		else
		{
			CCLOG("%s - unknown field [%s]", __FUNCTION__, field_name.c_str());
		}
	}
}
void CMakerScene::apply(CEntityMgr::ID entity_id, AzVRP* visual, const ::google::protobuf::Message& msg)
{
	if (!visual) return;

	auto desc = msg.GetDescriptor();
	auto reflect = msg.GetReflection();
	if (!desc || !reflect) return;

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;

		if (!reflect->HasField(msg, field)) continue;

		const std::string& field_name = field->name();
		if (field_name == "file_name")
		{
			std::string path;
			if (GetFile(path, reflect->GetMessage(msg, field)))
			{
				std::list<std::string> socket_list;
				visual->getSocketNodeList(socket_list);

				for (auto& socket_node_name : socket_list)
				{
					auto socket_node = visual->getSocketNode(socket_node_name);
					if (socket_node)
					{
						auto parent_node_helper = reinterpret_cast<CEntityHelper*>(socket_node->getUserData());
						if (parent_node_helper)
						{
							while (socket_node->getChildrenCount() > 0)
							{
								auto child = socket_node->getChildren().front();
								auto entity_helper = reinterpret_cast<CEntityHelper*>(child->getUserData());
								if (entity_helper)
								{
									onCmd_Move(entity_helper->getEntityID(), parent_node_helper->getEntityID(), 0, entity_id);
								}
							}
						}
					}
				}

                // 툴에서 visual을 생성했을 때 width, height가 100, 100으로 설정되어 있는 부분 0, 0으로 보정
                if (path == "")
                {
                    visual->setContentSize(Size(0, 0));
                    applyToTool_ContentSize(entity_id, visual);
                }

				visual->setFile(path);

				std::list<std::string> visual_list;
				visual->getVisualList(VISUAL_GROUP__VISUAL, visual_list);

				if (!visual_list.empty())
				{
					const std::string& first_visual_id = visual_list.front();
					auto split_pos = first_visual_id.find(VISUAL_GROUP__VISUAL);
					if (split_pos != std::string::npos)
					{
						if (split_pos != std::string::npos)
						{
							auto visual_group_name = first_visual_id.substr(0, split_pos);
							auto visual_name = first_visual_id.substr(split_pos + VISUAL_GROUP__VISUAL.size());
							visual->setVisual(visual_group_name, visual_name);
						}
					}
				}
				applyToTool(entity_id, visual);

				visual->loadPlistFiles("");
				visual->buildSprite("");
			}
		}
		else if (field_name == "visual_group")
		{
			visual->setVisual(reflect->GetString(msg, field), visual->getVisualName());
		}
		else if (field_name == "visual")
		{
			visual->setVisual(visual->getVisualGroupName(), reflect->GetString(msg, field));
		}
		else if (field_name == "visual_id")
		{
			std::string name;
			if (GetName(name, reflect->GetMessage(msg, field)))
			{
				auto split_pos = name.find(VISUAL_GROUP__VISUAL);
				if (split_pos != std::string::npos)
				{
					auto visual_group_name = name.substr(0, split_pos);
					auto visual_name = name.substr(split_pos + VISUAL_GROUP__VISUAL.size());
					visual->setVisual(visual_group_name, visual_name);
				}
				else
				{
					visual->setVisual(0);
				}

                applyToTool(entity_id, visual);
			}
		}
		else if (field_name == "auto_play")
		{
			if (reflect->GetBool(msg, field))
			{
                visual->unscheduleAllSelectors();
                visual->scheduleUpdate();
			}
			else
			{
				visual->setFrame(0);
				visual->unscheduleAllSelectors();
			}
		}
		else if (field_name == "is_repeat")
		{
			visual->setRepeat(reflect->GetBool(msg, field));
		}
		else if (field_name == "color")
		{
			Color3B color;
			auto& color_msg = reflect->GetMessage(msg, field);
			if (GetColor(color, color_msg))
			{
				visual->setColor(color);
			}
		}
		else if (field_name == "opacity") visual->setOpacity(reflect->GetInt32(msg, field));
		else
		{
			CCLOG("%s - unknown field [%s]", __FUNCTION__, field_name.c_str());
		}
	}
}
void CMakerScene::apply(CEntityMgr::ID entity_id, ParticleSystemQuad* particle, const ::google::protobuf::Message& msg)
{
	if (!particle) return;

	auto desc = msg.GetDescriptor();
	auto reflect = msg.GetReflection();
	if (!desc || !reflect) return;

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;

		if (!reflect->HasField(msg, field)) continue;

		const std::string& field_name = field->name();
		if (field_name == "file_name")
		{
			std::string path;
			if (GetFile(path, reflect->GetMessage(msg, field)))
			{
				auto pos = particle->getPosition();
				particle->initWithFile(path);
				particle->setPosition(pos);
			}
		}
		else
		{
			CCLOG("%s - unknown field [%s]", __FUNCTION__, field_name.c_str());
		}
	}
}

void CMakerScene::apply(CEntityMgr::ID entity_id, RotatePlate* rotate_plate, const ::google::protobuf::Message& msg)
{
    if (!rotate_plate) return;

    auto desc = msg.GetDescriptor();
    auto reflect = msg.GetReflection();
    if (!desc || !reflect) return;

    for (int i = 0; i < desc->field_count(); ++i)
    {
        auto* field = desc->field(i);

        if (!field) continue;
        if (field->is_repeated()) continue;

        if (!reflect->HasField(msg, field)) continue;

        const std::string& field_name = field->name();
        if (field_name == "radius_x")
        {
            float radius_x = reflect->GetFloat(msg, field);
            float radius_y = rotate_plate->getRadiusY();

            rotate_plate->setRadiusX(radius_x);

            updateContentSizeInTool(entity_id, rotate_plate, Size(radius_x * 2.0f, radius_y * 2.0f));
        }
        else if (field_name == "radius_y")
        {
            float radius_x = rotate_plate->getRadiusX();
            float radius_y = reflect->GetFloat(msg, field);

            rotate_plate->setRadiusY(radius_y);

            updateContentSizeInTool(entity_id, rotate_plate, Size(radius_x * 2.0f, radius_y * 2.0f));
        }
        else if (field_name == "min_scale")
        {
            float min_scale = reflect->GetFloat(msg, field);
            rotate_plate->setMinScale(min_scale);
        }
        else if (field_name == "max_scale")
        {
            float max_scale = reflect->GetFloat(msg, field);
            rotate_plate->setMaxScale(max_scale);
        }
        else if (field_name == "origin_dir")
        {
            int origin_dir = reflect->GetEnum(msg, field)->number();
            rotate_plate->setOriginDirection(origin_dir);
        }
        else
        {
            CCLOG("%s - unknown field [%s]", __FUNCTION__, field_name.c_str());
        }
    }
}

void CMakerScene::applyButtonImage(CEntityMgr::ID entity_id, MenuItemImage* menu_item_image, std::string& path, void(MenuItemImage::*pfSetImage)(Node*))
{
    static bool isSizeToContent = false;

    Size oldSize = menu_item_image->getNormalSize();

    auto sprite = menu_item_image->getNewImageByType(path);

    (menu_item_image->*pfSetImage)(sprite);

	// @jslors 20.11.23 버튼에 이미지 추가하면 가운데 정렬
	if (sprite && MenuItemImageType::SCALE9SPRITE != menu_item_image->getImageType())
	{
		sprite->setPosition((oldSize - sprite->getContentSize()) * 0.5f);
	}

    if (!isSizeToContent)
        menu_item_image->setNormalSize(oldSize);

    applyToTool_ContentSize(entity_id, menu_item_image);
}

void CMakerScene::updateProgressTimer(cocos2d::ProgressTimer* progress_timer)
{
	auto entity_helper = reinterpret_cast<CEntityHelper*>(progress_timer->getUserData());
	if (!entity_helper) return;


	if (progress_timer->getType() == ProgressTimer::Type::RADIAL) progress_timer->setType(ProgressTimer::Type::BAR);
	else progress_timer->setType(ProgressTimer::Type::RADIAL);

	auto mid_point = entity_helper->getMidPoint();

	switch (entity_helper->getProgressTimerType())
	{
	case maker::PROGRESS__RADIAL_CW:     progress_timer->setType(ProgressTimer::Type::RADIAL); progress_timer->setMidpoint(mid_point); progress_timer->setReverseProgress(false); break;
	case maker::PROGRESS__RADIAL_CCW:	   progress_timer->setType(ProgressTimer::Type::RADIAL); progress_timer->setMidpoint(mid_point); progress_timer->setReverseProgress(true); break;
	case maker::PROGRESS__TOP_TO_BOTTOM: progress_timer->setType(ProgressTimer::Type::BAR); progress_timer->setMidpoint(Point(0, 1)); progress_timer->setBarChangeRate(Point(0, 1)); break;
	case maker::PROGRESS__BOTTOM_TO_TOP: progress_timer->setType(ProgressTimer::Type::BAR); progress_timer->setMidpoint(Point(0, 0)); progress_timer->setBarChangeRate(Point(0, 1)); break;
	case maker::PROGRESS__LEFT_TO_RIGHT: progress_timer->setType(ProgressTimer::Type::BAR); progress_timer->setMidpoint(Point(0, 0)); progress_timer->setBarChangeRate(Point(1, 0)); break;
	case maker::PROGRESS__RIGHT_TO_LEFT: progress_timer->setType(ProgressTimer::Type::BAR); progress_timer->setMidpoint(Point(1, 0)); progress_timer->setBarChangeRate(Point(1, 0)); break;
	}

	progress_timer->updateProgress();

	mid_point = progress_timer->getMidpoint();
	maker::CMD cmd;
	CCMDPipe::initApplytoTool(cmd, entity_helper->getEntityID(), "ProgressTimer", "mid_point_x", CCMDPipe::VAR(mid_point.x));
	CCMDPipe::initApplytoTool(cmd, entity_helper->getEntityID(), "ProgressTimer", "mid_point_y", CCMDPipe::VAR(mid_point.y));
	CCMDPipe::getInstance()->send(cmd);
}
void CMakerScene::updateStencil(ClippingNode* clipper)
{
	if (!clipper) return;

	auto entity_helper = reinterpret_cast<CEntityHelper*>(clipper->getUserData());
	if (!entity_helper) return;

	int stencil_type = entity_helper->getStencilType();

	if (stencil_type == 1) // CUSTOM
	{
		std::string path = entity_helper->getStencilSpritePath();
		if (path != "")	updateStencil(clipper, path);
	}
	else
	{
		Size size = clipper->getContentSize();
		updateStencil(clipper, stencil_type, size.width, size.height);
	}
}
void CMakerScene::updateStencil(ClippingNode* clipper, int stencil_type, float width, float height)
{
	if (!clipper) return;
		
	auto stencil = DrawNode::create();
	stencil->clear();

	if (stencil_type == 0) // SQUARE
	{
		Vec2 rectangle[4];
		rectangle[0] = Vec2(0, 0);
		rectangle[1] = Vec2(width, 0);
		rectangle[2] = Vec2(width, height);
 		rectangle[3] = Vec2(0, height);
		Color4F white(1, 1, 1, 1);
		stencil->drawPolygon(rectangle, 4, white, 1, white);
	}

	clipper->setStencil(stencil);
	
	clipper->setAlphaThreshold(1);
}
void CMakerScene::updateStencil(ClippingNode* clipper, string path)
{
	if (!clipper) return;

	auto stencil = Node::create();
	auto stencil_sprite = Sprite::create(path);
	stencil_sprite->setAnchorPoint(Point(0.0f, 0.0f));
	stencil_sprite->setDockPoint(Point(0.0f, 0.0f));
	stencil->addChild(stencil_sprite);
	clipper->setStencil(stencil);
	
	//clipper->setAlphaThreshold(0.0f);
}
void CMakerScene::applyToTool_Position(CEntityMgr::ID entity_id, cocos2d::Node* node)
{
	if (!node) return;

	maker::CMD cmd;

	auto position = node->getPosition();
	CCMDPipe::initApplytoTool(cmd, entity_id, "Node", "x", CCMDPipe::VAR(position.x));
	CCMDPipe::initApplytoTool(cmd, entity_id, "Node", "y", CCMDPipe::VAR(position.y));

	applyToTool_SocketNodeList(cmd, dynamic_cast<cocos2d::AzVRP*>(node));

	CCMDPipe::getInstance()->send(cmd);
}
void CMakerScene::applyToTool_ContentSize(CEntityMgr::ID entity_id, cocos2d::Node* node, int flag)
{
	if (!node) return;

	maker::CMD cmd;

	auto size = node->getNormalSize();

    switch (flag)
    {
    case 0:
        CCMDPipe::initApplytoTool(cmd, entity_id, "Node", "width", CCMDPipe::VAR(static_cast<int>(size.width)));
        CCMDPipe::initApplytoTool(cmd, entity_id, "Node", "height", CCMDPipe::VAR(static_cast<int>(size.height)));
        break;
    case 1:
        CCMDPipe::initApplytoTool(cmd, entity_id, "Node", "width", CCMDPipe::VAR(static_cast<int>(size.width)));
        break;
    case 2:
        CCMDPipe::initApplytoTool(cmd, entity_id, "Node", "height", CCMDPipe::VAR(static_cast<int>(size.height)));
        break;
    }

	applyToTool_SocketNodeList(cmd, dynamic_cast<cocos2d::AzVRP*>(node));

	CCMDPipe::getInstance()->send(cmd);

	applyToTool_ContentSizeToChild(node);
}
void CMakerScene::applyToTool_ContentSizeToChild(cocos2d::Node* parent)
{
	if (!parent) return;

	for (auto child : parent->getChildren())
	{
		if (kRelativeSizeNone == child->getRelativeSizeType())
		{
			continue;
		}

		auto find_it = find_if(m_node_bind.begin(), m_node_bind.end(), [=](const std::pair<CEntityMgr::ID, Node*>& pair){
			return pair.second == child;
		});

		if (find_it != m_node_bind.end())
		{
			applyToTool_ContentSize(find_it->first, child, 0);
		}
	}
}
void CMakerScene::applyToTool_RelativeSize(CEntityMgr::ID entity_id, cocos2d::Node* node, int flag)
{	
    if (!node) return;

    maker::CMD cmd;

    auto size = node->getRelativeSize();

    switch (flag)
    {
    case 0:
        CCMDPipe::initApplytoTool(cmd, entity_id, "Node", "rel_width", CCMDPipe::VAR(static_cast<int>(size.width)));
        CCMDPipe::initApplytoTool(cmd, entity_id, "Node", "rel_height", CCMDPipe::VAR(static_cast<int>(size.height)));
        break;
    case 1:
        CCMDPipe::initApplytoTool(cmd, entity_id, "Node", "rel_width", CCMDPipe::VAR(static_cast<int>(size.width)));
        break;
    case 2:
        CCMDPipe::initApplytoTool(cmd, entity_id, "Node", "rel_height", CCMDPipe::VAR(static_cast<int>(size.height)));
        break;
    }

    applyToTool_SocketNodeList(cmd, dynamic_cast<cocos2d::AzVRP*>(node));

    CCMDPipe::getInstance()->send(cmd);

	applyToTool_ContentSizeToChild(node);
}
void CMakerScene::applyToTool_ViewSize(CEntityMgr::ID entity_id, cocos2d::extension::TableView* table_view)
{
	if (!table_view) return;

	maker::CMD cmd;

	auto size = table_view->getViewSize();
	CCMDPipe::initApplytoTool(cmd, entity_id, "TableView", "view_width", CCMDPipe::VAR(static_cast<int>(size.width)));
	CCMDPipe::initApplytoTool(cmd, entity_id, "TableView", "view_height", CCMDPipe::VAR(static_cast<int>(size.height)));

	CCMDPipe::getInstance()->send(cmd);
}
void CMakerScene::applyToTool(CEntityMgr::ID entity_id, cocos2d::AzVRP* visual)
{
	if (!visual) return;

	CCMDPipe::VAR v;
	maker::CMD cmd;

	std::list<std::string> visual_list;
	visual->getVisualList(VISUAL_GROUP__VISUAL, visual_list);

	if (visual_list.empty())
	{
		CCMDPipe::initApplytoTool(cmd, entity_id, "", "", v);
	}
	else
	{
        std::string visualGroup = visual->getVisualGroupName();
        std::string visualName = visual->getVisualName();
        std::string visualString = visualGroup + VISUAL_GROUP__VISUAL + visualName;

        if (visualString == VISUAL_GROUP__VISUAL)
        {
            v.m_string = visual_list.front();
        }
        else
        {
            v.m_string = visualString;
        }

        v.m_type = CCMDPipe::VAR::TYPE::NAME_VISUAL_ID;
        CCMDPipe::initApplytoTool(cmd, entity_id, "Visual", "visual_id", v);

		auto enum_list = cmd.mutable_enum_list();
		if (enum_list)
		{
			for (auto& i : visual_list)
			{
				auto visual_id = enum_list->Add();
				if (visual_id)
				{
					*visual_id = i;
				}
			}
		}
	}

	applyToTool_SocketNodeList(cmd, visual);

	CCMDPipe::getInstance()->send(cmd);
}
void CMakerScene::applyToTool_SocketNodeList(maker::CMD& cmd, cocos2d::AzVRP* visual)
{
	if (!visual) return;

	std::list<std::string> socket_list;
	visual->getSocketNodeList(socket_list);

	for (auto& socket_node_name : socket_list)
	{
		auto socket_node = visual->getSocketNode(socket_node_name);
		if (socket_node)
		{
			CEntityMgr::ID booking_id = 0;
			auto entity_helper = reinterpret_cast<CEntityHelper*>(socket_node->getUserData());
			if (entity_helper)
			{
				booking_id = entity_helper->getEntityID();
			}
			else
			{
				auto entity_helper = reinterpret_cast<CEntityHelper*>(visual->getUserData());
				if (entity_helper)
				{
					auto entity = CEntityMgr::getInstance()->get(entity_helper->getEntityID());
					if (entity)
					{
						for (auto& child : entity->children())
						{
							auto& properties = child.properties();
							if (properties.has_socket_node() && properties.socket_node().socket_name() == socket_node_name)
							{
								booking_id = child.id();
								break;
							}
						}
					}
				}

				if (booking_id == 0)
				{
					booking_id = CEntityMgr::getInstance()->bookingId();
				}
				m_node_bind.insert(TYPE_NODE_BIND_MAP::value_type(booking_id, socket_node));

				entity_helper = new CEntityHelper(socket_node, booking_id, maker::ENTITY__SocketNode);
				socket_node->setUserData(entity_helper);
			}

			char szbuf[64];
			sprintf(szbuf, "%d;", booking_id);
			socket_node_name = szbuf + socket_node_name;
		}
	}

	auto socket_node_list = cmd.mutable_socket_node_list();
	if (socket_node_list)
	{
		for (auto& i : socket_list)
		{
			auto socket_node_name = socket_node_list->Add();
			if (socket_node_name)
			{
				*socket_node_name = i;
			}
		}
	}
}
void CMakerScene::applyToTool_Label(CEntityMgr::ID entity_id, cocos2d::Label* label, const std::string& type_name)
{
	if (!label) return;

	maker::CMD cmd;

	if (type_name == "LabelSystemFont")
	{
		CCMDPipe::initApplytoTool(cmd, entity_id, "LabelSystemFont", "font_name", CCMDPipe::VAR(g_prevLabelSystemFont_name));
		CCMDPipe::initApplytoTool(cmd, entity_id, "LabelSystemFont", "font_size", CCMDPipe::VAR(g_prevLabelSystemFont_size));
	}
	else if (type_name == "LabelTTF")
	{
		CCMDPipe::VAR v;
		v.m_string = g_prevLabelTTF_name;
		v.m_type = CCMDPipe::VAR::TYPE::FILE_TTF;
		CCMDPipe::initApplytoTool(cmd, entity_id, "LabelTTF", "font_name", v);
		CCMDPipe::initApplytoTool(cmd, entity_id, "LabelTTF", "font_size", CCMDPipe::VAR(g_prevLabelTTF_size));
	}

	CCMDPipe::getInstance()->send(cmd);
}
void CMakerScene::applyToTool_LabelDimension(CEntityMgr::ID entity_id, cocos2d::Label* label)
{
    if (!label) return;

    auto entity = CEntityMgr::getInstance()->get(entity_id);
    
    maker::ENTITY_TYPE type = entity->properties().type();

    Size size = label->getDimensions();

    maker::CMD cmd;
    CCMDPipe::VAR v;
    v.m_type = CCMDPipe::VAR::TYPE::INT32;

    if (type == maker::ENTITY__LabelSystemFont)
    {
        v.V.m_int32 = static_cast<int>(size.width);
        CCMDPipe::initApplytoTool(cmd, entity_id, "LabelSystemFont", "dimension_width", v);
        v.V.m_int32 = static_cast<int>(size.height);
        CCMDPipe::initApplytoTool(cmd, entity_id, "LabelSystemFont", "dimension_height", v);
    }
    else if (type == maker::ENTITY__LabelTTF)
    {
        v.V.m_int32 = static_cast<int>(size.width);
        CCMDPipe::initApplytoTool(cmd, entity_id, "LabelTTF", "dimension_width", v);
        v.V.m_int32 = static_cast<int>(size.height);
        CCMDPipe::initApplytoTool(cmd, entity_id, "LabelTTF", "dimension_height", v);
    }
    else if (type == maker::ENTITY__TextFieldTTF)
    {
        v.V.m_int32 = static_cast<int>(size.width);
        CCMDPipe::initApplytoTool(cmd, entity_id, "TextFieldTTF", "dimension_width", v);
        v.V.m_int32 = static_cast<int>(size.height);
        CCMDPipe::initApplytoTool(cmd, entity_id, "TextFieldTTF", "dimension_height", v);
    }

    CCMDPipe::getInstance()->send(cmd);
}

void CMakerScene::applyToTool_RotatePlateRadius(CEntityMgr::ID entity_id, cocos2d::RotatePlate* plate)
{
    if (!plate) return;

    auto entity = CEntityMgr::getInstance()->get(entity_id);

    maker::ENTITY_TYPE type = entity->properties().type();

    Size size = plate->getNormalSize();

    float radiusX = size.width * 0.5f;
    float radiusY = size.height * 0.5f;

    maker::CMD cmd;
    CCMDPipe::VAR v;
    v.m_type = CCMDPipe::VAR::TYPE::FLOAT;

    v.V.m_float = static_cast<float>(radiusX);
    CCMDPipe::initApplytoTool(cmd, entity_id, "RotatePlate", "radius_x", v);
    v.V.m_float = static_cast<float>(radiusY);
    CCMDPipe::initApplytoTool(cmd, entity_id, "RotatePlate", "radius_y", v);

    CCMDPipe::getInstance()->send(cmd);
}

void CMakerScene::applyToTool_EditBox(CEntityMgr::ID entity_id, cocos2d::extension::EditBox *edit_box)
{
    if (!edit_box) return;
}

void CMakerScene::applyToTool_TextFieldTTF(CEntityMgr::ID entity_id, cocos2d::TextFieldTTF* text_field_ttf)
{
	if (!text_field_ttf) return;

	maker::CMD cmd;
	CCMDPipe::VAR v;
	v.m_string = g_prevLabelTTF_name;
	v.m_type = CCMDPipe::VAR::TYPE::FILE_TTF;
	CCMDPipe::initApplytoTool(cmd, entity_id, "TextFieldTTF", "font_name", v);
	CCMDPipe::initApplytoTool(cmd, entity_id, "TextFieldTTF", "font_size", CCMDPipe::VAR(g_prevLabelTTF_size));
	CCMDPipe::getInstance()->send(cmd);
}

void CMakerScene::applyToTool_CapInsets(CEntityMgr::ID entity_id, cocos2d::extension::Scale9Sprite* scale9sprite)
{
    if (!scale9sprite) return;

    maker::CMD cmd;

    auto rect = scale9sprite->getCapInsets();

    CCMDPipe::initApplytoTool(cmd, entity_id, "Scale9Sprite", "center_rect_x", CCMDPipe::VAR(static_cast<int>(rect.origin.x)));
    CCMDPipe::initApplytoTool(cmd, entity_id, "Scale9Sprite", "center_rect_y", CCMDPipe::VAR(static_cast<int>(rect.origin.y)));
    CCMDPipe::initApplytoTool(cmd, entity_id, "Scale9Sprite", "center_rect_width", CCMDPipe::VAR(static_cast<int>(rect.size.width)));
    CCMDPipe::initApplytoTool(cmd, entity_id, "Scale9Sprite", "center_rect_height", CCMDPipe::VAR(static_cast<int>(rect.size.height)));

    CCMDPipe::getInstance()->send(cmd);
}

void CMakerScene::updateCapInsetsInTool(CEntityMgr::ID entity_id, Node *node)
{
    auto scale9sprite = dynamic_cast<Scale9Sprite*>(node);
    if (scale9sprite)
    {
        applyToTool_CapInsets(entity_id, scale9sprite);
    }
}

void CMakerScene::updateViewSizeInTool(CEntityMgr::ID entity_id, Node *node)
{
    auto table_view = dynamic_cast<TableView*>(node);
    if (table_view)
    {
        applyToTool_ViewSize(entity_id, table_view);
    }
}

void CMakerScene::updateDimensionSizeInTool(CEntityMgr::ID entity_id, Node *node)
{
    auto label = dynamic_cast<Label*>(node);
    if (label)
    {
        applyToTool_LabelDimension(entity_id, label);
    }
}

void CMakerScene::updateRadiusSizeInTool(CEntityMgr::ID entity_id, Node *node)
{
    auto plate = dynamic_cast<RotatePlate*>(node);
    if (plate)
    {
        applyToTool_RotatePlateRadius(entity_id, plate);
    }
}

void CMakerScene::updateContentSizeInTool(CEntityMgr::ID entity_id, Node *node, Size size)
{
    node->setNormalSize(size);
    applyToTool_ContentSize(entity_id, node);
}

void CMakerScene::updateContentSizeWidthInTool(CEntityMgr::ID entity_id, Node *node, float width)
{
    applyToTool_ContentSize(entity_id, node, 1);
}

void CMakerScene::updateContentSizeHeightInTool(CEntityMgr::ID entity_id, Node *node, float height)
{
    applyToTool_ContentSize(entity_id, node, 2);
}

void CMakerScene::updateRelativeSizeInTool(CEntityMgr::ID entity_id, Node *node, Size size)
{
    auto parent = node->getParent();
    if (parent)
    {
        Size parentSize = parent->getNormalSize();
        node->setRelativeSize(Node::getRelSizeFromSize(parentSize, size));
        applyToTool_RelativeSize(entity_id, node);
    }
}

void CMakerScene::updateRelativeSizeWidthInTool(CEntityMgr::ID entity_id, Node *node, float width)
{
    auto parent = node->getParent();
    if (parent)
    {
        Size parentSize = parent->getNormalSize();
        Size relSize = Node::getRelSizeFromSize(parentSize, Size(width, 0));
        node->setRelativeSizeWidth(relSize.width);

        applyToTool_RelativeSize(entity_id, node, 1);
    }
}

void CMakerScene::updateRelativeSizeHeightInTool(CEntityMgr::ID entity_id, Node *node, float height)
{
    auto parent = node->getParent();
    if (parent)
    {
        Size parentSize = parent->getNormalSize();
        Size relSize = Node::getRelSizeFromSize(parentSize, Size(0, height));
        node->setRelativeSizeHeight(relSize.height);

        applyToTool_RelativeSize(entity_id, node, 2);
    }
}

void CMakerScene::updateButtonImagePos(Node *node)
{
	// @jslors 20.11.23
	// 해당 설정 값은 툴에서 가운데 정렬로 보이도록 하는 값
	// cocos2d-x 3.17.2에서는 버튼에 이미지 설정시 가운데 정렬되도록 되어있음
	auto menuItemImage = dynamic_cast<MenuItemImage*>(node);
	if (menuItemImage && MenuItemImageType::SCALE9SPRITE != menuItemImage->getImageType())
	{
		auto image = dynamic_cast<Sprite*>(menuItemImage->getNormalImage());
		if (image)
		{
			image->setPosition((menuItemImage->getContentSize() - image->getTexture()->getContentSize()) * 0.5f);
		}

		image = dynamic_cast<Sprite*>(menuItemImage->getSelectedImage());
		if (image)
		{
			image->setPosition((menuItemImage->getContentSize() - image->getTexture()->getContentSize()) * 0.5f);
		}

		image = dynamic_cast<Sprite*>(menuItemImage->getDisabledImage());
		if (image)
		{
			image->setPosition((menuItemImage->getContentSize() - image->getTexture()->getContentSize()) * 0.5f);
		}
	}
}

cocos2d::Node* CMakerScene::getNode(const CEntityMgr::ID& id) const
{
	auto iter_node = m_node_bind.find(id);
	if (iter_node == m_node_bind.end()) return nullptr;

	return iter_node->second;
}
void CMakerScene::clearSelectedFlag()
{
	for (auto& iter_node : m_node_bind)
	{
		auto node = iter_node.second;
		if (!node) continue;

		auto entity_helper = reinterpret_cast<CEntityHelper*>(node->getUserData());
		if (!entity_helper) continue;

		entity_helper->setSelected(false);
	}
}
void CMakerScene::setSelectedFlag(Node* node)
{
	if (!node) return;

	auto entity_helper = reinterpret_cast<CEntityHelper*>(node->getUserData());
	if (!entity_helper) return;

	entity_helper->setSelected(true);
}

void CMakerScene::clearScene()
{
	removeAllChildren();
	
	m_node_bind.clear();

	m_root = Node::create();
	m_root->setNormalSize(getNormalSize());
	addChild(m_root);

	CEntityHelper::setRoot(m_root);

	m_zoom_center_pos = getNormalSize() / 2;

	_grid = CGrid::create();
	m_root->addChild(_grid);

	m_root->addChild(CEntitySelectedHelper::create(m_node_bind));

	_select_box = CSelectBox::create();
	m_root->addChild(_select_box);

	_edit_root = nullptr;
}

