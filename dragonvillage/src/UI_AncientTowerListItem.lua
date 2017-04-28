local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AncientTowerListItem
-------------------------------------
UI_AncientTowerListItem = class(PARENT, {
        m_stageTable = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerListItem:init(t_data)
    local vars = self:load('tower_scene_item.ui')

    self.m_stageTable = t_data

    self:initUI(t_data)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerListItem:initUI(t_data)
    local vars = self.vars

    -- TODO: 클리어시 보상 표시
    --local item_card = UI_ItemCard(item_id, count)
    --vars['rewardNode']
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerListItem:initButton()
    local vars = self.vars
    vars['floorBtn']:registerScriptTapHandler(function() self:click_floorButton() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerListItem:refresh()
    local vars = self.vars

    local stage_id = self.m_stageTable['stage']
    local floor = g_ancientTowerData:getFloor(stage_id)

    vars['floorLabel']:setString(Str('{1}층', floor))
    
end

-------------------------------------
-- function click_floorButton
-------------------------------------
function UI_AncientTowerListItem:click_floorButton()
    -- TODO: 현재 층을 포커싱하고 오른쪽 상세 UI 갱신되어야함
end