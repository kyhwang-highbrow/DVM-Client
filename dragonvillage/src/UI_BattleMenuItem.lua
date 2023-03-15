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
        -- ancient_ruin 고대 유적 던전
        -- gold_dungeon 황금 던전
        
        m_notiIcon = 'cc.Sprite',
        m_listCnt = 'number',
     })

local THIS = UI_BattleMenuItem

-------------------------------------
-- function init
-------------------------------------
function UI_BattleMenuItem:init(content_type, list_cnt)
    self.m_contentType = content_type
    self.m_listCnt = list_cnt or 1
    -- 컨텐츠 별 ui 파일 분리 - 파생 클래스에서 ui 로드
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BattleMenuItem:initUI()
    local vars = self.vars
    local content_type = self.m_contentType

    self.root:setSwallowTouch(false)
    vars['swallowTouchMenu']:setSwallowTouch(false)
    --[[
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
	--]]
    -- 베타 버튼 표시
    if vars['betaLabel'] then
        if g_contentLockData:isContentBeta(content_type) then
            vars['betaLabel']:setVisible(true) 
        else
            vars['betaLabel']:setVisible(false)
        end
    end
	
    -- 컨텐츠 크기별로 애니메이션 지정
    local ani_num = '_01'
    if (self.m_listCnt <= 3) then
        ani_num = '_01'
    elseif (self.m_listCnt == 4) then
        ani_num = '_02'   
    elseif (self.m_listCnt >= 5) then
        ani_num = '_03'
    end
    cclog(content_type..ani_num)
    vars['itemVisual']:changeAni(content_type .. ani_num, true)
    vars['titleLabel']:setString(getContentName(content_type))
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
    -- 컨텐츠 별로 버튼 크기 달라지면서 노티 아이콘 위치 다름
    local noti_pos 

    if (content_type == 'adventure') then
        local visible = g_hotTimeData:isHighlightHotTime() or g_fevertimeData:isActiveFevertime_adventure()
        self.vars['battleHotSprite']:setVisible(visible)

    elseif (content_type == 'nest_evo_stone') then
        local visible = g_fevertimeData:isActiveFevertime_dungeonGdItemUp() or g_fevertimeData:isActiveFevertime_dungeonGdStDc() 
        self.vars['HotSprite']:setVisible(visible)

    elseif (content_type == 'nest_tree') then
        local visible = g_fevertimeData:isActiveFevertime_dungeonGtItemUp() or g_fevertimeData:isActiveFevertime_dungeonGtStDc() 
        self.vars['HotSprite']:setVisible(visible)

    elseif (content_type == 'ancient_ruin') then
        local visible = g_fevertimeData:isActiveFevertime_dungeonRuneLegendUp() or g_fevertimeData:isActiveFevertime_dungeonRuneUp() or g_fevertimeData:isActiveFevertime_dungeonArStDc() 
        self.vars['HotSprite']:setVisible(visible)

    elseif (content_type == 'nest_nightmare') then
        local visible = g_fevertimeData:isActiveFevertime_dungeonRuneLegendUp() or g_fevertimeData:isActiveFevertime_dungeonRuneUp() or  g_fevertimeData:isActiveFevertime_dungeonNmStDc()
        self.vars['HotSprite']:setVisible(visible)

    elseif (content_type == 'rune_guardian') then
        local visible = g_fevertimeData:isActiveFevertime_dungeonRgStDc() or g_fevertimeData:isActiveFevertime_dungeonRuneLegendUp() or g_fevertimeData:isActiveFevertime_dungeonRuneUp()
        self.vars['HotSprite']:setVisible(visible)

    elseif (content_type == 'colosseum') then
        local visible = g_fevertimeData:isActiveFevertime_pvpHonorUp()
        self.vars['HotSprite']:setVisible(visible)

    elseif (content_type == 'arena_new') then
        local visible = g_fevertimeData:isActiveFevertime_pvpHonorUp()
        self.vars['HotSprite']:setVisible(visible)

    elseif (content_type == 'league_raid') then
        local visible = g_fevertimeData:isActiveFevertime_raidUp()
        self.vars['HotSprite']:setVisible(visible)
        
    elseif (content_type == 'exploration') then
        has_noti = g_highlightData:isHighlightExploration()
        noti_pos = cc.p(190, -138)

    elseif (content_type == 'secret_relation') then
        has_noti = g_secretDungeonData:isSecretDungeonExist()
        noti_pos = cc.p(90, -90)

    elseif (content_type == 'gold_dungeon') then
        local event_data = g_eventGoldDungeonData
        -- 현재 입장권 개수
        local stamina_cnt = event_data:getStaminaCount()
        has_noti = stamina_cnt > 0
        noti_pos = cc.p(90, -90)

    elseif (content_type == 'clan_raid') then
        has_noti = false
    end

    if (has_noti) then
        if (not self.m_notiIcon and noti_pos) then
            local noti_icon = IconHelper:getNotiIcon()
            noti_icon:setPosition(noti_pos)
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
    elseif (content_type == 'exploration') then
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

    -- 콜로세움
    elseif (content_type == 'arena_new') then
        UINavigator:goTo('arena_new')

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

    -- 룬 수호자 던전
    elseif (content_type == 'rune_guardian') then
        UINavigator:goTo('rune_guardian')

    -- 고대 유적 던전
    elseif (content_type == 'ancient_ruin') then
        UINavigator:goTo('ancient_ruin')

    -- 황금 던전
    elseif (content_type == 'gold_dungeon') then
        UINavigator:goTo('gold_dungeon')

    -- 챌린지 모드
    elseif (content_type == 'challenge_mode') then
        UINavigator:goTo('challenge_mode')

    -- 그랜드 콜로세움 (이벤트 PvP 10대10)
    elseif (content_type == 'grand_arena') then
        UINavigator:goTo('grand_arena')
    
    -- 그랜드 콜로세움 (이벤트 PvP 10대10)
    elseif (content_type == 'clan_war') then
        UINavigator:goTo('clan_war')
    -- 시련 (차원문)
    elseif (content_type == 'dmgate') then
        UINavigator:goTo('dmgate')

    elseif (content_type == 'league_raid') then
        UINavigator:goTo('league_raid')

    else
        error('content_type : ' .. content_type)
    end
end