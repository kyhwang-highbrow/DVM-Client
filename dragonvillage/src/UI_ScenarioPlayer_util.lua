-------------------------------------
-- function getCSVHeader
-------------------------------------
function UI_ScenarioPlayer:getCSVHeader(csv)
    local header = {}
    for i=1,#csv do
        header[i] = string.match(csv[i], '[A-Za-z%d_-]+')
    end
    return header
end

-------------------------------------
-- function loadScenario
-------------------------------------
function UI_ScenarioPlayer:loadScenario(scenario_name)
    local filename = scenario_name
    local content = TABLE:loadTableFile('scenario/' .. filename, '.csv')

    local header = {}
    local tables = {}

    for _,line in ipairs(seperate(content,'\r\n')) do
        local csv = {}
        local t = {}
        local v1, v2
        csv = ParseCSVLine(line)
        if _ == 1 then
            header = self:getCSVHeader(csv)
            if not key then key = header[1] end
        else
            if csv[1] == nil then break end

            for i=1,#header do
                if (not csv[i]) then
                    csv[i] = ''
                end
                v1 = trim(tostring(csv[i]))
                v2 = string.match(v1, '%d+[.]?%d*')
                if v2 then v2 = tostring(tonumber(v2)) end
                if v1 == v2 then
                    t[header[i]] = tonumber(v2)
                else
                    t[header[i]] = string.gsub(v1, '\\\\n', '\n')
                    if (t[header[i]] == '') then
                        t[header[i]] = nil
                    end
                end
            end

            tables[t[key]] = t
        end
    end

    self.m_scenarioTable = tables
end

-------------------------------------
-- function adjustScenarioTable
-- @brief t_content로부터 key와 대체할 값을 가져와 scenarioTable 을 순회하며 변동 값을 적용시킨다.
-------------------------------------
function UI_ScenarioPlayer:adjustScenarioTable(t_content)
	for _, t_scene in pairs(self.m_scenarioTable) do
		for i, v in pairs(t_scene) do
			if (t_content[v]) then
				t_scene[i] = t_content[v]
			end
		end
	end
end

-------------------------------------
-- function applyEffect
-- @comment https://docs.google.com/spreadsheets/d/1_obKDht0MJRJV2GtO3RCEwxY-8NE4Eb4LR2svlix8BU/edit#gid=0 기능일람과 동기화 해주세요!
-------------------------------------
function UI_ScenarioPlayer:applyEffect(effect)
    if (not effect) then
        return
    end

    local l_str = TableClass:seperate(effect, ';')
    local effect = l_str[1]
    local val_1 = l_str[2]
    local val_2 = l_str[3]

    local vars = self.vars

    if (effect == 'flash') then
        self:fadeWholeLayer('white', 100, 0)

    elseif (effect == 'white_in') then
        self:fadeWholeLayer('white', 0, 100)

    elseif (effect == 'black_in') then
        self:fadeWholeLayer('black', 0, 100)

    elseif (effect == 'overlay') then
        self:fadeLayer(val_1, 50, val_2)

    elseif (effect == 'fadeout') then
        vars['layerColor']:runAction(cc.FadeOut:create(0.3))
        vars['layerColor2']:runAction(cc.FadeOut:create(0.3))

    elseif (effect == 'shaking') then
        self:doShake()

    elseif (effect == 'vibe') then
        self:vibrate()

    elseif (effect == 'scratch') then
        self:scratch(val_1)

    elseif (effect == 'bomb') then
        self:bomb()

    elseif (effect == 'title') then
        self:effect_title(effect, val_1, val_2, val_3)

    elseif (effect == 'vrp') then
        local key = val_1
        local vrp = self.m_bgAnimator
        local loop = string.find(key, '_idle') and true or false
        vrp:changeAni(key, loop)
        vrp:addAniHandler(function() 
			-- idle일 경우 auto skip 시간에 따라 진행
			if (loop == false) then
				self:next() 
			end
		end)

    elseif (effect == 'clear_text') then
        self.m_scenarioPlayerTalk:hide()

    elseif (effect == 'clear_char') then
        for i,v in pairs(self.m_mCharacter) do
            v:hide()
        end

    elseif (effect == 'clear_all') then
        for i,v in pairs(self.m_mCharacter) do
            v:hide()
        end
        self.m_scenarioPlayerTalk:hide()

    elseif effect == 'skip_invisible' then
        self.vars['skipBtn']:setVisible(false)

    elseif effect == 'skip_disable' then
        self.m_bSkipEnable = false
        self.vars['skipBtn']:setVisible(false)
        self.vars['nextVisual']:setVisible(false)

    elseif effect == 'skip_enable' then
        self.m_bSkipEnable = true
        self.vars['skipBtn']:setVisible(true)
        self.vars['nextVisual']:setVisible(true)

    elseif effect == 'next_disable' then
        self.m_bNextEnable = false
        self.vars['nextBtn']:setEnabled(false)
        self.vars['nextVisual']:setVisible(false)

    elseif effect == 'next_enable' then
        self.m_bNextEnable = true
        self.vars['nextBtn']:setEnabled(true)
        self.vars['nextVisual']:setVisible(true)

    elseif (effect == 'hide_all') then
        self.root:setVisible(false)

    elseif (effect == 'show_all') then
        self.root:setVisible(true)

    else
        cclog('정의되지 않은 이펙트 ' .. effect)
        return true
    end
