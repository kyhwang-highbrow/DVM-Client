local PARENT = UI

-------------------------------------
-- class UI_LoadingAdLoad
-- @brief 광고 다운로드에 사용되는 로딩 UI
--        sgkim 20190508 AdMob의 보상형 광고 시청 시 광고를 다운로드 하는 과정에서 사용됨
--        드빌M 스타일의 로딩이 아닌, AdMob의 UI 스타일로 제작을 해서 개발사 로딩이 아님을 간접적으로 표현함
--        참고 문서 : https://perplelab.atlassian.net/wiki/x/YYE9Mg
-------------------------------------
UI_LoadingAdLoad = class(PARENT,{
})

-------------------------------------
-- function init
-------------------------------------
function UI_LoadingAdLoad:init()
    self.m_uiName = 'UI_LoadingAdLoad'
    local vars = self:load('network_loading_02.ui')
    UIManager:open(self, UIManager.LOADING)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_LoadingAdLoad')

    -- 로딩 배경을 출력하지 않음
    vars['bgLayerColor']:setVisible(false)
    vars['loadingLabel']:setString(Str('취소'))
end

-------------------------------------
-- function setLoadingMsg
-------------------------------------
function UI_LoadingAdLoad:setLoadingMsg(msg)
    self.vars['loadingLabel']:setString(msg)
end

-------------------------------------
-- function showLoading
-------------------------------------
function UI_LoadingAdLoad:showLoading(msg, only_msg)
    self.root:setVisible(true)
    self.vars['visual']:setVisible(not only_msg)
    if msg then
        self:setLoadingMsg(msg)
    end
end

-------------------------------------
-- function hideLoading
-------------------------------------
function UI_LoadingAdLoad:hideLoading()
    self.root:setVisible(false)
end

-------------------------------------
-- function getCloseBtn
-------------------------------------
function UI_LoadingAdLoad:getCloseBtn()
    return self.vars['closeBtn']
end

-------------------------------------
-- function showBgLayer
-------------------------------------
function UI_LoadingAdLoad:showBgLayer()
    self.vars['bgLayerColor']:setVisible(true)
end

-------------------------------------
-- function hideBgLayer
-------------------------------------
function UI_LoadingAdLoad:hideBgLayer()
    self.vars['bgLayerColor']:setVisible(false)
end

-------------------------------------
-- function onLoading
-------------------------------------
function UI_LoadingAdLoad:onLoading()
    return self.root:isVisible()
end

-------------------------------------
-- function close
-------------------------------------
function UI_LoadingAdLoad:close()
    if (not self.closed) then
        PARENT.close(self)
    end
end