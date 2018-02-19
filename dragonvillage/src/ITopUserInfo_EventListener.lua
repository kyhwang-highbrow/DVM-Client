-------------------------------------
-- interface ITopUserInfo_EventListener
-------------------------------------
ITopUserInfo_EventListener = {
    m_ownerUIIdx = 'number',    -- 리스너들이 가지는 고유 idx
    m_uiName = 'string',        -- 디버깅을 위한 UI 클래스명 지정

    m_bVisible = 'boolean',
    m_bUseExitBtn = 'boolean',
    m_titleStr = 'string',

	m_staminaType = 'string', -- 보여줄 활동력 타입
    m_subCurrency = 'string', -- 서브 재화 (amethyst, fp)
    m_bShowChatBtn = '',

    m_invenType = 'string', 
    m_bShowInvenBtn = '',

    m_uiBgm = 'string',
}

-------------------------------------
-- function init
-------------------------------------
function ITopUserInfo_EventListener:init()
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_titleStr = nil
	self.m_staminaType = 'st'
    self.m_subCurrency = 'amethyst'
    self.m_bShowChatBtn = true
    self.m_invenType = 'dragon'
    self.m_bShowInvenBtn = false
    self.m_uiBgm = nil
end

-------------------------------------
-- function init_after
-------------------------------------
function ITopUserInfo_EventListener:init_after()
    self:initParentVariable()
    if g_topUserInfo then
        g_topUserInfo:pushOwnerUI(self)
    end
end

-------------------------------------
-- function releaseI_TopUserInfo_EventListener
-------------------------------------
function ITopUserInfo_EventListener:releaseI_TopUserInfo_EventListener()
    if g_topUserInfo then
        g_topUserInfo:popOwnerUI(self)
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function ITopUserInfo_EventListener:click_exitBtn()
    error('\nUI name : ' .. (self.m_uiName or 'no name'))
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function ITopUserInfo_EventListener:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'ITopUserInfo_EventListener'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function onClose
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function ITopUserInfo_EventListener:onClose()
    self:releaseI_TopUserInfo_EventListener()
    g_currScene:removeBackKeyListener(self)
end

-------------------------------------
-- function getCloneTable
-- @brief
-------------------------------------
function ITopUserInfo_EventListener:getCloneTable()
    return clone(ITopUserInfo_EventListener)
end

-------------------------------------
-- function getCloneClass
-- @brief
-------------------------------------
function ITopUserInfo_EventListener:getCloneClass()
    return class(clone(ITopUserInfo_EventListener))
end

-------------------------------------
-- function onFocus
-- @brief 자식 클래스에서 구현할 것
-------------------------------------
function ITopUserInfo_EventListener:onFocus()
end