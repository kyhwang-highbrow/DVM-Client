local PARENT = UI_DragonManage_Base
local MAX_SELL_CNT = 30

-------------------------------------
-- class UI_DragonConversion
-------------------------------------
UI_DragonConversion = class(PARENT,{
		m_tConversionTable = 'list',
		m_price = 'number'
    })

-------------------------------------
-- function initParentVariable
-- @brief �ڽ� Ŭ�������� �ݵ�� ������ ��
-------------------------------------
function UI_DragonConversion:initParentVariable()
    -- ITopUserInfo_EventListener�� �ɹ� ������ ����
    self.m_uiName = 'UI_DragonConversion'
    self.m_bVisible = true
    self.m_titleStr = Str('')
    self.m_bUseExitBtn = true
    self.m_bShowInvenBtn = true 
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonConversion:init(doid)
    local vars = self:load('dragon_conversion.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey ����
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonConversion')

    self:sceneFadeInAction()
	
	self.m_tConversionTable = {}
	self.m_price = 0

    self:initUI()
    self:initButton()
    self:refresh()

    -- ���� �����
	self:init_mtrDragonSortMgr(false) -- slime_first
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonConversion:initUI()
	local vars = self.vars

	self:init_bg()
end

-------------------------------------
-- function initButton
-- @brief ��ư UI �ʱ�ȭ
-------------------------------------
function UI_DragonConversion:initButton()
    local vars = self.vars
    vars['conversionBtn']:registerScriptTapHandler(function() self:click_conversionBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonConversion:refresh()
    self:refresh_selectedMaterial()
	self:refresh_dragonMaterialTableView()
end

-------------------------------------
-- function init_bg
-- @brief �巡�� ����
-------------------------------------
function UI_DragonConversion:init_bg()
    local vars = self.vars

    -- ���
    local animator = ResHelper:getUIDragonBG('earth', 'idle')
    vars['bgNode']:addChild(animator.m_node)
end

-------------------------------------
-- function refresh_dragonMaterialTableView
-- @brief ��� ���̺� �� ����
-- @override
-------------------------------------
function UI_DragonConversion:refresh_dragonMaterialTableView()   
    local list_table_node = self.vars['materialTableViewNode']
    list_table_node:removeAllChildren()

    -- ����Ʈ ������ ���� �ݹ�
    local function create_func(ui, data)
        ui.root:setScale(0.80)
        -- Ŭ�� ��ư ����
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonMaterial(data) end)

		self:createMtrlDragonCardCB(ui, data)
    end

    -- ���̺�� ����
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(128.8, 128.8)
    table_view_td.m_nItemPerCell = 9
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_mtrlTableViewTD = table_view_td

    -- ����Ʈ�� ����� ��
    table_view_td:makeDefaultEmptyDescLabel(Str('�Ǹ��� �巡���� ����� �Ф�'))

    -- ���� ��� ������ ����Ʈ�� ����
    local l_dragon_list = self:getDragonMaterialList(self.m_selectDragonOID)
    self.m_mtrlTableViewTD:setItemList(l_dragon_list)
	
	self:apply_mtrlDragonSort()
end

-------------------------------------
-- function getDragonMaterialList
-- @brief ��Ḯ��Ʈ : �Ǹ� - ���/ ���� ������ ���
-- @override
-------------------------------------
function UI_DragonConversion:getDragonMaterialList(doid)
    local dragon_dic = g_dragonsData:getDragonsList()

    -- �ڱ� �ڽ� �巡�� ����
    if doid then
        dragon_dic[doid] = nil
    end

    -- ���� ��� �Ұ����� �巡�� ����
    for oid,v in pairs(dragon_dic) do
        if (not g_dragonsData:possibleConversion(oid)) then
            dragon_dic[oid] = nil
        end
    end

    return dragon_dic
end

-------------------------------------
-- function createMtrlDragonCardCB
-- @brief ��� ī�� ���� ��..
-- @override
-------------------------------------
function UI_DragonConversion:createMtrlDragonCardCB(ui, data)
    -- nothing to do
end

-------------------------------------
-- function click_dragonMaterial
-- @override
-------------------------------------
function UI_DragonConversion:click_dragonMaterial(t_dragon_data)
    local function next_func()
        local doid = t_dragon_data['id']

	    -- ���� ó�� �� ���̺���Ʈ ����
	    do
		    local price = TableDragonExp():getDragonSellGold(t_dragon_data['grade'], t_dragon_data['lv'])

		    -- ����
		    if (self.m_tConversionTable[doid]) then
			    self.m_tConversionTable[doid] = nil
			    self.m_price = self.m_price - price
		
		    -- �߰�
		    else
			    -- ���� üũ
			    local sell_cnt = table.count(self.m_tConversionTable)
			    if (sell_cnt >= MAX_SELL_CNT) then
				    UIManager:toastNotificationRed(Str('�� ���� �ִ� {1}�������� �����մϴ�.', MAX_SELL_CNT))
				    return
			    end

			    self.m_tConversionTable[doid] = t_dragon_data
			    self.m_price = self.m_price + price
		    end
	    end

	    -- ����
        self:refresh_materialDragonIndivisual(doid)
        self:refresh_selectedMaterial()
    end

    local doid = t_dragon_data['id']
    if self.m_tConversionTable[doid] then
        -- ������ ���
        next_func()
    else
        -- ��� ���
        local oid = t_dragon_data['id']
        g_dragonsData:dragonMaterialWarning(oid, next_func, nil, '��ȯ�Ͻðڽ��ϱ�?') -- param : oid, next_func, t_warning, warning_msg
    end
end

-------------------------------------
-- function refresh_materialDragonIndivisual
-- @brief �巡�� ��� ����Ʈ���� ���õ� �巡�� ǥ��
-------------------------------------
function UI_DragonConversion:refresh_materialDragonIndivisual(doid)
    if (not self.m_mtrlTableViewTD) then
        return
    end

    local item = self.m_mtrlTableViewTD:getItem(doid)
    if (not item) then
        return
    end
    
    local ui = item['ui']
    if (not ui) then
        return
    end

	local is_select = self.m_tConversionTable[doid] and true or false
    ui:setCheckSpriteVisible(is_select)
end

-------------------------------------
-- function refresh_selectedMaterial
-- @brief ���õ� ����� ������ ����Ǿ�����
-------------------------------------
function UI_DragonConversion:refresh_selectedMaterial()
	local vars = self.vars

	-- �Ǹ� ����
	local sell_cnt = table.count(self.m_tConversionTable)
	vars['selectLabel']:setString(string.format('%d / %d', sell_cnt, MAX_SELL_CNT))
end

-------------------------------------
-- function click_conversionBtn
-- @brief
-------------------------------------
function UI_DragonConversion:click_conversionBtn()
	-- ���� üũ
	local sell_cnt = table.count(self.m_tConversionTable)
	if (sell_cnt <= 0) then
		UIManager:toastNotificationGreen(Str('��� �巡���� �������ּ���!'))
		return
	end

	local doids = ''

	for oid, t_dragon_data in pairs(self.m_tConversionTable) do
		if (t_dragon_data.m_objectType == 'dragon') then
			if (doids == '') then
                doids = tostring(oid)
            else
                doids = doids .. ',' .. tostring(oid)
            end
		end
	end

	local function cb_func(ret)
		-- �ٽ� �ʱ�ȭ
		self.m_price = 0
		self.m_tConversionTable = {}
		self:refresh_dragonMaterialTableView()
        self:refresh_selectedMaterial()

		-- �ܺο� ��ȭ ���� ����
		self.m_bChangeDragonList = true
        local l_item = {}
        for i, v in pairs(ret['conversion_item_list']) do
            table.insert(l_item, {
                ['item_id'] = tonumber(i),
                ['count'] = v
            })
        end
        ccdump(l_item)
        UI_ObtainPopup(l_item, nil, nil, true)
	end

	g_dragonsData:request_dragonConversion(doids, cb_func)
end

--@CHECK
UI:checkCompileError(UI_DragonConversion)
