local PARENT = UI

-------------------------------------
-- class UI_ResultLeaderBoardListItem
-------------------------------------
UI_ResultLeaderBoardListItem = class(PARENT, {
        m_userName = 'string',
        m_rank = 'number',
        m_score = 'number',
        m_isMe = 'boolean',
        m_mark = 'StructClanMark',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ResultLeaderBoardListItem:init(type, t_data, is_me)
    local vars = self:load('rank_ladder_item.ui')

    self.m_userName = t_data['name']
    self.m_rank = t_data['rank']
    self.m_score = t_data['score']
    self.m_isMe = is_me
    self.m_mark = StructClanMark:create(t_data['mark'])

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ResultLeaderBoardListItem:initUI()
    local vars = self.vars
    local user_name = self.m_userName
    local rank = self.m_rank
    local score = self.m_score

    vars['meRankMenu']:setVisible(self.m_isMe)
    vars['rankMenu']:setVisible(not self.m_isMe)

    if (self.m_isMe) then
        vars['meNameLabel']:setString(Str(user_name))
        vars['meScoreLabel']:setString(comma_value(score)..Str('점'))
        vars['meRankLabel']:setString(comma_value(rank))
        local icon = self.m_mark:makeClanMarkIcon()
        vars['meMarkNode']:addChild(icon)
    else
        vars['nameLabel']:setString(Str(user_name))
        vars['scoreLabel']:setString(comma_value(score)..Str('점'))
        vars['rankLabel']:setString(comma_value(rank))
        local icon = self.m_mark:makeClanMarkIcon()
        vars['markNode']:addChild(icon)
    end
end
