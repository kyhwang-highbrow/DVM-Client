local PARENT = UI

-------------------------------------
-- class UI_ScenarioPlayer
-------------------------------------
UI_ScenarioPlayer = class(PARENT,{
        m_currPage = 'number',
        m_maxPage = 'number',
        m_scenarioTable = 'table',

        m_titleUI = '',

        m_bgName = 'bg',

        m_autoSkipActionNode = '',

        m_mCharacter = '',
        m_bSkipEnalbe = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ScenarioPlayer:init(scenario_id)
    local vars = self:load('scenario_talk.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_skip() end, 'UI_ScenarioPlayer')

    self.m_currPage = 0
    self:loadScenario(scenario_id)
    self.m_maxPage = table.count(self.m_scenarioTable)

    -- 캐릭터 관련
    self.m_mCharacter = {}
    self.m_mCharacter['left'] = UI_ScenarioPlayer_Character('left', vars['tamerNode1'], vars['nameNode1'], vars['nameLabel1'], vars['talkSprite1'], vars['talkLabel1'])
    self.m_mCharacter['left'].m_bCharFlip = false
    self.m_mCharacter['left']:hide()

    self.m_mCharacter['right'] = UI_ScenarioPlayer_Character('right', vars['tamerNode2'], vars['nameNode2'], vars['nameLabel2'], vars['talkSprite2'], vars['talkLabel2'])
    self.m_mCharacter['right'].m_bCharFlip = true
    self.m_mCharacter['right']:hide()

    self.m_bSkipEnalbe = true
    
    self:initUI()
    self:initButton()
    self:refresh()

    self:next()
end

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
function UI_ScenarioPlayer:loadScenario(scenario_id)
    local filename = 'scenario_' .. scenario_id
    local content = TABLE:loadTableFile(filename, '.csv')

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
-- function initUI
-------------------------------------
function UI_ScenarioPlayer:initUI()
    local vars = self.vars

    self.m_autoSkipActionNode = cc.Node:create()
    self.root:addChild(self.m_autoSkipActionNode)
end

-------------------------------------
-- function click_skip
-------------------------------------
function UI_ScenarioPlayer:click_skip()
    if (not self.m_bSkipEnalbe) then
        return
    end

    self:close()
end

-------------------------------------
-- function click_next
-------------------------------------
function UI_ScenarioPlayer:click_next()
    if (not self.m_bSkipEnalbe) then
        return
    end

    self:next()
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
-- function next
-------------------------------------
function UI_ScenarioPlayer:next()
    self.m_currPage = self.m_currPage + 1

    if (self.m_currPage <= self.m_maxPage) then
        self:showPage()
    else
        self:close()
    end
end

-------------------------------------
-- function showPage
-------------------------------------
function UI_ScenarioPlayer:showPage()
    local vars = self.vars

    do -- 이전 페이지에서 끊어줘야할 행동들
        self.m_autoSkipActionNode:stopAllActions()
    end

    local t_page = self.m_scenarioTable[self.m_currPage]

    if (t_page['bg'] and (t_page['bg'] ~= self.m_bgName)) then
        vars['bgNode']:removeAllChildren()
        local bg = MakeAnimator(t_page['bg'])
        vars['bgNode']:addChild(bg.m_node)
    end

    -- 캐릭터
    do
        if (t_page['char'] and t_page['char_pos']) then
            self.m_mCharacter[t_page['char_pos']]:setCharacter(t_page['char'])

            self.m_mCharacter[t_page['char_pos']]:setCharText(Str(t_page['t_text']))

            if t_page['t_char_name'] then
                self.m_mCharacter[t_page['char_pos']]:setCharName(Str(t_page['t_char_name']))
            end
            
        end
    end

    -- 자동 넘김
    if (t_page['auto_skip']) then
        if (t_page['auto_skip'] == 0) then
            return self:next()
        else
            local action = cc.Sequence:create(cc.DelayTime:create(t_page['auto_skip']), cc.CallFunc:create(function() self:next() end))
            self.m_autoSkipActionNode:runAction(action)
        end
    end

    self:applyEffect(t_page['effect_1'])
    self:applyEffect(t_page['effect_2'])
    self:applyEffect(t_page['effect_3'])
end

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

    local vars = self.vars

    if effect == 'whiteblack' then
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

    elseif effect == 'clear' then
        for i,v in pairs(self.m_tHeroAnimator) do
            self:removeHeroVisual(self.m_tHeroAnimator[i], i)
            self.m_tHeroAnimator[i] = nil
        end

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

    elseif effect == 'blend_off' then
        vars['layerBlend']:runAction(cc.FadeTo:create(0.3, 0))

    elseif (effect == 'title') then
        self:effect_title(effect, val_1, val_2, val_3)

    elseif (effect == 'clear_text') then
        for i,v in pairs(self.m_mCharacter) do
            v:hideCharText()
        end

    elseif effect == 'skip_disable' then
        self.m_bSkipEnalbe = false
        self.vars['skipBtn']:setVisible(false)

    elseif effect == 'skip_enable' then
        self.m_bSkipEnalbe = true
        self.vars['skipBtn']:setVisible(true)

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
        doAllChildren(self.m_titleUI.root, function(node) node:setCascadeOpacityEnabled(true) end)
    end
    self.m_titleUI.vars['titleLabel']:setString(val_1)
    self.m_titleUI.root:setVisible(true)
    self.m_titleUI.root:stopAllActions()
    self.m_titleUI.root:setOpacity(0)

    local action = cc.Sequence:create(cc.FadeIn:create(0.5), cc.DelayTime:create(2), cc.FadeOut:create(0.5), cc.Hide:create())
    self.m_titleUI.root:runAction(action)
end