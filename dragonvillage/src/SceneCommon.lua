-------------------------------------
-- class SceneCommon
-- #brief UI클래스를 전달받아 생성하는 기본 Scene
-------------------------------------
SceneCommon = class(PerpleScene, {
        m_classUI = 'class',
        m_uiCloseCB = 'function',
        m_data = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function SceneCommon:init(class_ui, t_data, close_cb)
    self.m_classUI = class_ui
    self.m_data = t_data
    self.m_uiCloseCB = close_cb
    assert(self.m_classUI, 'class_ui is nil')
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneCommon:onEnter()
    PerpleScene.onEnter(self)

    if self.m_classUI then
        local ui = self.m_classUI(self.m_data)
        ui:setCloseCB(self.m_uiCloseCB)
    end
end
