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

    self.m_selectedSkinData = nil
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
    self:initButton()
    self:refresh()
    

    -- spine 캐시 정리 확인
    SpineCacheManager:getInstance():purgeSpineCacheData()

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
    self:init_dragonSkinTableView()
    -- -- 드래곤 정보 보드 생성
    -- self.m_dragonInfoBoardUI = UI_DragonInfoBoard()

    -- if (IS_TEST_MODE()) then
    --     self.m_dragonInfoBoardUI.vars['equipmentBtn']:setVisible(true)
    --     self.m_dragonInfoBoardUI.vars['equipmentBtn']:registerScriptTapHandler(function() self:click_equipmentBtn() end)
    -- else
    --     self.m_dragonInfoBoardUI.vars['equipmentBtn']:setVisible(false)
    -- end
    -- self.vars['infoNode']:addChild(self.m_dragonInfoBoardUI.root)
    --self.root:addChild(self.m_dragonInfoBoardUI.root)
    -- @TODO77


    -- 드래곤 실리소스
    if vars['dragonNode'] then
        self.m_dragonAnimator = UIC_DragonAnimator()
        self.m_dragonAnimator.m_node:setScale(0.9)
        vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)
    end
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonSkinManageInfo:initButton()
    local vars = self.vars
    
	-- -- 우측 버튼
    -- do 
 
    -- end

    do -- 기타 버튼
        -- 장비 개별 버튼 1~3
        --[[ @TODO77
        vars['equipSlotBtn1']:registerScriptTapHandler(function() self:click_runeBtn(1) end)
        vars['equipSlotBtn2']:registerScriptTapHandler(function() self:click_runeBtn(2) end)
        vars['equipSlotBtn3']:registerScriptTapHandler(function() self:click_runeBtn(3) end)
        vars['equipSlotBtn4']:registerScriptTapHandler(function() self:click_runeBtn(4) end)
        vars['equipSlotBtn5']:registerScriptTapHandler(function() self:click_runeBtn(5) end)
        vars['equipSlotBtn6']:registerScriptTapHandler(function() self:click_runeBtn(6) end)
        --]]
    end
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
    local l_struct_dragon_skin = g_dragonSkinData:makeStructSkinList(self.m_selectDragonData['did'])
    self.m_selectedSkinData = l_struct_dragon_skin[1]
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

    -- 드래곤 실리소스
    -- cclog('t_dragon_data', t_dragon_data['dragon_skin'] )

    

    if self.m_dragonAnimator then
        -- 외형 변환 적용 Animator
        self.m_dragonAnimator:setDragonAnimatorByTransform(struct_dragon)
    end


--[[     do -- 스킨 스파인 -- 드래곤 스킨 Res 변경
        self:setDragonSkinRes(skin_data)
    end

    do -- 좌측 드래곤 아이콘 이미지 변경
        self:setDragonSkinIconRes(skin_data)
    end ]]


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
    self:refreshSkinData()

    -- -- 리더 드래곤 여부 표시
    -- self:refresh_leaderDragon(t_dragon_data)

    -- -- 도감작 (해치, 해츨링, 성룡의 도감을 채워서 다이아를 받는 행위) 상태 갱신
    -- self:refresh_bookSprite(t_dragon_data)

    -- -- 진화/승급/스킬강화 알림 - 개발 하다가 중단 
    -- --self:refresh_buttonNoti()

	-- -- 조합 드래곤
	-- self:refresh_combination()

	-- -- 잠금 표시
	-- vars['lockSprite']:setVisible(t_dragon_data:getLock())

    -- -- 외형 변환 표시
    -- local b_transform_change = t_dragon_data:isPossibleTransformChange()
    -- vars['transformBtn']:setVisible(b_transform_change)
    -- vars['evolutionBtn']:setVisible(not b_transform_change)

    --local is_myth_dragon = t_dragon_data:getRarity() == 'myth'
    --vars['upgradeBtn']:setEnabled(not is_myth_dragon)
    --vars['reinforceBtn']:setEnabled(not is_myth_dragon)
    --vars['goodbyeBtn']:setVisible(not is_myth_dragon)
    --vars['goodbyeSelectBtn']:setVisible(not is_myth_dragon)
    --vars['lockBtn']:setVisible(not is_myth_dragon)

    -- local doid = t_dragon_data:getObjectId()
    -- local is_recall_target = g_dragonsData:isDragonRecallTarget(doid)
    -- vars['recallBtn']:setVisible(is_recall_target)

--[[     for i = 1, 3 do 
        local node = vars['dragonNode'..i]
        if (node) then
            local data = clone(self.m_selectDragonData)
            data['evolution'] = i

            local card = UI_SkinDragonCard(data)
            card.root:setSwallowTouch(false)
            card.root:setScale(0.8)
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
        end
    end ]]
    
    -- spine 캐시 정리 확인
    SpineCacheManager:getInstance():purgeSpineCacheData_checkNumber()
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

        cclog(res)

        self.m_dragonAnimator:setDragonAnimatorRes(self.m_selectDragonData['did'], res, attr, self.m_evolutionLevel)
    end
end


-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonSkinManageInfo:click_exitBtn()
    self:close()
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

    -- self.m_selectedSkinData = l_struct_dragon_skin[1]
    vars['skinTitleLabel']:setString(Str(l_struct_dragon_skin[1]:getName()))

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
            self:click_buy_skin(self.m_selectDragonData)
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
            -- 모든 상태 변경
            self:refresh()
            -- 코스튬 테이블뷰 초기화
            -- self:refreshSkinData()

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
end

-------------------------------------
-- function refreshCostumeData
-- @brief 해당 테이머 코스튬 메뉴 갱신
-------------------------------------
function UI_DragonSkinManageInfo:refreshSkinData()
    if (self.m_selectedSkinData) then
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
        
        -- 드래곤 리스트 새로 생성
        self:init_dragonTableView()

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
