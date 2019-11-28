local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarMatchingSceneListItem
-------------------------------------
UI_ClanWarMatchingSceneListItem = class(PARENT,{
        m_myStructMatchItem = 'StructClanWarMatch,',
        m_enemyStructMatchItem = 'StructClanWarMatch,',

        m_hasEnemy = 'boolean',
        m_isDefeat = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarMatchingSceneListItem:init(data)
    local vars = self:load('clan_war_match_scene_item_me.ui')
    self:initUI(data)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarMatchingSceneListItem:initUI(data)
    local vars = self.vars
    -- 초기화
    vars['rivalMenu']:setVisible(false)
    vars['noSelectMenu']:setVisible(false)
    vars['defenseNoti']:setVisible(false)

    -- 선택 안한 상태
    local attack_uid = data['attack_uid']
    self.m_hasEnemy = (attack_uid ~= nil)

    -- 부전승 표시
    if (data['clan_id'] == 'defeat') then
    --if vars['unearnedWinDescLabel'] then -- <- 테스트용 코드
        local idx = data['idx']
        --local idx = 1 -- <-- 테스트용 코드
        vars['meNameLabel']:setVisible(false)
        vars['unearnedWinDescLabel']:setVisible(true)

        local str = Str('부전패')
        if idx then
            str = (str .. ' ' .. idx)

            -- 첫 번째 부전승에만 설명 추가
            if (idx == 1) then
                -- 번역이 되어있지 않아서 사용 불가
                --str = str .. '\n{@MUSTARD}' .. Str('클랜원이 10명 이하일 경우 부족한 수 만큼 상대방 클랜이 세트 승점을 획득합니다.')
            end
        end
        vars['unearnedWinDescLabel']:setString(str)
        self.m_isDefeat = true
        return 
	end

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarMatchingSceneListItem:update()
    local vars = self.vars
    local struct_match_item = self.m_myStructMatchItem
    vars['lastTimeLabel']:setString('')
    if (not struct_match_item) then
        return
    end

    local remain_time = struct_match_item:getRemainEndTimeText()
    vars['lastTimeLabel']:setString(remain_time)
end

-------------------------------------
-- function setStructMatchItem
-------------------------------------
function UI_ClanWarMatchingSceneListItem:setStructMatchItem(my_struct_match_item, enemy_struct_match_item)
    self.m_myStructMatchItem = my_struct_match_item
    self.m_enemyStructMatchItem = enemy_struct_match_item
    
    -- 부전패의 경우
    if (self.m_isDefeat) then
        return
    end
    
    -- 상대가 없는 상태
    if (not self.m_enemyStructMatchItem) then
        self:setUserInfo(self.m_myStructMatchItem, true) -- param : struct_match_item, is_my
    else
        self:setUserInfo(self.m_enemyStructMatchItem, false) -- param : struct_match_item, is_my
        self:setUserInfo(self.m_myStructMatchItem, true) -- param : struct_match_item, is_my
    end

    self:setResult()
end

-------------------------------------
-- function setUserInfo
-------------------------------------
function UI_ClanWarMatchingSceneListItem:setUserInfo(struct_match_item, is_my)
    local vars = self.vars
    
    local prefix = 'me'
    if (not is_my) then
        prefix = 'rival'    
    end

    -- 닉네임
    if (not struct_match_item) then
        vars[prefix .. 'NameLabel']:setString('')
        return
    end

    local nick_name = struct_match_item:getMyNickName() or ''
    vars[prefix .. 'NameLabel']:setString(nick_name)

    -- 티어 아이콘
    local struct_user_info_clan = struct_match_item:getUserInfo()
    local icon
    if (struct_user_info_clan) then
	    icon = struct_user_info_clan:getLastTierIcon('big')       
    end
    if (icon) then
        vars[prefix .. 'TierIconNode']:addChild(icon)
    end
end

-------------------------------------
-- function setResult
-------------------------------------
function UI_ClanWarMatchingSceneListItem:setResult()
    local vars = self.vars
    local struct_match_item = self.m_myStructMatchItem
    if (not struct_match_item) then
        return
    end

    -- 방어 정보 표시
    local defend_cnt = struct_match_item:getDefendCount()
	if (defend_cnt > 0) then
		vars['defenseNoti']:setVisible(true)
		vars['defenseLabel']:setString(tostring(defend_cnt))
    end

    -- 내 클랜 강조
    local my_uid = g_userData:get('uid')
    local my_clan_id = g_clanWarData:getMyClanId()
    if (vars['meSprite']) then
        if (my_uid == struct_match_item['uid']) and (my_clan_id == struct_match_item['clan_id']) then
            vars['meSprite']:setVisible(true)
	    else
            vars['meSprite']:setVisible(false)
        end
    end
        
    -- 싸우는 상대방이 없는 경우
    if (not self.m_hasEnemy) then
        vars['noSelectMenu']:setVisible(true)
        return
    else
        vars['rivalMenu']:setVisible(true)
        vars['lastTimeLabel']:setVisible(true)
    end

    -- 승/패
    vars['resultSprite']:setVisible(true)
    local attack_state = struct_match_item:getAttackState()
    if (attack_state == StructClanWarMatchItem.ATTACK_STATE['ATTACK_SUCCESS']) then
        vars['winSprite']:setVisible(true)
        vars['loseSprite']:setVisible(false)
    elseif (attack_state == StructClanWarMatchItem.ATTACK_STATE['ATTACK_FAIL']) then
        vars['winSprite']:setVisible(false)
        vars['loseSprite']:setVisible(true)
    else
        vars['resultSprite']:setVisible(false)
    end
    
    -- 게임 스코어
    for i = 1,3 do
        if (vars['setResult'..i]) then
            vars['setResult'..i]:setColor(StructClanWarMatch.STATE_COLOR['DEFAULT'])
            vars['setResult'..i]:setVisible(false)
        end
    end

    local l_result = struct_match_item:getGameResult()
    for i, result in ipairs(l_result) do
        local color
        if (result == '0') then
            color = StructClanWarMatch.STATE_COLOR['LOSE']
        else
            color = StructClanWarMatch.STATE_COLOR['WIN']
        end
        if (vars['setResult'..i]) then
            vars['setResult'..i]:setColor(color)
            vars['setResult'..i]:setVisible(true)
        end
    end
end






local PARENT = UI_ClanWarMatchingSceneListItem

-------------------------------------
-- class UI_ClanWarMatchingSceneListItem_enemy
-------------------------------------
UI_ClanWarMatchingSceneListItem_enemy = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarMatchingSceneListItem_enemy:init(data)
    local vars = self:load('clan_war_match_scene_item_rival.ui')

    self:initUI(data)
end