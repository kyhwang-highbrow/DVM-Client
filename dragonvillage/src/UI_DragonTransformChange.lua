local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonTransformChange
-------------------------------------
UI_DragonTransformChange = class(PARENT,{
        m_bEnoughMaterial = 'boolean',
        m_transformRadioButton = 'UIC_RadioButton',

        m_targetMap = 'map',
        m_targetEvolution = 'number',
    })

local DRAGON_SCALE = 1

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonTransformChange:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonTransformChange'
    self.m_bVisible = true 
    self.m_titleStr = Str('외형 변환') 
    self.m_bUseExitBtn = true 
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonTransformChange:init(doid)
    local vars = self:load('dragon_transform.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonTransformChange')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonTransformChange:initUI()
    local vars = self.vars
    self:init_dragonTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonTransformChange:initButton()
    local vars = self.vars
    -- radio button 선언
    local radio_button = UIC_RadioButton()
    
    radio_button:addButton('slot_1', vars['selectBtn1'], vars['selectSprite1'])
    radio_button:addButton('slot_2', vars['selectBtn2'], vars['selectSprite2'])
    radio_button:setSelectedButton('slot_1')
    radio_button:setChangeCB(function() self:onChangeOption() end)

    self.m_transformRadioButton = radio_button

    vars['transformBtn']:registerScriptTapHandler(function() self:click_transformBtn() end)
    vars['materialBtn1']:registerScriptTapHandler(function() self:click_materialInfo(1) end)
    vars['materialBtn2']:registerScriptTapHandler(function() self:click_materialInfo(2) end)
    vars['materialBtn3']:registerScriptTapHandler(function() self:click_materialInfo(3) end)
    vars['materialBtn4']:registerScriptTapHandler(function() self:click_materialInfo(4) end)
end

-------------------------------------
-- function onChangeOption
-------------------------------------
function UI_DragonTransformChange:onChangeOption()
    local vars = self.vars 
    local slot = self.m_transformRadioButton.m_selectedButton
    local target_evolution = self.m_targetMap[slot]
    if (target_evolution) then
        self.m_targetEvolution = target_evolution
        
        vars['selectVisual1']:setVisible(false)
        vars['selectVisual2']:setVisible(false)
        local num = string.gsub(slot, 'slot_', '')
        vars['selectVisual'..num]:setVisible(true)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonTransformChange:refresh()
    local struct_dragon_data = self.m_selectDragonData

    if (not struct_dragon_data) then
        return
    end

    local vars = self.vars

    -- 배경
    local attr = struct_dragon_data:getAttr()
    if self:checkVarsKey('bgNode', attr) then    
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

    -- 드래곤 정보
    self:refresh_currDragonInfo(struct_dragon_data)

    -- 외형 변환 정보
    self:refresh_currDragonTransform(struct_dragon_data)

    -- 재료 정보
    self:refresh_currDragonMaterial(struct_dragon_data)
end

-------------------------------------
-- function refresh_currDragonInfo
-- @brief 드래곤 정보
-------------------------------------
function UI_DragonTransformChange:refresh_currDragonInfo(struct_dragon_data)
    local vars = self.vars

    -- 드래곤 이름
    vars['dragonNameLabel']:setString(struct_dragon_data:getDragonNameWithEclv())

    local attr = struct_dragon_data:getAttr()
    local role_type = struct_dragon_data:getRole()
    local rarity_type = nil
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)

    do -- 드래곤 속성
        local attr = struct_dragon_data:getAttr()
        vars['attrNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)
    end

    do -- 드래곤 역할(role)
        local role_type = struct_dragon_data:getRole()
        vars['typeNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'], t_info)
    end

    do -- 드래곤 아이콘
        vars['dragonNode']:removeAllChildren()
        local ui = UI_DragonCard(struct_dragon_data)
        vars['dragonNode']:addChild(ui.root)
    end
end

-------------------------------------
-- function refresh_currDragonTransform
-- @brief 현재 선택한 외형, 변경 가능한 외형 정보
-------------------------------------
function UI_DragonTransformChange:refresh_currDragonTransform(struct_dragon_data)
    local vars = self.vars

    local did = struct_dragon_data['did']
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[did]

    local cur_transform = struct_dragon_data['transform']
    local is_set = false

    self.m_targetMap = {}

    for i = 1, 3 do
        local res = t_dragon['res']
        local attr = t_dragon['attr']
        local evolution = i
        local target_num

        -- 현재 선택한 외형이 3번 노드
        if (evolution == cur_transform) then
            target_num = 3
        else
            target_num = (is_set) and 2 or 1
            is_set = true
            self.m_targetMap['slot_' .. tostring(target_num)] = evolution
        end

        -- 해치, 해츨링, 성룡 표시
        local name = evolutionName(evolution)
        if (vars['selectLabel'..target_num]) then
            vars['selectLabel'..target_num]:setString(name)
        end

        local node = vars['dragonNode'..target_num]
        node:removeAllChildren()
        
        local animator = AnimatorHelper:makeDragonAnimator(res, evolution, attr)
        animator:setDockPoint(CENTER_POINT)
        animator:setAnchorPoint(CENTER_POINT)
        animator:changeAni('idle', true)
        animator:setScale(DRAGON_SCALE)
        node:addChild(animator.m_node)
    end

    self:onChangeOption() 
