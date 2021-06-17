#pragma once

#include "cocos2d.h"
#include "extensions/cocos-ext.h"

#include "editor-support/anb/CCAzVisual.h"
#include "editor-support/anb/CCAzVrp.h"

namespace maker {
	class Entity;
}

class SampleTableViewDataSource : public cocos2d::extension::TableViewDataSource
{
public:
	SampleTableViewDataSource();
	virtual ~SampleTableViewDataSource();

	virtual cocos2d::Size tableCellSizeForIndex(cocos2d::extension::TableView *table, ssize_t idx);
	virtual cocos2d::Size cellSizeForTable(cocos2d::extension::TableView *table);
	virtual cocos2d::extension::TableViewCell* tableCellAtIndex(cocos2d::extension::TableView *table, ssize_t idx);
	virtual ssize_t numberOfCellsInTableView(cocos2d::extension::TableView *table);

	inline void setInnerWidth(float v) { _inner_width = v; }
	inline void setInnerHeight(float v) { _inner_height = v; }

	inline void setCellWidth(float v) { _cell_width = v; }
	inline void setCellHeight(float v) { _cell_height = v; }

private:
	float _inner_width;
	float _inner_height;

	float _cell_width;
	float _cell_height;
};

class CEntityHelper
{
public:
	CEntityHelper(cocos2d::Node* node, long long entity_id, int entity_type);
	~CEntityHelper();

	void appendDrawCommand(cocos2d::Renderer *renderer, float z_order);

	void updateSelectBox();
	void drawSelected();
	void drawSelectedInfo(cocos2d::Sprite* sprite);
    void drawSelectedInfo(cocos2d::extension::Scale9Sprite* sprite);
    void drawSelectedInfo(cocos2d::RotatePlate* plate);
    void drawSelectedInfo(cocos2d::AzVRP* visual);
	void drawSelectedInfo(cocos2d::Node* node);
	void drawWorkspace(cocos2d::Node* node);

    void drawCircle(const cocos2d::Rect& rect, const cocos2d::Color4B& color, float angle, int count);
	void drawRectBox(const cocos2d::Size& size, const cocos2d::Color4B& color);
	void drawRectBox(const cocos2d::Rect& rect, const cocos2d::Color4B& color);
	void drawRectBox(const cocos2d::V3F_C4B_T2F_Quad& quad, const cocos2d::Color4B& color);
	void drawAnchor(cocos2d::Point origin, const cocos2d::Point parent_origin);

	inline long long getEntityID() const { return m_entity_id; }
	inline int getEntityType() const { return m_entity_type; }

	inline bool isSelected() const { return m_selected; }
	inline void setSelected(bool v) { m_selected = v; }
	inline bool isParentSelected() const { return m_parent_selected; }
	inline void setParentSelected(bool v) { m_parent_selected = v; }
	inline bool isDrag() const { return m_draging; }
	inline void setDrag(bool v) { m_draging = v; }
	inline void setPickPos(const cocos2d::Point& pick_pos) { m_pick_pos = pick_pos; }
	inline const cocos2d::Point& getPickPos() { return m_pick_pos; }
	inline void setPickSize(const cocos2d::Size& pick_size) { m_pick_size = pick_size; }
	inline const cocos2d::Size& getPickSize() { return m_pick_size; }

	inline cocos2d::TTFConfig& getTTFConfig() { return m_ttf_config; }
	inline const cocos2d::TTFConfig& getTTFConfig() const { return m_ttf_config; }

	inline void setTTFConfig(cocos2d::TTFConfig v) { m_ttf_config = v; }
	inline cocos2d::Color4B getTextColor() const { return m_text_color; }
	inline void setTextColor(cocos2d::Color4B v) { m_text_color = v; }

	inline bool isOutline() const { return m_outline; }
	inline void enableOutline(bool v) { m_outline = v; }
	inline cocos2d::Color4B getOutlineColor() const { return m_outline_color; }
	inline void setOutlineColor(cocos2d::Color4B v) { m_outline_color = v; }
	inline float getOutlineSize() const { return m_outline_size; }
	inline void setOutlineSize(float v) { m_outline_size = v; }

	//shadow
	inline bool isShadow() const { return m_shadow; }
	inline void enableShadow(bool v) { m_shadow = v; }
	inline cocos2d::Color4B getShadowColor() const { return m_shadow_color; }
	inline void setShadowColor(cocos2d::Color4B v) { m_shadow_color = v; }
	inline float getShadowDistance() const { return m_shadow_distance; }
	inline void setShadowDistance(float v) { m_shadow_distance = v; }
	inline int getShadowDirection() const { return m_shadow_direction; }
	inline void setShadowDirection(int v) { m_shadow_direction = v; }
	inline void setShadowOpacity(int v) { m_shadow_opacity = v; }
	inline int getShadowOpacity() const { return m_shadow_opacity; }

	//bold
	inline bool isBold() const { return m_bold; }
	inline void enableBold(bool v) { m_bold = v; }

	inline void setProgressTimerType(int progress_timer_type) { m_progress_timer_type = progress_timer_type; }
	inline int getProgressTimerType() const { return m_progress_timer_type; }
	inline void setMidPoint(const cocos2d::Point& mid_point) { m_mid_point = mid_point; }
	inline const cocos2d::Point& getMidPoint() const { return m_mid_point; }

	//clippingNode
	inline int getStencilType() const { return m_stencil_type; }
	inline void setStencilType(int v) { m_stencil_type = v; }
	inline std::string getStencilSpritePath() const { return m_stencil_sprite_path; }
	inline void setStencilSpritePath(std::string v) { m_stencil_sprite_path = v; }

	void backupEntityInfo(const maker::Entity& entity);

private:
	long long m_entity_id;
	int m_entity_type;
	bool m_selected;
	bool m_parent_selected;
	bool m_draging;

	// for Node
	cocos2d::Node* m_node;
	cocos2d::CustomCommand m_customDebugDrawCommand;
	cocos2d::Point m_pick_pos;
	cocos2d::Size m_pick_size;

	// for ClippingNode
	int m_stencil_type;
	std::string m_stencil_sprite_path;

	// for Label
	cocos2d::TTFConfig m_ttf_config;
	cocos2d::Color4B m_text_color;
	bool m_outline;
	cocos2d::Color4B m_outline_color;
	float m_outline_size;
	bool m_shadow;
	cocos2d::Color4B m_shadow_color;
	float m_shadow_distance;
	int m_shadow_blur;
	int m_shadow_direction;
	int m_shadow_opacity;
	bool m_bold;

	// for ProgressTimer
	int m_progress_timer_type;
	cocos2d::Point m_mid_point;

	// for select box
	GLushort m_select_box_pattern;
	DWORD m_select_box_dt;
	DWORD m_select_box_pattern_update_unit;

	static cocos2d::Node* m_root;

public:
	static void setRoot(cocos2d::Node* root) { m_root = root; }
};

