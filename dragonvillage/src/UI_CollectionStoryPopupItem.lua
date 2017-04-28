local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_CollectionStoryPopupItem
-------------------------------------
UI_CollectionStoryPopupItem = class(PARENT, {
        m_dragonUnitID = 'number',
        m_lDragonCard = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionStoryPopupItem:init(unit_id)
    self.m_dragonUnitID = unit_id

    local vars = self:load('collection_story_popup_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CollectionStoryPopupItem:initUI()
    local vars = self.vars

    local table_dragon_unit = TableDragonUnit()
    local t_dragon_unit = table_dragon_unit:get(self.m_dragonUnitID)

    -- 이름
    vars['titleLabel']:setString(Str(t_dragon_unit['t_name']))

    -- 설명
    vars['infoLabel']:setString(Str(t_dragon_unit['t_desc']))

    -- 조건 설명
    vars['conditionLabel']:setString(Str(t_dragon_unit['t_condition']))


    local t_dragon_unit_data = g_dragonUnitData:getDragonUnitData(self.m_dragonUnitID)
    local unit_list = t_dragon_unit_data['unit_list']

    local table_dragon = TableDragon()

    self.m_lDragonCard = {}

    for i,v in ipairs(unit_list) do
        local type = v['type']
        local value = v['value']

        local did
        if (type == 'dragon') then
            did = value
        elseif (type == 'category') then
            local dragon_type = value
            did = TableDragonType:getBaseDid(dragon_type)
        end

        local card = MakeSimpleDragonCard(did)
        card.root:setSwallowTouch(false)
        card.vars['starIcon']:setVisible(false)
        vars['dragonNode' .. i]:addChild(card.root)

        self.m_lDragonCard[i] = card
    end

    do -- 보상 표시
        local reward_str = t_dragon_unit_data['reward']
        local item_id, count = ServerData_Item:parsePackageItemStrIndivisual(reward_str)
        local icon = IconHelper:getItemIcon(item_id)
        vars['rewardNode']:addChild(icon)
        vars['rewardLabel']:setString(comma_value(count))
    end

    vars['buffSprite']:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CollectionStoryPopupItem:initButton()
    local vars = self.vars

    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
    vars['storyBtn']:registerScriptTapHandler(function() self:click_srotyBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CollectionStoryPopupItem:refresh()
    local vars = self.vars

    local t_dragon_unit_data = g_dragonUnitData:getDragonUnitData(self.m_dragonUnitID)
    local unit_list = t_dragon_unit_data['unit_list']

    for i,v in ipairs(unit_list) do
        local exist = v['exist']
        local ui = self.m_lDragonCard[i]
        ui:setShadowSpriteVisible(not exist)
    end

    if t_dragon_unit_data['received'] then
        vars['rewardBtn']:setVisible(false)
        vars['rewardNode']:setVisible(false)
        vars['rewardLabel']:setVisible(false)
        vars['storyBtn']:setVisible(true)
    else
        vars['rewardBtn']:setEnabled(true)
        vars['rewardNode']:setVisible(true)
        vars['rewardLabel']:setVisible(true)
        vars['storyBtn']:setVisible(false)
    end
end

-------------------------------------
-- function click_srotyBtn
-------------------------------------
function UI_CollectionStoryPopupItem:click_srotyBtn()
    local unit_id = self.m_dragonUnitID
    local scene_id = TableDragonUnit:getStoryScene(unit_id)

    local ui = UI_ScenarioPlayer(scene_id)
end

-------------------------------------
-- function click_rewardBtn
-- @brief
-------------------------------------
function UI_CollectionStoryPopupItem:click_rewardBtn()
    local function finish_cb()
        self:refresh()
        self:click_srotyBtn()
    end

    local unit_id = self.m_dragonUnitID
    g_dragonUnitData:request_unitReward(unit_id, finish_cb)
end