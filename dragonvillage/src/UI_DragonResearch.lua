local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonResearch
-- @brief 연구 UI
-------------------------------------
UI_DragonResearch = class(PARENT,{
        m_bChangeDragonList = 'boolean',
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
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonResearch:init(doid, b_ascending_sort, sort_type)
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
    self:init_dragonSortMgr(b_ascending_sort, sort_type)

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
    local t_dragon = table_dragon:get(t_dragon_data['did'])
    local doid = t_dragon_data['id']
    
    do -- 드래곤 리소스    
        local evolution = MAX_DRAGON_EVOLUTION
        vars['dragonNode']:removeAllChildren()
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
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
end

-------------------------------------
-- function click_lacteaButton
-------------------------------------
function UI_DragonResearch:click_lacteaButton()
    local ui = UI_DragonGoodbye()

    -- UI종료 후 콜백
    local function close_cb()
        if ui.m_bChangeDragonList then
            --[[
            self.m_bChangeDragonList = true
            self:init_dragonTableView()

            -- 기존에 선택되어 있던 드래곤이 없어졌을 경우
            if (not g_dragonsData:getDragonDataFromUid(self.m_selectDragonOID)) then
                self:setDefaultSelectDragon(nil)
            end

            -- 보유 라테아 갯수 라벨
            local vars = self.vars
            local lactea = g_userData:get('lactea')
            vars['lacteaLabel']:setString(comma_value(lactea))
            --]]
        end

        self:sceneFadeInAction()
    end
    ui:setCloseCB(close_cb)
end

--@CHECK
UI:checkCompileError(UI_DragonResearch)
