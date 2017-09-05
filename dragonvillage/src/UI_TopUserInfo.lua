local PARENT = UI

-------------------------------------
-- class UI_TopUserInfo
-------------------------------------
UI_TopUserInfo = class(PARENT,{
        m_lOwnerUI = 'list',
        m_ownerUIIdx = 'number',

		m_staminaType = 'string',

        m_mAddedSubCurrency = 'table',

        m_broadcastLabel = 'UIC_BroadcastLabel',
        m_chatBroadcastLabel = 'UIC_BroadcastLabel',

        m_mGoodsInfo = 'map[UI_GoodsInfo]',
        m_staminaInfo = 'UI_StaminaInfo',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TopUserInfo:init()
    local vars = self:load('top_user_info.ui')

    vars['exitBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    --vars['st_ad_btn']:registerScriptTapHandler(function() self:click_st_ad_btn() end)
    --vars['settingBtn']:registerScriptTapHandler(function() self:click_settingBtn() end)
    vars['quickBtn']:registerScriptTapHandler(function() self:click_quickPopupBtn() end)    
    vars['chatBtn']:registerScriptTapHandler(function() self:click_chatBtn() end)

    self:initGoodsUI()
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
-- function initGoodsUI
-------------------------------------
function UI_TopUserInfo:initGoodsUI()
    self.m_mGoodsInfo = {}
    self.m_mAddedSubCurrency = {}

    -- 붙박이 재화
    self:makeGoodsUI('gold', 2) -- param : goods_type, x_pos_idx
    self:makeGoodsUI('cash', 3) -- param : goods_type, x_pos_idx

    self.m_staminaInfo = UI_StaminaInfo:create()
    do -- addChild, 위치 조정
        local ui = self.m_staminaInfo
        local x_pos_idx = 1
        ui.root:setDockPoint(cc.p(1, 0.5))
        local pos_x = -258 - ((x_pos_idx-1) * 190)
        ui.root:setPosition(pos_x, 0)
        self.vars['actionNode']:addChild(ui.root)
    end
end

-------------------------------------
-- function refreshData
-------------------------------------
function UI_TopUserInfo:refreshData()

    for _,ui in pairs(self.m_mGoodsInfo) do
        ui:refresh()
    end

    self.m_staminaInfo:refresh()
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
    
    -- UI BGM 재생
    if (ui.m_uiBgm) then
        SoundMgr:playBGM(ui.m_uiBgm)
    end
    ui:onFocus()

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
-- function setEnabledBraodCast
-- @brief 방송, 채팅 라벨, 채팅 버튼 활성화/비활성화 
-------------------------------------
function UI_TopUserInfo:setEnabledBraodCast(enable)
    self.vars['quickBtn']:setEnabled(enable)   
    self.vars['chatBtn']:setEnabled(enable)  

    self.m_broadcastLabel.m_bEnabled = enable
    self.m_chatBroadcastLabel.m_bEnabled = enable

    if (not enable) then
        self.m_broadcastLabel:setVisible(false)
        self.m_chatBroadcastLabel:setVisible(false)
    end
end

-------------------------------------
-- function setSubCurrency
-------------------------------------
function UI_TopUserInfo:setSubCurrency(subCurrency)
    if isExistValue(subCurrency, 'money', 'cash', 'gold', 'package', 'st') then
        return
    end

    local goods_type = subCurrency

    -- 해당 타입의 ui가 생성되지 않았을 경우 생성
    if (not self.m_mGoodsInfo[goods_type]) then
        local ui = self:makeGoodsUI(goods_type, 4) -- param : goods_type, x_pos_idx
        self.m_mAddedSubCurrency[goods_type] = ui
    end

    -- 현재 지정된 서브 재화만 visible true
    for k, ui in pairs(self.m_mAddedSubCurrency) do
        ui.root:setVisible(k == goods_type)
    end
end

-------------------------------------
-- function makeGoodsUI
-- @brief 재화별 UI 생성
-------------------------------------
function UI_TopUserInfo:makeGoodsUI(goods_type, x_pos_idx)
    local vars = self.vars

    local ui = UI_GoodsInfo(goods_type)
    self.m_mGoodsInfo[goods_type] = ui

    -- addChild, 위치 조정
    ui.root:setDockPoint(cc.p(1, 0.5))
    local pos_x = -258 - ((x_pos_idx-1) * 190)
    ui.root:setPosition(pos_x, 0)
    vars['actionNode']:addChild(ui.root)

    return ui
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

    self.m_staminaInfo:setStaminaType(stamina_type)
end

-------------------------------------
-- function noticeBroadcast
-------------------------------------
function UI_TopUserInfo:noticeBroadcast(msg, duration)
    self.m_broadcastLabel:setString(msg)
end

-------------------------------------
-- function clearBroadcast
-------------------------------------
function UI_TopUserInfo:clearBroadcast()
    self.m_broadcastLabel:clear()
    self.m_chatBroadcastLabel:clear()
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