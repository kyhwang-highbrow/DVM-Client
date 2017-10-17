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
        -- 현재 위치 이름택 숨김
        if self.m_currPos and vars['nameNode_' .. self.m_currPos] then
            vars['nameNode_' .. self.m_currPos]:setVisible(false)
        end

        self.m_currPos = pos

        -- 새로운 현재 위치 이름택 나타남
        if vars['nameNode_' .. self.m_currPos] then
            vars['nameNode_' .. self.m_currPos]:setVisible(true)
        end

        -- 이름도 붙여줌
        if vars['nameLabel_' .. self.m_currPos] then
            vars['nameLabel_' .. self.m_currPos]:setString(name or '')
        end
        self.m_currName = name

    -- 현재위치에서 이름만 바뀐다면
    elseif name and (self.m_currName ~= name) then
        
        if vars['nameLabel_' .. self.m_currPos] then
            vars['nameLabel_' .. self.m_currPos]:setString(name or '')
        end
        self.m_currName = name

    -- 이름도 위치도 없다면
    elseif (not name) and (not pos) then
        -- 숨김
        if self.m_currPos and vars['nameNode_' .. self.m_currPos] then
            vars['nameNode_' .. self.m_currPos]:setVisible(false)
        end
        self.m_currName = name
        self.m_currPos = pos
    end

    -- 대사 처리
    if text then
        vars['talkLabel']:setString(text)
        
        -- 대사 효과
        local text_type = text_type or 'none'
        vars['talkLabel']:setBold(string.find(text_type, 'bold'))
        vars['talkLabel']:setItalic(string.find(text_type, 'italic'))

        -- 대사창 위치 처리
        if (text_pos == 'top') then
            vars['talkMenu']:setPositionY(470)
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

    else
        vars['talkLabel']:setString('')

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