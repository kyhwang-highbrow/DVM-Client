local PARENT = UI

-------------------------------------
-- class UI_ResultLeaderBoardListItem
-------------------------------------
UI_ResultLeaderBoardListItem = class(PARENT, {
        m_userName = 'string',
        m_rank = 'number',
        m_score = 'number',
        m_subData = 'table',
        m_isMe = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ResultLeaderBoardListItem:init(type, user_name, rank, score, is_me, sub_data)
    local vars = self:load('rank_ladder_item.ui')

    self.m_userName = user_name
    self.m_rank = rank
    self.m_score = score
    self.m_subData = sub_data
    self.m_isMe = is_me

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
        vars['meScoreLabel']:setString(comma_value(score))
        vars['meRankLabel']:setString(comma_value(rank))
    else
        vars['nameLabel']:setString(Str(user_name))
        vars['scoreLabel']:setString(comma_value(score))
        vars['rankLabel']:setString(comma_value(rank))
    end
end
