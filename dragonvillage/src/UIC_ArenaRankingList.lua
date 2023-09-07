local PARENT = UIC_RankingList
-------------------------------------
-- class UIC_ArenaRankingList
-------------------------------------
UIC_ArenaRankingList = class(PARENT, {
})

-------------------------------------
-- function makeRankList
-------------------------------------
function UIC_ArenaRankingList:makeRankList(node)
    local l_item = self.m_itemList
    if (not l_item) then
        l_item = {}
    end

    local create_func = function(ui, data)    
        -- 이전 버튼 세팅
        local click_prev = function()
            self:click_prev()
        end       

        if (data['rank'] == 'prev') then
            if (ui.vars['prevBtn']) then
                ui.vars['prevBtn']:registerScriptTapHandler(click_prev)
                ui.vars['prevBtn']:setVisible(true)
            end
            ui.vars['itemMenu']:setVisible(false)
        end

        -- 다음 버튼 세팅
        local click_next = function()
            self:click_next()
        end

        if (data['rank'] == 'next') then
            if (ui.vars['nextBtn']) then
                ui.vars['nextBtn']:registerScriptTapHandler(click_next)
                ui.vars['nextBtn']:setVisible(true)
            end
            ui.vars['itemMenu']:setVisible(false)
        end

        if (self.m_cellUICreateCB) then
            self.m_cellUICreateCB(ui, data)
        end
    end

    node:removeAllChildren()

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(550, 120 + 5)
    table_view:setCellUIClass(self.m_cellUIClass, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:makeDefaultEmptyDescLabel(self.m_emptyMsg)
    table_view:setItemList(l_item)

    self.m_rankTableView = table_view

    if (self.m_makeMyRankCb) then
        self.m_makeMyRankCb()
    end
end
