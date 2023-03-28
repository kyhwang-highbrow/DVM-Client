local PARENT = UI

-------------------------------------
-- class UI_ScenarioPlayer
-------------------------------------
UI_ScenarioPlayer = class(PARENT,{
        m_currPage = 'number',
        m_maxPage = 'number',
        m_scenarioTable = 'table',

        m_titleUI = '',
		m_narrationUI = '',

        m_bgName = 'bg',
        m_bgAnimator = 'Animator',

        m_bgm = '',

        m_autoSkipActionNode = '',

        m_focusCharacter = '',
        m_mCharacter = '',

        m_bSkipEnable = 'bool',
        m_bNextEnable = 'bool',

        m_scenarioPlayerTalk = '',
        m_sceneCB = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ScenarioPlayer:init(scenario_name)
    -- spine 캐시 정리 확인
    SpineCacheManager:getInstance():purgeSpineCacheData()

    self:init_player()

	-- 멤버 변수
    self.m_scenarioPlayerTalk = UI_ScenarioPlayer_Talk(self)
    self.m_currPage = 0

    

	self:loadScenario(scenario_name)
    self.m_maxPage = table.count(self.m_scenarioTable)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function init_player
-------------------------------------
function UI_ScenarioPlayer:init_player()
    local vars = self:load_keepZOrder('scenario_talk.ui', false)

	UIManager:open(self, UIManager.SCENE)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_skip() end, 'UI_ScenarioPlayer')
	self.m_bSkipEnable = true
    self.m_bNextEnable = true

    SoundMgr:stopBGM()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ScenarioPlayer:initUI()
    local vars = self.vars

    -- 캐릭터 관련
    self.m_mCharacter = {}
    self.m_mCharacter['left'] = UI_ScenarioPlayer_Character('left', vars['tamerNode1'], vars['nameNode1'], vars['nameLabel1'], vars['talkSprite1'], vars['talkLabel1'])
    self.m_mCharacter['left']:setMonoTextNode(vars['textMomoSprite1'], vars['textMomoLabel1'])
    self.m_mCharacter['left'].m_bCharFlip = false
    self.m_mCharacter['left']:hide()

    self.m_mCharacter['right'] = UI_ScenarioPlayer_Character('right', vars['tamerNode2'], vars['nameNode2'], vars['nameLabel2'], vars['talkSprite2'], vars['talkLabel2'])
    self.m_mCharacter['right']:setMonoTextNode(vars['textMomoSprite2'], vars['textMomoLabel2'])
    self.m_mCharacter['right'].m_bCharFlip = true
    self.m_mCharacter['right']:hide()

    vars['illustrationMenu']:setVisible(false)

    self.m_autoSkipActionNode = cc.Node:create()
    self.root:addChild(self.m_autoSkipActionNode)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ScenarioPlayer:initButton()
    local vars = self.vars
    vars['nextBtn']:registerScriptTapHandler(function() self:click_next() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:click_skip() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ScenarioPlayer:refresh()
end

-------------------------------------
-- function click_skip
-------------------------------------
function UI_ScenarioPlayer:click_skip()
    if (not self.m_bSkipEnable) then
        return
    end
    SoundMgr:playPrevBGM()
    self:_close()
end

-------------------------------------
-- function click_next
-------------------------------------
function UI_ScenarioPlayer:click_next()
    if (not self.m_bNextEnable) then
        return
    end

    if self.m_titleUI ~= nil then
        self.vars['titleNode']:removeAllChildren()
        self.m_titleUI = nil
    end

    self:next()
end

-------------------------------------
-- function next
-------------------------------------
function UI_ScenarioPlayer:next()
	if (self.m_narrationUI) then
		return
	end

    -- spine 캐시 정리
    SpineCacheManager:getInstance():purgeSpineCacheData()

    self.m_currPage = self.m_currPage + 1

    if (self.m_currPage <= self.m_maxPage) then
        self:showPage()
    else
        self:_close()
    end
end

-------------------------------------
-- function showPage
-------------------------------------
function UI_ScenarioPlayer:showPage()
    -- 2018-05-03 sgkim
    -- 타이밍 이슈로 ui가 삭제된 후 showPage가 콜이 되는경우가 있음
    if (self.root == nil) then
        return
    end

    local vars = self.vars

    do -- 이전 페이지에서 끊어줘야할 행동들
        self.m_autoSkipActionNode:stopAllActions()
    end

    local t_page = self.m_scenarioTable[self.m_currPage]

    -- 배경 교체
    if (t_page['bg'] and (t_page['bg'] ~= self.m_bgName)) then
        self:changeBg(t_page['bg'])
    end

    do -- 삽화
        local illustration = t_page['illustration']
        if illustration then

            if (illustration == 'hide' or illustration == 'clear') then
                vars['illustrationMenu']:setVisible(false)
            else
                vars['illustrationMenu']:setVisible(true)

                vars['illustrationNode']:removeAllChildren()
                local bg_res = TableScenarioResource:getScenarioRes(illustration)
                local bg = MakeAnimator(bg_res)
                vars['illustrationNode']:addChild(bg.m_node)
            end
        end
    end

    -- 캐릭터
    do
        if (t_page['char'] and t_page['char_pos']) then
            local character = self.m_mCharacter[t_page['char_pos']]
            character:setCharacter(t_page['char'])

            if t_page['char_ani'] then
                character:setCharAni(t_page['char_ani'])
            end

            self:setFocusCharacter(character)
        end
    end

    do -- 캐릭터 이펙트
        if (t_page['char_pos'] and t_page['char_effect']) then
            self.m_mCharacter[t_page['char_pos']]:applyCharEffect(t_page['char_effect'])
        end
    end
    
    do -- 대사
        local text_type = t_page['text_type']
        if (text_type == 'narrate') then
            self:effect_narrate(t_page)
			-- narration이 있을 경우 해당 UI에서 skip 제어, 좀 이상한데 구조 크게 바꾸지 않는 선에서 함
			t_page['auto_skip'] = nil
        else
            local char_pos = t_page['char_pos']
            local char_name = (t_page['t_char_name'] or t_page['char'])
			local text = t_page['t_text']
			local text_pos = t_page['text_pos']
            self.m_scenarioPlayerTalk:setTalk(char_pos, char_name, text, text_type, text_pos)
        end
    end

    do -- 배경음
        local bgm = t_page['bgm']
        if bgm then
            if (bgm == 'off') then
                SoundMgr:stopBGM()
            else
                SoundMgr:playBGM(bgm)
                self.m_bgm = bgm
            end
        end

        local bgm_action = t_page['bgm_action']
        if bgm_action then
            if (bgm_action == 'volume_down') then
                SoundMgr:setMusicVolume(0.5)

            elseif (bgm_action == 'volume_reset') then
                SoundMgr:setMusicVolume(1)

            elseif (bgm_action == 'off') then
                SoundMgr:stopBGM()
            end
            
        end
    end

    do -- 사운드
        local sound = t_page['sound']
		if (sound == 'prologue') then
			SoundMgr:playEffect('EFFECT', sound)		
		elseif (sound) then
			SoundMgr:playEffect('EFX', sound)
		end
    end

    do -- 이전에 disable시킨 것 해제
        self.m_bSkipEnable = true
        self.m_bNextEnable = true
        self.vars['skipBtn']:setVisible(true)
        self.vars['nextBtn']:setEnabled(true)
        self.vars['nextVisual']:setVisible(true)
    end

    -- 지정된 효과 실행
    for i = 1, 5 do
        local effect = t_page['effect_' .. i]
        if (effect) and (effect ~= '') then
            self:applyEffect(t_page['effect_' .. i])
        end
    end 

    -- 자동 넘김
    if (t_page['auto_skip']) then
		local time = tonumber(t_page['auto_skip'])
        if (time == 0) then
            self:next()
        else
            local action = cc.Sequence:create(cc.DelayTime:create(time), cc.CallFunc:create(function() self:next() end))
            self.m_autoSkipActionNode:runAction(action)
        end
    end
end
--[[ 
-------------------------------------
-- function applyEffect
-------------------------------------
function UI_ScenarioPlayer:applyEffect(effect)
    if (not effect) then
        return
    end

    local l_str = TableClass:seperate(effect, ';')
    local effect = l_str[1]
    local val_1 = l_str[2]
    local val_2 = l_str[3]

    self[effect](val_1, val_2)
end ]]

-------------------------------------
-- function isExistEffect
-------------------------------------
function UI_ScenarioPlayer:isExistEffect(page_no, find)
    local t_page = self.m_scenarioTable[self.m_currPage]
    if (t_page) then
        for i = 1, 3 do
            local effect = t_page['effect_' .. i]
            local l_str = TableClass:seperate(effect, ';')
            for _i, _v in ipairs(l_str) do
                if (string.match(_v, find)) then
                    return true
                end
            end
        end 
    end
    return false
end

-------------------------------------
-- function setReplaceSceneCB
-------------------------------------
function UI_ScenarioPlayer:setReplaceSceneCB(scene_cb)
    self.m_sceneCB = scene_cb
end

-------------------------------------
-- function _close
-------------------------------------
function UI_ScenarioPlayer:_close()
    if (self.m_sceneCB) then
        UI_BlockPopup()
        self.m_sceneCB()
        self.m_sceneCB = nil
    else
        self:close()
    end
end

-------------------------------------
-- function onClose
-------------------------------------
function UI_ScenarioPlayer:onClose()
    -- 볼륨 원복 (시나리오 재생 중 volume_down으로 50%로 줄었을 수 있음)
    SoundMgr:setMusicVolume(1)

    -- 시나리오에서 재생된 BGM이면 stop
    if self.m_bgm then
        SoundMgr:stopBGM()
    end

    PARENT.onClose(self)

    -- spine 캐시 정리 확인
    SpineCacheManager:getInstance():purgeSpineCacheData()
end