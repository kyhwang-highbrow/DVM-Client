local PARENT = UI

-------------------------------------
-- class UI_BattleMenuItem
-------------------------------------
UI_BattleMenuItem = class(PARENT, {
        m_contentType = 'string',
        -- sgkim 2017-08-03
        -- table_content_lock.csv와 용어 통일
        -- adventure	모험
        -- exploration	탐험
        -- nest_tree	[네스트] 거목 던전
        -- nest_evo_stone	[네스트] 진화재료 던전
        -- ancient	고대의 탑
        -- attr_tower 시험의 탑
        -- colosseum	콜로세움
        -- nest_nightmare	[네스트] 악몽 던전
        -- secret_relation 인연던전
        
        m_notiIcon = 'cc.Sprite',
     })

local THIS = UI_BattleMenuItem

-------------------------------------
-- function init
-------------------------------------
function UI_BattleMenuItem:init(content_type)
    self.m_contentType = content_type

    local vars = self:load('battle_menu_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BattleMenuItem:initUI()
    local vars = self.vars

    local content_type = self.m_contentType

    self.root:setSwallowTouch(false)
    vars['swallowTouchMenu']:setSwallowTouch(false)

    -- 컨텐츠에 따라 사용하는 레이아웃이 다름
    if isExistValue(content_type, 'adventure', 'exploation', 'colosseum', 'ancient', 'attr_tower') then
        vars['enterBtn1']:setVisible(true)
        vars['enterBtn2']:setVisible(false)

        vars['enterBtn'] = vars['enterBtn1']
        vars['itemVisual'] = vars['itemVisual1']
        vars['titleLabel'] = vars['titleLabel1']
        vars['dscLabel'] = vars['dscLabel1']
    else
        vars['enterBtn1']:setVisible(false)
        vars['enterBtn2']:setVisible(true)

        vars['enterBtn'] = vars['enterBtn2']
        vars['itemVisual'] = vars['itemVisual2']
        vars['titleLabel'] = vars['titleLabel2']
        vars['dscLabel'] = vars['dscLabel2']
    end
    
    -- 버튼 잠금 상태 처리
    local is_content_lock, req_user_lv = g_contentLockData:isContentLock(content_type)
    if is_content_lock then
        vars['lockSprite']:setVisible(true)
        local msg
        -- 시험의 탑 예외 처리
        if (content_type == 'attr_tower') then
            msg = Str('고대의 탑 {1}층 클리어', ATTR_TOWER_OPEN_FLOOR)
        else
            msg = Str('레벨 {1}', req_user_lv)
        end
        vars['lockLabel']:setString(msg)
    else
        vars['lockSprite']:setVisible(false)
    end

    -- 베타 버튼 표시
    if vars['betaLabel'] then
        if g_contentLockData:isContentBeta(content_type) then
            vars['betaLabel']:setVisible(true) 
        else
            vars['betaLabel']:setVisible(false)
        end
    end

	-- 경쟁 컨텐츠 (고탑, 시탑, 콜로) 는 보상 정보를 찍어준다.
	if isExistValue(content_type, 'ancient', 'attr_tower', 'colosseum') then
		self:initCompetitionRewardInfo(content_type)
	end

    -- 컨텐츠 타입별 지정
    vars['itemVisual']:changeAni(content_type, true)
    vars['titleLabel']:setString(getContentName(content_type))
    vars['dscLabel']:setString(self:getDescStr(content_type))
end

-------------------------------------
-- function initCompetitionRewardInfo
-- @brief 경쟁 메뉴 보상 안내
-- @comment 갱신되는 케이스는 없어 initialize 로 만듬
-------------------------------------
function UI_BattleMenuItem:initCompetitionRewardInfo(content_type)
	local vars = self.vars

	local t_item, text_1, text_2

	-- 고대의 탑
	if (content_type == 'ancient') then
		local curr_floor = g_ancientTowerData:getClearStage()

		-- 탈출 : 50층까지 전부 클리어 시
		if (curr_floor >= 50) then
			return
		end

		t_item = {['item_id'] = 779215, ['count'] = 1} -- 스킬 슬라임
		
		local item_name = UIHelper:makeItemNamePlain(t_item)
		text_1 = Str('{1} 획득까지', item_name)

		local goal_floor = (50 > curr_floor) and (curr_floor >= 30) and 50 or 30
		local left_cnt = goal_floor - curr_floor
		text_2 = Str('{1}층 남음', left_cnt)

	-- 시험의 탑
	elseif (content_type == 'attr_tower') then
		local struct_quest = g_questData:getQuest(TableQuest.CHALLENGE, 14501)
		
		-- 탈출 : 업적 달성 시
		if (struct_quest:isEnd())then
			return
		end

		t_item = struct_quest:getRewardInfoList()[1]

		local item_name = UIHelper:makeItemNamePlain(t_item)
		text_1 = Str('업적 보상 - {1}', item_name)

		local _, text = struct_quest:getProgressInfo()
		text_2 = string.format('%s : %s', Str('달성'), text)

	-- 콜로세움
	elseif (content_type == 'colosseum') then
		local win = g_colosseumData:getPlayerColosseumUserInfo():getWinCnt()
		local next_reward_info = TableColosseumWinReward:getNextReawardInfo(win)

		-- 탈출 : 다음 승리 보상 없을 경우
		if (not next_reward_info) then
			return
		end

		t_item = next_reward_info['t_item']

		local item_name = UIHelper:makeItemNamePlain(t_item)
		text_1 = Str('{1} 획득까지', item_name)

		local left_cnt = next_reward_info['win'] - win
		text_2 = Str('{1}승 남음', left_cnt)
	end

	-- visible on
	vars['rewardMenu']:setVisible(true)

	-- 아이콘
	local icon = IconHelper:getItemIcon(t_item['item_id'])
	vars['itemNode']:addChild(icon)
	
	-- 텍스트
	vars['rewardLabel1']:setString(text_1)
	vars['rewardLabel2']:setString(text_2)			
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BattleMenuItem:initButton()
    local vars = self.vars

    vars['enterBtn']:registerScriptTapHandler(function() self:click_enterBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BattleMenuItem:refresh()
    -- noti를 관리
    local content_type = self.m_contentType
    local has_noti = false

    if (content_type == 'adventure') then
        local visible = g_hotTimeData:isHighlightHotTime()
        self.vars['battleHotSprite']:setVisible(visible)

    elseif (content_type == 'exploation') then
        has_noti = g_highlightData:isHighlightExploration()

    elseif (content_type == 'secret_relation') then
        has_noti = g_secretDungeonData:isSecretDungeonExist()

    elseif (content_type == 'clan_raid') then
        has_noti = false
    end

    if (has_noti) then
        if (not self.m_notiIcon) then
            local noti_icon = IconHelper:getNotiIcon()
            noti_icon:setPosition(125, -100)
            self.root:addChild(noti_icon)
            self.m_notiIcon = noti_icon
        end
    else
        if (self.m_notiIcon) then
            self.m_notiIcon:removeFromParent(true)
            self.m_notiIcon = nil
        end
    end

    return has_noti
end

-------------------------------------
-- function getDescStr
-------------------------------------
function UI_BattleMenuItem:getDescStr(content_type)
    local content_type = (content_type or self.m_contentType)

    local desc = ''

    -- 진화재료 던전
    if (content_type == 'nest_evo_stone') then
        desc = Str('진화재료 획득 가능')

    -- 거목 던전
    elseif (content_type == 'nest_tree') then
        desc = Str('친밀도 열매 획득 가능')

    -- 악몽 던전
    elseif (content_type == 'nest_nightmare') then
        desc = Str('룬 획득 가능')

    -- 인연 던전
    elseif (content_type == 'secret_relation') then
        desc = Str('인연포인트 획득 가능')

    -- 클랜 던전
    elseif (content_type == 'clan_raid') then
        desc = Str('클랜 던전')
    end

    return desc
end

-------------------------------------
-- function click_enterBtn
-------------------------------------
function UI_BattleMenuItem:click_enterBtn()
    local content_type = self.m_contentType

    -- 잠금 확인
    if (not g_contentLockData:checkContentLock(content_type)) then
        return
    end

    -- 모험
    if (content_type == 'adventure') then
        UINavigator:goTo('adventure')

    -- 탐험
    elseif (content_type == 'exploation') then
        UINavigator:goTo('exploration')

    -- 고대의 탑
    elseif (content_type == 'ancient') then
        UINavigator:goTo('ancient')

    -- 시험의 탑 
    elseif (content_type == 'attr_tower') then
        UINavigator:goTo('attr_tower')

    -- 콜로세움
    elseif (content_type == 'colosseum') then
        UINavigator:goTo('colosseum')

    -- 진화재료 던전
    elseif (content_type == 'nest_evo_stone') then
        UINavigator:goTo('nest_evo_stone')

    -- 거목 던전
    elseif (content_type == 'nest_tree') then
        UINavigator:goTo('nest_tree')

    -- 악몽 던전
    elseif (content_type == 'nest_nightmare') then
        UINavigator:goTo('nest_nightmare')

    -- 인연 던전
    elseif (content_type == 'secret_relation') then
        UINavigator:goTo('secret_relation')

    -- 클랜 던전
    elseif (content_type == 'clan_raid') then
        UINavigator:goTo('clan_raid')
    end
end