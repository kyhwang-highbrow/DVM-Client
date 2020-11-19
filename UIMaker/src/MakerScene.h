#pragma once

#include "cocos2d.h"
#include "extensions/cocos-ext.h"
#include "editor-support/anb/CCazVisual.h"
#include "editor-support/anb/CCAzVRP.h"
#include "editor-support/perplelab/CCPerpSpriter.h"

#include "EntityMgr.h"


#include <map>

class CGrid;
class CSelectBox;

class CMakerScene : public cocos2d::Scene
{
public:
	typedef std::map< CEntityMgr::ID, Node* > TYPE_NODE_BIND_MAP;


	CMakerScene(void);
	virtual ~CMakerScene(void);

	static CMakerScene * create(void);

	std::string getDescription() const override;

	virtual bool init();

	void onEnter() override;

	virtual void update(float delta) override;

	void updateCmd();

	static const int ENTITY_TAG = 8086;
	static const int EDIT_ROOT_TAG = 8087;

    static bool isPickedLeftSide(maker::PICK_PART pickPart);
    static bool isPickedRightSide(maker::PICK_PART pickPart);
    static bool isPickedTopSide(maker::PICK_PART pickPart);
    static bool isPickedBottomSide(maker::PICK_PART pickPart);

private:
	TYPE_NODE_BIND_MAP m_node_bind;

	cocos2d::Node* m_root;

	cocos2d::EventListenerMouse* m_mouse_listener;
	cocos2d::EventListenerTouchOneByOne* m_touch_listener;
	cocos2d::EventListenerKeyboard* m_key_listener;

	bool checkNode(cocos2d::Touch* touch, cocos2d::Event* event, Node *target);
	bool onTouchBegan(cocos2d::Touch* touch, cocos2d::Event* event);
	void onTouchMoved(cocos2d::Touch* touch, cocos2d::Event* event);
	void onTouchEnded(cocos2d::Touch* touch, cocos2d::Event* event);
	void onkeyPressed(cocos2d::EventKeyboard::KeyCode keyCode, cocos2d::Event* event);
	void onkeyReleased(cocos2d::EventKeyboard::KeyCode keyCode, cocos2d::Event* event);
	void onMouseDown(cocos2d::Event* event);
	void onMouseUp(cocos2d::Event* event);
	void onMouseMove(cocos2d::Event* event);
	void onMouseScroll(cocos2d::Event* event);

	void onMouseDown_editEntity(cocos2d::EventMouse* mouse_event, bool on_ctrl);
	void onMouseUp_editEntity(cocos2d::EventMouse* mouse_event);
	void onMouseMove_editEntity(cocos2d::EventMouse* mouse_event);

    void calcSizeAndDisplace_editEntity(Size &size, Vec2 &displace, float zoom, Node *target);

	void onMouseDown_scroll(cocos2d::EventMouse* mouse_event);
	void onMouseUp_scroll(cocos2d::EventMouse* mouse_event);
	void onMouseMove_scroll(cocos2d::EventMouse* mouse_event);

	void onMouseDown_selectBox(cocos2d::EventMouse* mouse_event);
	void onMouseUp_selectBox(cocos2d::EventMouse* mouse_event);
	void onMouseMove_selectBox(cocos2d::EventMouse* mouse_event);

	maker::PICK_PART getPickPart(const cocos2d::Node* node, const cocos2d::Point& point) const;
	maker::PICK_PART pickSelectedNode(cocos2d::Node *target, const cocos2d::Point& pick_pos, maker::CMD& cmd);
	maker::PICK_PART pickTopNode(cocos2d::Node *target, const cocos2d::Point& pick_pos, maker::CMD& cmd);
	void pickAllNode(cocos2d::Node *target, const cocos2d::Point& pick_pos, maker::CMD& cmd);
	void pickNode_selectBox(cocos2d::Node *target, const cocos2d::Point& rect_min, const cocos2d::Point& rect_max, maker::CMD& cmd);

	cocos2d::Node* _edit_root;

