local PARENT = UI

-------------------------------------
-- class ForestStuffUI
-------------------------------------
ForestStuffUI = class(PARENT, {
        m_stuff = 'ForestStuff',
        m_tSuffInfo = 'table',
     })

local TIME_FORMAT = pl.Date.Format('HH:MM:SS')
local T_SOCKET_RES = 
{
    ['well'] = 'dragon_forest_reward_dia.png',
    ['nest'] = 'dragon_forest_reward_egg_common_unknown.png', --dragon_forest_reward_egg_middle_mystery.png
    ['table'] = 'dragon_forest_reward_fruit_01.png', --dragon_forest_reward_fruit_02.png
    ['chest'] = 'dragon_forest_reward_gold.png',
    ['bookshelf'] = 'dragon_forest_reward_wing.png',
}


-------------------------------------
-- function init
-------------------------------------
function ForestStuffUI:init(forest_stuff)
    self:load('dragon_forest_object.ui')
    
    self.m_stuff = forest_stuff
    self.m_tSuffInfo = forest_stuff.m_tStuffInfo

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function ForestStuffUI:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function ForestStuffUI:initButton()
    local vars = self.vars
    vars['objectBtn']:registerScriptTapHandler(function() self:click_objectBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function ForestStuffUI:refresh()
    local vars = self.vars
    local t_stuff_info = self.m_tSuffInfo

    -- 이름
    local stuff_lv = t_stuff_info['stuff_lv'] or 0
    local name = t_stuff_info['t_stuff_name']
    vars['nameLabel']:setString(string.format('%s Lv.%d', Str(name), stuff_lv))

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

    -- 이름표는 가린다.
    vars['objectSprite']:setVisible(false)
    vars['timeLabel']:setString('')

    local reward_visual = vars['rewardVisual']
    reward_visual:setVisible(true)

    local stuff_type = self.m_tSuffInfo['stuff_type']
    local reward_icon = cc.Sprite:createWithSpriteFrameName(T_SOCKET_RES[stuff_type]) -- plist 등록은 UI_Forest에서 한다
    local socket_node = reward_visual.m_node:getSocketNode('dragon_forest_reward')

    if reward_icon and socket_node then
        socket_node:addChild(reward_icon)
    end
end

-------------------------------------
-- function resetReward
-------------------------------------
function ForestStuffUI:resetReward()
    local vars = self.vars
    vars['rewardVisual']:setVisible(false)
    vars['objectSprite']:setVisible(true)
end

-------------------------------------
-- function click_objectBtn
-------------------------------------
function ForestStuffUI:click_objectBtn()
    self.m_stuff:touchStuff()
end