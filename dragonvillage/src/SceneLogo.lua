-------------------------------------
-- class SceneLogo
-------------------------------------
SceneLogo = class(PerpleScene, {
        m_tLogoList = 'table',
        m_currLogoIdx = 'number',
        m_startCB = 'function',
        m_bCallStartCB = 'boolean',
        m_finishCB = 'function',
        m_startTimeMillisec = 'sec',
    })

local LOGO_TIME = 1

-------------------------------------
-- function init
-------------------------------------
function SceneLogo:init(class_ui)
    self.m_bShowTopUserInfo = false
    --self.m_tLogoList = {'res/logo/logo_highbrow.png', 'res/logo/perplelab.png'}
    self.m_tLogoList = {'res/logo/logo_highbrow.png'}
    self.m_currLogoIdx = 0
    self.m_finishCB = nil
    self.m_bCallStartCB = false
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneLogo:onEnter()
    self.m_scene:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
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
    else
        self.m_scene:unscheduleUpdate()
        if self.m_finishCB then
            self.m_finishCB()
        end
    end
end

-------------------------------------
-- function update
-------------------------------------
function SceneLogo:update(dt)
    if (not self.m_bCallStartCB) and (self.m_currLogoIdx == 1) then
        if self.m_startCB then
            self.m_startCB()
        end
        self.m_bCallStartCB = true
        return
    end
    
    local curr_millisec = socket.gettime()
    if (not self.m_startTimeMillisec) or (self.m_startTimeMillisec + LOGO_TIME <= curr_millisec) then
        self:showLogo()
        self.m_startTimeMillisec = curr_millisec
    end
end

-------------------------------------
-- function setStartCB
-------------------------------------
function SceneLogo:setStartCB(startCB)
    self.m_startCB = startCB
end

-------------------------------------
-- function setFinishCB
-------------------------------------
function SceneLogo:setFinishCB(finishCB)
    self.m_finishCB = finishCB
end
