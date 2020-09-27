local PARENT = UI

-------------------------------------
-- class UI_PackageRandomBoxInfo
-------------------------------------
UI_PackageRandomBoxInfo = class(PARENT,{
        m_item_list = 'table',
        m_packageName = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PackageRandomBoxInfo:init(l_item, package_name)
    -- ui 파일이 다르다. package에 따라 하드코딩함
    local ui_name
    if (package_name == 'package_lucky_box_9.9k') then
        ui_name = 'package_lucky_box_9.9k_popup.ui'
    else
        ui_name = 'package_lucky_box_popup.ui'
    end

    local vars = self:load(ui_name)
    UIManager:open(self, UIManager.POPUP)

    -- 확률 순으로 정렬
    table.sort(l_item, function(a,b)
        return a['pick_weight'] < b['pick_weight']
    end)

    self.m_packageName = package_name
    self.m_item_list = l_item

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_PackageRandomBoxInfo')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_PackageRandomBoxInfo:initUI()
    local vars = self.vars
    local l_item = self.m_item_list
    for i, v in ipairs(l_item) do
        local tar_node = vars['itemNode'..i]
        if (tar_node) then
            local ui = self.makeCellUI(v, self.m_packageName)
            tar_node:addChild(ui.root)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PackageRandomBoxInfo:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)  
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PackageRandomBoxInfo:refresh()
end

-------------------------------------
-- function makeCellUI
-- @static
-- @brief 테이블 셀 생성
-------------------------------------
function UI_PackageRandomBoxInfo.makeCellUI(t_data, package_name)
	local ui = class(UI, ITableViewCell:getCloneTable())()

    -- ui 파일이 다르다. package에 따라 하드코딩함
    local ui_name
    if (package_name == 'package_lucky_box_9.9k') then
        ui_name = 'package_lucky_box_9.9k_popup_item.ui'
    else
        ui_name = 'package_lucky_box_popup_item.ui'
    end

	local vars = ui:load(ui_name)

    local item_id = t_data['item_id']
    local count = t_data['count']
    local rate = t_data['pick_weight']/10

    -- 아이콘
	local icon = IconHelper:getItemIcon(item_id)
	vars['itemNode']:addChild(icon)

    -- 이름
    local name = TableItem:getItemName(item_id)
    local full_name = string.format('%s', name) .. ' '..Str('{1}개', comma_value(count))
    vars['itemLabel']:setString(full_name)
    
    -- 설명 
    -- 번역문제로 일딴 기존 문구 하드 코딩
    vars['dscLabel']:setString('')
    local msg
    if (item_id == 703004) then
        msg = Str('3~5등급 (한정 드래곤 포함)')

    elseif (item_id == 703005) then
        msg = Str('5등급 확정')
    
    elseif (item_id == 703003) then
        msg = Str('4~5등급 (한정 드래곤 포함)')

    elseif (item_id == 703001) then
        msg = Str('5등급 확정 (한정 드래곤 포함)')
    end
    
    if (msg) then
        vars['dscLabel']:setString(msg)
    end

    -- 확률
    vars['percentLabel']:setString(string.format('%d%%', math.floor(rate)))

    vars['itemBtn']:registerScriptTapHandler(function()
        UI_ItemInfoPopup(item_id, count, nil)
    end)

	return ui
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_PackageRandomBoxInfo:click_closeBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_PackageRandomBoxInfo)
