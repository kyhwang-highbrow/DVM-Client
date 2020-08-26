local PARENT = UI

-------------------------------------
-- class UI_EventDragonLaunchLegend
-- @brief 신규 전설 드래곤 출시, 신규 드래곤
-------------------------------------
UI_EventDragonLaunchLegend = class(PARENT,{
        m_newDragonList = 'table',
        m_newDragonAttrList = 'table',
        m_commonFirstFiveDragonCode = 'table',
        m_dragonAnimator = 'node',
        m_mapAttrBtnUI = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventDragonLaunchLegend:init(popup_key)
    ui_name = 'event_dragon_launch_legend.ui'    
    self:load(ui_name)

    local l_str = plSplit(popup_key, ';')
    local new_dragon_list = {}
    local new_dragon_attr_list = {}
    if (#l_str > 1) then
        for i = 2, #l_str do
            table.insert(new_dragon_list, tonumber(l_str[i]))
            local attr = string.sub(l_str[i], 6, 6)
            table.insert(new_dragon_attr_list, tonumber(attr))
        end
        self.m_commonFirstFiveDragonCode = string.sub(l_str[2], 1, 5)
    end
    self.m_newDragonList = new_dragon_list
    self.m_newDragonAttrList = new_dragon_attr_list

    self:doActionReset()
    self:doAction(nil, false)

    self:initButton()
    self:refresh()
    self:initUI()
end

-------------------------------------
-- function initUI
-- @breif 초기화
-------------------------------------
function UI_EventDragonLaunchLegend:initUI()
    local vars = self.vars

    -- 드래곤 실리소스
    if vars['dragonNode'] then
        self.m_dragonAnimator = UIC_DragonAnimator()
        vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)
    end

    self:addSameTypeDragon()

    do -- 기본 드래곤 표시
        local attr = ''
        if (self.m_newDragonAttrList[1] == 1) then
            attr = 'earth'
        elseif (self.m_newDragonAttrList[1] == 2) then
            attr = 'water'
        elseif (self.m_newDragonAttrList[1] == 3) then
            attr = 'fire'
        elseif (self.m_newDragonAttrList[1] == 4) then
            attr = 'light'
        else
            attr = 'dark'
        end
        self:clickAttrBtn(attr)
    end
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventDragonLaunchLegend:onEnterTab()
end

-------------------------------------
-- function clickAttrBtn
-- @param attr 드래곤 속성
-------------------------------------
function UI_EventDragonLaunchLegend:clickAttrBtn(attr)
    if (attr == 'earth') then
        self:click_earthBtn()
    elseif (attr == 'water') then
        self:click_waterBtn()
    elseif (attr == 'fire') then
        self:click_fireBtn()
    elseif (attr == 'light') then
        self:click_lightBtn()
    else
        self:click_darkBtn()
    end
    self:setSelectSprite(attr) -- 속성 노드 정상/어둡게
    self:setBgNode(attr)
end

-------------------------------------
-- function setSelectSprite
-------------------------------------
function UI_EventDragonLaunchLegend:setSelectSprite(target_attr)
    local l_attr = getAttrTextList()
    for _, attr in ipairs(l_attr) do
        local ui = self.m_mapAttrBtnUI[attr]
        ui.vars['selectSprite']:setVisible(false)
    end
    local ui = self.m_mapAttrBtnUI[target_attr]
    ui.vars['selectSprite']:setVisible(true)
end

-------------------------------------
-- function click_earthBtn
-------------------------------------
function UI_EventDragonLaunchLegend:click_earthBtn()
    
    local did = self:getDidFromAttr(1)
    self:setDragon(did)
    self:summonUp(did)
end

-------------------------------------
-- function click_waterBtn
-------------------------------------
function UI_EventDragonLaunchLegend:click_waterBtn()
    local did = self:getDidFromAttr(2)
    self:setDragon(did)
    self:summonUp(did)
end

-------------------------------------
-- function click_fireBtn
-------------------------------------
function UI_EventDragonLaunchLegend:click_fireBtn()
    local did = self:getDidFromAttr(3)
    self:setDragon(did)
    self:summonUp(did)
end

-------------------------------------
-- function click_lightBtn
-------------------------------------
function UI_EventDragonLaunchLegend:click_lightBtn()
    local did = self:getDidFromAttr(4)
    self:setDragon(did)
    self:summonUp(did)
end

-------------------------------------
-- function click_darkBtn
-------------------------------------
function UI_EventDragonLaunchLegend:click_darkBtn()
    local did = self:getDidFromAttr(5)
    self:setDragon(did)
    self:summonUp(did)
end

-------------------------------------
-- function setBgNode
-- @brief 신규 드래곤 팝업의 배경을 설정한다.
-------------------------------------
function UI_EventDragonLaunchLegend:setBgNode(attr)
    local vars = self.vars

    if vars['bgNode'] then
        local frame_res = 'res/ui/event/bg_dragon_launch_legend_' .. attr .. '.png'
        vars['bgNode']:removeAllChildren()
        local frame = cc.Scale9Sprite:create(frame_res)
        frame:setDockPoint(CENTER_POINT)
	    frame:setAnchorPoint(CENTER_POINT)
        vars['bgNode']:addChild(frame)
    end
end

-------------------------------------
-- function summonUp
-- @brief 확률업이 걸렸을 때 라벨 표시
-------------------------------------
function UI_EventDragonLaunchLegend:summonUp(did)
    local is_chance_up = false
    local chance_up = g_eventData:getChanceUpDragons()
    for _, v in pairs(chance_up) do
        if (v['did'] == did) then
            is_chance_up = true
        end
    end
    if (is_chance_up == true) then
        self.vars['summonLabel']:setVisible(true)
    else
        self.vars['summonLabel']:setVisible(false)
    end
end
    
-------------------------------------
-- function getDidFromAttr
-------------------------------------
function UI_EventDragonLaunchLegend:getDidFromAttr(target_attr)
    for _, did in pairs(self.m_newDragonList) do
        local attr = string.sub(did, 6, 6)
        if (tonumber(attr) == target_attr) then
            return did
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventDragonLaunchLegend:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventDragonLaunchLegend:refresh()
end

-------------------------------------
-- function setDragon
-------------------------------------
function UI_EventDragonLaunchLegend:setDragon(did)
    local vars = self.vars
    local evolution = 3
    local flv = 0
    local table_dragon = TableDragon()
    local attr = table_dragon:getDragonAttr(did)

    self.m_dragonAnimator:setDragonAnimator(did, evolution, flv)
    self.m_dragonAnimator.vars['talkMenu']:setVisible(false)
    self.m_dragonAnimator:setScale(0.8)
    self.m_dragonAnimator:setTalkEnable(false)

    -- 배경
    -- 배경은 기존 배경을 사용하지 않고 setBgNode 함수에서 새로운 배경 사용

    local table_dragon = TableDragon()

    local attr = table_dragon:getDragonAttr(did)
    local role_type = table_dragon:getDragonRole(did)
    local rarity_type = table_dragon:getValue(did, 'rarity')
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)

    -- 이름
    local name = table_dragon:getChanceUpDragonName(did)
    vars['nameLabel']:setString(name)

    -- 희귀도
    vars['rarityNode']:removeAllChildren()
    DragonInfoIconHelper.setDragonRarityBtn(rarity_type, vars['rarityNode'], vars['rarityLabel'], t_info)

    -- 역할
    vars['typeNode']:removeAllChildren()
    DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'], t_info)
    
    -- 속성
    vars['attrNode']:removeAllChildren()
    DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)
