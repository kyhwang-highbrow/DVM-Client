local PARENT = UI

-------------------------------------
-- class UI_ArenaNewRankInfoPopup
-------------------------------------
UI_ArenaNewRankInfoPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewRankInfoPopup:init()
    self.m_uiName = 'UI_ArenaNewRankInfoPopup'
    local vars = self:load('arena_new_popup_tier_reward.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ArenaNewRankInfoPopup')

    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewRankInfoPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaNewRankInfoPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaNewRankInfoPopup:refresh()
    local vars = self.vars
    local node = vars['listNode']

    local table_arena_rank = TABLE:get('table_arena_new_rank')
    local struct_rank_reward = StructArenaNewRankReward()
    local l_rank_reward = struct_rank_reward:getRankRewardList()
    local finalList = {}

    for i, v in ipairs(l_rank_reward) do
        -- 입문자는 버리기
        if (v['tier_id'] ~= 99) then
            table.insert(finalList, v)
        end
    end

    table.sort(finalList, function(a,b) return a['tier_id'] < b['tier_id'] end)

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(720, 50)
    table_view:setCellUIClass(UI_ArenaNewTierInfoListItem)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(finalList)
end

--@CHECK
UI:checkCompileError(UI_ArenaNewRankInfoPopup)
