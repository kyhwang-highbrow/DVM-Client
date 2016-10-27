local PARENT = UI

-------------------------------------
-- class UI_TitleSceneLoading
-------------------------------------
UI_TitleSceneLoading = class(PARENT,{
})

-------------------------------------
-- function init
-------------------------------------
function UI_TitleSceneLoading:init()
    local vars = self:load('network_loading.ui')
    UIManager:open(self, UIManager.LOADING)

    -- 타이틀에서는 로딩 배경을 출력하지 않음
    vars['bgLayerColor']:setVisible(false)

    vars['loadingImg']:setScale(0.5)
    vars['loadingImg']:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(0, 10)), cc.MoveTo:create(0.5, cc.p(0, -10)))))
end

-------------------------------------
-- function setLoadingMsg
-------------------------------------
function UI_TitleSceneLoading:setLoadingMsg(msg)
    self.vars['loadingLabel']:setString(msg)
end

-------------------------------------
-- function showLoading
-------------------------------------
function UI_TitleSceneLoading:showLoading(msg)
    self.root:setVisible(true)
    if msg then
        self:setLoadingMsg(msg)
    end
end

-------------------------------------
-- function HideLoading
-------------------------------------
function UI_TitleSceneLoading:hideLoading()
    self.root:setVisible(false)
end