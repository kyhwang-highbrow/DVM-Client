-------------------------------------
-- class UI_ClanWar_GroupPaging
-------------------------------------
UI_ClanWar_GroupPaging = class({
        vars = 'vars',

        -- 외부에서 설정되어야 할 데이터
        m_numOfGroup = 'number', -- 조별리그 조의 수 (32개조, 64개조 ...)
        m_onGroupChange = 'function', -- 선택된 조가 변경되었을 때의 콜백 함수 function(group) end

        -- 내부에서 사용되는 변수
        m_currPage = 'number', -- 현재 선택된 페이지
        m_currTabName = 'string', -- 선택된 탭 버튼의 이름 'all', '01', '02', '03', '04', '05', '06', '07', '08'
     })

-- 상수 정의
UI_ClanWar_GroupPaging['NUM_PER_PAGE'] = 8 -- 한 페이지에 보여질 조의 수
UI_ClanWar_GroupPaging['TAB_NAME_LIST'] = {'all', '01', '02', '03', '04', '05', '06', '07', '08'} -- 탭 버튼 네이밍


-------------------------------------
-- function initVariable
-------------------------------------
function UI_ClanWar_GroupPaging:initVariable()
    self.m_currPage = nil
    self.m_currTabName = nil
end

-------------------------------------
-- function init
-- @brief 생성자
-- @param vars table UI클래스에서 사용하는 vars
-- @param num_of_group number 전체 조의 수 (8의 배수임을 가정한다. 32개조 or 64개조)
-------------------------------------
function UI_ClanWar_GroupPaging:init(vars, num_of_group)
    self.vars = vars
    self.m_numOfGroup = num_of_group

    self:initVariable()

	-- 초기화
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWar_GroupPaging:initUI(ret)
    local vars = self.vars

    -- 선택된 탭입을 표시하는 sprite의 visible이 켜져있을 수 있으므로 모두 끈다.
    for _, name in pairs(UI_ClanWar_GroupPaging['TAB_NAME_LIST']) do
        local luaname = (name .. 'SelectSprite')

        if vars[luaname] then
            vars[luaname]:setVisible(false)
        end
    end
    --[[
    vars['allSelectSprite']:setVisible(false)
    vars['01SelectSprite']:setVisible(false)
    vars['02SelectSprite']:setVisible(false)
    vars['03SelectSprite']:setVisible(false)
    vars['04SelectSprite']:setVisible(false)
    vars['05SelectSprite']:setVisible(false)
    vars['06SelectSprite']:setVisible(false)
    vars['07SelectSprite']:setVisible(false)
    vars['08SelectSprite']:setVisible(false)
    --]]
end



-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWar_GroupPaging:initButton()
    local vars = self.vars

    -- 그룹 페이지 이전, 다음 버튼
    vars['leagueMoveBtn1']:registerScriptTapHandler(function() self:changeTabPage('prev') end)
    vars['leagueMoveBtn2']:registerScriptTapHandler(function() self:changeTabPage('next') end)

    -- 모든 탭 버튼에 탭 핸들러를 등록한다
    local TAB_NAME_LIST = UI_ClanWar_GroupPaging['TAB_NAME_LIST']
    for _, name in pairs(TAB_NAME_LIST) do
        local luaname = (name .. 'TabBtn')

        if vars[luaname] then
            vars[luaname]:registerScriptTapHandler(function() self:changeTab(name) end)
        end
    end
    --[[
    vars['allTabBtn']:registerScriptTapHandler(function() self:changeTab('all') end)
    vars['01TabBtn']:registerScriptTapHandler(function() self:changeTab('01') end)
    vars['02TabBtn']:registerScriptTapHandler(function() self:changeTab('02') end)
    vars['03TabBtn']:registerScriptTapHandler(function() self:changeTab('03') end)
    vars['04TabBtn']:registerScriptTapHandler(function() self:changeTab('04') end)
    vars['05TabBtn']:registerScriptTapHandler(function() self:changeTab('05') end)
    vars['06TabBtn']:registerScriptTapHandler(function() self:changeTab('06') end)
    vars['07TabBtn']:registerScriptTapHandler(function() self:changeTab('07') end)
    vars['08TabBtn']:registerScriptTapHandler(function() self:changeTab('08') end)
    --]]
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWar_GroupPaging:refresh()
    local vars = self.vars
end

-------------------------------------
-- function changeTabPage
-- @brief 화면 상단에 8개의 조를 하나의 그룹으로 묶어서 페이징한다. 이 페이지를 변경을 관리하는 함수.
-- @param type 'init', 'prev', 'next'
-------------------------------------
function UI_ClanWar_GroupPaging:changeTabPage(type)
    local new_page

    -- 타입에 따라 초기화, 이전, 다음 페이지로 동작한다.
    if (type == 'init') or (self.m_currPage == nil) then
        new_page = 1
    else
        if (type == 'prev') then
            new_page = (self.m_currPage - 1)

        elseif (type == 'next') then
            new_page = (self.m_currPage + 1)
        end
    end

    -- 페이지의 범위를 1~최대 페이지로 보정한다.
    local NUM_PER_PAGE = UI_ClanWar_GroupPaging['NUM_PER_PAGE']
    local max_page = (self.m_numOfGroup / NUM_PER_PAGE)
    new_page = math_clamp(new_page, 1, max_page)

    -- 현재 페이지와 새로운 페이지가 다를 경우에만 동작한다.
    if (self.m_currPage ~= new_page) then

        -- 새로운 페이지 설정
        self:setPage(new_page)

        -- 페이지가 변경되었으므로 페이지의 첫탭을 포커싱
        self:changeTab('01', true) -- param : tab_name, force_refresh
    end

    self:log('new_page ' .. new_page)
