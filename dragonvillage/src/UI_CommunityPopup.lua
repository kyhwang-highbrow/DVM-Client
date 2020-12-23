local PARENT = UI

-------------------------------------
-- class UI_CommunityPopup
-------------------------------------
UI_CommunityPopup = class(PARENT,{

    })

-------------------------------------
-- function init
-------------------------------------
function UI_CommunityPopup:init(t_notice)
    local vars = self:load('setting_popup_community.ui')

    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventIncarnationOfSinsRankingPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CommunityPopup:initUI()
    -- UI Object
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CommunityPopup:initButton()
    local vars = self.vars
    local curLang = Translate:getGameLang()

    self:initBtnEvent('closeBtn', function() self:click_closeBtn() end)

    -- 한국만 오픈
    if curLang == 'ko' then
        self:initBtnEvent('naverBtn', function() self:click_naver() end)
    elseif vars['naverBtn'] then
        vars['naverBtn']:setVisible(false)
    end
    
    self:initBtnEvent('facebookBtn', function() self:click_facebook() end)
    self:initBtnEvent('instaBtn', function() self:click_instagram() end)
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_CommunityPopup:refresh()
end

-------------------------------------
-- function setBtnBlock
-------------------------------------
function UI_CommunityPopup:setBtnBlock()
end

-------------------------------------
-- function click_checkBtn
-------------------------------------
function UI_CommunityPopup:click_checkBtn()

end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_CommunityPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function initBtnEvent
-------------------------------------
function UI_CommunityPopup:initBtnEvent(lua_name, callback)
    local btnClose = self.vars[lua_name]

    if btnClose then
        btnClose:registerScriptTapHandler(callback)
    end
end

-------------------------------------
-- function click_naver
-------------------------------------
function UI_CommunityPopup:click_naver(lua_name, callback)
    local plug_url = NaverCafeManager:getUrlByChannel(nil) -- article_id
    SDKManager:goToWeb(plug_url)
end

-------------------------------------
-- function click_facebook
-------------------------------------
function UI_CommunityPopup:click_facebook()
    local plug_url = NaverCafeManager:getUrlByChannel(nil) -- article_id
    SDKManager:goToWeb(plug_url)
end

-------------------------------------
-- function click_instagram
-------------------------------------
function UI_CommunityPopup:click_instagram()
    local plug_url = NaverCafeManager:getUrlByChannel(nil) -- article_id
    SDKManager:goToWeb(plug_url)
end
