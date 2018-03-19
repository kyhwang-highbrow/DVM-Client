local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_LobbyGuideAncientTower
-------------------------------------
UI_LobbyGuideAncientTower = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LobbyGuideAncientTower:init()
	local vars = self:load('lobby_guide_ancient_tower.ui')
	UIManager:open(self, UIManager.SCENE)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_LobbyGuideAncientTower')

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
function UI_LobbyGuideAncientTower:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_LobbyGuideAncientTower'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('도움말')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LobbyGuideAncientTower:initUI()
    local vars = self.vars

    -- npc 일러스트
    -- res/character/dragon/aphrodite_fire_03/aphrodite_fire_03.spine
    -- res/character/npc/narvi/narvi.spine
    -- npcNode
    -- dragonNode
    local res = 'res/character/npc/narvi/narvi.spine'
    if self:checkVarsKey('npcNode', res) then
	    vars['npcNode']:removeAllChildren(true)
        local animator = MakeAnimator(res)
        animator:changeAni('idle', true)
        vars['npcNode']:addChild(animator.m_node)
    end

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LobbyGuideAncientTower:initButton()
    local vars = self.vars
    vars['questLinkBtn']:registerScriptTapHandler(function() self:click_questLinkBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LobbyGuideAncientTower:refresh()
    local vars = self.vars

    vars['descLabel']:setString(Str('고대의 탑'))

    local floor = 30
    if (30 <= g_ancientTowerData:getClearFloor()) then
        floor = 50
    end
    local msg = Str('{@subject}고대의 탑 {1}층{@default}을 정복하면 {@item_name}스킬슬라임{@default}을 획득할 수 있어요!\n고대의 탑에서 마스터의 실력을 보여주세요!', floor)
    vars['npcSpeechLabel']:setString(msg)

    vars['rewardNode']:removeAllChildren(true)
    local item = UI_ItemCard(779215, 1)
    vars['rewardNode']:addChild(item.root)
end

-------------------------------------
-- function click_questLinkBtn
-- @brief 바로가기
-------------------------------------
function UI_LobbyGuideAncientTower:click_questLinkBtn()
    -- 고대의 탑으로 이동
    UINavigator:goTo('ancient')
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_LobbyGuideAncientTower:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_LobbyGuideAncientTower)