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
-------------------------------------
function UI_ScenarioPlayer:applyEffect(effect)
    if (not effect) then
        return
    end

    cclog('#UI_ScenarioPlayer effect : ' .. effect)

    local l_str = TableClass:seperate(effect, ';')
    local effect = l_str[1]
    local val_1 = l_str[2]
    local val_2 = l_str[3]

    local vars = self.vars
    vars['layerBlend'] = vars['layerColor']
    vars['layerBlend2'] = vars['layerColor2'] -- bg와 talk menu 중간 뎁스    

    if (effect == 'flash') then
        vars['layerColor']:setColor(cc.c3b(255,255,255))
        vars['layerColor']:setOpacity(255)
        vars['layerColor']:runAction(cc.FadeOut:create(0.3))

    elseif (effect == 'shaking') then
        self:doShake()


    elseif effect == 'whiteblack' then
        vars['layerColor']:setColor(cc.c3b(255,255,255))
        vars['layerColor']:setOpacity(0)
        vars['layerColor']:runAction(cc.FadeTo:create(0.3, 255))

    elseif effect == 'fadein' then
        vars['layerColor']:runAction(cc.FadeTo:create(0.3, 0))

    elseif effect == 'vibe' then
        self.vars['bgNode']:stopAllActions()
        local start_action = cc.MoveTo:create(0.05, cc.p(25, 25))
        local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(1, cc.p(0, 0)), 0.2)
        self.vars['bgNode']:runAction(cc.Sequence:create(start_action, end_action))

    elseif effect == 'black' then
        vars['layerColor']:setColor(cc.c3b(0,0,0))
        if (val_1) then
            val_1 = tonumber(val_1)
            if (val_1 <= 0) then
                vars['layerColor']:setOpacity(255)
            else
                vars['layerColor']:setOpacity(0)
                vars['layerColor']:runAction(cc.FadeTo:create(val_1, 255))
            end
        else
            vars['layerColor']:setOpacity(0)
            vars['layerColor']:runAction(cc.FadeTo:create(0.3, 255))
        end

    elseif effect == 'shine' then

    elseif effect == 'scratch_1' then
        local visual = VrpHelper:makeVrpEffect(vars['vibeNode'], 'res/effect/effect_scratch_screen/effect_scratch_screen', 'scratch_right', 0, 0)
        visual:setAnchorPoint(cc.p(0.5, 0.5))
        visual:setDockPoint(cc.p(0.5, 0.5))

    elseif effect == 'scratch_2' then
        local visual = VrpHelper:makeVrpEffect(vars['vibeNode'], 'res/effect/effect_scratch_screen/effect_scratch_screen', 'scratch_left', 0, 0)
        visual:setAnchorPoint(cc.p(0.5, 0.5))
        visual:setDockPoint(cc.p(0.5, 0.5))

    elseif effect == 'bomb' then
        local visual = VrpHelper:makeVrpEffect(vars['vibeNode'], 'res/effect/effect_bomb_screen/effect_bomb_screen', 'idle', 0, 0)
        visual:setAnchorPoint(cc.p(0.5, 0.5))
        visual:setDockPoint(cc.p(0.5, 0.5))

    elseif effect == 'blend_black_20' then
        vars['layerBlend']:setColor(cc.c3b(0,0,0))
        vars['layerBlend']:runAction(cc.FadeTo:create(0.3, 51))

    elseif effect == 'blend_black_40' then
        vars['layerBlend']:setColor(cc.c3b(0,0,0))
        vars['layerBlend']:runAction(cc.FadeTo:create(0.3, 102))

    elseif effect == 'blend_black_60' then
        vars['layerBlend']:setColor(cc.c3b(0,0,0))
        vars['layerBlend']:runAction(cc.FadeTo:create(0.3, 153))

    elseif effect == 'blend_black_80' then
        vars['layerBlend']:setColor(cc.c3b(0,0,0))
        vars['layerBlend']:runAction(cc.FadeTo:create(0.3, 204))

    elseif effect == 'blend_black_talk' then
        self.vars['skipBtn']:setVisible(false)

        vars['layerBlend2']:setColor(cc.c3b(0,0,0))
        vars['layerBlend2']:runAction(cc.FadeTo:create(0.3, 153))

    elseif effect == 'blend_off' then
        vars['layerBlend']:runAction(cc.FadeTo:create(0.3, 0))
        vars['layerBlend2']:runAction(cc.FadeTo:create(0.3, 0))

    elseif (effect == 'title') then
        self:effect_title(effect, val_1, val_2, val_3)

    elseif (effect == 'clear_char') then
        for i,v in pairs(self.m_mCharacter) do
            v:hide()
        end
        self.m_scenarioPlayerTalk:hide()

    elseif (effect == 'vrp') then
        local key = val_1
        local vrp = self.m_bg
        local loop = string.find(key, '_idle') and true or false
        vrp:changeAni(key, loop)
        vrp:addAniHandler(function() self:next() end)

    elseif (effect == 'clear_text') or (effect == 'cleartext') then
        self.m_scenarioPlayerTalk:hide()

    elseif effect == 'skip_disable' then
        self.m_bSkipEnable = false
        self.vars['skipBtn']:setVisible(false)
        self.vars['nextVisual']:setVisible(false)

    elseif effect == 'skip_enable' then
        self.m_bSkipEnable = true
        self.vars['skipBtn']:setVisible(true)
        self.vars['nextVisual']:setVisible(true)

    -- 스킵만 가능하고 화면넘김 불가능한 상태
    elseif effect == 'next_disable' then
        self.m_bSkipEnable = true
        self.vars['skipBtn']:setVisible(true)

        self.vars['nextBtn']:setEnabled(false)
        self.vars['nextVisual']:setVisible(false)

    elseif effect == 'hide_all' then
        self.root:setVisible(false)

    elseif effect == 'show_all' then
        self.root:setVisible(true)

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
    self.m_titleUI.vars['titleLabel']:setString(val_1)

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
function UI_ScenarioPlayer:effect_narrate(t_narrate)
    local ui = UI_ScenarioPlayer_Narrate(t_narrate)
    local function close_cb()
        self:next()
    end
    ui:setCloseCB(close_cb)
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