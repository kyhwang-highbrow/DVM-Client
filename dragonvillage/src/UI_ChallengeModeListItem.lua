local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ChallengeModeListItem
-------------------------------------
UI_ChallengeModeListItem = class(PARENT, {
        m_userData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChallengeModeListItem:init(t_data)
    local vars = self:load('challenge_mode_list_item_01.ui')

    self.m_userData = t_data

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChallengeModeListItem:initUI()
    local vars = self.vars

    local t_data = self.m_userData

    if (t_data['advance_notice']) then
        vars['masterTimeSprite']:setVisible(true)
        vars['stageBtn']:setEnabled(false)
        vars['stageBtn']:setVisible(false)

        -- 남은 시간 표기
        local sec = g_challengeMode:getChallengeModeMasterStatusText()
        local time_str = datetime.makeTimeDesc(sec, false, false, false)
        vars['masterTimeLabel']:setString(Str('마스터 구역 잠금해제까지\n {1} 남음', Str(time_str)))
        return
    end

    local stage = t_data['stage']
    local nick = t_data['nick'] or ''
    local clan = t_data['clan'] or ''
    local uid = t_data['uid'] or ''
    -- 랭킨, 클랜, 닉네임
    --[[
    local str = Str('{1}위', t_data['rank'])
    str = str .. ' {@}' .. nick
    if (clan and (clan ~= '')) then
        str = str .. ' {@clan_name}' .. clan
    end
    vars['stageNumberLabel']:setString(str)
    --]]

    -- 스테이지 (순위)
    vars['stageNumberLabel']:setString(tostring(t_data['rank']))
    
    -- 서버, 닉네임, 클랜명
    local server_name = g_challengeMode:getUserServer(uid, true)
    local str = server_name .. ' {@default}' .. nick
    if (clan and (clan ~= '')) then
        str = str .. ' {@clan_name}' .. clan
    end
    vars['tamerNameLabel']:setString(str)


    -- 아이콘
    if vars['dragonNode'] then
        if t_data['leader'] and (t_data['leader'] ~= '') then
            local struct_dragon_obj = StructDragonObject:parseDragonStringData(t_data['leader'])
            local card = UI_DragonCard(struct_dragon_obj)
            card:setButtonEnabled(false)
            vars['dragonNode']:addChild(card.root)
        end
    end

    -- 잠금 여부
    local is_open = g_challengeMode:isOpenStage_challengeMode(t_data['stage'])
    vars['lockSprite']:setVisible(not is_open)

    -- 클리어 여부
    local is_clear = g_challengeMode:isClearStage_challengeMode(t_data['stage'])
    vars['clearSprite']:setVisible(is_clear)

    do -- 클리어 보상
        
        -- 마스터 스테이지 인지 구별
        local master_stage = g_challengeMode:getRewardList('clear_reward')
        local reward_type = 'clear_reward'
        if (tonumber(t_data['rank']) > g_challengeMode:getMasterStage()) then
            reward_type = 'clear_reward'
        else
            reward_type = 'clear_reward_master'
        end

        -- 700002;100000 형식의 보상 문자열을 파싱하여 보상 카드 생성
        local reward_str = g_challengeMode:getRewardList(reward_type)
        local comma_split_list = plSplit(reward_str, ',') -- 아이템별로 리스트 생성
        for i, each_reward_str in pairs(comma_split_list) do
            local semi_split_list = plSplit(each_reward_str, ';') -- 아이템 id와 count 분리한 리스트 생성
            item_id = semi_split_list[1]
            item_count = semi_split_list[2]               
            self:setRewardItemCard(tonumber(item_id), tonumber(item_count))
        end
    end

    -- 점수
    local point = g_challengeMode:getChallengeModeStagePoint(stage)
    local color_str
    if (point < 100) then
        color_str = '{@DESC}'
    else
        color_str = '{@gray}'
    end
    local str = color_str .. Str('{1}점', point)
    vars['pointLabel']:setString(str)

    -- 도전 횟수
    --local play_cnt = g_challengeMode:getChallengeModeStagePlayCnt(stage)
    --vars['playLabel']:setString('{@gray}' .. Str('{1}회 도전', play_cnt))


    -- 클리어한 난이도와 자동 전투 여부 표시
    if (point == 0) then
        vars['difficultyLabel']:setVisible(false)
    else
        vars['difficultyLabel']:setVisible(true)

        local difficulty, is_auto, text = g_challengeMode:parseChallengeModeStagePoint(point)
        vars['difficultyLabel']:setString(text or DIFFICULTY:getText(difficulty))
        vars['difficultyLabel']:setColor(DIFFICULTY:getColor(difficulty))
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChallengeModeListItem:initButton()
    local vars = self.vars
    
    if true then
        return
    end
    vars['floorBtn']:getParent():setSwallowTouch(false)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChallengeModeListItem:refresh()
end

-------------------------------------
-- function setRewardItemCard
-------------------------------------
function UI_ChallengeModeListItem:setRewardItemCard(reward_item_id, count)
    local vars = self.vars
    
    local item_card = UI_ItemCard(reward_item_id, count)
    item_card.root:setSwallowTouch(false)
    --card.vars['commonSprite']:setVisible(false)
    --card.vars['bgSprite']:setVisible(false)
    item_card.vars['clickBtn']:registerScriptTapHandler(function() UI_ChallengeModeInfoPopup('reward') end)
    if (reward_item_id == ITEM_ID_GOLD) then
        vars['rewardNode2']:addChild(item_card.root)
    else
        vars['rewardNode1']:addChild(item_card.root)
    end
    
    local point = g_challengeMode:getChallengeModeStagePoint(stage)
    if (0 < point) then
        local icon = IconHelper:getIcon('res/ui/icons/stage_box_check.png')
        icon:setScale(2)
        item_card.root:addChild(icon)
    end
end
