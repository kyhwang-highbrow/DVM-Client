local PARENT = UI

-------------------------------------
-- class UI_CommunityPopup
-------------------------------------
UI_CommunityPopup = class(PARENT,{
    m_naverBtn = 'UIC_Button',
    m_facebookBtn = 'UIC_Button',
    m_instagramBtn = 'UIC_Button',

    m_closeBtn = 'UIC_Button',
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

    self.m_naverBtn = vars['naverBtn']
    self.m_facebookBtn = vars['facebookBtn']
    self.m_instagramBtn = vars['instaBtn']

    self.m_closeBtn = vars['closeBtn']
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CommunityPopup:initButton()
    local vars = self.vars
    local curLang = Translate:getGameLang()
    local isKorean = curLang == 'ko'

    -- x버튼
    if self.m_closeBtn then
        self.m_closeBtn:registerScriptTapHandler(function() self:click_closeBtn() end)
    end

    -- 네이버 버튼
    if self.m_naverBtn then
        -- 한국어만 네이버 버튼이 보임
        -- if 에 안걸리면 한국어가 아니기 때문에 오브젝트만 있으면 하이드
        if isKorean then
            self.m_naverBtn:registerScriptTapHandler(function() self:click_naver() end)
        elseif self.m_naverBtn then
            self.m_naverBtn:setVisible(false)
        end
    end

    -- 페이스북 버튼
    if self.m_facebookBtn then
        self.m_facebookBtn:registerScriptTapHandler(function() self:click_facebook() end)
    end

    -- 인스타 버튼
    if self.m_instagramBtn then
        self.m_instagramBtn:registerScriptTapHandler(function() self:click_instagram() end)
    end
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_CommunityPopup:refresh()
    -- 하나라도 null이면 정렬을 그만두자.
    if not (self.m_naverBtn and self.m_facebookBtn and self.m_instagramBtn) then return end

    local isNaverActive = self.m_naverBtn:isVisible()

    -- 활성화 상태는 네이버만 체크하면 된다.
    -- 추후 커뮤니티는 절대 늘리지는 않는다고 하니 위치를 박아넣어도 무방하다고 판단됨
    if isNaverActive then
        self.m_naverBtn:setPosition(0, 44)
        self.m_facebookBtn:setPosition(0, -30)
        self.m_instagramBtn:setPosition(0, -105)
    else
        self.m_facebookBtn:setPosition(0, 6)
        self.m_instagramBtn:setPosition(0, -67)
    end
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
    -- TODO
    -- 링크를 저장할 곳을 찾아서 보금자리를 마련해주자
    SDKManager:goToWeb('https://www.facebook.com/DragonVillageM')
end

-------------------------------------
-- function click_instagram
-------------------------------------
function UI_CommunityPopup:click_instagram()
    -- TODO
    -- 링크를 저장할 곳을 찾아서 보금자리를 마련해주자
    SDKManager:goToWeb('https://www.instagram.com/dragonvillage_m/')
end
