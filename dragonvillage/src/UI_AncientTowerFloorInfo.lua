-------------------------------------
-- class UI_AncientTowerFloorInfo
-------------------------------------
UI_AncientTowerFloorInfo = class({
        m_uiScene = 'UI_AncientTower',
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

    vars['towerTabLabel']:setString(Str('고대의 탑 {1}층', info.m_floor))

    do -- 시즌 정보
        local season_score = math_max(g_ancientTowerData.m_nTotalScore, 0)
        local str_score = Str('{1}점', comma_value(season_score))
        vars['totalScoreLabel']:setString(str_score)
    end
    
    do -- 층 정보
        local my_score = info.m_myScore
        local my_high_score = info.m_myHighScore
        local season_high_score = info.m_seasonHighScore
        local top_user = info.m_topUserInfo
        local nick = top_user and top_user:getNickname() or ''
        local str = Str('{@DESC2}{1}점\n{@DESC}{@MUSTARD2}{2}점\n{@DESC}{3}점\n{4}', 
                        comma_value(my_high_score), 
                        comma_value(my_score), 
                        comma_value(season_high_score), 
                        nick)
        vars['scoreLabel']:setString(str)

        local stage_id = info.m_stage
        local str_help = TableStageData():getValue(tonumber(stage_id), 't_help')
        vars['towerDscLabel']:setString(str_help)
    end
    
    do -- 스테이지에 해당하는 스테미나 아이콘 생성
        local stage_id = info.m_stage
        local st_type, st_cnt = TableDrop:getStageStaminaType(stage_id)
        local icon = IconHelper:getStaminaInboxIcon(st_type)
        vars['staminaNode']:addChild(icon)
        vars['actingPowerLabel']:setString(st_cnt)
    end

    local rank = comma_value(g_ancientTowerData.m_nTotalRank)
    if (rank == '-1') then
        vars['meTotalScoreLabel']:setString(Str('기록 없음'))
    else
        local score = math.max(g_ancientTowerData.m_nTotalScore, 0)
        local str_info = '{@yellow}' .. Str('{1}위', comma_value(rank)) .. '{@default}  ' ..  Str('{1}점', comma_value(score))
        vars['meTotalScoreLabel']:setString(str_info)
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

    local id, cnt = info:getReward()
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

    -- 스테이지 레벨로 몬스터와 드래곤 레벨 설정 (전투력 계산에 쓰임)
    local stage_id = info.m_stage

    -- 고대의 탑은 드래곤 몬스터인 경우 모두 보스 처리
    local function is_boss(id)
        local code = getDigit(id, 10000, 2)
        if (code == 12) then
            return true
        end
        return false
    end

    local function make_func(data)
        local ui = UI_MonsterCard(data, is_boss(data))
        ui:setStageID(stage_id)
        return ui
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(152, 150)
    table_view:setCellUIClass(make_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_item_list)
    table_view.m_bAlignCenterInInsufficient = true -- 리스트 내 개수 부족 시 가운데 정렬
end