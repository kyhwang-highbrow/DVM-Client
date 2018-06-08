local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_LobbyGuideArena
-------------------------------------
UI_LobbyGuideArena = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LobbyGuideArena:init()
	local vars = self:load('lobby_guide_arena.ui')
	UIManager:open(self, UIManager.SCENE)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_LobbyGuideArena')

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
function UI_LobbyGuideArena:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_LobbyGuideArena'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('도움말')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LobbyGuideArena:initUI()
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
function UI_LobbyGuideArena:initButton()
    local vars = self.vars
    vars['questLinkBtn']:registerScriptTapHandler(function() self:click_questLinkBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LobbyGuideArena:refresh()
    local vars = self.vars

    vars['descLabel']:setString(Str('콜로세움'))

    -- 어려움 12-7
    vars['npcSpeechLabel']:setString(Str('{@subject}콜로세움 20회{@default} 참여시 {@item_name}캡슐코인{@default}을 획득할 수 있어요!\n콜로세움에서 마스터의 실력을 보여주세요!'))

    -- 주간 참여 보상
    local struct_user_info = g_arenaData:getPlayerArenaUserInfo()
    if struct_user_info then
	    local curr_cnt = struct_user_info:getWinCnt() + struct_user_info:getLoseCnt()
	    local temp
	    if curr_cnt > 20 then
		    temp = 4
	    else
		    temp = math_floor(curr_cnt/5)
	    end
	    vars['rewardVisual']:changeAni('reward_' .. temp, true)
    end
end

-------------------------------------
-- function click_questLinkBtn
-- @brief 바로가기
-------------------------------------
function UI_LobbyGuideArena:click_questLinkBtn()
    -- 아레나 이동
    UINavigator:goTo('arena')
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_LobbyGuideArena:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_LobbyGuideArena)