	const float cm_pick_margin = 3.0f;
	bool isOverlap(const cocos2d::Node* node, const cocos2d::Point& rect_min, const cocos2d::Point& rect_max) const;
	void setCursor(maker::PICK_PART pick) const;

	maker::PICK_PART m_pick_part;
	cocos2d::Point m_pick;
	cocos2d::Node* m_pick_node;

	cocos2d::Point m_pick_offset;
	int _zoom_step;

	void updateZoom(float zoom);

	cocos2d::Point m_zoom_center_pos;
	cocos2d::Point m_pick_zoom_center_pos;

	CSelectBox* _select_box;
	CGrid* _grid;

	void updateKeyEvents(float delta);

	typedef struct
	{
		bool m_pressed;
		bool m_pressing;
		bool m_released;
		float m_delta;
	} KEY_INFO;
	std::map< cocos2d::EventKeyboard::KeyCode, KEY_INFO > m_key_map;
	void updateKeyEvent(cocos2d::EventKeyboard::KeyCode keyCode, const KEY_INFO& key_info);

protected:
	void onCmd_Create(const maker::CMD& cmd);
	cocos2d::Node* onCmd_Create(CEntityMgr::ID entity_id, CEntityMgr::ID parent_id, const maker::Properties& properties, bool is_only_apply);
	cocos2d::Node* onCmd_Create(cocos2d::Node* parent, CEntityMgr::ID entity_id, const maker::Properties& properties, bool is_only_apply);
	void appendChildren(cocos2d::Node* parent, const ::google::protobuf::RepeatedPtrField< ::maker::Entity >& children, bool is_only_apply);
	void onCmd_Remove(const maker::CMD& cmd);
	void removeAllChildrenNodeAtNodeBindMap(cocos2d::Node* node);
	void onCmd_Move(const maker::CMD& cmd);
	void onCmd_Move(CEntityMgr::ID entity_id, CEntityMgr::ID parent_id, CEntityMgr::ID dest_id, CEntityMgr::ID dest_parent_id);
	void onCmd_Modify(const maker::CMD& cmd);
	void onCmd_Modify(CEntityMgr::ID entity_id, const maker::Properties& properties, bool is_only_apply);
    void onCmd_SizeToContent(const maker::CMD& cmd);
	void onCmd_SelectOne(const maker::CMD& cmd);
	void onCmd_SelectAppend(const maker::CMD& cmd);
	void onCmd_SelectBoxAppend(const maker::CMD& cmd);
	void onCmd_EventToViewer(const maker::CMD& cmd);

	cocos2d::Node* getEditRoot(cocos2d::Node* node);
	void initEditRoot(cocos2d::Node* node);

	bool GetColor(cocos2d::Color3B& color, const::google::protobuf::Message& msg);
	bool GetFile(std::string& file_name, const::google::protobuf::Message& msg);
	bool GetName(std::string& file_name, const::google::protobuf::Message& msg);

	void apply(CEntityMgr::ID entity_id, cocos2d::Node* node, const ::google::protobuf::Message& msg, bool is_only_apply);
	void apply(CEntityMgr::ID entity_id, cocos2d::ClippingNode* clipping_node, const ::google::protobuf::Message& msg);
	void apply(CEntityMgr::ID entity_id, cocos2d::Sprite* sprite, const ::google::protobuf::Message& msg);
	void apply(CEntityMgr::ID entity_id, cocos2d::LayerColor* layer_color, const ::google::protobuf::Message& msg);
	void apply(CEntityMgr::ID entity_id, cocos2d::LayerGradient* layer_gradient, const ::google::protobuf::Message& msg);
	void apply(CEntityMgr::ID entity_id, cocos2d::Label* label, const ::google::protobuf::Message& msg, bool is_only_apply);
    void apply(CEntityMgr::ID entity_id, cocos2d::extension::EditBox* edit_box, const ::google::protobuf::Message& msg, bool is_only_apply);
	void apply(CEntityMgr::ID entity_id, cocos2d::TextFieldTTF* text_field_ttf, const ::google::protobuf::Message& msg, bool is_only_apply);
	void apply(CEntityMgr::ID entity_id, cocos2d::MenuItemImage* menu_item_image, const ::google::protobuf::Message& msg);
	void apply(CEntityMgr::ID entity_id, cocos2d::extension::TableView* table_view, const ::google::protobuf::Message& msg, bool is_only_apply);
	void apply(CEntityMgr::ID entity_id, cocos2d::extension::Scale9Sprite* scale9sprite, const ::google::protobuf::Message& msg);
	void apply(CEntityMgr::ID entity_id, cocos2d::ProgressTimer* progress_timer, const ::google::protobuf::Message& msg);
    void apply(CEntityMgr::ID entity_id, cocos2d::AzVRP* visual, const ::google::protobuf::Message& msg);
	void apply(CEntityMgr::ID entity_id, cocos2d::ParticleSystemQuad* particle, const ::google::protobuf::Message& msg);
    void apply(CEntityMgr::ID entity_id, cocos2d::RotatePlate* rotate_plate, const ::google::protobuf::Message& msg);

