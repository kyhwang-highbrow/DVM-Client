local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonLatea
-------------------------------------
UI_DragonLatea = class(PARENT,{
    -- 서버상의 드래곤 정보가 마지막으로 변경된 시간 (refresh 체크 용도)
    m_dragonListLastChangeTime = 'timestamp',
    m_lateaTableView = '',

    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonLatea:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonLatea'
    
    self.m_subCurrency = 'memory_myth'  -- 상단 유저 재화 정보 중 서브 재화
    self.m_bVisible = true or false
    self.m_titleStr = nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
    self.m_bShowInvenBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLatea:init(doid)
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

    self.m_dragonListLastChangeTime = g_dragonsData:getLastChangeTimeStamp()
end

-------------------------------------
-- function init_after
-------------------------------------
function UI_DragonLatea:init_after()
    PARENT.init_after(self)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLatea:initUI()
    local vars = self.vars

    self:init_dragonTableView()
    self:init_lateaTableView()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonLatea:initButton()
    local vars = self.vars
end


-------------------------------------
-- function init_lateaTableView
-------------------------------------
function UI_DragonLatea:init_lateaTableView()
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
            self:setSelectLateaDragonData(data['id'])
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
    self.m_lateaTableView = table_view_td
    self.m_lateaTableView:setItemList({})
end

-------------------------------------
-- function setSelectDragonData
-- @brief 선택된 드래곤 설정
-------------------------------------
function UI_DragonLatea:setSelectDragonData(object_id, b_force)
    local ok_btn_cb = function ()
        local struct_dragon = g_dragonsData:getDragonObject(object_id)
        if struct_dragon ~= nil then
            self.m_lateaTableView:addItem(object_id, struct_dragon)
        end
    end

    local msg = Str('드래곤을 라테아에 등록하시겠습니까?')
    local submsg = Str('라테아에 등록해도 자유롭게 해제가 가능합니다.')
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end


-------------------------------------
-- function setSelectLateaDragonData
-- @brief 선택된 라테아 드래곤 설정
-------------------------------------
function UI_DragonLatea:setSelectLateaDragonData(object_id, b_force)
    local ok_btn_cb = function ()
        local struct_dragon = g_dragonsData:getDragonObject(object_id)
        if struct_dragon ~= nil then
            self.m_lateaTableView:delItem(object_id)
        end
    end

    local msg = Str('드래곤을 라테아에서 해제하시겠습니까?')
    local submsg = Str('해제해도 자유롭게 등록이 가능합니다.')
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLatea:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonLatea:click_exitBtn()
    self:close()
end

-------------------------------------
-- function getSelectedDragon
-------------------------------------
function UI_DragonLatea:getSelectedDragon()
    return self.m_selectDragonData
end

-------------------------------------
-- function _hasDragon
-- @brief 플레이어가 드래곤를 보유 했는지 여부
-- @return boolean
-------------------------------------
function UI_DragonLatea:_hasDragon(did)
    local dragon_cnt = g_dragonsData:getNumOfDragonsByDid(did)
    return (dragon_cnt ~= 0)
end

-------------------------------------
-- function checkDragonListRefresh
-- @brief 드래곤 리스트에 변경이 있는지 확인 후 갱신
-------------------------------------
function UI_DragonLatea:checkDragonListRefresh()
    local is_changed = g_dragonsData:checkChange(self.m_dragonListLastChangeTime)

    if is_changed then
        self.m_dragonListLastChangeTime = g_dragonsData:getLastChangeTimeStamp()
        -- 정렬
        self:apply_dragonSort_saveData()
    end
end

--@CHECK
UI:checkCompileError(UI_DragonLatea)
