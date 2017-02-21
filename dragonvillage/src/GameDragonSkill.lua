local PARENT = class(IEventListener:getCloneClass(), IStateHelper:getCloneTable())

GAME_DRAGON_SKILL_WAIT = 0
GAME_DRAGON_SKILL_LIVE = 1

-------------------------------------
-- class GameDragonSkill
-------------------------------------
GameDragonSkill = class(PARENT, {
        m_world = 'GameWorld',
        
        -- 스킬을 사용할 드래곤 정보
        m_dragon = 'Dragon',
                
        m_skillDescEffect = 'Animator',
        m_skillNameLabel = 'cc.Label',
        m_skillDescLabel = 'cc.Label',
     })

-------------------------------------
-- function init
-------------------------------------
function GameDragonSkill:init(world)
    self.m_world = world
    self.m_state = GAME_DRAGON_SKILL_WAIT

    self.m_dragon = nil
    
    self:initState()
    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function GameDragonSkill:initUI()
    -- 스킬 설명
    self.m_skillDescEffect = MakeAnimator('res/ui/a2d/ingame_dragon_skill/ingame_dragon_skill.vrp')
    self.m_skillDescEffect:setPosition(0, -200)
    self.m_skillDescEffect:changeAni('skill', false)
    self.m_skillDescEffect:setVisible(false)
    g_gameScene.m_containerLayer:addChild(self.m_skillDescEffect.m_node)

    local titleNode = self.m_skillDescEffect.m_node:getSocketNode('skill_title')
    local descNode = self.m_skillDescEffect.m_node:getSocketNode('skill_dsc')
    
    self.m_skillNameLabel = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 60, 3, cc.size(800, 200), 1, 1)
    self.m_skillNameLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_skillNameLabel:setDockPoint(cc.p(0, 0))
	self.m_skillNameLabel:setColor(cc.c3b(84,244,87))
    self.m_skillNameLabel:enableShadow(cc.c4b(0,0,0,255), cc.size(-3, 3), 0)
    titleNode:addChild(self.m_skillNameLabel)

    self.m_skillDescLabel = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 30, 3, cc.size(800, 200), 1, 1)
    self.m_skillDescLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_skillDescLabel:setDockPoint(cc.p(0, 0))
	self.m_skillDescLabel:setColor(cc.c3b(220,220,220))
    self.m_skillDescLabel:enableShadow(cc.c4b(0,0,0,255), cc.size(-3, 3), 0)
    descNode:addChild(self.m_skillDescLabel)
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameDragonSkill:initState()
    self:addState(GAME_DRAGON_SKILL_WAIT,   function(self, dt) end)
    self:addState(GAME_DRAGON_SKILL_LIVE,   GameDragonSkill.update_live)
end

-------------------------------------
-- function update
-------------------------------------
function GameDragonSkill:update(dt)
    return PARENT.update(self, dt)
end

-------------------------------------
-- function update_live
-------------------------------------
function GameDragonSkill.update_live(self, dt)
    local dragon = self.m_dragon
    local timeScale = 0.1
    local delayTime = 1
    
    if (self.m_stateTimer == 0) then
        -- 게임 조작 막음
        self.m_world.m_bPreventControl = true

        -- 슬로우
        self.m_world.m_gameTimeScale:set(timeScale)

        -- 드래곤 승리 애니메이션
        dragon.m_animator:changeAni('pose_1', false)

        local duration = dragon:getAniDuration()
        dragon.m_animator:setTimeScale(duration / (timeScale * delayTime))
        
        -- 카메라 줌인
        self.m_world.m_gameCamera:setTarget(dragon, {time = timeScale / 8})

        -- 스킬 이름 및 설명 문구를 표시
        do
            local active_skill_id = dragon:getSkillID('active')
            local t_skill = TABLE:get('dragon_skill')[active_skill_id]

            self.m_skillDescEffect.m_node:setFrame(0)
            self.m_skillDescEffect:setVisible(true)
            self.m_skillDescEffect:setTimeScale(duration / (timeScale * delayTime))

            self.m_skillNameLabel:setString(Str(t_skill['t_name']))
            self.m_skillDescLabel:setString(IDragonSkillManager:getSkillDescPure(t_skill))
        end

        -- 스킬 사용 직전 이펙트
        do
            local attr = dragon:getAttribute()
            local animator = MakeAnimator('res/effect/effect_skillcasting_dragon/effect_skillcasting_dragon.vrp')
            animator:changeAni('idle_' .. attr, false)
            animator:setPosition(0, 80)
            g_gameScene.m_containerLayer:addChild(animator.m_node)

            local duration = animator:getDuration() * delayTime
            animator:setTimeScale(duration / (timeScale * delayTime))
            animator:addAniHandler(function() animator:runAction(cc.RemoveSelf:create()) end)
        end

        -- 효과음
        SoundMgr:playEffect('EFFECT', 'skill_ready')

        -- 음성
        playDragonVoice(dragon.m_charTable['type'])
    
    elseif (self.m_stateTimer >= timeScale * delayTime) then
        -- 게임 조작 막음 해제
        self.m_world.m_bPreventControl = false

        -- 슬로우
        self.m_world.m_gameTimeScale:set(1)

        -- 드래곤 스킬 애니메이션
        dragon:changeState('skillIdle')
        dragon.m_animator:setTimeScale(1)

        -- 카메라 줌아웃
        self.m_world.m_gameCamera:reset()

        self.m_dragon = nil
                
        self:changeState(GAME_DRAGON_SKILL_WAIT)
    end
end

-------------------------------------
-- function isEqualDragon
-------------------------------------
function GameDragonSkill:isEqualDragon(char)
    if ((not self.m_dragon) or (char.m_charType ~= 'dragon') or (not char.m_bLeftFormation)) then
        return false
    end

    return (char.m_charTable['did'] == self.m_dragon.m_charTable['did'])
end

-------------------------------------
-- function onEvent
-------------------------------------
function GameDragonSkill:onEvent(event_name, t_event, ...)
    if (event_name == 'dragon_skill') then
        local arg = {...}
        local dragon = arg[1]

        self.m_dragon = dragon

        self:changeState(GAME_DRAGON_SKILL_LIVE)
    end
end