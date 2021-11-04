local PARENT = UI

local structLeaderBoard

-------------------------------------
-- class UI_ResultLeagueRaidScore
-------------------------------------
UI_ResultLeagueRaidScore = class(PARENT, {
        m_resultData = 'table',
    })

-- 앞/뒤 순위 정보 없을 때 자신의 점수에서 해당 값을 뺀 값을 뒤 순위 점수, 더한 점수를 앞 순위 점수로 사용
local DEFAULT_GAP = 1000000

-------------------------------------
-- function init
-------------------------------------
function UI_ResultLeagueRaidScore:init(game_result_data)
    local vars = self:load('league_raid_result_popup.ui')

    UIManager:open(self, UIManager.POPUP)
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ResultLeagueRaidScore') 

    self.m_resultData = game_result_data

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ResultLeagueRaidScore:initUI()
    local vars = self.vars 

    self:setCurrentInfo()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ResultLeagueRaidScore:initButton()
    self.vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ResultLeagueRaidScore:refresh()
    self:startMoving()
end

-------------------------------------
-- function setCurrentInfo
-------------------------------------
function UI_ResultLeagueRaidScore:setCurrentInfo()
    local vars = self.vars
    local my_info = g_leagueRaidData:getMyInfo()

    local remaining_reward = 0
    local promotion_reward = 0
    local demoted_reward = 0

    if (my_info and my_info['up_season_reward']) then promotion_reward = my_info['up_season_reward']['700001'] end
    if (my_info and my_info['stay_season_reward']) then remaining_reward = my_info['stay_season_reward']['700001'] end
    if (my_info and my_info['down_season_reward']) then demoted_reward = my_info['down_season_reward']['700001'] end

    if (vars['promotionRewardLabel']) then vars['promotionRewardLabel']:setString(comma_value(promotion_reward)) end
    if (vars['remainingRewardLabel']) then vars['remainingRewardLabel']:setString(comma_value(remaining_reward)) end
    if (vars['demotedRewardLabel']) then vars['demotedRewardLabel']:setString(comma_value(demoted_reward)) end


    self:addGroupUserItems()
end


-------------------------------------
-- function setCurrentInfo
-------------------------------------
function UI_ResultLeagueRaidScore:addGroupUserItems()
    local vars = self.vars
    if (not vars['userNode']) then return end

    local vars = self.vars
    local l_member = g_leagueRaidData:getMemberList()
    local l_x_pos = self:createItemPositions()

    for i, member in ipairs(l_member) do
        if (member) then
            local user_item = UI_ResultLeagueRaidScoreItem(member)
            vars['userNode']:addChild(user_item.root)
            user_item.root:setPositionX(l_x_pos[i])
        end
    end
end


-------------------------------------
-- function startMoving
-------------------------------------
function UI_ResultLeagueRaidScore:startMoving()
    local vars = self.vars

    
end

-------------------------------------
-- function generatePositions
-------------------------------------
function UI_ResultLeagueRaidScore:createItemPositions()
    local vars = self.vars
    local l_member = g_leagueRaidData:getMemberList()
    
    local l_item_position = {}
    local compare_score = 0
    local feild_width = vars['userNode']:getContentSize()['width']
    local last_pos_x = 0 - math_floor(feild_width / 2)

    --[[
    for i = 5, 10 do
        local member = clone(l_member[2])
        member['rank'] = i
        member['score'] = (10 - i) * 20000
        table.insert(l_member, member)
    end]]

    local member_count = #l_member
    local item_cell = math_floor(feild_width / member_count)

    table.sort(l_member, function(a, b)
        return tonumber(a['rank']) > tonumber(b['rank'])
    end)

    for index, member in ipairs(l_member) do
        if (index == 1) then
            last_pos_x = last_pos_x +  math_random(20, 40)
        elseif (index == member_count) then
            last_pos_x = math_floor(feild_width / 2) -  math_random(20, 40)
        elseif (member['score'] - compare_score > 10000) then
            last_pos_x = last_pos_x + item_cell + math_random(0, 30)
            last_pos_x = math.min(math_floor(feild_width / 2) - 60, last_pos_x)
        else
            last_pos_x = last_pos_x + item_cell + math_random(-30, 0)
            last_pos_x = math.min(math_floor(feild_width / 2) - 60, last_pos_x)
        end

        table.insert(l_item_position, last_pos_x)

        compare_score = member['score']
    end

    return l_item_position
end


--@CHECK
UI:checkCompileError(UI_ResultLeagueRaidScore)



local PARENT = UI

-------------------------------------
-- class UI_ResultLeagueRaidScoreItem
-------------------------------------
UI_ResultLeagueRaidScoreItem = class(PARENT, {
        m_userData = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ResultLeagueRaidScoreItem:init(t_data)
    local vars = self:load('league_raid_result_popup_item.ui')

    self.m_userData = t_data

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ResultLeagueRaidScoreItem:initUI()
    local vars = self.vars

    if (not self.m_userData) then return end

    local score_str = Str('{1}점', comma_value(self.m_userData['score']))
    local rank_str = Str('No. {1}', self.m_userData['rank'])
    local leader_info = self.m_userData['leader']

    if (vars['userLabel']) then vars['userLabel']:setString(self.m_userData['nick']) end
    if (vars['rankLabel']) then vars['rankLabel']:setString(rank_str) end
    if (vars['scoreLabel']) then vars['scoreLabel']:setString(score_str) end

    if (vars['dragonNode']) then 
        -- dragon
        do -- 리더 드래곤 아이콘
            local dragon_id = leader_info['did']
            local transform = leader_info['transform']
            local evolution = transform and transform or leader_info['evolution']
            local icon = IconHelper:getDragonIconFromDid(dragon_id, evolution, 0, 0)
            icon:setDockPoint(cc.p(0.5, 0.5))
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            icon:setFlippedX(true)
            vars['dragonNode']:addChild(icon)
        end
    end

    if (vars['meVisual'] ) then 
        local is_my_profile = self.m_userData['uid'] == g_userData:get('uid')
        vars['meVisual']:setVisible(is_my_profile)
    end

end
