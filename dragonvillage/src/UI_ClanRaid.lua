local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanRaid
-------------------------------------
UI_ClanRaid = class(PARENT, {
        m_stageID = 'number',
        m_remainHp = 'number',
        m_preRefreshTime = 'time',
     })

local TAB_TOTAL = 1 -- 누적 기여도
local TAB_CURRENT = 2 -- 현재 기여도

local RENEW_INTERVAL = 5
local SHOW_NEXT_LEVEL_LIMIT = 4 

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ClanRaid:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ClanRaid'
    self.m_titleStr = Str('클랜 던전')
	self.m_staminaType = 'cldg'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'clancoin'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function init
-------------------------------------
function UI_ClanRaid:init()
    local vars = self:load_keepZOrder('clan_raid_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    self.m_preRefreshTime = 0

    local struct_raid = g_clanRaidData:getClanRaidStruct()
    self.m_stageID = struct_raid:getStageID()
    self.m_remainHp = struct_raid:getHp()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanRaid')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:initTab()
    
    self:refresh(true)

    -- 보상 안내 팝업
    local function finich_cb()
        self:checkEnterEvent()
    end

    self:sceneFadeInAction(nil, finich_cb)
end

-------------------------------------
-- function checkEnterEvent
-------------------------------------
function UI_ClanRaid:checkEnterEvent()
    -- 클랜던전 주간 보상이 있을 경우 여기서 처리
    if (g_clanRaidData.m_tClanRewardInfo) then
        local t_info = g_clanRaidData.m_tClanRewardInfo
        local is_clan = true

        if (ui) then
            ui:setCloseCB(function()
                UI_ClanRaidRankingRewardPopup(t_info, is_clan)
            end)
        else
            UI_ClanRaidRankingRewardPopup(t_info, is_clan)
        end

        g_clanRaidData.m_tClanRewardInfo = nil
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanRaid:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanRaid:initUI()
    local vars = self.vars
    local struct_clan = g_clanData:getClanStruct()

    -- 클랜 마크
    local icon = struct_clan:makeClanMarkIcon()
    vars['clanNode']:removeAllChildren()
    vars['clanNode']:addChild(icon)

    -- 클랜 이름
    local clan_name = struct_clan:getClanName()
    vars['clanLabel']:setString(clan_name)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanRaid:initButton()
    local vars = self.vars
    vars['prevBtn']:registerScriptTapHandler(function() self:click_prevBtn() end)
    vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end)
    vars['rankBtn']:registerScriptTapHandler(function() self:click_rankBtn() end)
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
    vars['readyBtn']:registerScriptTapHandler(function() self:click_readyBtn() end)
    
    -- 상세 정보 팝업
    vars['bossInfoBtn']:registerScriptTapHandler(function() self:click_bossInfoBtn('info') end)
    vars['synastryInfoBtn']:registerScriptTapHandler(function() self:click_bossInfoBtn('synastry') end)
    vars['fbInfoBtn']:registerScriptTapHandler(function() self:click_bossInfoBtn('finalblow') end)

    -- 클랜 던전 안내 (네이버 sdk 링크)
    NaverCafeManager:setPluginInfoBtn(vars['plugInfoBtn'], 'clanraid_help')
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ClanRaid:initTab()
    local vars = self.vars
    self:addTabWithLabel(TAB_TOTAL, vars['damageTabBtn1'], vars['damageTabLabel1'], vars['damageTabNode1'])
    self:addTabWithLabel(TAB_CURRENT, vars['damageTabBtn2'], vars['damageTabLabel2'], vars['damageTabNode2'])
    self:setTab(TAB_TOTAL)
    self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ClanRaid:onChangeTab(tab, first)
    if (not first) then return end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanRaid:refresh(first)
    if (first) then
        self:initTotalTabTableView()
    end

    self:initCurrentTabTableView()
    self:initRaidInfo()
    self:refreshBtn()
end

