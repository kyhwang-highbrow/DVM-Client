local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())
-------------------------------------
--- @class UI_Research
-------------------------------------
UI_Research = class(PARENT,{
    m_researchTableViewList = 'List<TableView>',
    m_researchIdList = 'List<List<number>>',
})

-------------------------------------
--- @function initParentVariable
--- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Research:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Research'
    self.m_subCurrency = 705091  -- 상단 유저 재화 정보 중 서브 재화    
    self.m_titleStr = Str('연구')
    self.m_bUseExitBtn = true -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_Research:init(doid)
    self:load('research.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Research')

    self:doActionReset()
	self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:makeTableView()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Research:initUI()
    local vars = self.vars

end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_Research:initButton()
    local vars = self.vars

    vars['resetBtn']:registerScriptTapHandler(function() 
        self:click_resetBtn()
    end)

    vars['helpBtn']:registerScriptTapHandler(function() 
        self:click_helpBtn()
    end)

    vars['statBtn']:registerScriptTapHandler(function() 
        self:click_statBtn()
    end)

    for idx = 1,2 do
        local str = string.format('researchAll%dBtn', idx)
        vars[str]:registerScriptTapHandler(function()
            self:click_researchAllBtn(idx)
        end)
    end
end

-------------------------------------
-- function makeTableView
-------------------------------------
function UI_Research:makeTableView()
    local vars = self.vars
    self.m_researchTableViewList = {}
    self.m_researchIdList = {}
    -- 생성 콜백
    local function create_func(ui, data)
        ui.vars['infoBtn']:registerScriptTapHandler(function()
            self:click_infoBtn(data)
        end)

        ui.vars['infoBtn']:registerScriptPressHandler(function()
            local research_id = data
            local tooltip_str = TableResearch:getInstance():getResearchTooltipStr(research_id)
            local tooltip = UI_Tooltip_Skill(0, 0, tooltip_str)
            if (tooltip) then
                tooltip:autoPositioning(ui.vars['infoBtn'])
            end
        end)
    end

    for type = 1,2 do
        local str = string.format('list%dNode', type)
        vars[str]:removeAllChildren()

        local item_list = TableResearch:getInstance():getIdListByType(type)
        local table_view = UIC_TableView(vars[str])
        table_view.m_defaultCellSize = cc.size(140, 200)
        table_view:setCellUIClass(UI_ResearchItem, create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        table_view:setItemList(item_list)

        self.m_researchTableViewList[type] = table_view
        self.m_researchIdList[type] = item_list

        local select_idx_1 = (g_researchData:getLastResearchId(type) + 1) % 10000
        local select_idx_2 = (g_researchData:getAvailableLastResearchId(type)) % 10000
        local select_idx = select_idx_2 > select_idx_1 and select_idx_2 or select_idx_1

        table_view:update(0)
        table_view:relocateContainerFromIndex(select_idx)
    end
end

--------------------------------------------------------------------------
--- @function refreshTableView
--------------------------------------------------------------------------
function UI_Research:refreshTableView()
    local refresh_func = function(t_data, data)
        if t_data['ui'] ~= nil then
            t_data['ui']:refresh()
        end
    end

    for type = 1,2 do
        local item_list = self.m_researchIdList[type]
        self.m_researchTableViewList[type]:mergeItemList(item_list, refresh_func)
    end
end

-------------------------------------
--- @function refresh
-------------------------------------
function UI_Research:refresh()
    local vars = self.vars
    for type = 1,2 do
        local str = string.format('level%dLabel', type)
        local lv = g_researchData:getLastResearchId(type) % 10000

        if lv == 0 then
            vars[str]:setString(Str('없음'))
        else
            vars[str]:setString(string.format('Lv. %d', lv))
        end
    end

    self:refreshTableView()
end

-------------------------------------
--- @function click_infoBtn
-------------------------------------
function UI_Research:click_infoBtn(research_id)
    local research_type = TableResearch:getInstance():getResearchType(research_id)
    local last_research_id = g_researchData:getLastResearchId(research_type)

    -- 잠금해제가 가능한 상태
    local is_unlock_available = g_researchData:isAvailableResearchId(research_id)

    -- 잠금된 상태
    local is_locked = research_id > last_research_id and is_unlock_available == false

    -- 해제 상태 - 완료 체크
    local is_unlocked = research_id <= last_research_id

    if is_unlocked == true then
        UI_ResearchConfirmPopup(research_id, 'view')
    elseif is_locked == true then
        UI_ResearchConfirmPopup(research_id, 'view')
    else
        local ui = UI_ResearchConfirmPopup(research_id)
        ui:setCloseCB(function()
            if last_research_id ~= g_researchData:getLastResearchId(research_type) then
                self:refresh()
            end
        end)
    end
end

-------------------------------------
--- @function click_resetBtn
-------------------------------------
function UI_Research:click_resetBtn()
    local success_cb = function()
        self:makeTableView()
        self:refresh()
    end

    local finish_cb = function()
        g_researchData:request_researchReset(success_cb)
    end

    if g_researchData:isResearchResetAvailable() == false then
        UIManager:toastNotificationRed(Str('현재까지 연구 정보가 없습니다.'))
        return
    end

    local need_count = 3000
    -- 다이아 3000개
    local cost = g_researchData:getResearchAccCost()
    local item_id = TableResearch:getInstance():getResearchCostItemId()
    local item_name = TableItem:getItemName(item_id)
    local msg = Str('연구 정보를 초기화 하시겠습니까?')
    local submsg = Str('{@orange}지금까지의 연구 정보는 모두 초기화되며 {@G}{1}{@}{@orange}개의 {2}(을)를 돌려받습니다.', comma_value(cost), item_name)
    local ui = MakeSimplePricePopup(POPUP_TYPE.YES_NO, msg, submsg, finish_cb)
    ui:setPrice('cash', need_count)
end

-------------------------------------
--- @function click_helpBtn
-------------------------------------
function UI_Research:click_helpBtn()
    UI_Help('research')
end

-------------------------------------
--- @function click_statBtn
-------------------------------------
function UI_Research:click_statBtn()
    UI_ResearchAbilityPopup.open()
end

-------------------------------------
--- @function click_researchAllBtn
-------------------------------------
function UI_Research:click_researchAllBtn(type)
    local vars = self.vars
    do -- 능력치 텍스트
        local last_research_id = g_researchData:getLastResearchId(type)
        local map = TableResearch:getInstance():getAccumulatedBuffList({last_research_id})
        local str = TableResearch:getInstance():getResearchBuffMapToStr(map)
        if str == '' then
            str = Str('아직 연구 정보가 없습니다.')
        end

        local tooltip = UI_Tooltip_Skill(0, 0, string.format('{@green}%s', str))
        if (tooltip) then
            local btn_str = string.format('researchAll%dBtn', type)
            tooltip:autoPositioning(vars[btn_str])
        end
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Research:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_Research)
