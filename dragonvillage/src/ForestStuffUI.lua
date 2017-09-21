local PARENT = UI

-------------------------------------
-- class ForestStuffUI
-------------------------------------
ForestStuffUI = class(PARENT, {
        m_tSuffInfo = 'table',
        
        m_hasReward = 'bool',
        m_isLock = 'bool',
        m_rewardTime = 'timestamp',
     })

local TIME_FORMAT = pl.Date.Format('HH:MM:SS')

-------------------------------------
-- function init
-------------------------------------
function ForestStuffUI:init(t_stuff_info)
    self:load('dragon_forest_object.ui')
    self.m_tSuffInfo = t_stuff_info
    self.m_hasReward = false
    self.m_isLock = false
    self.m_rewardTime = t_stuff_info['reward_at']

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function init
-------------------------------------
function ForestStuffUI:initUI()
    local vars = self.vars
    local t_stuff_info = self.m_tSuffInfo
    
    ccdump(t_stuff_info)

    local stuff_lv = t_stuff_info['stuff_lv']
    
    -- 활성화 되지 않은 상태
    if (not stuff_lv) then
        self.m_isLock = true
        --vars['levelupBtn']:setEnabled(false)
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
-- function initButton
-------------------------------------
function ForestStuffUI:initButton()
    local vars = self.vars
    --vars['levelupBtn']:registerScriptTapHandler(function() self:click_levelupBtn() end)
end

-------------------------------------
-- function updateTime
-------------------------------------
function ForestStuffUI:updateTime()
    if (self.m_isLock) then
        return
    end
    if (not self.m_rewardTime) then
        return
    end
    if (self.m_hasReward) then
        return
    end

    -- 남은시간 출력
    local remain_time = (self.m_rewardTime/1000 - Timer:getServerTime())
    if remain_time > 0 then
        local date = pl.Date(remain_time)
        self.vars['timeLabel']:setString(TIME_FORMAT:tostring(date))

    -- 더이상 계산하지 않도록 처리
    else
        self.m_hasReward = true
        self.vars['timeLabel']:setString('')
    end
end

-------------------------------------
-- function touchStuff
-------------------------------------
function ForestStuffUI:touchStuff()
    -- 재화 수령 가능한 상태
    if (self.m_hasReward) then
        ccdisplay('reward ready')
        return
    end

    -- 레벨업 UI 오픈
    ccdisplay('레벨업 UI 오픈')
end