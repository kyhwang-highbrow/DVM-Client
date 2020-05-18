-- 확률업

local PARENT = UI

-------------------------------------
-- class UI_DragonChanceUp
-------------------------------------
UI_DragonChanceUp = class(PARENT,{
        m_map_target_dragons = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonChanceUp:init()
    local map_target_dragons = g_eventData:getChanceUpDragons()
    if (not map_target_dragons) then
        return
    end

    local total_cnt = table.count(map_target_dragons)
    
    -- 확률업에 지정된 드래곤 수에 따라 사용하는 ui와 초기화 함수가 다름
    local ui_name = nil
    local init_func = nil

    if (total_cnt == 1) then
        -- 확률업에 드래곤 1종만 걸렸을 경우
        ui_name = 'event_chanceup_02.ui'
        init_func = UI_DragonChanceUp.initUI_OnlyOne
    else
        -- 확률업에 드래곤 2종이걸렸을 경우
        ui_name = 'event_chanceup.ui'
        init_func = UI_DragonChanceUp.initUI
    end

    self:load(ui_name)

    self.m_map_target_dragons = map_target_dragons

    self:doActionReset()
    self:doAction(nil, false)

    init_func(self)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-- @breif 확률업 드래곤이 2개가 적용되었을 경우 UI 초기화
-------------------------------------
function UI_DragonChanceUp:initUI()
    local vars = self.vars
    local map_target_dragons = self.m_map_target_dragons

    local total_cnt = #table.MapToList(map_target_dragons)
    local idx = 0
    local width = 455

    for k, t_data in pairs(map_target_dragons) do
        local did = t_data['did']
        idx = idx + 1
        local ui = UI_DragonChanceUpListItem(did)
        local pos_x = UIHelper:getNodePosXWithScale(total_cnt, idx, width)
        ui.root:setPositionX(pos_x)
        vars['itemNode']:addChild(ui.root)
    end
end

-------------------------------------
-- function initUI_OnlyOne
-- @breif 확률업 드래곤이 1개가 적용되었을 경우 UI 초기화
-------------------------------------
function UI_DragonChanceUp:initUI_OnlyOne()
    local vars = self.vars
    local map_target_dragons = self.m_map_target_dragons

    local did = nil
    for _, data in pairs(map_target_dragons) do
        did = data['did']
        break
    end

    local vars = self.vars
    local table_dragon = TableDragon()

    local attr = table_dragon:getDragonAttr(did)
    local role_type = table_dragon:getDragonRole(did)
    local rarity_type = table_dragon:getValue(did, 'rarity')
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)

    -- 이름
    local name = table_dragon:getChanceUpDragonName(did)
    vars['nameLabel']:setString(name)

    -- 희귀도
    DragonInfoIconHelper.setDragonRarityBtn(rarity_type, vars['rarityNode'], vars['rarityLabel'], t_info)

    -- 역할
    DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'], t_info)
    
    -- 속성
    DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)
    
    -- 드래곤
    local animator = AnimatorHelper:makeDragonAnimator_usingDid(did, 3)
    vars['dragonNode']:addChild(animator.m_node)

    -- 배경
    local attr = table_dragon:getDragonAttr(did)
    vars['bgNode']:removeAllChildren()
    local animator = ResHelper:getUIDragonBG(attr, 'idle')
    vars['bgNode']:addChild(animator.m_node)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonChanceUp:initButton()
    local vars = self.vars
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_DragonChanceUp:onEnterTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonChanceUp:refresh()
end

--@CHECK
UI:checkCompileError(UI_DragonChanceUp)
