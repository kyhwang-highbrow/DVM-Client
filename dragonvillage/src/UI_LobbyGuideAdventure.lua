local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_LobbyGuideAdventure
-------------------------------------
UI_LobbyGuideAdventure = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LobbyGuideAdventure:init()
	local vars = self:load('lobby_guide_adventure.ui')
	UIManager:open(self, UIManager.SCENE)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_LobbyGuideAdventure')

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
function UI_LobbyGuideAdventure:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_LobbyGuideAdventure'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('도움말')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LobbyGuideAdventure:initUI()
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
function UI_LobbyGuideAdventure:initButton()
    local vars = self.vars
    vars['questLinkBtn']:registerScriptTapHandler(function() self:click_questLinkBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LobbyGuideAdventure:refresh()
    local vars = self.vars

    vars['descLabel']:setString(Str('모험'))

    -- 어려움 12-7
    if (not g_adventureData:isClearStage(1121207)) then
        vars['npcSpeechLabel']:setString(Str('{@diff_hard}어려움 12-7{@default}을 정복하면 {@item_name}전설의 알{@default}을 획득할 수 있어요!\n저와 함께 모험을 떠나볼까요?'))
        
        vars['rewardNode']:removeAllChildren(true)
        local item = UI_ItemCard(703005, 1)
        vars['rewardNode']:addChild(item.root)
        return
    end

    -- 지옥 12-7
    if (not g_adventureData:isClearStage(1131207)) then
        vars['npcSpeechLabel']:setString(Str('{@diff_hell}지옥 12-7{@default}을 정복하면 {@item_name}빛나는 전설의 알{@default}을 획득할 수 있어요!\n저와 함께 모험을 떠나볼까요?'))

        vars['rewardNode']:removeAllChildren(true)
        local item = UI_ItemCard(703001, 1)
        vars['rewardNode']:addChild(item.root)
        return
    end   
end

-------------------------------------
-- function click_questLinkBtn
-- @brief 바로가기
-------------------------------------
function UI_LobbyGuideAdventure:click_questLinkBtn()

    local stage_id = nil

    -- 난이도
    for difficulty=MAX_ADVENTURE_DIFFICULTY, 1, -1 do
        if stage_id then break end

        -- 챕터
        for chapter=MAX_ADVENTURE_CHAPTER, 1, -1 do
            if stage_id then break end

            -- 스테이지
            for stage=MAX_ADVENTURE_STAGE, 1, -1 do
                if stage_id then break end
                local stage_id_ = makeAdventureID(difficulty, chapter, stage)
                if g_adventureData:isOpenStage(stage_id_) then
                    stage_id = stage_id_
                end
            end
        end    
    end

    -- 모험 모드로 이동
    UINavigator:goTo('adventure', stage_id)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_LobbyGuideAdventure:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_LobbyGuideAdventure)