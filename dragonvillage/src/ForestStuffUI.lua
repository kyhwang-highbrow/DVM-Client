local PARENT = UI

-------------------------------------
-- class ForestStuffUI
-------------------------------------
ForestStuffUI = class(PARENT, {
        m_tSuffInfo = 'table',
     })

local TIME_FORMAT = pl.Date.Format('HH:MM:SS')

-------------------------------------
-- function init
-------------------------------------
function ForestStuffUI:init(t_stuff_info)
    self:load('dragon_forest_object.ui')
    
    self.m_tSuffInfo = t_stuff_info

    self:initUI()
end

-------------------------------------
-- function init
-------------------------------------
function ForestStuffUI:initUI()
    local vars = self.vars
    local t_stuff_info = self.m_tSuffInfo
    local stuff_lv = t_stuff_info['stuff_lv']
    
    -- 활성화 되지 않은 상태
    if (not stuff_lv) then
        vars['timeLabel']:setVisible(false)
        vars['lockSprite']:setVisible(true)
        vars['infoLabel']:setString(Str('테이머 레벨 {1} 달성 시 오픈'))
        return
    end

    -- 이름
    local name = t_stuff_info['stuff_name']
    vars['nameLabel']:setString(string.format('%s Lv.%d', name, stuff_lv))
end

-------------------------------------
-- function updateTime
-------------------------------------
function ForestStuffUI:updateTime(remain_time)
    -- 남은시간 출력
    if remain_time > 0 then
        local date = pl.Date(remain_time)
        self.vars['timeLabel']:setString(TIME_FORMAT:tostring(date))
    end
end

-------------------------------------
-- function readyForReward
-------------------------------------
function ForestStuffUI:readyForReward()
    self.vars['notiSprite']:setVisible(true)
    self.vars['timeLabel']:setString('')
end