-------------------------------------
-- function initTotalTabTableView
-- @brief 누적 기여도 테이블 뷰 
-------------------------------------
function UI_ClanRaid:initTotalTabTableView()
    local vars = self.vars
    local struct_raid = g_clanRaidData:getClanRaidStruct()

    local node = vars['damageTabNode1']
    node:removeAllChildren()

    -- cell size 정의
	local width = node:getContentSize()['width']
	local height = 50 + 2

    -- 테이블 뷰 인스턴스 생성
    local l_rank_list = g_clanRaidData:getRankList()
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(width, height)
    table_view:setCellUIClass(UI_ClanRaidRankListItem)
	table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_rank_list)

    local msg = Str('참여한 유저가 없습니다.')
    table_view:makeDefaultEmptyDescLabel(msg)
end

-------------------------------------
-- function initCurrentTabTableView
-- @brief 현재 기여도 테이블 뷰 
-------------------------------------
function UI_ClanRaid:initCurrentTabTableView()
    local vars = self.vars
    local struct_raid = g_clanRaidData:getClanRaidStruct()

    local node = vars['damageTabNode2']
    node:removeAllChildren()

    -- cell size 정의
	local width = node:getContentSize()['width']
	local height = 50 + 2

    -- 테이블 뷰 인스턴스 생성
    local l_rank_list = struct_raid:getRankList()
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(width, height)
    table_view:setCellUIClass(UI_ClanRaidRankListItem)
	table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_rank_list)

    local msg = Str('참여한 유저가 없습니다.')
    table_view:makeDefaultEmptyDescLabel(msg)
end

-------------------------------------
-- function initRaidInfo
-------------------------------------
function UI_ClanRaid:initRaidInfo()
    local vars = self.vars
    local struct_raid = g_clanRaidData:getClanRaidStruct()
    local stage_id = struct_raid:getStageID()
    local _, boss_mid = g_stageData:isBossStage(stage_id)
    local state = struct_raid:getState()

    -- 종료 시간
    local status_text = g_clanRaidData:getClanRaidStatusText()
    vars['timeLabel']:setString(status_text)

    -- 보스 animator
    local boss_node = vars['bossNode']
    boss_node:removeAllChildren()

    local l_monster = g_stageData:getMonsterIDList(stage_id)
    for _, mid in ipairs(l_monster) do
        local res, attr, evolution = TableMonster:getMonsterRes(mid)
        animator = AnimatorHelper:makeMonsterAnimator(res, attr, evolution)
        
        if (animator) then
            local zOrder = WORLD_Z_ORDER.BOSS
            local idx = getDigit(mid, 10, 1)
            if (idx == 1) and (mid == boss_mid) then
                zOrder = WORLD_Z_ORDER.BOSS     
            elseif (idx == 1) then
                zOrder = WORLD_Z_ORDER.BOSS + 1
            elseif (idx == 7) then
                zOrder = WORLD_Z_ORDER.BOSS
            else
                zOrder = WORLD_Z_ORDER.BOSS + 1 + 7 - idx
            end
            boss_node:addChild(animator.m_node, zOrder)

            -- 클리어한 경우 회색 처리
            if (state == CLAN_RAID_STATE.CLEAR) then
                animator:setAnimationPause(true)
                animator.m_node:setColor(COLOR['deep_gray']) 
                --animator:setBaseShader(SHADER_GRAY)
            else
                animator:changeAni('idle', true)
            end
        end
    end

    -- 레벨, 이름
    local is_rich_label = true
    local name = struct_raid:getBossNameWithLv(is_rich_label)
    vars['levelLabel']:setString(name)

    -- 속성 아이콘
    local attr = struct_raid:getAttr()
    local icon = IconHelper:getAttributeIcon(attr)
    vars['attrNode']:removeAllChildren()
    vars['attrNode']:addChild(icon)

    -- 체력 퍼센트
    local tween_cb = function(number, label)
        label:setString(string.format('%0.2f%%', number))
    end

    local hp_label = vars['hpLabel']
    hp_label = NumberLabel(hp_label, 0, 0.3)
    hp_label:setTweenCallback(tween_cb)

    local rate = struct_raid:getHpRate()
    hp_label:setNumber(rate, false)

    -- 체력 수치
    local cur_hp = struct_raid:getHp()
    local max_hp = struct_raid:getMaxHp() 
    local hp_label2 = vars['hpLabel2']
    local str_hp = string.format('%s/%s', comma_value(cur_hp), comma_value(max_hp))
    hp_label2:setString(str_hp)

    -- 체력 게이지
    local gauge = vars['bossHpGauge1']
    gauge:setPercentage(0)
    local action = cc.ProgressTo:create(0.3, rate)
    gauge:runAction(action)
    
    -- 보너스 속성
    do
        local str, map_attr = struct_raid:getBonusSynastryInfo()

        for k, v in pairs(map_attr) do
            -- 속성 아이콘
            local icon = IconHelper:getAttributeIcon(k)
            local target_node = vars['bonusAttrNode']
            target_node:removeAllChildren()
            target_node:addChild(icon)
        end
    end

    -- 페널티 속성
    do
        vars['panaltyAttrNode']:removeAllChildren()
        for i = 1, 4 do
            vars['panaltyAttrNode'..i]:removeAllChildren()
        end

        local str, map_attr = struct_raid:getPenaltySynastryInfo()
        local cnt = table.count(map_attr)
        local idx = 0

        for k, v in pairs(map_attr) do
            idx = idx + 1
            -- 속성 아이콘
            local icon = IconHelper:getAttributeIcon(k)
            local target_node = (cnt == 1) and 
                                vars['panaltyAttrNode'] or 
                                vars['panaltyAttrNode'..idx]
            target_node:addChild(icon)
        end
    end

    self:showDungeonStateUI()