end

-------------------------------------
-- function refresh_currDragonMaterial
-- @brief 재료 정보
-------------------------------------
function UI_DragonTransformChange:refresh_currDragonMaterial(struct_dragon_data)
    local vars = self.vars
    local map_material = TableDragonTransform():getMaterialInfoByDragon(struct_dragon_data)

    self.m_bEnoughMaterial = true
    -- 속성, 등급별 재료 표시
    for i = 1, 4 do
        local key = 'material_' .. tostring(i)
        local data = map_material[key]
        if (data) then
            local item_id = data['item_id']
            local cnt = data['cnt']

            -- 필요 개수가 0인 경우 visible 꺼줌
            local is_apply = (cnt ~= 0)
            vars['materialBtn' .. i]:setVisible(is_apply)

            if (is_apply) then
                -- 아이콘 
                vars['materialItemNode' .. i]:removeAllChildren()
                local item_icon = IconHelper:getItemIcon(item_id)
                vars['materialItemNode' .. i]:addChild(item_icon)

                -- 이름
                local name = TableItem():getItemName(item_id)
                vars['materialLabel' .. i]:setString(name)

                 -- 갯수 체크
                local req_count = cnt
                local own_count = g_userData:getTransformMaterialCount(item_id)
                local str = Str('{1} / {2}', own_count, req_count)

                if (req_count <= own_count) then
                    str = '{@possible}' .. str
                else
                    str = '{@impossible}' .. str
                    self.m_bEnoughMaterial = false
                end

                vars['numberLabel' .. i]:setString(str)
            end
        end
    end

    -- 필요 골드
    local price = map_material['gold']
    if (price) then
        vars['priceLabel']:setString(comma_value(price))
    end
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-- @override
-------------------------------------
function UI_DragonTransformChange:getDragonList()
    local dragon_dic = g_dragonsData:getDragonListWithSlime()

    -- 성룡이 아닌 드래곤은 제외!!!
    for oid, v in pairs(dragon_dic) do
        if (v['evolution'] < POSSIBLE_TRANSFORM_CHANGE_EVO) then
            dragon_dic[oid] = nil
        end
    end

    return dragon_dic
end

-------------------------------------
-- function click_materialInfo
-- @breif 재료 획득 장소
-------------------------------------
function UI_DragonTransformChange:click_materialInfo(i)
    local key = 'material_'..tostring(i)
    local struct_dragon_data = self.m_selectDragonData
    local map_material = TableDragonTransform():getMaterialInfoByDragon(struct_dragon_data)
    local t_transform = map_material[key]

    if (t_transform) then
        local item_id = t_transform['item_id']
         UI_ItemInfoPopup(item_id)
    end
end

-------------------------------------
-- function click_transformBtn
-------------------------------------
function UI_DragonTransformChange:click_transformBtn()
    local vars = self.vars

    -- 재료 부족
    if (not self.m_bEnoughMaterial) then
        UIManager:toastNotificationRed(Str('재료가 부족합니다.'))

        cca.uiImpossibleAction(vars['materialBtn1'])
        cca.uiImpossibleAction(vars['materialBtn2'])
        cca.uiImpossibleAction(vars['materialBtn3'])
        cca.uiImpossibleAction(vars['materialBtn4'])
        return
    end

    -- 골드 체크
    local struct_dragon_data = self.m_selectDragonData
    local price = TableDragonTransform():getPrice(struct_dragon_data)
    if (not ConfirmPrice('gold', price)) then
        return
    end

    local name = evolutionName(self.m_targetEvolution)
    local msg = Str('외형 변환{@sky_blue}({1}){@default}을 진행하시겠습니까?', name)
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, function() self:request_transform_change() end)
end

-------------------------------------
-- function click_transformBtn
-- @brief 외형 변환
-------------------------------------
function UI_DragonTransformChange:request_transform_change()
    local struct_dragon_data = self.m_selectDragonData
    -- transfom 없으면 evolution 으로 
    local before_transform = struct_dragon_data['transform'] or struct_dragon_data['evolution']
    local uid = g_userData:get('uid')
    local doid = struct_dragon_data['id']
    local target_transform = self.m_targetEvolution

    local function success_cb(ret)
        -- 재화 갱신
        g_serverData:networkCommonRespone(ret)

        -- 드래곤 갱신
		g_dragonsData:applyDragonData(ret['dragon'])

        -- 드래곤 관리 UI 갱신
		self.m_bChangeDragonList = true

        -- 대표드래곤인 경우 정보 저장
		if (ret['leaders']) then
			g_userData:applyServerData(ret['leaders'], 'leaders')

            -- 채팅 서버에 변경사항 적용
            g_lobbyChangeMgr:globalUpdatePlayerUserInfo()
		end

        local new_struct_dragon_data = StructDragonObject(ret['dragon'])
        UI_DragonTransformChangeResult(new_struct_dragon_data, before_transform, target_transform)

        self:setSelectDragonDataRefresh()
        self:refresh()
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/transform')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('transform', target_transform)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

--@CHECK
UI:checkCompileError(UI_DragonTransformChange)