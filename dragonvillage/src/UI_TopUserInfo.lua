local PARENT = UI

-------------------------------------
-- class UI_TopUserInfo
-------------------------------------
UI_TopUserInfo = class(PARENT,{
        m_lOwnerUI = 'list',
        m_ownerUIIdx = 'number',

        m_lNumberLabel = 'list',
		m_staminaType = 'string',

        m_mAddedSubCurrency = 'table',

        m_broadcastLabel = 'UIC_BroadcastLabel',
        m_chatBroadcastLabel = 'UIC_BroadcastLabel',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TopUserInfo:init()
    local vars = self:load('top_user_info.ui')

    vars['exitBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['st_ad_btn']:registerScriptTapHandler(function() self:click_st_ad_btn() end)
    --vars['settingBtn']:registerScriptTapHandler(function() self:click_settingBtn() end)
    vars['settingBtn']:registerScriptTapHandler(function() self:click_quickPopupBtn() end)    
    vars['chatBtn']:registerScriptTapHandler(function() self:click_chatBtn() end)

    self.m_lNumberLabel = {}
    self.m_lNumberLabel['gold'] = NumberLabel(vars['goldLabel'], 0, 0.3)
    self.m_lNumberLabel['cash'] = NumberLabel(vars['cashLabel'], 0, 0.3)
    self.m_lNumberLabel['amethyst'] = NumberLabel(vars['amethystLabel'], 0, 0.3)
    self.m_lNumberLabel['st_ad'] = NumberLabel(vars['actingPowerLabel'], 0, 0.3)
    self.m_lNumberLabel['fp'] = NumberLabel(vars['fpLabel'], 0, 0.3)
    
    self.m_mAddedSubCurrency = {}

    self:clearOwnerUI()

    -- UI가 enter로 진입되었을 때 update함수 호출
    self.root:registerScriptHandler(function(event)
        if (event == 'enter') then
            self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
        end
    end)


    self.m_broadcastLabel = UIC_BroadcastLabel:create(vars['noticeBroadcastNode'], vars['noticeBroadcastLabel'])
    self.m_chatBroadcastLabel = UIC_BroadcastLabel:create(vars['chatBroadcastNode'], vars['chatBroadcastLabel'])
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
-- function click_quickPopupBtn
-------------------------------------
function UI_TopUserInfo:click_quickPopupBtn()
    UI_QuickPopup()
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

    if isExistValue(subCurrency, 'money', 'cash', 'gold', 'package', 'st') then
        return
    end

    local vars = self.vars

    -- 서브 재화
    vars['amethystNode']:setVisible(subCurrency == 'amethyst')
    vars['fpNode']:setVisible(subCurrency == 'fp')

    for k, _ in pairs(self.m_mAddedSubCurrency) do
        if (vars[k .. 'Node']) then
            vars[k .. 'Node']:setVisible(k == subCurrency)
        end
    end

    -- 해당 재화 타입의 노드가 없다면 추가
    if (not vars[subCurrency .. 'Node']) then

        local ui = UI()
        ui:load('top_user_info_goods.ui')

        do -- 재화 아이콘 생성
            local res_icon = string.format('res/ui/icon/inbox/inbox_%s.png', subCurrency)
            local icon = cc.Sprite:create(res_icon)
            if (icon) then
                icon:setDockPoint(cc.p(0.5, 0.5))
                icon:setAnchorPoint(cc.p(0.5, 0.5))
                ui.vars['iconNode']:addChild(icon)
            end
        end

        -- 메인 클래스에서 관리 가능하도록 vars에 저장
        vars[subCurrency .. 'Node'] = ui.root
        vars[subCurrency .. 'Label'] = ui.vars['label']

        -- NumberLabel객체 생성
        local value = g_userData:get(subCurrency) or 0
        local numberLabel = NumberLabel(ui.vars['label'], 0, 0.3)
        numberLabel:setNumber(value)
        self.m_mAddedSubCurrency[subCurrency] = numberLabel

        -- addChild, 위치 조정
        ui.root:setPosition(-170, 0)
        vars['actionNode']:addChild(ui.root)
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
    self.m_broadcastLabel:setString(msg)
end

-------------------------------------
-- function chatBroadcast
-------------------------------------
function UI_TopUserInfo:chatBroadcast(t_data)
    local vars = self.vars
    --ccdump(t_data)

    local msg = t_data['message']
    local nickname = t_data['nickname']
    local uid = t_data['uid']

    if (not msg) or (not nickname) or (not uid) then
        return
    end

    local rich_str = '{@SKILL_NAME}[' .. nickname .. '] {@SKILL_DESC}' .. msg

    --[[
    self.vars['chatBroadcastLabel']:setString(rich_str)
    self.vars['chatBroadcastNode']:setVisible(true)
    self.vars['chatBroadcastNode']:stopAllActions()
    self.vars['chatBroadcastNode']:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.Hide:create()))
    --cclog(rich_str)

    -- 리치텍스트의 가로 길이를 얻어옴
    local label_width = self.vars['chatBroadcastLabel']:getStringWidth()

    -- scale9sprite의 크기를 정함 (리치텍스트의 가로 길이를 참고해서)
    local size = cc.size(vars['chatBroadcastNode']:getNormalSize())
    size['width'] = math_max(label_width + 10, 30) -- 말풍선은 최소 30픽셀
    vars['chatBroadcastNode']:setNormalSize(size)

    -- scale9sprite의 setNormalSize를 했을 때 자식들의 layout이 제대로 반영되지 않아서 강제로 호출
    self.vars['chatBroadcastNode']:setUpdateChildrenTransform()
    --]]

    self.m_chatBroadcastLabel:setString(rich_str)
end

-------------------------------------
-- function hide
-------------------------------------
function UI_TopUserInfo:hide()
	self.root:runAction(cc.MoveTo:create(0.5, cc.p(0, 200)))
end

-------------------------------------
-- function hide
-------------------------------------
function UI_TopUserInfo:show()
	self.root:runAction(cc.MoveTo:create(0.5, cc.p(0, 0)))
end