end

-------------------------------------
-- function effect_title
-------------------------------------
function UI_ScenarioPlayer:effect_title(effect, val_1, val_2, val_3)
    local vars = self.vars

    val_1 = val_1 or 'title을 입력해주세요'

    if (not self.m_titleUI) then
        self.m_titleUI = UI()
        self.m_titleUI:load('scenario_title.ui')
        self.vars['titleNode']:addChild(self.m_titleUI.root)

        -- 하위 UI가 모두 opacity값을 적용되도록
        self.m_titleUI:setOpacityChildren(true)
    end
    self.m_titleUI.vars['titleLabel']:setString(Str(val_1))

    self.m_titleUI.root:setVisible(true)
    local action = cc.Sequence:create(cc.DelayTime:create(3), cc.Hide:create())
    self.m_titleUI.root:runAction(action)

    self.m_titleUI.vars['menu']:stopAllActions()
    self.m_titleUI.vars['menu']:setOpacity(0)
    local action = cc.Sequence:create(cc.FadeIn:create(0.5), cc.DelayTime:create(2), cc.FadeOut:create(0.5))
    self.m_titleUI.vars['menu']:runAction(action)

    self.m_titleUI.vars['layerColor']:stopAllActions()
    self.m_titleUI.vars['layerColor']:setOpacity(255)
    local action = cc.Sequence:create(cc.DelayTime:create(2.5), cc.FadeOut:create(0.5))
    self.m_titleUI.vars['layerColor']:runAction(action)
end

-------------------------------------
-- function effect_narrate
-------------------------------------
function UI_ScenarioPlayer:effect_narrate(t_page)
    local ui = UI_ScenarioPlayer_Narrate(t_page)
    local function close_cb()
		self.m_narrationUI = nil
        self:next()
    end
    ui:setCloseCB(close_cb)
	ui.vars['skipBtn']:registerScriptTapHandler(function()
		ui:closeWithoutCB()
		self:click_skip() 
	end)

	self.m_narrationUI = ui
end

-------------------------------------
-- function doShake
-------------------------------------
function UI_ScenarioPlayer:doShake()
	-- 1. 변수 설정
    local duration = duration or 0.5
	local is_repeat = is_repeat or false
    local interval =  interval or 0.2
    local x, y = 50, 50

	-- 2. 기존에 있던 액션 중지
    self.root:stopAllActions()

	-- 3. 새로운 액션 설정 
    local start_action = cc.MoveTo:create(0, cc.p(x, y))
    local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(duration, cc.p(0, 0)), interval)
	local sequence_action = cc.Sequence:create(start_action, end_action)

    self.root:runAction(sequence_action)

    --[[
        self.vars['bgNode']:stopAllActions()
        local start_action = cc.MoveTo:create(0.05, cc.p(25, 25))
        local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(1, cc.p(0, 0)), 0.2)
        self.vars['bgNode']:runAction(cc.Sequence:create(start_action, end_action))
    ]]
end

-------------------------------------
-- function setFocusCharacter
-------------------------------------
function UI_ScenarioPlayer:setFocusCharacter(character)
    if (self.m_focusCharacter == character) then
        return
    end

    if self.m_focusCharacter then
        self.m_focusCharacter:killFocus()
    end

    self.m_focusCharacter = character

    if self.m_focusCharacter then
        self.m_focusCharacter:setFocus()
    end