end

-------------------------------------
-- function showDungeonStatus
-- @brief 전 상태에 따른 UI 변경
-------------------------------------
function UI_ClanRaid:showDungeonStateUI()
    local vars = self.vars
    local struct_raid = g_clanRaidData:getClanRaidStruct()
    local state = struct_raid:getState()
    local noti_visual = vars['notiVisual']
    noti_visual:setVisible(state ~= CLAN_RAID_STATE.NORMAL)

    -- 잠금 표시
    local curr_stage_id = g_clanRaidData:getChallengStageID()
    local stage_id = struct_raid:getStageID()
    vars['lockNode']:setVisible(stage_id > curr_stage_id)

    -- 다른 유저 도전중인 상태 
    if (state == CLAN_RAID_STATE.CHALLENGE) then
        local player = struct_raid:getPlayer()
        if (player) then
            local nick = player['nick']
            local label = vars['atkLabel']
            noti_visual:changeAni('atk', true)
            label:setVisible(true)

            local start_time = struct_raid:getStartTime()
            local curr_time = Timer:getServerTime()
            local play_time = curr_time - start_time
            label:setString(Str('{1}님이 전투중입니다.\n{2} 경과되었습니다.', nick, datetime.makeTimeDesc(play_time, true)))

            cca.reserveFunc(self.root, 2.0, function() 
                label:setString('')

                -- 노티 보여준 상태에서 또 파이널 블로우인지 체크
                if (struct_raid:getFinalblow()) then
                    noti_visual:changeAni('fb_01', true)
                else
                    noti_visual:setVisible(false)
                end
            end)
        end
        
    -- 파이널 블로우 상태
    elseif (state == CLAN_RAID_STATE.FINALBLOW) then
        noti_visual:changeAni('fb_01', true)

    -- 클리어한 상태
    elseif (state == CLAN_RAID_STATE.CLEAR) then
        noti_visual:changeAni('clear', true)

        noti_visual.m_node:setScale(1.3)
        local act1 = cc.EaseInOut:create(cc.ScaleTo:create(0.1, 0.95), 2)
        local act2 = cc.EaseInOut:create(cc.ScaleTo:create(0.1, 1.0), 2)
        local action = cc.Sequence:create(act1, act2)
        noti_visual:runAction(action)
    end
end

-------------------------------------
-- function refreshBtn
-- @brief 버튼 관련 활성화/비활성화
-------------------------------------
function UI_ClanRaid:refreshBtn()
    local vars = self.vars
    local struct_raid = g_clanRaidData:getClanRaidStruct()

    local stage_id = struct_raid:getStageID()
    local prev_stage_id = g_stageData:getSimplePrevStage(stage_id)
    vars['prevBtn']:setVisible((prev_stage_id ~= nil))

    local curr_stage_id = g_clanRaidData:getChallengStageID()
    local next_stage_id = g_stageData:getNextStage(stage_id)

    -- 현재 진행중인 던전 이후는 특정 레벨까지만 보여줌 (던전 인스턴스 생성되지 않은 상태)
    vars['nextBtn']:setVisible(curr_stage_id + SHOW_NEXT_LEVEL_LIMIT >= next_stage_id)

    -- 시작버튼 활성화/비활성화
    vars['readyBtn']:setEnabled(stage_id == curr_stage_id)
