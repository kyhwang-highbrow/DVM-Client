local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonSkinManageInfo
-------------------------------------
UI_DragonSkinManageInfo = class(PARENT,{
        -- 서버상의 드래곤 정보가 마지막으로 변경된 시간 (refresh 체크 용도)
        m_dragonListLastChangeTime = 'timestamp',
        m_skinTableView = 'UIC_TableView',
        m_selectedSkinData = 'StructDragonSkin',

        m_evolutionLevel = 'number',
        m_mapEvolutionBtnUI = 'map',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonSkinManageInfo:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonSkinManageInfo'
    
    self.m_subCurrency = 'memory_myth'  -- 상단 유저 재화 정보 중 서브 재화
    self.m_bVisible = true or false
    self.m_titleStr = nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
    self.m_bShowInvenBtn = true
    self.m_evolutionLevel = 1
    self.m_mapEvolutionBtnUI = {}
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkinManageInfo:init(struct_dragon_object)
    self.m_uiName = 'UI_DragonSkinManageInfo'
    self.m_resName = 'dragon_skin.ui'
    self.m_titleStr = Str('드래곤 스킨')
    self.m_bVisible = true
    self.m_bUseExitBtn = true

    self.m_selectDragonOID = struct_dragon_object:getObjectId()
    self.m_selectDragonData = struct_dragon_object

    local skin_id = struct_dragon_object:getSkinID()
    if skin_id ~= 0 then 
        self.m_selectedSkinData = g_dragonSkinData:getDragonSkinDataWithSkinID(skin_id)
    else
        local l_struct_dragon_skin = g_dragonSkinData:makeStructSkinList(self.m_selectDragonData['did'])
        self.m_selectedSkinData = l_struct_dragon_skin[1]
    end

    self.m_elapsedTime = 1
end

-------------------------------------
-- function init_after
-------------------------------------
function UI_DragonSkinManageInfo:init_after(struct_dragon_object)
    local vars = self:load(self.m_resName)
    UIManager:open(self, UIManager.SCENE)
    PARENT.init_after(self)
    self:sceneFadeInAction()

    self:initUI()
    self:init_dragonSkinTableView()
    self:initButton()
    self:refresh()
    
    -- spine 캐시 정리 확인
    -- SpineCacheManager:getInstance():purgeSpineCacheData()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, self.m_uiName)

    -- 정렬 도우미
    self:init_dragonSortMgr()
    self.m_dragonListLastChangeTime = g_dragonsData:getLastChangeTimeStamp()

    -- local sub_menu = self.m_startSubMenu
    -- if sub_menu then
    --     self:clickSubMenu(sub_menu)
    -- end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSkinManageInfo:initUI()
    local vars = self.vars
    
    -- 드래곤 실리소스
    if vars['dragonNode'] then
        self.m_dragonAnimator = UIC_DragonAnimator()
        self.m_dragonAnimator.m_node:setScale(0.9)
        vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)
    end
end

-------------------------------------
-- function init_dragonSkinTableView
-- @breif 드래곤 스킨 리스트 테이블 뷰
-------------------------------------
function UI_DragonManage_Base:init_dragonSkinTableView()

    if (not self.m_tableViewExt) then
        local list_table_node = self.vars['listTableNode']

        local function make_func(object)
            return UI_DragonCard(object)
        end

        local function create_func(ui, data)
            self:createDragonCardCB(ui, data)
            ui.root:setScale(0.66)
            ui.vars['clickBtn']:registerScriptTapHandler(function() self:setSelectDragonData(data['id']) end)
            ui.vars['clickBtn']:unregisterScriptPressHandler()

            -- 선택한 드래곤
            if (data['id'] == self.m_selectDragonOID) then
                self:changeDragonSelectFrame(ui)
            end

            -- 승급/진화/스킬강화 
            -- local is_noti_dragon = data:isNotiDragon()
            -- ui:setNotiSpriteVisible(is_noti_dragon)

            -- 새로 획득한 드래곤 뱃지
            local is_new_dragon = data:isNewDragon()
            ui:setNewSpriteVisible(is_new_dragon)
        end

        local table_view = UIC_TableView(list_table_node)
        table_view.m_defaultCellSize = cc.size(100, 100)
        table_view:setCellUIClass(make_func, create_func)
        self.m_tableViewExt = table_view
    end

    local l_item_list = self:getDragonSkinList()
    self.m_tableViewExt:setItemList(l_item_list)

    -- 드래곤 선택 버튼이 있다면
    local list_btn = self.vars['listBtn']
    if (list_btn) then
        list_btn:registerScriptTapHandler(function() self:click_listBtn() end)
    end
