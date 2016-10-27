local PARENT = UI

-------------------------------------
-- class UI_TopUserInfo
-------------------------------------
UI_TopUserInfo = class(PARENT,{
        m_lOwnerUI = 'list',
        m_ownerUIIdx = 'number',

        m_lNumberLabel = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TopUserInfo:init()
    local vars = self:load('top_user_info.ui')

    g_userDataOld.m_staminaList['st_ad']:addChangeCB(function(str)
        local msg = comma_value(g_userDataOld.m_staminaList['st_ad'].m_stamina)
        vars['actingPowerTimeLabel']:setString(str)
    end)

    --vars['exitBtn']:setVisible(false)

    vars['exitBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['st_ad_btn']:registerScriptTapHandler(function() self:click_st_ad_btn() end)
    vars['mailBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"우편함" 미구현') end)
    vars['chatBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"채팅" 미구현') end)
    

    self.m_lNumberLabel = {}
    self.m_lNumberLabel['gold'] = NumberLabel(vars['goldLabel'], 0, 0.3)
    self.m_lNumberLabel['cash'] = NumberLabel(vars['rubyLabel'], 0, 0.3)
    self.m_lNumberLabel['st_ad'] = NumberLabel(vars['actingPowerLabel'], 0, 0.3)

    self:clearOwnerUI()
end

-------------------------------------
-- function refreshData
-------------------------------------
function UI_TopUserInfo:refreshData()
    local vars = self.vars

    local gold = g_userDataOld.m_userData['gold']
    local cash = g_userDataOld.m_userData['cash']
    
    --vars['goldLabel']:setString(comma_value(gold))
    self.m_lNumberLabel['gold']:setNumber(gold)
    --vars['rubyLabel']:setString(comma_value(cash))
    self.m_lNumberLabel['cash']:setNumber(cash)

    -- 모험 스태미너
    local st_ad = g_userDataOld.m_staminaList['st_ad'].m_stamina
    --vars['actingPowerLabel']:setString(st_ad)
    self.m_lNumberLabel['st_ad']:setNumber(st_ad)
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
end

-------------------------------------
-- function changeOwnerUI
-------------------------------------
function UI_TopUserInfo:changeOwnerUI(ui)
    local vars = self.vars
    vars['exitBtn']:setVisible(ui.m_bUseExitBtn)

    if ui.m_titleStr then
        --vars['titleBgSprite']:setVisible(true)
        vars['titleLabel']:setVisible(true)
        vars['titleLabel']:setString(ui.m_titleStr)
    else
        --vars['titleBgSprite']:setVisible(false)
        vars['titleLabel']:setVisible(false)
    end

    self.root:setVisible(ui.m_bVisible)
end
