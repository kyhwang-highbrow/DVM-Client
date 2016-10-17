-------------------------------------
-- class SceneLogo
-------------------------------------
SceneLogo = class(PerpleScene, {
        m_tLogoList = 'table',
        m_currLogoIdx = 'number',
        m_finishCB = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function SceneLogo:init(class_ui)
    self.m_tLogoList = {'res/logo/perplelab.png'}
    self.m_currLogoIdx = 0
    self.m_finishCB = nil
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneLogo:onEnter()
    self:showLogo()
end

-------------------------------------
-- function showLogo
-------------------------------------
function SceneLogo:showLogo()
    self.m_currLogoIdx = self.m_currLogoIdx + 1
    if self.m_currLogoIdx <= #self.m_tLogoList then

        -- 화면 중앙에 랜더링 하기 위해 화면 사이즈를 얻어온다
        local visibleSize = cc.Director:getInstance():getVisibleSize()
        local origin = cc.Director:getInstance():getVisibleOrigin()

        -- 로고 sprite를 만들고 scene에 add한다
        local logoImg = self.m_tLogoList[self.m_currLogoIdx]
        local sprite = cc.Sprite:create(logoImg)
        sprite:setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2)
        self.m_scene:addChild(sprite)

        -- 콜백함수
        local function removeLogo()
            sprite:getParent():removeChild(sprite, true)
            self:showLogo()
        end

        -- 1초 후 removeLogo()를 호출하는 Action을 실행한다
        if logoImg == 'res/logo/perplelab.png' then
            sprite:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(removeLogo)))
        else
            sprite:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(removeLogo)))
        end
    else
        if self.m_finishCB then
            self.m_finishCB()
        end
    end
end

-------------------------------------
-- function setFinishCB
-------------------------------------
function SceneLogo:setFinishCB(finishCB)
    self.m_finishCB = finishCB
end
