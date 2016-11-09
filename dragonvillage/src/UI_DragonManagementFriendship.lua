local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonManagementFriendship
-------------------------------------
UI_DragonManagementFriendship = class(PARENT,{
        m_bChangeDragonList = 'boolean',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonManagementFriendship:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonManagementFriendship'
    self.m_bVisible = true or false
    self.m_titleStr = Str('친밀도') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManagementFriendship:init()
    self.m_bChangeDragonList = false

    local vars = self:load('dragon_management_friendship.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonManagementFriendship')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManagementFriendship:initUI()
    local vars = self.vars
    self:init_dragonTableView()
    --self:setDefaultSelectDragon()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManagementFriendship:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManagementFriendship:refresh()

    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars

    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManagementFriendship:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonManagementFriendship)
