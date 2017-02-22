local PARENT = UI

-------------------------------------
-- class UI_TopUserInfo
-------------------------------------
UI_TopUserInfo = class(PARENT,{
        m_lOwnerUI = 'list',
        m_ownerUIIdx = 'number',

        m_lNumberLabel = 'list',
		m_staminaType = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TopUserInfo:init()
    local vars = self:load('top_user_info.ui')

    vars['exitBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['st_ad_btn']:registerScriptTapHandler(function() self:click_st_ad_btn() end)
    vars['settingBtn']:registerScriptTapHandler(function() self:click_settingBtn() end)
    vars['chatBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"채팅" 미구현') end)

    self.m_lNumberLabel = {}
    self.m_lNumberLabel['gold'] = NumberLabel(vars['goldLabel'], 0, 0.3)
    self.m_lNumberLabel['cash'] = NumberLabel(vars['rubyLabel'], 0, 0.3)
    self.m_lNumberLabel['st_ad'] = NumberLabel(vars['actingPowerLabel'], 0, 0.3)
    self.m_lNumberLabel['fp'] = NumberLabel(vars['fpLabel'], 0, 0.3)
    

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
    local fp = g_userData:get('fp')
    
    self.m_lNumberLabel['gold']:setNumber(gold)
    self.m_lNumberLabel['cash']:setNumber(cash)

    -- 스태미너
    local st_ad = g_staminasData:getStaminaCount(self.m_staminaType)
    self.m_lNumberLabel['st_ad']:setNumber(st_ad)

    local str = g_staminasData:getChargeRemainText(self.m_staminaType)
    vars['actingPowerTimeLabel']:setString(str)

    self.m_lNumberLabel['fp']:setNumber(fp)
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
    UI_SettingPopup()
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
	self.m_staminaType = ui.m_staminaType
	vars['stIcon']:setVisible((self.m_staminaType == GAME_MODE.ADVENTURE))
	vars['pvpIcon']:setVisible((self.m_staminaType == GAME_MODE.COLOSSEUM))

    do -- 스태미너 업데이트 관련 임시 위치
        if ui.m_bVisible then
            g_staminasData:updateOn()
        else
            g_staminasData:updateOff()
        end
    end

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
-- function update
-------------------------------------
function UI_TopUserInfo:update(dt)
    self:refreshData()
end