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
function UI_ScenarioPlayer_Talk:setTalk(pos, name, text)
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
-- function hide
-------------------------------------
function UI_ScenarioPlayer_Talk:hide()
    self.root:setVisible(false)
end