end

-------------------------------------
-- function addSameTypeDragon
-- @brief 같은 타입 드래곤 리스트
-------------------------------------
function UI_EventDragonLaunchLegend:addSameTypeDragon()
    local vars = self.vars

    local l_attr = getAttrTextList()
    self.m_mapAttrBtnUI = {}

    for _, attr in ipairs(l_attr) do
        local node = vars[attr..'Node']
        node:removeAllChildren()

        local ui = UI()
        ui:load('book_detail_popup_attr_btn.ui')
        node:addChild(ui.root)
        ui.vars[attr..'Sprite']:setVisible(true)
        ui.vars['disableSprite']:setVisible(true)
        self.m_mapAttrBtnUI[attr] = ui
    end
    

    for k, v in pairs(self.m_newDragonAttrList) do
        local attr = ''
        if (v == 1) then
            attr = 'earth'
        elseif (v == 2) then
            attr = 'water'
        elseif (v == 3) then
            attr = 'fire'
        elseif (v == 4) then
            attr = 'light'
        else
            attr = 'dark'
        end
        local ui = self.m_mapAttrBtnUI[attr]
        ui.vars['disableSprite']:setVisible(false)
        -- 존재하는 속성만 클릭 핸들러 등록
        ui.vars['attrBtn']:registerScriptTapHandler(function()
            self:clickAttrBtn(attr)
        end)
    end
end

--@CHECK
UI:checkCompileError(UI_EventDragonLaunchLegend)