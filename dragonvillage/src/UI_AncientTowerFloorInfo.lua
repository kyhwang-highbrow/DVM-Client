-------------------------------------
-- class UI_AncientTowerFloorInfo
-------------------------------------
UI_AncientTowerFloorInfo = class({
        m_uiScene = 'UI_AncientTowerScene',
        m_floorInfo = 'StructAncientTowerFloorData',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerFloorInfo:init(ui_scene)
    self.m_uiScene = ui_scene

	self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerFloorInfo:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerFloorInfo:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerFloorInfo:refresh(floor_info)
    if (floor_info) then
        self.m_floorInfo = floor_info
    end

    self:refresh_floorData()
    self:refresh_rewardData()
    self:refresh_monsterList()
end

-------------------------------------
-- function refresh_floorData
-------------------------------------
function UI_AncientTowerFloorInfo:refresh_floorData()
    local vars = self.m_uiScene.vars
    local info = self.m_floorInfo

    vars['floorLabel']:setString(Str('고대의 탑 {1}층', info.m_floor))

    do -- 시즌 정보
        local season_score = math_max(g_ancientTowerData.m_nTotalScore, 0)
        local season_rank = g_ancientTowerData.m_nTotalRank
        season_rank = (season_rank == 0) and Str('순위 없음') or Str('{1}위', season_rank)

        local str = Str('{1}점\n{2}', season_score, season_rank)
        vars['totalScoreLabel']:setString(str)
    end
    
    do -- 층 정보
        local my_score = info.m_myScore
        local my_high_score = info.m_myHighScore
        local season_high_score = info.m_seasonHighScore
        local top_user = info:getTopUserNick()
        local str = Str('{1}점\n{2}점\n{3}점\n{4}', my_score, my_high_score, season_high_score, top_user)
        vars['scoreLabel']:setString(str)

        vars['challengeLabel']:setString(Str('도전 횟수 {1}회', info.m_failCnt))

        local weak_grade = info:getCurrentWeakGrade()
        local max_grade = 5
        vars['weakenLabel']:setString(Str('약화 등급 {1}/{2}', weak_grade, max_grade))
    end
    
    do -- 스테이지에 해당하는 스테미나 아이콘 생성
        local stage_id = info.m_stage
        local type = TableDrop:getStageStaminaType(stage_id)
        local icon = IconHelper:getStaminaInboxIcon(type)
        vars['staminaNode']:addChild(icon)
        vars['actingPowerLabel']:setString(info:getNeedStamina())
    end
end

-------------------------------------
-- function refresh_rewardData
-------------------------------------
function UI_AncientTowerFloorInfo:refresh_rewardData()
    local vars = self.m_uiScene.vars
    local info = self.m_floorInfo

    -- 재화일 경우 숫자만
    local node = vars['rewardNode']
    node:removeAllChildren()

    local id, cnt = info:getFirstReward()
    local ui = UI_ItemCard(id, cnt)
    node:addChild(ui.root)
end

-------------------------------------
-- function refresh_monsterList
-------------------------------------
function UI_AncientTowerFloorInfo:refresh_monsterList()
    local vars = self.m_uiScene.vars
    local info = self.m_floorInfo

    local node = vars['monsterListNode']
    node:removeAllChildren()

    local l_item_list = info:getMonsterList()

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(152, 150)
    table_view:setCellUIClass(UI_MonsterCard)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_item_list)
    table_view.m_bAlignCenterInInsufficient = true -- 리스트 내 개수 부족 시 가운데 정렬
end