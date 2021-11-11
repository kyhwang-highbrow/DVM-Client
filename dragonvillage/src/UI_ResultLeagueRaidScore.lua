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
function UI_ResultLeagueRaidScore:init(game_result_data, new_info)
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

    if (my_info and my_info['up_season_reward']) then promotion_reward = my_info['season_reward']['up_season_reward']['700001'] end
    if (my_info and my_info['stay_season_reward']) then remaining_reward = my_info['season_reward']['stay_season_reward']['700001'] end
    if (my_info and my_info['down_season_reward']) then demoted_reward = my_info['season_reward']['down_season_reward']['700001'] end

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
    local member_list = self:createItemPositions()

    local is_defeated = false

    local upper_item = member_list['upper_item']
    local my_item = member_list['my_item']
    local down_item = member_list['down_item']

    local my_node = UI_ResultLeagueRaidScoreItem(my_item)
    local upper_node

    vars['userNode']:addChild(my_node.root)
    my_node.root:setPositionX(my_item['pos_x'])

    if (upper_item) then
        upper_node = UI_ResultLeagueRaidScoreItem(upper_item)
        vars['userNode']:addChild(upper_node.root)
        upper_node.root:setPositionX(upper_item['pos_x'])

        is_defeated = g_leagueRaidData.m_currentDamage > upper_item['score']
    end

    if (down_item) then
        local down_node = UI_ResultLeagueRaidScoreItem(down_item)
        vars['userNode']:addChild(down_node.root)
        down_node.root:setPositionX(down_item['pos_x'])
    end

    local move_direction = my_item['pos_x'] + math_random(20, 60)

    -- 액션을 한다
    -- 일단 내 점수는 증가했음
    -- 앞에 있는 놈을 초과했는지에 따라서 마지막 위치 조정
    if (is_defeated) then
        move_direction = upper_item['pos_x'] + 180
    end

    local move_action = cc.Sequence:create(cc.DelayTime:create(0.5), cc.MoveTo:create(0.8, cc.p(move_direction, 0)))


    my_node.root:runAction(move_action)
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
    local my_info = g_leagueRaidData:getMyInfo()
    local l_member = g_leagueRaidData:getMemberList()

    local l_item_position = {}
    local compare_score = 0
    local feild_width = vars['userNode']:getContentSize()['width']
    local center_pos_x = math_floor(feild_width / 2)

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
    
    local my_uid = g_userData:get('uid')
    local my_score = my_info['score']

    local my_item = self:findElement(l_member, 'uid', my_uid)

    local upper_item = self:findElement(l_member, 'rank', my_item['rank'] - 1)

    local down_item = self:findElement(l_member, 'rank', my_item['rank'] + 1)
    
    local acting_list = {}

    local my_pos_x = 0

    --[[
    upper_item = clone(my_item)
    upper_item['rank'] = 0
    upper_item['score'] = 65]]

    local is_defeated = g_leagueRaidData.m_currentDamage > upper_item['score']

    if (down_item) then
        down_item['pos_x'] =  0 - center_pos_x + math_random(40, 80)
        acting_list['down_item'] = down_item
    end

    if (my_item) then
        my_item['pos_x'] = is_defeated and my_pos_x - 130 or my_pos_x - 100
        acting_list['my_item'] = my_item
    end
    
    if (upper_item) then
        upper_item['pos_x'] = is_defeated and my_pos_x - 100 or my_pos_x + 150
        acting_list['upper_item'] = upper_item
    end

    return acting_list
end

-------------------------------------
-- function generatePositions
-------------------------------------
function UI_ResultLeagueRaidScore:findElement(list, key, value)
    local result = nil

    if (not list) then return result end

    for _, v in ipairs(list) do
        if (v and v[key] and v[key] == value) then
            result = v
            break
        end
    end

    return result
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
