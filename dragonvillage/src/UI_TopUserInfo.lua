local PARENT = UI

-------------------------------------
-- class UI_TopUserInfo
-------------------------------------
UI_TopUserInfo = class(PARENT,{
        m_lOwnerUI = 'list',
        m_ownerUIIdx = 'number',

        m_lNumberLabel = 'list',
		m_staminaType = 'string',

        m_mAddedSubCurrency = 'table'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TopUserInfo:init()
    local vars = self:load('top_user_info.ui')

    vars['exitBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['st_ad_btn']:registerScriptTapHandler(function() self:click_st_ad_btn() end)
    vars['settingBtn']:registerScriptTapHandler(function() self:click_settingBtn() end)
    vars['chatBtn']:registerScriptTapHandler(function() self:click_chatBtn() end)

    self.m_lNumberLabel = {}
    self.m_lNumberLabel['gold'] = NumberLabel(vars['goldLabel'], 0, 0.3)
    self.m_lNumberLabel['cash'] = NumberLabel(vars['cashLabel'], 0, 0.3)
    self.m_lNumberLabel['amethyst'] = NumberLabel(vars['amethystLabel'], 0, 0.3)
    self.m_lNumberLabel['st_ad'] = NumberLabel(vars['actingPowerLabel'], 0, 0.3)
    self.m_lNumberLabel['fp'] = NumberLabel(vars['fpLabel'], 0, 0.3)
    self.m_lNumberLabel['lactea'] = NumberLabel(vars['lacteaLabel'], 0, 0.3)
    
    self.m_mAddedSubCurrency = {}

    self:clearOwnerUI()

    -- UI가 enter로 진입되었을 때 update함수 호출
    self.root:registerScriptHandler(function(event)
        if (event == 'enter') then
            self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
        end
    end)
end

-------------------------------------
-- function refreshData
-------------------------------------
function UI_TopUserInfo:refreshData()
    local vars = self.vars

    local gold = g_userData:get('gold')
    local cash = g_userData:get('cash')
    local amethyst = g_userData:get('amethyst')
    local fp = g_userData:get('fp')
    local lactea = g_userData:get('lactea')
    
    self.m_lNumberLabel['gold']:setNumber(gold)
    self.m_lNumberLabel['cash']:setNumber(cash)
    self.m_lNumberLabel['amethyst']:setNumber(amethyst)

    -- 스태미너
    local st_ad = g_staminasData:getStaminaCount(self.m_staminaType)
    local max_cnt = g_staminasData:getStaminaMaxCnt(self.m_staminaType)
    --self.m_lNumberLabel['st_ad']:setNumber(st_ad)
    vars['actingPowerLabel']:setString(Str('{1}/{2}', st_ad, max_cnt))

    local str = g_staminasData:getChargeRemainText(self.m_staminaType)
    vars['actingPowerTimeLabel']:setString(str)

    self.m_lNumberLabel['fp']:setNumber(fp)

    self.m_lNumberLabel['lactea']:setNumber(lactea)

    for k, numberLabel in pairs(self.m_mAddedSubCurrency) do
        local value = g_userData:get(k) or 0
        numberLabel:setNumber(value)
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_TopUserInfo:click_exitBtn()
    local target_ui = self.m_lOwnerUI[1]
    if (not target_ui) then
        return
    end

    target_ui:click_exitBtn()
end

-------------------------------------
-- function click_st_ad_btn
-------------------------------------
function UI_TopUserInfo:click_st_ad_btn()
    self.vars['timeNode']:runAction(cc.ToggleVisibility:create())
end

-------------------------------------
-- function click_settingBtn
-------------------------------------
function UI_TopUserInfo:click_settingBtn()
    UI_Setting()
end

-------------------------------------
-- function click_chatBtn
-------------------------------------
function UI_TopUserInfo:click_chatBtn()
    g_chatManager:toggleChatPopup()
end

-------------------------------------
-- function pushOwnerUI
-------------------------------------
function UI_TopUserInfo:pushOwnerUI(ui)
    self.m_ownerUIIdx = (self.m_ownerUIIdx + 1)
    ui.m_ownerUIIdx = self.m_ownerUIIdx
    table.insert(self.m_lOwnerUI, 1, ui)

    self:changeOwnerUI(ui)
end

-------------------------------------
-- function popOwnerUI
-------------------------------------
function UI_TopUserInfo:popOwnerUI(ui)
    local change_owner_ui = false
    for i,v in ipairs(self.m_lOwnerUI) do
        if (ui.m_ownerUIIdx == v.m_ownerUIIdx) then
            table.remove(self.m_lOwnerUI, i)
            
            if (i == 1 ) and (0 < #self.m_lOwnerUI) then
                change_owner_ui = true
            end

            break
        end
    end

    if change_owner_ui then
        self:changeOwnerUI(self.m_lOwnerUI[1])
    end
end

-------------------------------------
-- function clearOwnerUI
-------------------------------------
function UI_TopUserInfo:clearOwnerUI()
    self.m_lOwnerUI = {}
    self.m_ownerUIIdx = 0

    -- 스태미너 업데이트 관련 임시 위치
    g_staminasData:updateOff()
end

-------------------------------------
-- function changeOwnerUI
-------------------------------------
function UI_TopUserInfo:changeOwnerUI(ui)
    self.root:removeFromParent()
    ui.root:addChild(self.root, 100)

    local vars = self.vars
    vars['exitBtn']:setVisible(ui.m_bUseExitBtn)

    if (ui.m_titleStr == -1) then
        vars['titleLabel']:setVisible(true)
    elseif ui.m_titleStr then
        vars['titleLabel']:setVisible(true)
        vars['titleLabel']:setString(ui.m_titleStr)
    else
        vars['titleLabel']:setVisible(false)
    end

    self.root:setVisible(ui.m_bVisible)
	
	-- 스태미나 관련
    self:setStaminaType(ui.m_staminaType)

    do -- 스태미너 업데이트 관련 임시 위치
        if ui.m_bVisible then
            g_staminasData:updateOn()
        else
            g_staminasData:updateOff()
        end
    end

    vars['chatBtn']:setVisible(ui.m_bShowChatBtn)

    -- 서브 재화
    self:setSubCurrency(ui.m_subCurrency)
    
    self:refreshData()
    self:doAction()
end

-------------------------------------
-- function setTitleString
-------------------------------------
function UI_TopUserInfo:setTitleString(str)
    self.vars['titleLabel']:setString(str)
end

-------------------------------------
-- function setGoldNumber
-------------------------------------
function UI_TopUserInfo:setGoldNumber(gold)
    self.m_lNumberLabel['gold']:setNumber(gold)
end

-------------------------------------
-- function setSubCurrency
-------------------------------------
function UI_TopUserInfo:setSubCurrency(subCurrency)
    local vars = self.vars

    -- 서브 재화
    vars['amethystNode']:setVisible(subCurrency == 'amethyst')
    vars['lacteaNode']:setVisible(subCurrency == 'lactea')
    vars['fpNode']:setVisible(subCurrency == 'fp')

    for k, _ in pairs(self.m_mAddedSubCurrency) do
        if (vars[k .. 'Node']) then
            vars[k .. 'Node']:setVisible(k == subCurrency)
        end
    end

    -- 해당 재화 타입의 노드가 없다면 추가
    if (not vars[subCurrency .. 'Node']) then
        local t_item = TableItem():getRewardItem(subCurrency)
        if (t_item) then
            local node = cc.Node:create()
            node:setDockPoint(CENTER_POINT)
            node:setAnchorPoint(CENTER_POINT)
            node:setPosition(-170, 0)
            node:setContentSize(180, 44)
            vars['actionNode']:addChild(node)

            --local res_icon = t_item['icon']
            local res_icon = string.format('res/ui/icon/inbox/inbox_%s.png', subCurrency)
            local icon = cc.Sprite:create(res_icon)
            if (icon) then
                icon:setDockPoint(cc.p(0, 0.5))
                icon:setAnchorPoint(cc.p(0, 0.5))
                icon:setPosition(-14, 2)
                icon:setContentSize(60, 60)
                node:addChild(icon)
            end

            local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 26, 2, cc.size(100, 49), cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
            label:setDockPoint(cc.p(1, 0.5))
            label:setAnchorPoint(cc.p(1, 0.5))
            label:setPosition(-16, -3)
            label:setContentSize(100, 49)
            node:addChild(label)

            vars[subCurrency .. 'Node'] = node
            vars[subCurrency .. 'Label'] = label

            local value = g_userData:get(subCurrency) or 0
            local numberLabel = NumberLabel(label, 0, 0.3)
            numberLabel:setNumber(value)

            self.m_mAddedSubCurrency[subCurrency] = numberLabel
        end
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_TopUserInfo:update(dt)
    self:refreshData()
end

-------------------------------------
-- function setStaminaType
-------------------------------------
function UI_TopUserInfo:setStaminaType(stamina_type)
    if (stamina_type == nil) then
        return
    end

    if (self.m_staminaType == stamina_type) then
        return
    end

    local vars = self.vars

    self.m_staminaType = stamina_type
    vars['staminaIconNode']:removeAllChildren()
    local icon = IconHelper:getStaminaInboxIcon(stamina_type)
    vars['staminaIconNode']:addChild(icon)
end

-------------------------------------
-- function noticeBroadcast
-------------------------------------
function UI_TopUserInfo:noticeBroadcast(msg, duration)
    local duration = duration or 2

    self.vars['noticeBroadcastLabel']:setString(msg)
    self.vars['noticeBroadcastNode']:setVisible(true)
    self.vars['noticeBroadcastNode']:stopAllActions()
    self.vars['noticeBroadcastNode']:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.Hide:create()))
end

-------------------------------------
-- function chatBroadcast
-------------------------------------
function UI_TopUserInfo:chatBroadcast(t_data)
    --ccdump(t_data)

    local msg = t_data['message']
    local nickname = t_data['nickname']
    local uid = t_data['uid']

    local rich_str = '{@SKILL_NAME}[' .. nickname .. '] {@SKILL_DESC}' .. msg
    self.vars['chatBroadcastLabel']:setString(rich_str)
    self.vars['chatBroadcastNode']:setVisible(true)
    self.vars['chatBroadcastNode']:stopAllActions()
    self.vars['chatBroadcastNode']:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.Hide:create()))
    --cclog(rich_str)
end