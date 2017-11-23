-------------------------------------
-- class SceneCommon
-- #brief UI클래스를 전달받아 생성하는 기본 Scene
-------------------------------------
SceneCommon = class(PerpleScene, {
        m_classUI = 'class',
        m_uiCloseCB = 'function',
        m_args = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function SceneCommon:init(class_ui, close_cb, ...)
    self.m_classUI = class_ui
    self.m_args = {...}
    self.m_uiCloseCB = close_cb
    self.m_sceneName = 'SceneCommon'
    assert(self.m_classUI, 'class_ui is nil')
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneCommon:onEnter()
    PerpleScene.onEnter(self)

    -- 연속 모드 해제
    g_autoPlaySetting:setAutoPlay(false)

    if self.m_classUI then
        local args = self.m_args
		-- 매개변수가 10개를 넘지 않는다는 가정 sgkim 2017-08-08
        local ui = self.m_classUI(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10])
        ui:setCloseCB(self.m_uiCloseCB)
    end
end
