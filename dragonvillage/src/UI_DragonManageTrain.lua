local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonManageTrain
-------------------------------------
UI_DragonManageTrain = class(PARENT,{
        m_bChangeDragonList = 'boolean',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonManageTrain:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonManageTrain'
    self.m_bVisible = true or false
    self.m_titleStr = Str('승급') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManageTrain:init(doid, b_ascending_sort, sort_type)
    self.m_bChangeDragonList = false

    local vars = self:load('dragon_train.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonManageTrain')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

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
function UI_DragonManageTrain:initUI()
    local vars = self.vars

    self:init_dragonTableView()
    --self:setDefaultSelectDragon()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManageTrain:initButton()
    local vars = self.vars
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManageTrain:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonManageTrain)
