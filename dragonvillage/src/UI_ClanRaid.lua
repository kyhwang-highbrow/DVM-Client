local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanRaid
-------------------------------------
UI_ClanRaid = class(PARENT, {
        m_sortManager = '',
        m_tableView = '',
     })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ClanRaid:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ClanRaid'
    self.m_titleStr = Str('클랜던전')
	--self.m_staminaType = 'pvp'
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

    self.m_uiName = 'UI_ClanRaid'
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanRaid')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

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

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanRaid:initButton()
    local vars = self.vars
    vars['prevBtn']:registerScriptTapHandler(function() self:click_prevBtn() end)
    vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanRaid:refresh()
    local vars = self.vars
    local struct_clan = g_clanData:getClanStruct()

    -- 클랜 마크
    local icon = struct_clan:makeClanMarkIcon()
    vars['clanNode']:removeAllChildren()
    vars['clanNode']:addChild(icon)

    -- 클랜 이름
    local clan_name = struct_clan:getClanName()
    vars['clanLabel']:setString(clan_name)

    -- 종료 시간
    local status_text = g_clanRaidData:getClanRaidStatusText()
    vars['timeLabel']:setString(status_text)

    self:initTableView()
    self:initRaidInfo()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ClanRaid:initTab()
    local vars = self.vars
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_ClanRaid:initTableView()
    local vars = self.vars
    local struct_raid = g_clanRaidData:getClanRaidStruct()

    local node = vars['listNode']
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

    local msg = Str('참여한 유저가 없다고라')
    local scale = 0.8
    table_view:makeDefaultEmptyMandragora(msg, scale)
end

-------------------------------------
-- function initRaidInfo
-------------------------------------
function UI_ClanRaid:initRaidInfo()
    local vars = self.vars
    local struct_raid = g_clanRaidData:getClanRaidStruct()
    local stage_id = struct_raid:getStageID()

    -- 보스 animator
    local boss_node = vars['bossNode']
    boss_node:removeAllChildren()
    local animator = struct_raid:getBossAnimator()
    if (animator) then
        boss_node:addChild(animator.m_node)
    end

    -- 레벨, 이름
    local name = struct_raid:getBossNameWithLv()
    vars['levelLabel']:setString(name)

    -- 속성 아이콘
    local attr = struct_raid:getAttr()
    local icon = IconHelper:getAttributeIcon(attr)
    vars['attrNode']:removeAllChildren()
    vars['attrNode']:addChild(icon)

    -- 체력 게이지
    local rate = struct_raid:getHpRate()
    local action = cc.ProgressTo:create(0.5, rate)
    vars['bossHpGauge1']:runAction(action)
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
    else
        UIManager:toastNotificationRed(Str('클랜던전 정보가 없습니다.'))
    end
end

-------------------------------------
-- function click_nextBtn
-- @brief 다음 던전 정보
-------------------------------------
function UI_ClanRaid:click_nextBtn()
    local curr_stage_id = g_clanRaidData.m_curr_stageID
    local struct_raid = g_clanRaidData:getClanRaidStruct()
    local stage_id = struct_raid:getStageID()
    local next_stage_id = g_stageData:getNextStage(stage_id)

    -- 현재 진행중인 던전 이후는 보여주지 않음 (던전 인스턴스 생성되지 않은 상태)
    if (curr_stage_id < next_stage_id) then
        UIManager:toastNotificationRed(Str('현재 난이도를 먼저 클리어하세요!'))
        return
    end

    local finish_cb = function()
        self:refresh()
    end

    if (next_stage_id) then
        g_clanRaidData:request_info(next_stage_id, finish_cb)
    else
        UIManager:toastNotificationRed(Str('클랜던전 정보가 없습니다.'))
    end
end

-------------------------------------
-- function click_startBtn
-- @brief 던전입장
-------------------------------------
function UI_ClanRaid:click_startBtn()
    local struct_raid = g_clanRaidData:getClanRaidStruct()
    local stage_id = struct_raid:getStageID()

    UI_ReadySceneNew(stage_id)
end

--@CHECK
UI:checkCompileError(UI_ClanRaid)