end

-------------------------------------
-- function changeBg
-------------------------------------
function UI_ScenarioPlayer:changeBg(bg_name)
    local vars = self.vars

    -- 배경을 삭제한다!
    if (bg_name == 'clear') and (self.m_bgAnimator) then
        local fade_out = cc.FadeOut:create(1)
        local remove_self = cc.RemoveSelf:create()
        self.m_bgAnimator:runAction(cc.Sequence:create(fade_out, remove_self))
        self.m_bgAnimator = nil
		self.m_bgName = nil
        return
    end

    -- 현재 배경 밑에 새로운 배경을 넣고
    local bg_res = TableScenarioResource:getScenarioRes(bg_name)
    local bg_animator = MakeAnimator(bg_res)
    vars['bgNode']:addChild(bg_animator.m_node)

    -- 배경 현재 보이는 사이즈 기준으로 조정
    local visible_size = cc.Director:getInstance():getVisibleSize()
    local bg_size = bg_animator:getContentSize()

    local width_scale, height_scale = 1, 1
    if (bg_size['width'] > visible_size['width']) then
        width_scale = (visible_size['width'] / bg_size['width'])
    end
    if (bg_size['height'] > visible_size['height']) then
        height_scale = (visible_size['height'] / bg_size['height'])
    end
    bg_animator:setScale(math.max(width_scale, height_scale))

    -- 현재 배경이 서서히 사라지도록 한다.
    if (self.m_bgAnimator) then
        local fade_out = cc.FadeOut:create(1)
        local cb_func = cc.CallFunc:create(function() bg_animator:setLocalZOrder(1) end)
        local remove_self = cc.RemoveSelf:create()

        self.m_bgAnimator:runAction(cc.Sequence:create(fade_out, cb_func, remove_self))
    else
        bg_animator:setLocalZOrder(1)
    end

    self.m_bgAnimator = bg_animator
    self.m_bgName = bg_name
end

-------------------------------------
-- function fadeWholeLayer
-------------------------------------
function UI_ScenarioPlayer:fadeWholeLayer(color, start_rate, end_rate)
    local vars = self.vars
    local color = COLOR[color]
    local start_opacity = (255 * (start_rate / 100))
    local end_opacity = (255 * (end_rate / 100))

    vars['layerColor']:setColor(color)
    vars['layerColor']:setOpacity(start_opacity)
    vars['layerColor']:runAction(cc.FadeTo:create(0.3, end_opacity))
end

-------------------------------------
-- function fadeLayer
-------------------------------------
function UI_ScenarioPlayer:fadeLayer(color, start_rate, end_rate)
    local vars = self.vars
    local color = COLOR[color]
    local start_opacity = (255 * (start_rate / 100))
    local end_opacity = (255 * (end_rate / 100))

    vars['layerColor2']:setColor(color)
    vars['layerColor2']:setOpacity(start_opacity)
    vars['layerColor2']:runAction(cc.FadeTo:create(0.3, end_opacity))
end

-------------------------------------
-- function vibrate
-------------------------------------
function UI_ScenarioPlayer:vibrate()
    cc.SimpleAudioEngine:getInstance():playVibrate(1000)
end

-------------------------------------
-- function scratch
-------------------------------------
function UI_ScenarioPlayer:scratch(dir)
    local vars = self.vars
    local dir = dir or 'left'
    local ani = 'scratch_' .. dir
    local visual = VrpHelper:makeVrpEffect(vars['vibeNode'], 'res/effect/effect_scratch_screen/effect_scratch_screen', ani, 0, 0)
    visual:setAnchorPoint(cc.p(0.5, 0.5))
    visual:setDockPoint(cc.p(0.5, 0.5))
end

-------------------------------------
-- function bomb
-------------------------------------
function UI_ScenarioPlayer:bomb()
    local vars = self.vars
    local visual = VrpHelper:makeVrpEffect(vars['vibeNode'], 'res/effect/effect_bomb_screen/effect_bomb_screen', 'idle', 0, 0)
    visual:setAnchorPoint(cc.p(0.5, 0.5))
    visual:setDockPoint(cc.p(0.5, 0.5))
end