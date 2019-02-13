local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanRaid
-------------------------------------
UI_ClanRaid = class(PARENT, {
        m_stageID = 'number',
        m_preRefreshTime = 'time',

        m_contributionTab = '',
     })

local TAB_CLAN_CONTRIBUTION = 'clan_contribution' -- 클랜 기여도 
local TAB_CLAN_RANK = 'clan_rank' -- 클랜 랭킹

local RENEW_INTERVAL = 3  -- 갱신 호출 시간 제한
local SHOW_NEXT_LEVEL_LIMIT = 4 -- 다음 4레벨 보스까지 미리 볼 수 있음

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
    local vars = self:load_keepZOrder('clan_raid_scene_new.ui')
    UIManager:open(self, UIManager.SCENE)

    self.m_preRefreshTime = 0

    local struct_raid = g_clanRaidData:getClanRaidStruct()
    self.m_stageID = struct_raid:getStageID()

    g_clanRaidData:setBossStatus()

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

        UI_ClanRaidRankingRewardPopup(t_info, is_clan)

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
    self:addTabWithLabel(TAB_CLAN_CONTRIBUTION, vars['contributionTabBtn'], vars['contributionTabLabel'], vars['contributionTabMenu'])
    self:addTabWithLabel(TAB_CLAN_RANK, vars['clanRankTabBtn'], vars['clanRankTabLabel'], vars['clanRankTabMenu'])

    self:setTab(TAB_CLAN_CONTRIBUTION)
    self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ClanRaid:onChangeTab(tab, first)
    -- 클랜 랭킹은 클릭할때마다 갱신
    if (tab == TAB_CLAN_RANK) then
        UI_ClanRaidTabRank(self)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanRaid:refresh(force)
    if (force) then
        self.m_contributionTab = UI_ClanRaidTabContribution(self)
    end

    if (self.m_contributionTab) then
        self.m_contributionTab:initTableViewCurrentRank()
    end

    self:initRaidInfo()
    self:refreshBtn()
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

    -- 골드 누적 보상 표시
    local boss_lv = g_clanRaidData.m_challenge_stageID % 1000 -- 현재 진행중인 레벨
    vars['bossRewardLvLabel']:setString(string.format('Lv.%d', boss_lv))

    local total_reward = g_clanRaidData:getTotalGoldReward()
    vars['bossRewardLabel']:setString(comma_value(total_reward))

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
-- function showDungeonStateUI
-- @brief 던전 상태에 따른 UI 변경
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

        -- 끝까지 클리어한 경우, 마지막 스테이지에서 다음 시즌 정보 출력
        if (struct_raid:isClearAllClanRaidStage() and stage_id == MAX_STAGE_ID) then
            local status_text = g_clanRaidData:getClanRaidStatusText()
            vars['atkLabel']:setString(Str('마지막 스테이지를 클리어 했습니다.\n다음 시즌까지 {1}', status_text))
            vars['atkLabel']:setVisible(true)
            vars['lastClearSprite']:setVisible(true)
            vars['notiVisual']:setVisible(false)
        else
            vars['atkLabel']:setVisible(false)
            vars['lastClearSprite']:setVisible(false)
            vars['notiVisual']:setVisible(true)

            noti_visual:changeAni('clear', true)
            noti_visual.m_node:setScale(1.3)
        end

    end

    -- 파이널 블로우에서 보상 문구 노출
    vars['bossRewardInfoNode']:setVisible(state == CLAN_RAID_STATE.FINALBLOW)
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
    if (struct_raid:isOverMaxStage(next_stage_id)) then
        vars['nextBtn']:setVisible(false)
    else
        vars['nextBtn']:setVisible(curr_stage_id + SHOW_NEXT_LEVEL_LIMIT >= next_stage_id)
    end

    -- 시작버튼 활성화/비활성화, 
    -- 해당 스테이지가 마지막이고, 마지막 스테이지 클리어한 상태라면 준비버튼 비활성화
    if (struct_raid:isClearAllClanRaidStage() and stage_id == MAX_STAGE_ID) then
        vars['readyBtn']:setEnabled(false) 
    else
        vars['readyBtn']:setEnabled(stage_id == curr_stage_id)       
    end

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
-- function click_rewardBtn
-- @brief 클랜 던전 보상
-------------------------------------
function UI_ClanRaid:click_rewardBtn()
    UI_HelpClan('clan_dungeon','clan_dungeon_reward')
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

                -- 덱 준비화면은 진입가능하게 수정
                self.m_preRefreshTime = 0
                UI_ReadySceneNew(self.m_stageID) 

            -- 도전중인 클랜던전이 변경되었다면 다시 모두 갱신
            elseif (self.m_stageID ~= stage_id) then
                self.m_stageID = stage_id
                self:refresh(true)

            -- 보스 정보가 변경되었다면 다시 모두 갱신
            elseif (not g_clanRaidData:checkBossStatus()) then
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
    UI_HelpClan('clan_dungeon','clan_dungeon_summary')
end

--@CHECK
UI:checkCompileError(UI_ClanRaid)