    void applyButtonImage(CEntityMgr::ID entity_id, MenuItemImage* menu_item_image, std::string& path, void(MenuItemImage::*pfSetImage)(Node*));

	void updateProgressTimer(cocos2d::ProgressTimer* progress_timer);
	void updateStencil(cocos2d::ClippingNode* clipper);
	void updateStencil(cocos2d::ClippingNode* clipper, int stencil_type, float width, float height);
	void updateStencil(cocos2d::ClippingNode* clipper, string path);

	void applyToTool_Position(CEntityMgr::ID entity_id, cocos2d::Node* node);
	void applyToTool_ContentSize(CEntityMgr::ID entity_id, cocos2d::Node* node, int flag = 0);
	void applyToTool_ContentSizeToChild(cocos2d::Node* parent);
    void applyToTool_RelativeSize(CEntityMgr::ID entity_id, cocos2d::Node* node, int flag = 0);
    void applyToTool_ViewSize(CEntityMgr::ID entity_id, cocos2d::extension::TableView* table_view);
    void applyToTool(CEntityMgr::ID entity_id, cocos2d::AzVRP* visual);
    void applyToTool_SocketNodeList(maker::CMD& cmd, cocos2d::AzVRP* visual);
	void applyToTool_Label(CEntityMgr::ID entity_id, cocos2d::Label* label, const std::string& type_name);
    void applyToTool_LabelDimension(CEntityMgr::ID entity_id, cocos2d::Label* label);
    void applyToTool_RotatePlateRadius(CEntityMgr::ID entity_id, cocos2d::RotatePlate* plate);
    void applyToTool_EditBox(CEntityMgr::ID entity_id, cocos2d::extension::EditBox* edit_box);
	void applyToTool_TextFieldTTF(CEntityMgr::ID entity_id, cocos2d::TextFieldTTF* text_field_ttf);
    void applyToTool_CapInsets(CEntityMgr::ID entity_id, cocos2d::extension::Scale9Sprite* scale9sprite);

    void updateCapInsetsInTool(CEntityMgr::ID entity_id, Node *node);
    void updateViewSizeInTool(CEntityMgr::ID entity_id, Node *node);
    void updateRadiusSizeInTool(CEntityMgr::ID entity_id, Node *node);
    void updateDimensionSizeInTool(CEntityMgr::ID entity_id, Node *node);
    void updateContentSizeInTool(CEntityMgr::ID entity_id, Node *node, Size size);
    void updateContentSizeWidthInTool(CEntityMgr::ID entity_id, Node *node, float width);
    void updateContentSizeHeightInTool(CEntityMgr::ID entity_id, Node *node, float height);
    void updateRelativeSizeInTool(CEntityMgr::ID entity_id, Node *node, Size size);
    void updateRelativeSizeWidthInTool(CEntityMgr::ID entity_id, Node *node, float width);
	void updateRelativeSizeHeightInTool(CEntityMgr::ID entity_id, Node *node, float height);

	void clearScene();
	
	cocos2d::Size _setLabelShadow(float distance, int direction);

	cocos2d::Node* getNode(const CEntityMgr::ID& id) const;
	void clearSelectedFlag();
	void setSelectedFlag(cocos2d::Node* node);
};