end

-------------------------------------
-- function setPage
-- @return boolean 페이지가 변경된 여부
-------------------------------------
function UI_ClanWar_GroupPaging:setPage(page)
    local NUM_PER_PAGE = UI_ClanWar_GroupPaging['NUM_PER_PAGE']
    local new_page = page

    if (self.m_currPage ~= new_page) then
        self.m_currPage = new_page

        local add_idx = (new_page - 1) * NUM_PER_PAGE

        local vars = self.vars
        for i=1, NUM_PER_PAGE do
            vars['0' .. i .. 'TabLabel']:setString(Str('{1}조', add_idx + i))
        end

        -- 페이지가 변경되었을 경우 버튼 연출
        local TAB_NAME_LIST = UI_ClanWar_GroupPaging['TAB_NAME_LIST']
        for i, name in ipairs(TAB_NAME_LIST) do
            local btn = vars[name .. 'TabBtn']
            btn:stopAllActions()
            btn:setScale(0)
            btn:runAction(cc.Sequence:create(cc.DelayTime:create((i-1) * 0.025), cc.EaseElasticOut:create(cc.ScaleTo:create(1, 1, 1), 0.8)))
        end
        return true
    end

    return false
end

-------------------------------------
-- function changeTab
-------------------------------------
function UI_ClanWar_GroupPaging:changeTab(tab_name, force_refresh)
    local prev = nil
    local next = nil
    local changed = (force_refresh or false)

    if (self.m_currTabName ~= tab_name) then
        prev = self.m_currTabName
        self.m_currTabName = tab_name
        next = tab_name
        changed = true
    end

    local vars = self.vars

    if (prev) then
        vars[prev .. 'SelectSprite']:setVisible(false)
    end

    if (next) then
        vars[next .. 'SelectSprite']:setVisible(true)
    end

    if (changed == true) then
        if self.m_onGroupChange then
            if (tab_name == 'all') then
                self.m_onGroupChange('all')
            else
                local NUM_PER_PAGE = UI_ClanWar_GroupPaging['NUM_PER_PAGE']
                local tab_idx = tonumber(tab_name)
                local group_idx = ((self.m_currPage - 1) * NUM_PER_PAGE) + tab_idx
                self.m_onGroupChange(group_idx)
            end
        end
    end
end


-------------------------------------
-- function getPageFromGroupIdx
-- @brief 조로 페이지를 얻어옴
-------------------------------------
function UI_ClanWar_GroupPaging:getPageFromGroupIdx(group_idx)
    local NUM_PER_PAGE = UI_ClanWar_GroupPaging['NUM_PER_PAGE']
    local page = math_floor((group_idx - 1) / NUM_PER_PAGE) + 1
    self:log('group_idx : ' .. group_idx .. ' page : ' .. page)
    return page
end


-------------------------------------
-- function setGroup
-- @brief
-------------------------------------
function UI_ClanWar_GroupPaging:setGroup(group_idx)

    -- 조가 속한 페이지를 계산하고 설정한다.
    local page = self:getPageFromGroupIdx(group_idx)
    local changed = self:setPage(page)

    -- 페이지 내에서 해당 조의 idx를 계산한다.
    local NUM_PER_PAGE = UI_ClanWar_GroupPaging['NUM_PER_PAGE']
    local idx_at_page = group_idx - ((page - 1) * NUM_PER_PAGE)

    -- 페이지 내의 idx를 통해 tab_name을 조합하고 탭을 설정한다.
    local tab_name = ('0' .. idx_at_page)
    self:changeTab(tab_name, changed)
end


-------------------------------------
-- function setGroupChangeCB
-- @brief
-- @param cb function(group) end
--           group은 all, 1, 2, 3, 4 .. 64 의 형태로 선택된 조를 의미한다.
-------------------------------------
function UI_ClanWar_GroupPaging:setGroupChangeCB(cb)
    self.m_onGroupChange = cb
end

-------------------------------------
-- function log
-- @brief 클래스 내부에서 사용하는 로그. 가급적 개발 중에만 사용하고 커밋 시 skip을 true로 설정하도록 한다.
-------------------------------------
function UI_ClanWar_GroupPaging:log(msg)
    local skip = true
    if (skip == true) then
        return
    end

    cclog('##UI_ClanWar_GroupPaging log## : ' .. tostring(msg))
end


-------------------------------------
-- function sampleCode
-- @brief
--        SceneDv에서 확인해보세요.
--        require('UI_ClanWar_GroupPaging')
--        UI_ClanWar_GroupPaging:sampleCode()
-------------------------------------
function UI_ClanWar_GroupPaging:sampleCode()
    local ui = UI()
    ui:load('clan_war_group_stage.ui')
    UIManager:open(ui, UIManager.SCENE)

    local vars = ui.vars
    local num_of_group = 64

    -- param group 'all' or number
    local function on_group_change(group)
        cclog('#### group : ' .. group)
    end

    self.m_groupPaging = UI_ClanWar_GroupPaging(vars, num_of_group)
    self.m_groupPaging:setGroupChangeCB(on_group_change)
    --self.m_groupPaging:setPage(1) -- 해당 페이지의 첫 조로 설정
    self.m_groupPaging:setGroup(20) -- 해당 조를 설정(페이지 자동 계산)
end