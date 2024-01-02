local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanRaid
-------------------------------------
UI_ClanRaid = class(PARENT, {
        m_stageID = 'number',
        m_preRefreshTime = 'time',

        m_contributionTab = '',
        m_cur_stage_arrow_item = 'ui',
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
    self.m_cur_stage_arrow_item = nil

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
-- function openNotiPopup
-------------------------------------
function UI_ClanRaid:openNotiPopup()
    local check_never_show = g_settingData:get('clan_raid_noti')
    if (not check_never_show) then
        local notice_ui = UI()
        notice_ui:load('clan_raid_change_popup.ui')
        notice_ui.vars['closeBtn']:setVisible(false)
        
        local check_cb = function()
            g_settingData:applySettingData(true, 'clan_raid_noti')
        end

        -- 체크 박스 붙어있는 이벤트 풀팝업에 붙여서 사용
        local ui_full_popup = UI_EventFullPopup('', notice_ui, check_cb) -- popup_key, target_ui, m_check_cb
        ui_full_popup:openEventFullPopup()
        ui_full_popup.vars['checkMsgLabel']:setString(Str('다시 보지 않기'))
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
    local struct_raid = g_clanRaidData:getClanRaidStruct()
    
    -- 클랜 마크
    local icon = struct_clan:makeClanMarkIcon()
    vars['clanNode']:removeAllChildren()
    vars['clanNode']:addChild(icon)

    -- 클랜 이름
    local clan_name = struct_clan:getClanName()
    vars['clanLabel']:setString(clan_name)

    -- 보스 hp
    vars['hpLabel2']:setVisible(true)
    vars['hpLabel2']:setString(Str('{1}/{1}', struct_raid:getHp(), struct_raid:getMaxHp()))

    -- 보너스 속성
    do
        local str, map_attr = struct_raid:getBonusSynastryInfo()
        vars['bonusTipsDscLabel']:setString(str)

        for k, v in pairs(map_attr) do
            -- 속성 아이콘
            local icon = IconHelper:getAttributeIconButton(k)
            local target_node = vars['bonusTipsNode']
            target_node:addChild(icon)
        end
    end

    -- 페널티 속성
    do
        local str, map_attr = struct_raid:getPenaltySynastryInfo()
        vars['panaltyTipsDscLabel']:setString(str)

        local cnt = table.count(map_attr)
        local idx = 0

        for k, v in pairs(map_attr) do
            idx = idx + 1
            -- 속성 아이콘
            local icon = IconHelper:getAttributeIconButton(k)
            local target_node = (cnt == 1) and 
                                vars['panaltyTipsNode'] or 
                                vars['panaltyTipsNode'..idx]
            target_node:addChild(icon)
        end
    end

    -- 속성 로테이션
    local attr = struct_raid:getAttr()
    local l_rotation_order = getAttrTextList()
    local m_rotation_order = getAttrOrderMap()
    local attr_order = m_rotation_order[attr]

    -- 현재 속성을 가운데에 두기 위해, Node3부터 찍는다
    for i=3,7 do
        local target_order = attr_order + (i-3) -- 1씩 증가
        -- 인덱스 로테이션 예외처리
        if (i>5) then
            i = i - 5
        end
        -- 속성 순서 로테이션 예외처리
        if (target_order>5) then
            target_order = target_order - 5
        end
        vars['rotationAttrNode' .. i]:setTexture(string.format('res/ui/icons/attr/attr_%s_02.png', l_rotation_order[target_order]))
    end
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
    vars['bossInfoBtn']:registerScriptTapHandler(function() self:click_bossInfoBtn('cldg_summary') end)
    vars['synastryInfoBtn']:registerScriptTapHandler(function() self:click_bossInfoBtn('cldg_attr_bonus') end)

    -- 클랜 던전 안내 (네이버 sdk 링크)
    NaverCafeManager:setPluginInfoBtn(vars['plugInfoBtn'], 'clanraid_help')

    vars['clanRankBtn']:registerScriptTapHandler(function() self:click_clanRankBtn() end)

    vars['trainingBtn']:registerScriptTapHandler(function() self:click_trainBtn() end)

    --@dhkim 23.01.12 배틀 패스 버튼 추가
    vars['battlePassBtn']:registerScriptTapHandler(function() self:click_battlePassBtn() end)
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
    local status_text = Str(g_clanRaidData:getClanRaidStatusText())
    status_text = string.gsub(status_text, '\n', ' ')
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
    local boss_lv = struct_raid:getLv()
    local boss_name = struct_raid:getBossName()
    vars['levelLabel']:setString(string.format('Lv.%d', boss_lv))
    vars['bossNameLabel']:setString(boss_name)

    -- 속성 아이콘
    local attr = struct_raid:getAttr()
    local icon = IconHelper:getAttributeIconButton(attr)
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
        vars['bonusTipsDscLabel']:setString(str)        
    end

    -- 페널티 속성
    do
        local str, map_attr = struct_raid:getPenaltySynastryInfo()
        vars['panaltyTipsDscLabel']:setString(str)
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
    local is_lock_stage = (stage_id == curr_stage_id)
    vars['lockNode']:setVisible(not is_lock_stage)
    vars['readyBtn']:setVisible(is_lock_stage)
    vars['bossLockSprite']:setVisible(stage_id > curr_stage_id)
    vars['trainingBtn']:setVisible(is_lock_stage)

    -- 다른 유저 도전중인 상태 
    if (state == CLAN_RAID_STATE.CHALLENGE) then
        local player = struct_raid:getPlayer()
        if (player) then
            local nick = player['nick']
            local label = vars['atkLabel']
            noti_visual:changeAni('atk', true)
            label:setVisible(true)

            local start_time = struct_raid:getStartTime()
            local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
            local play_time = curr_time - start_time
            label:setString(Str('{1}님이 전투중입니다.\n{2} 경과되었습니다.', nick, ServerTime:getInstance():makeTimeDescToSec(play_time, true)))

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

        -- 끝까지 클리어한 경우
        if (struct_raid:isClearAllClanRaidStage() and stage_id == g_clanRaidData:getClanRaidMaxStageId()) then
            local status_text = g_clanRaidData:getClanRaidStatusText()
            vars['atkLabel']:setString(status_text)
            vars['atkLabel']:setVisible(true)
            vars['lastClearSprite']:setVisible(true)
            vars['notiVisual']:setVisible(false)
        else
            vars['atkLabel']:setVisible(false)
            vars['lastClearSprite']:setVisible(false)
            vars['notiVisual']:setVisible(true)

            noti_visual:changeAni('clear', true)
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
    if (struct_raid:isClearAllClanRaidStage() and stage_id == g_clanRaidData:getClanRaidMaxStageId()) then
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
	local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
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
    UI_HelpClan('clan_dungeon','clan_dungeon_summary', tab)
end

-------------------------------------
-- function click_clanRankBtn
-- @brief 랭킹 정보 버튼
-------------------------------------
function UI_ClanRaid:click_clanRankBtn()
    UI_ClanRaidRankingPopup()
end

-------------------------------------
-- function click_battlePassBtn
-- @brief 배틀패스 버튼
-------------------------------------
function UI_ClanRaid:click_battlePassBtn()
    UI_BattlePassPopup()
end

-------------------------------------
-- function click_trainBtn
-------------------------------------
function UI_ClanRaid:click_trainBtn()
    local cb_func = function()
        UI_ClanRaidTrainingPopup(self.m_stageID)
    end
    g_clanRaidData:requestGameInfo_training(cb_func)
end


--@CHECK
UI:checkCompileError(UI_ClanRaid)







