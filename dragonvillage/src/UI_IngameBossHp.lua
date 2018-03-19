local PARENT = class(UI, IEventListener:getCloneTable())

-------------------------------------
-- class UI_IngameBossHp
-------------------------------------
UI_IngameBossHp = class(PARENT, {
    m_lBoss = 'table',
})

    -------------------------------------
    -- function init
    -------------------------------------
    function UI_IngameBossHp:init(parent, boss_list)
        self.m_lBoss = boss_list or {}

        cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_btn/ingame_btn.plist')

        local vars = self:load('ingame_boss_hp.ui', nil, false, true)
        parent:addChild(self.root, 102)

        vars['bossSkillSprite']:setVisible(false)
        vars['bossHpLabel']:setVisible(false)

        for _, boss in ipairs(self.m_lBoss) do
            boss:addListener('character_set_hp', self)
        end

        self:doActionReset()
        self:doAction()
    end

    -------------------------------------
    -- function refresh
    -------------------------------------
    function UI_IngameBossHp:refresh()
        local vars = self.vars

        local totalHp = 0
        local totalMaxHp = 0

        for _, v in ipairs(self.m_lBoss) do
            totalHp = totalHp + v.m_hp
            totalMaxHp = totalMaxHp + v.m_maxHp
        end

        local percentage = totalHp / totalMaxHp

        -- 체력바 가감 연출
        if (vars['bossHpGauge1']) then
            vars['bossHpGauge1']:setScaleX(percentage)
        end
	    if (vars['bossHpGauge2']) then
            local action = cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.5, percentage, 1))
            vars['bossHpGauge2']:runAction(cc.EaseIn:create(action, 2))
        end
    end

    -------------------------------------
    -- function onEvent
    -------------------------------------
    function UI_IngameBossHp:onEvent(event_name, t_event, ...)
        local vars = self.vars

        if (event_name == 'character_set_hp') then
            self:refresh()
        end
    end



-------------------------------------
-- class UI_IngameSharedBossHp
-- @brief 하나의 체력을 여러 보스가 공유하는 경우 사용
-------------------------------------
UI_IngameSharedBossHp = class(PARENT, {})

    -------------------------------------
    -- function init
    -------------------------------------
    function UI_IngameSharedBossHp:init(parent, boss_list, show_number)
        local show_number = show_number or false

        cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_btn/ingame_btn.plist')

        local vars = self:load('ingame_boss_hp.ui', nil, false, true)
        parent:addChild(self.root, 102)

        vars['bossSkillSprite']:setVisible(false)
        vars['bossHpLabel']:setVisible(show_number)

        for _, boss in ipairs(boss_list) do
            boss:addListener('character_set_hp', self)
        end

        self:doActionReset()
        self:doAction()
    end

    -------------------------------------
    -- function refresh
    -------------------------------------
    function UI_IngameSharedBossHp:refresh(hp, max_hp)
        local vars = self.vars

        local percentage = hp / max_hp

        -- 체력 수치 표시
        do
            local str = string.format('%s / %s (%.2f%%)', comma_value(math_floor(hp)), comma_value(max_hp), percentage * 100)
            vars['bossHpLabel']:setString(str)
        end

        -- 체력바 가감 연출
        if (vars['bossHpGauge1']) then
            vars['bossHpGauge1']:setScaleX(percentage)
        end
	    if (vars['bossHpGauge2']) then
            local action = cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.5, percentage, 1))
            vars['bossHpGauge2']:runAction(cc.EaseIn:create(action, 2))
        end
    end
    
    -------------------------------------
    -- function onEvent
    -------------------------------------
    function UI_IngameSharedBossHp:onEvent(event_name, t_event, ...)
        local vars = self.vars

        if (event_name == 'character_set_hp') then
            local hp = t_event['hp']
            local max_hp = t_event['max_hp']
            
            self:refresh(hp, max_hp)
        end
    end
