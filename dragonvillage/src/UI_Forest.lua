local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_Forest
-------------------------------------
UI_Forest = class(PARENT,{
        m_territory = 'ForestTerritory',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Forest:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Forest'
    self.m_uiBgm = 'bgm_lobby'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_bShowChatBtn = true
    self.m_titleStr = Str('드래곤의 숲')
end

-------------------------------------
-- function init
-------------------------------------
function UI_Forest:init()
    local vars = self:load('dragon_forest.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Forest')

    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/dragon_forest/dragon_forest.plist')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Forest:initUI()
    local vars = self.vars

    local territory = ForestTerritory(vars['cameraNode'])
    self.m_territory = territory
    self.m_territory:setUI(self)
	
	--self:initParticle()
end

-------------------------------------
-- function initParticle
-------------------------------------
function UI_Forest:initParticle()
	-- 저사양 모드에서는 실행하지 않는다.
	if (isLowEndMode()) then
		return
	end

	local particle = cc.ParticleSystemQuad:create("res/ui/particle/particle_cherry.plist")
	particle:setAnchorPoint(CENTER_POINT)
	particle:setDockPoint(CENTER_POINT)
	self.root:addChild(particle)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Forest:initButton()
    local vars = self.vars

    vars['levelupBtn']:registerScriptTapHandler(function() self:click_levelupBtn() end)
    vars['changeBtn']:registerScriptTapHandler(function() self:click_changeBtn() end)
    vars['helpBtn']:registerScriptTapHandler(function() self:click_helpBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Forest:refresh()
    self:refresh_cnt()
    self:refresh_happy()
    --self:refresh_noti()
    -- 광고 보기 버튼 체크
    self.vars['adBtn']:setVisible(g_advertisingData:isAllowToShow(DAILY_AD_KEY['FOREST']))
    self.vars['adBtn']:runAction(cca.buttonShakeAction(2, 2))
end

-------------------------------------
-- function refresh_cnt
-------------------------------------
function UI_Forest:refresh_cnt()
    local vars = self.vars

    -- 드래곤 수
    local curr_cnt = self.m_territory:getCurrDragonCnt()
    vars['dragonLabel']:setString(string.format('%d', curr_cnt))

    -- 드래곤 최대
    local max_cnt = ServerData_Forest:getInstance():getMaxDragon()
    vars['invenLabel']:setString(string.format('/%d', max_cnt))

    -- 드래곤의 숲 레벨
    local lv = ServerData_Forest:getInstance():getExtensionLV()
    local str = Str('Lv.{1}', lv)
    vars['forestLv']:setString(str)
end

-------------------------------------
-- function refresh_happy
-------------------------------------
function UI_Forest:refresh_happy()
    local vars = self.vars

    -- 만족도 바
    local happy_pnt = ServerData_Forest:getInstance():getHappy()
    vars['giftLabel']:setString(string.format('%.1f %%', happy_pnt/10))
    vars['giftGauge']:runAction(cc.ProgressTo:create(0.5, happy_pnt/10))
end

-------------------------------------
-- function refresh_noti
-- @comment 드래곤의 숲 내부 노티는 사용하지 않기로 하여 사용하는 곳이 없는 함수.
-------------------------------------
function UI_Forest:refresh_noti()
    local vars = self.vars

    -- 레벨업 가능할 때
    vars['levelupNotiSprite']:setVisible(ServerData_Forest:getInstance():isHighlightForest_lv())

    -- 배치 가능할 때
    local curr_cnt = self.m_territory:getCurrDragonCnt()
    local max_cnt = ServerData_Forest:getInstance():getMaxDragon()
    vars['changeNotiSprite']:setVisible(curr_cnt < max_cnt)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Forest:click_exitBtn()
	self:setExitEnbaled(false)

    local is_use_loading = true
    local scene = SceneLobby(is_use_loading)
    scene:runScene()
end

-------------------------------------
-- function click_changeBtn
-------------------------------------
function UI_Forest:click_changeBtn()
    local ui = UI_Forest_ChangePopup()

    -- 교체 했을 때만 체크
    ui:setChangeCB(function()
        -- 드래곤 다시 생성
        self.m_territory:initDragons()
    end)

    -- 닫을때 항상 체크
    ui:setCloseCB(function()
        self:refresh()
        self.m_territory:refreshStuffs()
        self:sceneFadeInAction()
    end)
end

-------------------------------------
-- function click_levelupBtn
-------------------------------------
function UI_Forest:click_levelupBtn()
    local t_stuff_object = self.m_territory:getStuffObjectTable()
    local ui = UI_Forest_StuffListPopup(t_stuff_object)

    local function close_cb()
        self:refresh()
        self.m_territory:refreshStuffs()
        self:sceneFadeInAction()
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_helpBtn
-------------------------------------
function UI_Forest:click_helpBtn()
    self.vars['helpNode']:runAction(cc.ToggleVisibility:create())
end