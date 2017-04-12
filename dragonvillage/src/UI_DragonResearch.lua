local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonResearch
-- @brief 연구 UI
-------------------------------------
UI_DragonResearch = class(PARENT,{
        m_bChangeDragonList = 'boolean',
        m_name = '',
        m_lv = '',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonResearch:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonResearch'
    self.m_bVisible = true or false
    self.m_titleStr = Str('연구')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
    self.m_subCurrency = 'lactea'
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonResearch:init(doid)
    self.m_bChangeDragonList = false

    local vars = self:load('dragon_reserch.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonResearch')

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
function UI_DragonResearch:initUI()
    local vars = self.vars

    self:init_dragonTableView()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonResearch:initButton()
    local vars = self.vars
    vars['lacteaBtn']:registerScriptTapHandler(function() self:click_lacteaButton() end)
    vars['reserchBtn']:registerScriptTapHandler(function() self:click_reserchBtn() end)
    
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonResearch:refresh()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars

    local table_dragon = TableDragon()
    local did = t_dragon_data['did']
    local t_dragon = table_dragon:get(t_dragon_data['did'])
    local doid = t_dragon_data['id']
    local dragon_type = table_dragon:getDragonType(did)
    
    do -- 드래곤 리소스
        local base_did = TableDragonType:getBaseDid(dragon_type)
        local t_base_dragon = table_dragon:get(base_did)

        local evolution = MAX_DRAGON_EVOLUTION
        vars['dragonNode']:removeAllChildren()
        local animator = AnimatorHelper:makeDragonAnimator(t_base_dragon['res'], evolution, t_base_dragon['attr'])
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        vars['dragonNode']:addChild(animator.m_node)

        animator:changeAni('idle', false)
        animator:setAnimationPause(true)
        --animator:changeAni('pose_1', false)
        --animator:addAniHandler(function() animator:changeAni('idle', true) end)

        -- 쉐이더 적용
        local shader = cc.GLProgram:createWithFilenames('shader/position_texture_color_noMvp_vertex.vsh', 'shader/gray.fsh')
        animator.m_node:setGLProgram(shader)
    end

    local research_lv = g_collectionData:getDragonResearchLevel_did(did)

    vars['reserchLabel']:setString(Str('연구 {1}/{2} 단계', research_lv, MAX_DRAGON_RESEARCH_LV))
    for i=1, MAX_DRAGON_RESEARCH_LV do
        local node = vars['reserchSprite' .. i]
        if (i <= research_lv) then
            node:setVisible(true)
        else
            node:setVisible(false)
        end
    end


    local table_dragon_research = TableDragonResearch()
    local price = table_dragon_research:getDragonResearchPrice(research_lv)
    vars['priceLabel']:setString(comma_value(price))

    local base_did = TableDragonType:getBaseDid(dragon_type)
    local dragon_name = table_dragon:getDragonName(base_did)
    local type_name = Str('고대 {1}', dragon_name)

    local desc = table_dragon_research:getDesc(research_lv, type_name)
    vars['dscLabel']:setString(desc)
    
    vars['dragonNameLabel']:setString(type_name)
    self.m_name = type_name

    local atk, def, hp = TableDragonResearch:getDragonResearchStatus(dragon_type, research_lv)
    local str = Str('+{1}\n+{2}\n+{3}', comma_value(math_floor(atk)), comma_value(math_floor(def)), comma_value(math_floor(hp)))
    vars['statusLabel1']:setString(str)

    self.m_lv = research_lv
    if (MAX_DRAGON_RESEARCH_LV <= research_lv) then
        vars['statusLabel2']:setVisible(false)
    else
        local atk, def, hp = TableDragonResearch:getDragonResearchStatus(dragon_type, research_lv + 1)
        local str = Str('+{1}\n+{2}\n+{3}', comma_value(math_floor(atk)), comma_value(math_floor(def)), comma_value(math_floor(hp)))
        vars['statusLabel2']:setVisible(true)
        vars['statusLabel2']:setString(str)
    end
end

-------------------------------------
-- function click_lacteaButton
-------------------------------------
function UI_DragonResearch:click_lacteaButton()
    -- 제외시킬 드래곤
    local excluded_dragons = {}
    excluded_dragons[self.m_selectDragonOID] = true

    local ui = UI_DragonGoodbye(excluded_dragons)

    -- UI종료 후 콜백
    local function close_cb()
        if ui.m_bChangeDragonList then
            self.m_bChangeDragonList = true
            self:init_dragonTableView()

            -- 기존에 선택되어 있던 드래곤이 없어졌을 경우
            if (not g_dragonsData:getDragonDataFromUid(self.m_selectDragonOID)) then
                self:setDefaultSelectDragon(nil)
            end
        end

        self:sceneFadeInAction()
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_reserchBtn
-------------------------------------
function UI_DragonResearch:click_reserchBtn()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local did = t_dragon_data['did']
    local dragon_type = TableDragon:getDragonType(did)

    local research_lv = g_collectionData:getDragonResearchLevel(dragon_type)

    -- 최대 레벨
    if (MAX_DRAGON_RESEARCH_LV <= research_lv) then
        return
    end

    -- 가격
    local price = TableDragonResearch:getDragonResearchPrice(research_lv)
    local lactea = g_userData:get('lactea')

    if (lactea < price) then
        local function ok_btn_cb()
            self:click_lacteaButton()
        end
        MakeSimplePopup(POPUP_TYPE.YES_NO, Str('라테아가 부족합니다.\n라테아 변환으로 이동하시겠습니까?'), ok_btn_cb)
        return
    end

    
    self:request_dragonResearch(dragon_type, price)
end

-------------------------------------
-- function request_dragonResearch
-------------------------------------
function UI_DragonResearch:request_dragonResearch(dragon_type, price)
    local function ok_btn_cb()
        local function finish_cb(ret)
            self.m_bChangeDragonList = true
            self:finish_dragonResearch(dragon_type)
        end

        g_collectionData:request_dragonResearch(dragon_type, finish_cb)
    end
    local msg = Str('{1}을 {2}단계로 연구하시겠습니까?', self.m_name, self.m_lv + 1)
    MakeSimplePopup_Confirm('lactea', price, msg, ok_btn_cb, nil)
end

-------------------------------------
-- function finish_dragonResearch
-------------------------------------
function UI_DragonResearch:finish_dragonResearch(dragon_type)
    local research_lv = g_collectionData:getDragonResearchLevel(dragon_type)

    -- 최대 레벨
    if (MAX_DRAGON_RESEARCH_LV <= research_lv) then
        UIManager:toastNotificationRed(Str('최고 연구 단계를 달성하셨습니다.'))
        self:close()
        return
    end

    local doid = self.m_selectDragonOID
    self:refresh_dragonIndivisual(doid)
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-------------------------------------
function UI_DragonResearch:getDragonList()
    local l_item_list = g_dragonsData:getDragonsList()

    for i,v in pairs(l_item_list) do
        local doid = i
        if (not g_dragonsData:checkResearchUpgradeable(doid)) then
            l_item_list[doid] = nil
        end
    end
    return l_item_list
end

--@CHECK
UI:checkCompileError(UI_DragonResearch)
