local PARENT = UI

-------------------------------------
-- class UI_ScenarioPlayer_Narrate
-------------------------------------
UI_ScenarioPlayer_Narrate = class(PARENT,{
        m_lines = 'string list',
        m_currLine = 'number',
        m_richlabelList = 'UIC_RichLabel list',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ScenarioPlayer_Narrate:init(t_narrate)
    local vars = self:load_keepZOrder('scenario_narrate.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_ScenarioPlayer_Narrate')

    self.m_lines = pl.stringx.splitlines(t_narrate)
    self.m_currLine = 0
    self.m_richlabelList = {}

    self:makeRichLabels(self.m_lines)

    vars['nextVisual']:setVisible(false)
    vars['nextBtn']:registerScriptTapHandler(function()
        if (self.m_currLine > #self.m_richlabelList) then
            self:close()
        else
            self:next()
        end
    end)

    self:next()
end

-------------------------------------
-- function makeRichLabels
-------------------------------------
function UI_ScenarioPlayer_Narrate:makeRichLabels(l_lines)
    local l_pos = getSortPosList(-40, #l_lines)

    for i,v in ipairs(l_lines) do
        local rich_label = UIC_RichLabel()
    
        --rich_label:initGLNode()

        -- label의 속성들
        rich_label:setString(v)
        rich_label:setFontSize(30)
        rich_label:setDimension(1280, 720)
        rich_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        --rich_label:enableOutline(cc.c4b(255, 0, 0, 127), 3)
        --rich_label:enableShadow(cc.c4b(0,0,0,255), cc.size(-3, 3), 0)

        -- Node의 기본 속성들 (UIC_Node 참고)
        rich_label:setDockPoint(cc.p(0.5, 0.5))
        rich_label:setAnchorPoint(cc.p(0.5, 0.5))
        --rich_label:setScale(1)
        --rich_label:setRotation(45)

        -- m_node맴버 변수를 addChild
        self.root:addChild(rich_label.m_node, 10)
        rich_label:setPositionY(l_pos[i])
        rich_label:setVisible(false)

        table.insert(self.m_richlabelList, rich_label)

        -- fade out을 위해 설정
        rich_label:update(0) -- 내부 label들을 생성하기 위해 강제로 호출
	    doAllChildren(rich_label.m_node, function(node) node:setCascadeOpacityEnabled(true) end)
    end
end

-------------------------------------
-- function next
-------------------------------------
function UI_ScenarioPlayer_Narrate:next()
    do
        local rich_label = self.m_richlabelList[self.m_currLine]

        if rich_label then
            rich_label:stopAllActions()
            rich_label:setVisible(true)
            rich_label:setOpacity(255)
        end
    end
    
    self.m_currLine = self.m_currLine + 1

    do
        local rich_label = self.m_richlabelList[self.m_currLine]

        if rich_label then
            rich_label:stopAllActions()
            rich_label:setVisible(true)
            rich_label:setOpacity(0)

            local action = cc.Sequence:create(cc.FadeIn:create(1), cc.DelayTime:create(0.5), cc.CallFunc:create(function() self:next() end))
            rich_label:runAction(action)
        end
    end

    if (self.m_currLine > #self.m_richlabelList) then
        self.vars['nextVisual']:setVisible(true)
        --self.root:runAction(cc.Sequence:create(cc.DelayTime:create(3))
    end
end