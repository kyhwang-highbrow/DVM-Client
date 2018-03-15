local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_LobbyGuideColosseum
-------------------------------------
UI_LobbyGuideColosseum = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LobbyGuideColosseum:init()
	local vars = self:load('lobby_guide_colosseum.ui')
	UIManager:open(self, UIManager.SCENE)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_LobbyGuideColosseum')

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
function UI_LobbyGuideColosseum:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_LobbyGuideColosseum'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('도움말')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LobbyGuideColosseum:initUI()
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
function UI_LobbyGuideColosseum:initButton()
    local vars = self.vars
    vars['questLinkBtn']:registerScriptTapHandler(function() self:click_questLinkBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LobbyGuideColosseum:refresh()
    local vars = self.vars

    vars['descLabel']:setString(Str('콜로세움'))

    -- 어려움 12-7
    vars['npcSpeechLabel']:setString(Str('{@subject}콜로세움 20승{@default}을 달성하면 {@item_name}캡슐코인{@default}을 획득할 수 있어요!\n콜로세움에서 마스터의 실력을 보여주세요!'))

    -- 주간 승수 보상
    local struct_user_info = g_colosseumData:getPlayerColosseumUserInfo()
    if struct_user_info then
	    local curr_win = struct_user_info:getWinCnt()
	    local temp
	    if curr_win > 20 then
		    temp = 4
	    else
		    temp = math_floor(curr_win/5)
	    end
	    vars['rewardVisual']:changeAni('reward_' .. temp, true)
    end
end

-------------------------------------
-- function click_questLinkBtn
-- @brief 바로가기
-------------------------------------
function UI_LobbyGuideColosseum:click_questLinkBtn()
    -- 모험 모드로 이동
    UINavigator:goTo('colosseum')
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_LobbyGuideColosseum:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_LobbyGuideColosseum)