end


-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonSkinManageInfo:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refreshEvolutionCards
-------------------------------------
function UI_DragonSkinManageInfo:refreshEvolutionCards()
    local vars = self.vars
    vars['evolutionLabel1']:setString(Str("해치"))
    vars['evolutionLabel2']:setString(Str("해츨링"))
    vars['evolutionLabel3']:setString(Str("성룡"))

    local did = self.m_selectDragonData['did']

    local dragon_name = TableDragon:getDragonName(did)
    vars['dragonNameLabel']:setString(Str(dragon_name))

    for i = 1, 3 do 
        local node = vars['dragonNode'..i]
        if (node) then
            local data = clone(self.m_selectDragonData)
            data['evolution'] = i

            local card = UI_SkinDragonCard(data)
            card.root:setSwallowTouch(false)
            card.root:setScale(0.8)
            node:removeAllChildren()
            node:addChild(card.root)

            -- -- 수집 여부에 따른 음영 처리
            -- if (not g_bookData:isExist(data)) then
            --     card:setShadowSpriteVisible(true)
            -- end

            -- 등급 표시 안함
            card.vars['starNode']:setVisible(false)
            -- -- 선택한 카드 표시
            -- card:setHighlightSpriteVisibleWithNoAction(i == self.m_evolution)
            -- 진화 단계 선택 
            card.vars['clickBtn']:registerScriptTapHandler(function()
                self:click_evolutionBtn(i)
            end)

            self.m_mapEvolutionBtnUI[i] = card
            -- self.m_mapEvolutionBtnUI[i] = card
        end
    end
end

