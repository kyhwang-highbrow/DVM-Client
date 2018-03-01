local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_LobbyGuideWeeklyShop
-------------------------------------
UI_LobbyGuideWeeklyShop = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LobbyGuideWeeklyShop:init()
	local vars = self:load('lobby_guide_weekly_shop.ui')
	UIManager:open(self, UIManager.SCENE)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_LobbyGuideWeeklyShop')

	-- @UI_ACTION
	self:doActionReset()
	self:doAction(nil, false)

	self:initUI()
	self:initButton()
	self:refresh()

    self:sceneFadeInAction()

	SoundMgr:playBGM('bgm_lobby')
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_LobbyGuideWeeklyShop:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_LobbyGuideWeeklyShop'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('도움말')
    self.m_subCurrency = 'clancoin'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LobbyGuideWeeklyShop:initUI()
    local vars = self.vars

    -- npc 일러스트
    -- res/character/npc/narvi/narvi.spine
    -- res/character/dragon/aphrodite_fire_03/aphrodite_fire_03.spine
    -- npcNode
    -- dragonNode
    local res = 'res/character/npc/narvi/narvi.spine'
    if self:checkVarsKey('npcNode', res) then
	    vars['npcNode']:removeAllChildren(true)
        local animator = MakeAnimator(res)
        animator:changeAni('idle', true)
        vars['npcNode']:addChild(animator.m_node)
    end

    -- 명에 스킬 슬라임 아이템
    local product_honor = g_shopDataNew:getProduct('honor', 50006)
    local product_ui = UI_ProductSmall(product_honor)
    vars['productNode1']:addChild(product_ui.root)
    product_ui:setBuyCB(function() product_ui:refresh() end)

    -- 클랜코인 스킬 슬라임 아이템
    local product_clancoin = g_shopDataNew:getProduct('clancoin', 60010)
    local product_ui = UI_ProductSmall(product_clancoin)
    vars['productNode2']:addChild(product_ui.root)
    product_ui:setBuyCB(function() product_ui:refresh() end)

    -- 상점에서 명예 추가
    if (g_topUserInfo) then
        g_topUserInfo:makeGoodsUI('honor', 5) 
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LobbyGuideWeeklyShop:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LobbyGuideWeeklyShop:refresh()
    local vars = self.vars

    vars['descLabel']:setString(Str('주간 구매 가능'))  
    vars['npcSpeechLabel']:setString(Str('스킬 레벨업 재료로 사용할 수 있는 신비한 슬라임'))
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_LobbyGuideWeeklyShop:click_exitBtn()
    self:close()
end

-------------------------------------
-- function onDestroyUI
-------------------------------------
function UI_LobbyGuideWeeklyShop:onDestroyUI()
    if (g_topUserInfo) then
        g_topUserInfo:deleteGoodsUI('honor') 
    end
end

--@CHECK
UI:checkCompileError(UI_LobbyGuideWeeklyShop)