end

-------------------------------------
-- function click_prevBtn
-- @brief 이전 던전 정보
-------------------------------------
function UI_ClanRaid:click_prevBtn()
    local struct_raid = g_clanRaidData:getClanRaidStruct()
    local stage_id = struct_raid:getStageID()
    local prev_stage_id = g_stageData:getSimplePrevStage(stage_id)

    local finish_cb = function()
        self:refresh()
    end

    if (prev_stage_id) then
        g_clanRaidData:request_info(prev_stage_id, finish_cb)
    end
end

-------------------------------------
-- function click_nextBtn
-- @brief 다음 던전 정보
-------------------------------------
function UI_ClanRaid:click_nextBtn()
    local struct_raid = g_clanRaidData:getClanRaidStruct()
    local stage_id = struct_raid:getStageID()
    local next_stage_id = g_stageData:getNextStage(stage_id)

    local finish_cb = function()
        self:refresh()
    end

    if (next_stage_id) then
        g_clanRaidData:request_info(next_stage_id, finish_cb)
    end
end

-------------------------------------
-- function click_rankBtn
-- @brief 클랜 던전 랭킹 (클랜)
-------------------------------------
function UI_ClanRaid:click_rankBtn()
    local rank_type = CLAN_RANK['RAID']
    local offset = 1
    local cb_func = function()
        UI_ClanRaidRankPopup()
    end

    g_clanRankData:request_getRank(rank_type, offset, cb_func)
end

-------------------------------------
-- function click_rewardBtn
-- @brief 클랜 던전 보상
-------------------------------------
function UI_ClanRaid:click_rewardBtn()
    UI_ClanRaidRewardPopup()
end

-------------------------------------
-- function click_readyBtn
-- @brief 던전입장
-------------------------------------
function UI_ClanRaid:click_readyBtn()

    -- 갱신 가능 시간인지 체크한다
	local curr_time = Timer:getServerTime()
	if (curr_time - self.m_preRefreshTime > RENEW_INTERVAL) then
		self.m_preRefreshTime = curr_time

		-- 이때 다른 유저가 플레이중인지 한번더 검사
        local finish_cb = function()
            local struct_raid = g_clanRaidData:getClanRaidStruct()
            local state = struct_raid:getState()
            local stage_id = g_clanRaidData:getChallengStageID()
            local hp = struct_raid:getHp()

            -- 플레이중인 유저가 있다면
            if (state == CLAN_RAID_STATE.CHALLENGE) then
                self:showDungeonStateUI()

            -- 도전중인 클랜던전이 변경되었다면 다시 모두 갱신
            elseif (self.m_stageID ~= stage_id) then
                self.m_stageID = stage_id
                self.m_remainHp = hp
                self:refresh(true)

            -- HP가 변경되었다면 다시 모두 갱신
            elseif (self.m_remainHp ~= hp) then
                self.m_remainHp = hp
                self:refresh(true)
                self.m_preRefreshTime = 1
                UIManager:toastNotificationGreen(Str('던전 정보가 갱신되었습니다.'))

            else
                -- 클랜 던전 처리 - 덱 map 추가로 생성
                self.m_preRefreshTime = 0
                UI_ReadySceneNew(self.m_stageID) 
            end
        end

        g_clanRaidData:request_info(self.m_stageID, finish_cb)
	
	else
		local ramain_time = math_ceil(RENEW_INTERVAL - (curr_time - self.m_preRefreshTime) + 1)
		UIManager:toastNotificationRed(Str('{1}초 후에 갱신 가능합니다.', ramain_time))
	end
end

-------------------------------------
-- function click_bossInfoBtn
-- @brief 보스 정보
-------------------------------------
function UI_ClanRaid:click_bossInfoBtn(tab)
    UI_ClanRaidBossInfo(tab)
end

--@CHECK
UI:checkCompileError(UI_ClanRaid)