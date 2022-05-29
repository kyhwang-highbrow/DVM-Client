local PARENT = UI

-- g_colosseumData -> g_arenaData 변경 필요, 아직 서버 api 분리안됨

-------------------------------------
-- class UI_ArenaNewHistory
-- @brief 아레나 기록 탭 (공격전, 방어전)
-------------------------------------
UI_ArenaNewHistory = class(PARENT,{
        vars = '',
        
        m_matchDefHistory = 'table',

        m_arenaAtkTableView = 'UIC_TableView',        
        m_arenaDefTableView = 'UIC_TableView',
    })

local OFFSET_GAP = 30 -- 한번에 보여주는 히스토리 수
local CLAN_OFFSET_GAP = 20

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewHistory:init()
    local vars = self:load('arena_new_popup_defense.ui')
	self.m_uiName = 'UI_ArenaNewHistory'
    UIManager:open(self, UIManager.POPUP)

    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self.m_matchDefHistory = g_arenaNewData.m_matchDefHistory

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ArenaNewHistory')
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)

    --self.root = owner_ui.vars['historyMenu'] -- root가 있어야 보임
    --self.vars = owner_ui.vars

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewHistory:initUI()
    local vars = self.vars

    local historyList = self.m_matchDefHistory
    local totalWin = 0
    local totalLose = 0
    local totalScore = 0

    if (historyList and (1 <= #historyList)) then
        --match 
        for i, v in ipairs(historyList) do

            local isWin = v.m_matchResult == 1

            if (isWin) then
                totalWin = totalWin + 1
            else
                totalLose = totalLose + 1
            end

            totalScore = totalScore + v.m_matchScore
        end
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['listNode'])
    table_view.m_defaultCellSize = cc.size(720, 85)
    table_view:setCellUIClass(UI_ArenaNewHistoryListItem)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(historyList)
    table_view:makeDefaultEmptyDescLabel(Str('방어 기록이 없습니다.'))

    local sum = totalWin + totalLose
    local win_rate_text = sum ~= 0 and math_floor(totalWin / sum * 100) or 0
    if (type(tonumber(win_rate_text)) ~= 'number') then win_rate_text = '0' end

    local strRecord = Str('{1}승 {2}패 ({3}%)', totalWin, totalLose, win_rate_text)
    local strScore = tostring(totalScore)

    vars['winLabel']:setString(strRecord)
    vars['scoreLabel']:setString(strScore)
end