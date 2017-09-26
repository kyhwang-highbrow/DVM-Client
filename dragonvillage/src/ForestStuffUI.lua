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
    self:refresh()
end

-------------------------------------
-- function init
-------------------------------------
function ForestStuffUI:initUI()
end

-------------------------------------
-- function refresh
-------------------------------------
function ForestStuffUI:refresh()
    local vars = self.vars
    local t_stuff_info = self.m_tSuffInfo

    -- 이름
    local stuff_lv = t_stuff_info['stuff_lv'] or 0
    local name = t_stuff_info['stuff_name']
    vars['nameLabel']:setString(string.format('%s Lv.%d', name, stuff_lv))

    -- 활성화 되지 않은 상태
    if (stuff_lv == 0) then
        vars['timeLabel']:setVisible(false)
        vars['lockSprite']:setVisible(true)

        local stuff_type = t_stuff_info['stuff_type']
        local open_lv = TableForestStuffLevelInfo:getOpenLevel(stuff_type)
        vars['infoLabel']:setString(Str('숲 레벨 {1} 달성 시 오픈', open_lv))
    else
        vars['timeLabel']:setVisible(true)
        vars['lockSprite']:setVisible(false)
    end
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
    local vars = self.vars

    vars['timeLabel']:setString('')

    local reward_visual = vars['rewardVisual']
    reward_visual:setVisible(true)

    local t_res = 
    {
        ['table'] = 'dragon_forest_reward_dia.png',
        ['nest'] = 'dragon_forest_reward_egg_common_unknown.png', --dragon_forest_reward_egg_middle_mystery.png
        ['table'] = 'dragon_forest_reward_fruit_01.png', --dragon_forest_reward_fruit_02.png
        ['chest'] = 'dragon_forest_reward_gold.png',
        ['bookshelf'] = 'dragon_forest_reward_wing.png',
    }

    local stuff_type = self.m_tSuffInfo['stuff_type']
    local reward_icon = cc.Sprite:createWithSpriteFrameName(t_res[stuff_type]) -- plist 등록은 UI_Forest에서 한다
    local socket_node = reward_visual.m_node:getSocketNode('dragon_forest_reward')
    socket_node:addChild(reward_icon)
end

-------------------------------------
-- function resetReward
-------------------------------------
function ForestStuffUI:resetReward()
    self.vars['rewardVisual']:setVisible(false)
end