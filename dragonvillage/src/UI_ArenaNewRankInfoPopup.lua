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
    self:addAction(self.root, UI_ACTION_TYPE_LEFT, 0, 0.2)
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
    local struct_rank_reward = StructArenaNewRankReward(table_arena_rank, true)
    local l_rank_reward = struct_rank_reward:getRankRewardList()

    table.sort(l_rank_reward, function(a,b) return a['tier_id'] < b['tier_id'] end)

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view:setScrollLock(true)
    table_view.m_defaultCellSize = cc.size(720, 50)
    table_view:setCellUIClass(UI_ArenaNewTierInfoListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_rank_reward)
end

--@CHECK
UI:checkCompileError(UI_ArenaNewRankInfoPopup)
