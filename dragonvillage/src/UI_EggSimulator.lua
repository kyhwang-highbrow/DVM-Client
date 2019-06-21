local PARENT = UI

-------------------------------------
-- class UI_EggSimulator
-------------------------------------
UI_EggSimulator = class(PARENT, {
        m_eggCnt = 'number',
        m_eggId = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_EggSimulator:init()
    local vars = self:load('egg_dev_api_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EggSimulator')
    
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EggSimulator:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function()
            self:close()
    end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EggSimulator:initUI()
    local vars = self.vars

    local list_table_node = self.vars['eggListNode']
    list_table_node:removeAllChildren()

    -- 아이템들 중에 알만 추려냄
    local table_item = TableItem()
    local l_egg_list = table_item:filterList('type', 'egg')
    local l_item_list = {}
    for i,v in ipairs(l_egg_list) do
        local egg_id = v['item']
        table.insert(l_item_list, egg_id)
    end
    table.sort(l_item_list, function(a, b)
            return a < b
        end)

    -- 생성 콜백
    local function create_func(ui, data)
        
        -- 알 클릭했을 경우, 갯수 묻는 팝업 생성
        local egg_id = data
        ui.vars['clickBtn']:registerScriptTapHandler(function()
            self.m_eggId = tonumber(egg_id)
            self:getEggCntPopup()
        end)

        -- 알 카드, 테이블뷰 생성
        local name = table_item:getValue(egg_id, 't_name')
        local label = cc.Label:createWithTTF(name, Translate:getFontPath(), 20, 1, cc.size(600, 50), 1, 1)
        label:setDockPoint(cc.p(0.5, 0.5))
        label:setAnchorPoint(cc.p(0.5, 0.5))
        label:setPositionY(50)
        ui.root:addChild(label)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(150, 150)
    table_view_td.m_nItemPerCell = 8
    table_view_td:setCellUIClass(UI_ItemCard, create_func)
    table_view_td:setItemList(l_item_list)
end


-------------------------------------
-- function getEggCntPopup
-------------------------------------
function UI_EggSimulator:getEggCntPopup()
    local vars = self.vars

    local ui_number_popup = UI()
    ui_number_popup:load('coupon_input.ui')
    UIManager:open(ui_number_popup, UIManager.POPUP)

    ui_number_popup.vars['titleLabel']:setString('부화할 알의 갯수를 입력하세요.')
    ui_number_popup.vars['dscLabel']:setString('애뮬레이터 로그창에서 부화결과를 확인할 수 있습니다')
    ui_number_popup.vars['okBtn']:registerScriptTapHandler(function() self:request_showResult() end)

    -- 숫자 3자리까지 입력 가능
    ui_number_popup.vars['editBox']:setMaxLength(3)
    ui_number_popup.vars['editBox']:setPlaceHolder('숫자로만 입력하세요.(천 단위까지 가능)')


    -- editBox handler 등록
	local function editBoxTextEventHandle(strEventName, pSender)
        if (strEventName == "return") then
            -- 숫자 아닌 값 예외처리
            local res = ui_number_popup.vars['editBox']:getText()
            if (res ~= string.match(res, '[0-9]*')) then
                MakeSimplePopup(POPUP_TYPE.OK, Str('숫자가 아닙니다.\n다시 입력해 주세요.'))
            end
            self.m_eggCnt = tonumber(res)
        end
    end
    ui_number_popup.vars['editBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

-------------------------------------
-- function request_showResult
-------------------------------------
function UI_EggSimulator:request_showResult()
    local egg_id = self.m_eggId
    local cnt = self.m_eggCnt

    if (egg_id == '' or not egg_id) then
        UIManager:toastNotificationRed('알맞은 값을 입력하세요')
        return
    elseif (cnt == '' or not cnt or cnt == 0) then
        UIManager:toastNotificationRed('알맞은 값을 입력하세요')
        return
    end

    local success_cb = function(ret)
        UIManager:toastNotificationGreen('알 시뮬레이션 결과는 로그창에서 확인하세요!')
        
        -- 알 시뮬 결과 출력
        local t_dragon = ret['dragonList'] or {}
        self:printSimulationResult(t_dragon)
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/shop/egg_simulate')
    ui_network:setParam('egg_id', egg_id)
    ui_network:setParam('count', cnt)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

--[[
"dragonList":{
    "120635":1,
    "121112":2,
    "120671":2,
    "120302":1,
    "120124":1,
    "120202":5,
    "120122":4,
    "120203":4,
    "120511":1,
    "121143":2,
    "120392":2,
--]]

-------------------------------------
-- function printSimulationResult
-------------------------------------
function UI_EggSimulator:printSimulationResult(t_dragon)
    local egg_name = TableItem():getValue(self.m_eggId, 't_name')
    local inform_str = string.format('[%s]을 %d 번 부화한 결과 ', egg_name, self.m_eggCnt)

    cclog('=============================================')
    cclog(inform_str)
    cclog('=============================================')
    
    local idx = 1
    local table_dragon = TableDragon()
    for dragon_id, cnt in pairs(t_dragon) do
        for i=1, cnt do
            local did = tonumber(dragon_id)
            local dragon_name = table_dragon:getDragonNameWithAttr(did)
            local result_str = string.format('%d. %s', idx,  dragon_name)
            cclog(result_str)

            idx = idx + 1
        end
    end

    cclog('=============================================')
    cclog(inform_str .. '출력 종료')
    cclog('=============================================')
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EggSimulator:refresh()
    local vars = self.vars
end



