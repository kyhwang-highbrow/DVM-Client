local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonLair
-------------------------------------
UI_DragonLair = class(PARENT,{
    m_lairTableView = '',

    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonLair:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonLair'
    
    self.m_subCurrency = 'memory_myth'  -- 상단 유저 재화 정보 중 서브 재화
    self.m_bVisible = true or false
    self.m_titleStr = nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
    self.m_bShowInvenBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLair:init(doid)
    local vars = self:load('dragon_latea.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, self.m_uiName)

    self:sceneFadeInAction()
    self:initUI()
    self:initButton()    
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr()
end

-------------------------------------
-- function init_after
-------------------------------------
function UI_DragonLair:init_after()
    PARENT.init_after(self)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLair:initUI()
    local vars = self.vars

    self:init_dragonTableView()
    self:init_lairTableView()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonLair:initButton()
    local vars = self.vars
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-------------------------------------
function UI_DragonLair:getDragonList()
    local result_dragon_map = {}
    local m_dragons = g_dragonsData:getDragonsListRef()

    for doid, struct_dragon_data in pairs(m_dragons) do
        if TableLairCondition:getInstance():isMeetCondition(struct_dragon_data) == true then
            result_dragon_map[doid] = struct_dragon_data
        end
    end

    return result_dragon_map
end

-------------------------------------
-- function init_lairTableView
-------------------------------------
function UI_DragonLair:init_lairTableView()
    local node = self.vars['lateaListNode']

    -- 리스트 아이템 생성 콜백
    local function make_func(object)
        return UI_DragonCard(object)
    end

    local function create_func(ui, data)
--[[         -- 새로 획득한 드래곤 뱃지
        local is_new_dragon = data:isNewDragon()
        ui:setNewSpriteVisible(is_new_dragon) ]]
        
        ui.root:setScale(0.66)
        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function()
            --self:click_dragon(data)
            self:setSelectLairDragonData(data['id'])
        end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(102, 102)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(make_func, create_func)
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['scale'])
    table_view_td:setCellCreatePerTick(3)
    self.m_lairTableView = table_view_td
    self.m_lairTableView:setItemList({})
end

-------------------------------------
-- function setSelectDragonData
-- @brief 선택된 드래곤 설정
-------------------------------------
function UI_DragonLair:setSelectDragonData(object_id, b_force)
    local ok_btn_cb = function ()
        local struct_dragon = g_dragonsData:getDragonObject(object_id)
        if struct_dragon ~= nil then
            self.m_lairTableView:addItem(object_id, struct_dragon)
            self.m_tableViewExt:delItem(object_id)
        end
    end

    local msg = Str('드래곤을 라테아에 등록하시겠습니까?')
    local submsg = Str('라테아에 등록해도 자유롭게 해제가 가능합니다.')
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

-------------------------------------
-- function setSelectLairDragonData
-- @brief 선택된 라테아 드래곤 설정
-------------------------------------
function UI_DragonLair:setSelectLairDragonData(object_id, b_force)
    local ok_btn_cb = function ()
        local struct_dragon = g_dragonsData:getDragonObject(object_id)
        if struct_dragon ~= nil then
            self.m_tableViewExt:addItem(object_id, struct_dragon)
            self.m_lairTableView:delItem(object_id)

            self:apply_dragonSort()
        end
    end

    local msg = Str('드래곤을 라테아에서 해제하시겠습니까?')
    local submsg = Str('해제해도 자유롭게 등록이 가능합니다.')
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLair:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonLair:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonLair)
