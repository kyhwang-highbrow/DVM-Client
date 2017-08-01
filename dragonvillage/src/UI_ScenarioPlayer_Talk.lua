-------------------------------------
-- class UI_ScenarioPlayer_Talk
-------------------------------------
UI_ScenarioPlayer_Talk = class({
        root = '',
        vars = '',

        m_currPos = 'string',
        m_currName = 'string',
        m_currText = 'string',

        m_nameLabelDictionary = 'dictionary',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ScenarioPlayer_Talk:init(scenario_player)
    local vars = scenario_player.vars
    self.vars = vars
    self.root = vars['talkMenu']

    vars['nameNode_left']:setVisible(false)
    vars['nameNode_right']:setVisible(false)
    vars['talkLabel']:setString('')

    self.root:setVisible(false)
end

-------------------------------------
-- function setTalk
-------------------------------------
function UI_ScenarioPlayer_Talk:setTalk(pos, name, text, text_type, text_pos)
    local vars = self.vars

    if pos and (self.m_currPos ~= pos) then
        if self.m_currPos and vars['nameNode_' .. self.m_currPos] then
            vars['nameNode_' .. self.m_currPos]:setVisible(false)
        end

        self.m_currPos = pos

        if vars['nameNode_' .. self.m_currPos] then
            vars['nameNode_' .. self.m_currPos]:setVisible(true)
        end

        if vars['nameLabel_' .. self.m_currPos] then
            vars['nameLabel_' .. self.m_currPos]:setString(name or '')
        end
        self.m_currName = name

    elseif name and (self.m_currName ~= name) then
        
        if vars['nameLabel_' .. self.m_currPos] then
            vars['nameLabel_' .. self.m_currPos]:setString(name or '')
        end
        self.m_currName = name
    end

    if text then
        vars['talkLabel']:setString(text)
        
        --[[
        if (text_type == 'bold') then
            vars['talkLabel']:enableOutline(nil, 1)
        else
            vars['talkLabel']:enableOutline(nil, 0)
        end
        ]]
        
        -- 대사창 위치 처리
        if (text_pos == 'top') then
            vars['talkMenu']:setPositionY(450)
            vars['nameNode_left']:setPositionY(-30)
            vars['nameNode_right']:setPositionY(-30)
        
        elseif (text_pos == 'mid') then
            vars['talkMenu']:setPositionY(250)
            vars['nameNode_left']:setPositionY(233)
            vars['nameNode_right']:setPositionY(233)

        elseif (text_pos == 'bot') then
            vars['talkMenu']:setPositionY(0)
            vars['nameNode_left']:setPositionY(233)
            vars['nameNode_right']:setPositionY(233)
        end

        self:show()
    end
end

-------------------------------------
-- function show
-------------------------------------
function UI_ScenarioPlayer_Talk:show()
    self.root:setVisible(true)
end

-------------------------------------
-- function show
-------------------------------------
function UI_ScenarioPlayer_Talk:show()
    self.root:setVisible(true)
end

-------------------------------------
-- function hide
-------------------------------------
function UI_ScenarioPlayer_Talk:hide()
    self.root:setVisible(false)

    local vars = self.vars
    vars['talkLabel']:setString('')
    vars['nameLabel_left']:setString('')
    vars['nameLabel_right']:setString('')
end