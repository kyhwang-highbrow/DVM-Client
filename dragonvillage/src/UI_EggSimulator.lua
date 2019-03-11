local PARENT = UI

-------------------------------------
-- class UI_EggSimulator
-------------------------------------
UI_EggSimulator = class(PARENT, {
       m_selected_item_id = 'number',
       m_selected_item_count = 'number',
        m_selected_item_id1 = 'number',
       m_selected_item_count1 = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_EggSimulator:init(rune_object_id)
    self.m_selected_item_id = nil
    self.m_selected_item_count = 1
    self.m_selected_item_id1 = nil
    self.m_selected_item_count1 = 1

    local vars = self:load('rune_dev_api_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EggSimulator')
    
    self:initUI()
    self:initButton()
    self:refresh()
    self:initEditBox()
    self:makeComboBox1()
    self:makeComboBox2()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EggSimulator:initUI()
    local vars = self.vars
    vars['nameLabel']:setString('부화하려는 알을 가지고 있어야 합니다')
    vars['titleLabel']:setString('알 시뮬레이터')
    vars['uoptLabel']:setString('5성 이하 부화')
    vars['soptLabel1']:setString('5성 부화')

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EggSimulator:initButton()
    local vars = self.vars
    vars['uoptDeleteBtn']:registerScriptTapHandler(function() self:click_applyBtn1() end)
    vars['soptDeleteBtn1']:registerScriptTapHandler(function() self:click_applyBtn2() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_EggSimulator:refresh()
    local vars = self.vars

end

-------------------------------------
-- function makeComboBox
-------------------------------------
function UI_EggSimulator:makeComboBox1()
    local vars = self.vars

    local button = vars['uoptBtn']
    local label = vars['uoptLabel']

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local uic = UIC_SortList()
    uic.m_direction = UIC_SORT_LIST_TOP_TO_BOT
    uic:setNormalSize(width, height)
    --uic:setPosition(x, y)
    uic:setPosition(x + 300, 400)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

    uic:setExtendButton(button)
        uic:setSortTypeLabel(label)
    button:registerScriptTapHandler(function()
        uic:toggleVisibility()
    end)
    
    parent:addChild(uic.m_node)

    local item_list = TableSummonGacha:getSummonEggList()

    for i, t_egg in ipairs(item_list) do
        if (t_egg['type'] == 'pick') and (t_egg['birthgrade_min'] ~= 5) then
            uic:addSortType(t_egg['item_id'], t_egg['t_name'])
        end
    end

	uic:setSortChangeCB(function(egg_type)
        self.m_selected_item_id = egg_type
    end)

    return uic
end

-------------------------------------
-- function makeComboBox
-------------------------------------
function UI_EggSimulator:makeComboBox2()
    local vars = self.vars

    local button = vars['soptBtn1']
    local label = vars['soptLabel1']

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local uic = UIC_SortList()
    uic.m_direction = UIC_SORT_LIST_TOP_TO_BOT
    uic:setNormalSize(width, height)
    --uic:setPosition(x, y)
    uic:setPosition(x + 300, 100)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

    uic:setExtendButton(button)
        uic:setSortTypeLabel(label)
    button:registerScriptTapHandler(function()
        uic:toggleVisibility()
    end)
    
    parent:addChild(uic.m_node)

    local item_list = TableSummonGacha:getSummonEggList()

    for i, t_egg in ipairs(item_list) do
        if (t_egg['type'] == 'pick') and (t_egg['birthgrade_min'] == 5) then
            uic:addSortType(t_egg['item_id'], t_egg['t_name'])
        end
    end

	uic:setSortChangeCB(function(egg_type)
        self.m_selected_item_id1 = egg_type
    end)

    return uic
end

-------------------------------------
-- function initEditBox
-------------------------------------
function UI_EggSimulator:initEditBox()
    local vars = self.vars
    local function isValidText(str)
        if (str ~= string.match(str, '[0-9]*')) then
            local msg = Str('숫자만 입력 가능합니다.')
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return false
        end

        return true
    end

    vars['uoptEditBox']:registerScriptEditBoxHandler(function(strEventName, pSender)
                if (strEventName == "return") then
                    local editbox = pSender
                    local str = editbox:getText()
                    if (isValidText(str)) then
                        self.m_selected_item_count = tonumber(str)
                    end
                end
            end)
    vars['soptEditBox1']:registerScriptEditBoxHandler(function(strEventName, pSender)
                if (strEventName == "return") then
                    local editbox = pSender
                    local str = editbox:getText()
                    if (isValidText(str)) then
                        self.m_selected_item_count1 = tonumber(str)
                    end
                end
            end)
            
end

-------------------------------------
-- function click_applyBtn
-------------------------------------
function UI_EggSimulator:click_applyBtn1()
    local vars = self.vars
    local egg_id = self.m_selected_item_id
    local cnt = self.m_selected_item_count

    if (not egg_id) then
        UIManager:toastNotificationRed('알을 선택하세요')
        return
    end

    if (cnt == 0) then
        UIManager:toastNotificationRed('수량이 0입니다')
        return
    end

    self:request_addEgg(egg_id)
end

-------------------------------------
-- function click_applyBtn
-------------------------------------
function UI_EggSimulator:click_applyBtn2()
    local vars = self.vars
    local egg_id = self.m_selected_item_id1
    local cnt = self.m_selected_item_count1

    if (not egg_id) then
        UIManager:toastNotificationRed('알을 선택하세요')
        return
    end

    if (cnt == 0) then
        UIManager:toastNotificationRed('수량이 0입니다')
        return
    end

    self:request_addEgg(egg_id)  
end

-------------------------------------
-- function request_addEgg
-- @brief 알 추가
-------------------------------------
function UI_EggSimulator:request_addEgg(egg_id, cb_func)
    local uid = g_userData:get('uid')


    local function success_cb(ret)
        if ret['user'] then
            g_serverData:applyServerData(ret['user'], 'user')
        end
        
        local tabel_dragon = TableDragon()
        local dragon_str = ''
        local finish_cb = function(ret)
            local l_dragon = ret['added_dragons']
            for _,t_dragon in ipairs(l_dragon) do
                local did = t_dragon['did']
                local dragon_name = tabel_dragon:getDragonName(tonumber(did))
                local dragon_attr = dragonAttributeName(tabel_dragon:getDragonAttr(did))
                dragon_str = dragon_str .. '  ' .. dragon_name .. ' (' .. dragon_attr .. ')'
            end
            ccdump(dragon_str)
        end

    
        g_eggsData:request_incubate(egg_id, cnt, finish_cb, nil)
    end

    local ui_network = UI_Network()
    ui_network:setRevocable(true)
    ui_network:setUrl('/users/manage')
    ui_network:setParam('uid', uid)
    ui_network:setParam('act', 'increase')
    ui_network:setParam('key', 'eggs')
    ui_network:setParam('value', tostring(egg_id) .. ',' .. tostring(5))

    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end