local PARENT = UI

-------------------------------------
-- class UI_ResultLeaderBoardListItem
-------------------------------------
UI_ResultLeaderBoardListItem = class(PARENT, {
        m_type = 'string', -- clan_raid, incarnation_of_sins
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

    self.m_type = type
    self.m_rank = t_data['rank']
    if (type == 'clan_raid') then
        self.m_userName = t_data['name']
        self.m_score = t_data['score']
        self.m_mark = StructClanMark:create(t_data['mark'])

    elseif (type == 'incarnation_of_sins') then
        self.m_userName = t_data['nick']
        self.m_score = t_data['rp']
        if (t_data['clan_info']) then
            self.m_mark = StructClanMark:create(t_data['clan_info']['mark'])
        end
    end

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
        vars['meScoreLabel']:setString(comma_value(score)..Str('점'))
        vars['meRankLabel']:setString(comma_value(rank))
        if (self.m_mark) then
            local icon = self.m_mark:makeClanMarkIcon()
            vars['meMarkNode']:addChild(icon)
        end
    else
        vars['nameLabel']:setString(Str(user_name))
        vars['scoreLabel']:setString(comma_value(score)..Str('점'))
        vars['rankLabel']:setString(comma_value(rank))
        if (self.m_mark) then
            local icon = self.m_mark:makeClanMarkIcon()
            vars['markNode']:addChild(icon)
        end
    end
end
