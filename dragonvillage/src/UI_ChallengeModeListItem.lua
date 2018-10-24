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
    local stage = t_data['stage']
    local nick = t_data['nick'] or ''
    local clan = t_data['clan'] or ''

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
    
    -- 닉네임, 클랜명
    local str = nick
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

    do -- 골드 보상
        -- 도전 보상
        local card = UI_ItemCard(ITEM_ID_GOLD, 20000)
        card.root:setSwallowTouch(false)
        --card.vars['commonSprite']:setVisible(false)
        --card.vars['bgSprite']:setVisible(false)
        card.vars['clickBtn']:registerScriptTapHandler(function() UI_ChallengeModeInfoPopup('reward') end)
        vars['rewardNode1']:addChild(card.root)

        local play_cnt = g_challengeMode:getChallengeModeStagePlayCnt(stage)
        if (0 < play_cnt) then
            local icon = IconHelper:getIcon('res/ui/icons/stage_box_check.png')
            icon:setScale(2)
            card.root:addChild(icon)
        end

        -- 클리어 보상
        local card = UI_ItemCard(ITEM_ID_GOLD, 80000)
        card.root:setSwallowTouch(false)
        --card.vars['commonSprite']:setVisible(false)
        --card.vars['bgSprite']:setVisible(false)
        card.vars['clickBtn']:registerScriptTapHandler(function() UI_ChallengeModeInfoPopup('reward') end)
        vars['rewardNode2']:addChild(card.root)
        
        local point = g_challengeMode:getChallengeModeStagePoint(stage)
        if (0 < point) then
            local icon = IconHelper:getIcon('res/ui/icons/stage_box_check.png')
            icon:setScale(2)
            card.root:addChild(icon)
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