-------------------------------------
-- function refresh_dragonBasicInfo
-- @brief 드래곤 기본 정보 갱신
-------------------------------------
function UI_DragonSkinManageInfo:refresh_dragonBasicInfo(struct_dragon)
    local vars = self.vars
    local attr = struct_dragon:getAttr()
    
    
    -- 배경
    if self:checkVarsKey('attrBgNode', attr) then
        vars['attrBgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['attrBgNode']:addChild(animator.m_node)
    end

    -- 드래곤 이름
    do
        local did = self.m_selectDragonData['did']
        local dragon_name = TableDragon:getDragonName(did)
        vars['dragonNameLabel']:setString(dragon_name)
    end

    if self.m_dragonAnimator ~= nil then
        -- 외형 변환 적용 Animator
        self.m_dragonAnimator:setDragonAnimatorByTransform(struct_dragon)
    end
end


-------------------------------------
-- function setSelectDragonData
-- @brief 선택된 드래곤 설정
-------------------------------------
function UI_DragonSkinManageInfo:setSelectDragonData(object_id, b_force)
    if (not b_force) and (self.m_selectDragonOID == object_id) then
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
    g_highlightData:removeNewDoid(object_id)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSkinManageInfo:refresh()
    local vars = self.vars

    -- self:refresh_buttonState()
    local t_dragon_data = self.m_selectDragonData
    -- 드래곤 기본 정보 갱신
    self:refresh_dragonBasicInfo(t_dragon_data)
    -- 진화 카드 단계 
    self:refreshEvolutionCards()
    -- 스킨 리스트
    self:refreshSkinTableView()
    -- 스킨 데이터
    --self:refreshSkinData()
    -- 드래곤 스킨 Res 변경
    self:setDragonSkinRes(self.m_selectedSkinData)
    -- 좌측 드래곤 아이콘 이미지 변경
    self:setDragonSkinIconRes(self.m_selectedSkinData)

   
    -- spine 캐시 정리 확인
    -- SpineCacheManager:getInstance():purgeSpineCacheData_checkNumber()
end

-------------------------------------
-- function click_evolutionBtn
-------------------------------------
function UI_DragonSkinManageInfo:click_evolutionBtn(i)
    cclog('CLICK EVOLUTION BTN : ' .. i)
    do -- 드래곤 리소스
        -- -- 이미지
        local res = self.m_selectedSkinData:getDragonSkinRes()
        local attr = self.m_selectedSkinData:getSkinAttribute()
        self.m_evolutionLevel = i

        self.m_dragonAnimator:setDragonAnimatorRes(self.m_selectDragonData['did'], res, attr, self.m_evolutionLevel)
    end
end


-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonSkinManageInfo:click_exitBtn()
    self:close()
end

function UI_DragonSkinManageInfo:getSelectedDragon()
    return self.m_selectDragonData
end

-------------------------------------
-- function refreshSkinTableView
-- @brief 해당 드래곤 스킨 테이블뷰 생성
-------------------------------------
function UI_DragonSkinManageInfo:refreshSkinTableView()
	local vars = self.vars

    local node = vars['skinListNode']
    node:removeAllChildren()

    local l_struct_dragon_skin = g_dragonSkinData:makeStructSkinList(self.m_selectDragonData['did'])
    vars['skinTitleLabel']:setString(Str(self.m_selectedSkinData:getName()))

    local function make_func(dragon_skin_sale)
        --local struct_product = dragon_skin_sale:getDragonSkinProduct('money')
        local ui = UI_DragonSkinListItem(dragon_skin_sale, self.m_selectDragonData)
        return ui
    end

    -- 스킨 버튼
    local function create_func(ui, data)
        -- 스킨 미리보기
        ui.vars['skinBtn']:registerScriptTapHandler(function()
            self:click_skin(ui.m_skinData)
            ui:setSelected(ui.m_skinData:getSkinID())
            vars['skinTitleLabel']:setString(Str(ui.m_skinData:getName()))
        end)

        -- 스킨 선택하기
        ui.vars['selectBtn']:registerScriptTapHandler(function()
            self:click_select_skin(ui.m_skinData)
            vars['skinTitleLabel']:setString(Str(ui.m_skinData:getName()))
        end)

        -- 스킨 구입하기
        ui.vars['buyBtn']:registerScriptTapHandler(function()
            self:click_buy_skin(ui.m_skinData)
        end)
    end

     -- 상품 정보 주지 않는 코스튬은 리스트에서 제외(토파즈 부류만) 
    -- local sale_list = self:removeCostume_WithoutShopInfo(l_struct_dragon_skin)

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(231, 393)
    table_view:setCellUIClass(make_func, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_struct_dragon_skin)

    self.m_skinTableView = table_view
end

-------------------------------------
-- function click_skin
-- @brief 스킨 미리보기
-------------------------------------
function UI_DragonSkinManageInfo:click_skin(skin_data)
    -- if (self.m_selectDragonData['did'] ~= self.m_selectedSkinData:getDid()) then
    --     return
    -- end

    self.m_selectedSkinData = skin_data
    self.m_evolutionLevel = self.m_selectDragonData:getEvolution()
    self:refreshSkinData()

    -- 드래곤 스킨 Res 변경
    self:setDragonSkinRes(skin_data)
    -- 좌측 드래곤 아이콘 이미지 변경
    self:setDragonSkinIconRes(skin_data)
end

-------------------------------------
-- function click_select_skin
-- @brief 스킨 선택
-------------------------------------
function UI_DragonSkinManageInfo:click_select_skin(skin_data)
    self.m_selectedSkinData = skin_data
    local skin_id = skin_data:getSkinID()
    local did = self.m_selectDragonData:getDid()
    local doid = self.m_selectDragonData:getObjectId()
    local has_dragon = self:_hasDragon(did)

    -- 변경 불가
    if (not has_dragon) then
        UIManager:toastNotificationRed(Str('보유하지 않은 드래곤은 스킨을 변경 할 수 없습니다.'))

    -- 코스튬 선택
    else
        local function finish_cb()
            UIManager:toastNotificationGreen(Str('스킨을 변경하였습니다.'))
            self.m_selectDragonData = g_dragonsData:get(doid)
            self.m_evolutionLevel = self.m_selectDragonData:getEvolution()

            -- 모든 상태 변경
            self:refresh()
            -- 코스튬 테이블뷰 초기화
            self:refreshSkinData()

            self:init_dragonSkinTableView()

            do
                --local leader_dragon = g_dragonsData:getLeaderDragon()
                if self.m_selectDragonData:isLeader() == true then
                    -- 채팅 서버에 변경사항 적용
                    g_lobbyChangeMgr:globalUpdatePlayerUserInfo()
                end
            end

        end

        g_dragonSkinData:request_dragonSkinSelect(skin_id, doid, finish_cb)
    end
end

-------------------------------------
-- function _hasDragon
-- @brief 플레이어가 드래곤를 보유 했는지 여부
-- @return boolean
-------------------------------------
function UI_DragonSkinManageInfo:_hasDragon(did)
    local dragon_cnt = g_dragonsData:getNumOfDragonsByDid(did)
    return (dragon_cnt ~= 0)
end

-------------------------------------
-- function click_buy_skin
-- @brief 스킨 구매
-------------------------------------
function UI_DragonSkinManageInfo:click_buy_skin(skin_data)
    ---UINavigatorDefinition:goTo('package_shop', 'package_dragon_skin')
    local finish_cb = function (ret)
        self:refresh()
    end

    require('UI_DragonSkinSaleConfirmPopup')
    UI_DragonSkinSaleConfirmPopup.open(skin_data, finish_cb)
end

-------------------------------------
-- function refreshCostumeData
-- @brief 해당 테이머 코스튬 메뉴 갱신
-------------------------------------
function UI_DragonSkinManageInfo:refreshSkinData()
    if (self.m_selectedSkinData and self.m_skinTableView) then
        for _, v in ipairs(self.m_skinTableView.m_itemList) do
            local ui = v['ui']
            if ui then
                local skin_id = self.m_selectedSkinData:getSkinID()
                ui:setSelected(skin_id)
                ui:refresh()
            end
        end
    end
end

-------------------------------------
-- function checkDragonListRefresh
-- @brief 드래곤 리스트에 변경이 있는지 확인 후 갱신
-------------------------------------
function UI_DragonSkinManageInfo:checkDragonListRefresh()
    local is_changed = g_dragonsData:checkChange(self.m_dragonListLastChangeTime)

    if is_changed then
        self.m_dragonListLastChangeTime = g_dragonsData:getLastChangeTimeStamp()
        -- 정렬
        self:apply_dragonSort_saveData()
    end
end

-------------------------------------
-- function setDragonSkinRes
-- @brief 드래곤 스킨 스파인 리소스 설정
-------------------------------------
function UI_DragonSkinManageInfo:setDragonSkinRes(skin_data)
	local vars = self.vars
    local table_skin = TableDragonSkin()
    local target_id = skin_data and skin_data:getSkinID()
	local t_skin = table_skin:get(target_id)
    self.m_selectedSkinData = skin_data
	-- -- 기존 이미지 정리
	-- vars['dragonNode']:removeAllChildren(true)

	-- 드래곤 스킨
    -- local skin_data = skin_data or g_tamerCostumeData:getCostumeDataWithTamerID(target_id)
    local res = skin_data:getDragonSkinRes()
    local attr = skin_data:getSkinAttribute()
	-- local dragon_animator = MakeAnimator(res)
	-- dragon_animator:setFlip(true)

    if (res) then
        self.m_dragonAnimator:setDragonAnimatorRes(skin_data:getDid(), res, attr, self.m_evolutionLevel)

        UIManager:toastNotificationGreen("res : " .. res .. ", attr : " .. attr)
        -- vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)
    end

    -- vars['dragonNode']:addChild(dragon_animator.m_node)

    local skin_name = skin_data:getName()
    vars['skinTitleLabel']:setString(skin_name)

	-- -- 없는 테이머는 음영 처리
	-- if (not self:_hasTamer(target_id)) then
	-- 	dragon_animator:setColor(COLOR['gray'])
	-- end
end

-------------------------------------
-- function setDragonSkinIconRes
-- @brief 드래곤 스킨 아이콘 변경
-------------------------------------
function UI_DragonSkinManageInfo:setDragonSkinIconRes(skin_data)
	local vars = self.vars
    local table_skin = TableDragonSkin()
    local target_id = skin_data and skin_data:getSkinID()
	local t_skin = table_skin:get(target_id)
    self.m_selectedSkinData = skin_data

    for i=1,3 do
        local res = skin_data:getDragonSkinIcon(i)
        if (res) then
            self.m_mapEvolutionBtnUI[i].m_charSkinIconRes = res
            self.m_mapEvolutionBtnUI[i]:refreshDragonInfo()
        end
    end
end

--@CHECK
UI:checkCompileError(UI_DragonSkinManageInfo)
