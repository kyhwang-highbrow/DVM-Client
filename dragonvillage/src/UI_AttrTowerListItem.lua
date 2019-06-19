local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AttrTowerListItem
-------------------------------------
UI_AttrTowerListItem = class(PARENT, {
        m_stageTable = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AttrTowerListItem:init(t_data)
    local vars = self:load('tower_scene_item.ui')

    self.m_stageTable = t_data

    self:initUI(t_data)
    self:initButton()
    self:refresh()

    self.m_cellSize = cc.size(800, 150)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttrTowerListItem:initUI(t_data)
    local vars = self.vars

    local stage_id = self.m_stageTable['stage']
    local floor = g_attrTowerData:getFloorFromStageID(stage_id)
    local clear_floor = g_attrTowerData.m_clearFloor

    -- 층 수 표시
    vars['floorLabel']:setString(Str('{1}층', floor))
    -- 클리어시 보상 표시
    local t_info = TABLE:get('anc_floor_reward')[stage_id]
    if (t_info) then
        local attr = g_attrTowerData:getSelAttr()
        local l_str = (floor > clear_floor) and seperate(t_info['reward_first_'..attr], ';') or seperate(t_info['reward_repeat_'..attr], ';')
        local item_type = l_str[1]
        local item_id = TableItem:getItemIDFromItemType(item_type) or tonumber(item_type)
        local item_count = tonumber(l_str[2])

        local item_card = UI_ItemCard(item_id, item_count)
        item_card.vars['clickBtn']:setEnabled(false)
        vars['rewardNode']:addChild(item_card.root)
    end

    local visual_id = g_attrTowerData:getSelAttr() .. '_normal'
    vars['towerVisual']:setIgnoreLowEndMode(true) -- 저사양 모드 무시
    vars['towerVisual']:changeAni(visual_id, true)

    local is_open = g_attrTowerData:isOpenStage(stage_id)
    vars['lockSprite']:setVisible(not is_open)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AttrTowerListItem:initButton()
    local vars = self.vars
    
    vars['floorBtn']:getParent():setSwallowTouch(false)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AttrTowerListItem:refresh()
end

-------------------------------------
-- class UI_AttrTowerListBottomItem
-------------------------------------
UI_AttrTowerListBottomItem = class(PARENT, {})

-------------------------------------
-- function init
-------------------------------------
function UI_AttrTowerListBottomItem:init(t_data)
    local vars = self:load('tower_scene_item.ui')

    vars['floorLabel']:setVisible(false)
    vars['floorBtn']:getParent():setSwallowTouch(false)

    local visual_id = g_attrTowerData:getSelAttr() .. '_bottom'
    vars['towerVisual']:changeAni(visual_id, true)
    
    self.m_cellSize = cc.size(800, 150)
end

-------------------------------------
-- class UI_AttrTowerListTopItem
-------------------------------------
UI_AttrTowerListTopItem = class(PARENT, {})

-------------------------------------
-- function init
-------------------------------------
function UI_AttrTowerListTopItem:init(t_data)
    local vars = self:load('tower_scene_item.ui')

    vars['floorLabel']:setVisible(false)
    vars['floorBtn']:getParent():setSwallowTouch(false)

    local visual_id = g_attrTowerData:getSelAttr() .. '_top'
    vars['towerVisual']:changeAni(visual_id, true)

	-- 시험의 탑은 최대 150개 층이 있고, 한번에 층 UI를 생성 시 퍼포먼스 이슈가 있음
    -- 따라사 최상단 탑의 크기를 다른 층들과 같게 하여 한번에 모든 층을 생성하지 않도록 변경함
    vars['towerVisual']:setPosition(0, 75)    
    self.m_cellSize = cc.size(800, 150) -- cc.size(800, 300)
end