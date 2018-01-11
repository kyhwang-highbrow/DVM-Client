local PARENT = class(UI, IEventListener:getCloneTable())

-------------------------------------
-- class UI_IngameBossHp
-------------------------------------
UI_IngameBossHp = class(PARENT, {
    m_world = 'GameWorld',
    m_lBoss = 'table',
})

    -------------------------------------
    -- function init
    -------------------------------------
    function UI_IngameBossHp:init(world, boss_list)
        self.m_world = world
        self.m_lBoss = boss_list or {}

        cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_btn/ingame_btn.plist')

        local vars = self:load('ingame_boss_hp.ui', nil, false, true)
        vars['bossSkillSprite']:setVisible(false)

        for _, boss in ipairs(self.m_lBoss) do
            boss:addListener('character_set_hp', self)
        end

        self:doActionReset()
        self:doAction()

        self:refresh()
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
-- class UI_IngameBossHpForClanRaid
-------------------------------------
UI_IngameBossHpForClanRaid = class(UI_IngameBossHp, {})

    -------------------------------------
    -- function refresh
    -------------------------------------
    function UI_IngameBossHpForClanRaid:refresh()
        local vars = self.vars

        local totalHp = self.m_lBoss[1].m_hp
        local totalMaxHp = self.m_lBoss[1].m_maxHp

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