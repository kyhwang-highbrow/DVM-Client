local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonCollection
-------------------------------------
UI_DragonCollection = class(PARENT,{
    -- 서버상의 드래곤 정보가 마지막으로 변경된 시간 (refresh 체크 용도)
    m_dragonListLastChangeTime = 'timestamp',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonCollection:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonCollection'
    
    self.m_subCurrency = 'memory_myth'  -- 상단 유저 재화 정보 중 서브 재화
    self.m_bVisible = true or false
    self.m_titleStr = nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
    self.m_bShowInvenBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonCollection:init(doid)
    -- spine 캐시 정리 확인
    SpineCacheManager:getInstance():purgeSpineCacheData()

    local vars = self:load('dragon_collection.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, self.m_uiName)

    self:sceneFadeInAction()
    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr()
    
    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)

    self.m_dragonListLastChangeTime = g_dragonsData:getLastChangeTimeStamp()
end

-------------------------------------
-- function init_after
-------------------------------------
function UI_DragonCollection:init_after()
    PARENT.init_after(self)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonCollection:initUI()
    local vars = self.vars

    self:init_dragonTableView()    
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonCollection:initButton()
    local vars = self.vars
end

-------------------------------------
-- function setSelectDragonData
-- @brief 선택된 드래곤 설정
-------------------------------------
function UI_DragonCollection:setSelectDragonData(object_id, b_force)
--[[     if (not b_force) and (self.m_selectDragonOID == object_id) then
        return
    end

    local object_data = g_dragonsData:getDragonDataFromUid(object_id)
    if (not object_data) then
        object_data = g_slimesData:getSlimeObject(object_id)
    end

    if (not object_data) then
        return self:setDefaultSelectDragon()
    end

    if (not self:checkDragonSelect(object_id)) then
        return
    end

    -- 선택된 드래곤의 데이터를 최신으로 갱신
    self.m_selectDragonOID = object_id
    self.m_selectDragonData = object_data

    local skin_id = object_data:getSkinID()
    if skin_id ~= 0 then 
        self.m_selectedSkinData = g_dragonSkinData:getDragonSkinDataWithSkinID(skin_id)
    else
        local l_struct_dragon_skin = g_dragonSkinData:makeStructSkinList(self.m_selectDragonData['did'])
        self.m_selectedSkinData = l_struct_dragon_skin[1]
    end

    self.m_bSlimeObject = (object_data.m_objectType == 'slime')
    self.m_evolutionLevel = self.m_selectDragonData:getEvolution()

    -- 선택된 드래곤 카드에 프레임 표시
    self:changeDragonSelectFrame()

    -- 선택된 드래곤이 변경되면 refresh함수를 호출
    self:refresh()

    -- 신규 드래곤이면 삭제
    g_highlightData:removeNewDoid(object_id) ]]
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonCollection:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonCollection:click_exitBtn()
    self:close()
end

-------------------------------------
-- function getSelectedDragon
-------------------------------------
function UI_DragonCollection:getSelectedDragon()
    return self.m_selectDragonData
end

-------------------------------------
-- function _hasDragon
-- @brief 플레이어가 드래곤를 보유 했는지 여부
-- @return boolean
-------------------------------------
function UI_DragonCollection:_hasDragon(did)
    local dragon_cnt = g_dragonsData:getNumOfDragonsByDid(did)
    return (dragon_cnt ~= 0)
end

-------------------------------------
-- function checkDragonListRefresh
-- @brief 드래곤 리스트에 변경이 있는지 확인 후 갱신
-------------------------------------
function UI_DragonCollection:checkDragonListRefresh()
    local is_changed = g_dragonsData:checkChange(self.m_dragonListLastChangeTime)

    if is_changed then
        self.m_dragonListLastChangeTime = g_dragonsData:getLastChangeTimeStamp()
        -- 정렬
        self:apply_dragonSort_saveData()
    end
end

--@CHECK
UI:checkCompileError(UI_DragonCollection)
