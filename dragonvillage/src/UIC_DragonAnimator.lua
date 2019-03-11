local PARENT = UIC_Node

-------------------------------------
-- class UIC_DragonAnimator
-------------------------------------
UIC_DragonAnimator = class(PARENT, {
        vars = '',

        m_did = '',
        m_evolution = '',
        m_friendshipLv = '',

        m_animator = 'Animator',

        m_randomAnimationList = '',

        m_timeStamp = '',
        m_bTalkEnable = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_DragonAnimator:init()
    local ui = UI()
    self.vars = ui:load('dragon_animator.ui')
    self.m_node = ui.root

    self.vars['dragonButton']:registerScriptTapHandler(function() self:click_dragonButton() end)
    self.vars['dragonButton']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    self.vars['talkSprite']:setVisible(false)
	self.vars['touchNode']:setVisible(false)

    self.m_bTalkEnable = true
end

-------------------------------------
-- function setDragonAnimator
-------------------------------------
function UIC_DragonAnimator:setDragonAnimator(did, evolution, flv)
    self.m_friendshipLv = flv or 0
    
    if (self.m_did == did) and (self.m_evolution == evolution) then
        return
    end

    local is_slime = TableSlime:isSlimeID(did)

    self.m_did = did
    self.m_evolution = evolution
    
    local t_dragon
    if is_slime then
        t_dragon = TableSlime():get(did)
    else
        t_dragon = TableDragon():get(did)
    end
    
    local res_name = t_dragon['res']
    local attr = t_dragon['attr']

    self.vars['dragonNode']:removeAllChildren()
    self.m_animator = AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)
    self.vars['dragonNode']:addChild(self.m_animator.m_node)
    
    -- 자코 몹들은 1.5배로 키워서 출력!
    if (t_dragon['birthgrade'] == 1) then
        self.m_animator:setScale(1.5)
    end

    -- 랜덤 에니메이션 리스트 생성
    self.m_randomAnimationList = {}
    for i,ani in ipairs(self.m_animator:getVisualList()) do
        if isExistValue(ani, 'attack', 'pose_1', 'pose_2', 'change') then
            table.insert(self.m_randomAnimationList, ani)
        end
    end

    self.m_timeStamp = nil
    self.vars['talkSprite']:setVisible(false)

    local idle_motion = true
    self:click_dragonButton(idle_motion)
end

-------------------------------------
-- function setDragonAnimatorByTransform
-------------------------------------
function UIC_DragonAnimator:setDragonAnimatorByTransform(struct_dragon_data)
    local did = struct_dragon_data['did']
    local evolution = struct_dragon_data['evolution']
    local flv = struct_dragon_data:getFlv()

    -- 성체부터 외형변환 적용
    if (evolution == POSSIBLE_TRANSFORM_CHANGE_EVO) then
        evolution = struct_dragon_data['transform'] or evolution
    end

    self:setDragonAnimator(did, evolution, flv)
end

-------------------------------------
-- function click_dragonButton
-------------------------------------
function UIC_DragonAnimator:click_dragonButton(idle_motion)
    local idle_motion = idle_motion or false -- 클릭한 경우 바로 랜덤 애니메이션
    local curr_time = Timer:getServerTime()

    if (self.m_timeStamp) and ((curr_time - self.m_timeStamp) < 3) then
        return
    end

    self.m_timeStamp = curr_time

    -- 에니메이션 랜덤 (기획 팀 요청)
    -- idle x 2 -> random ani idx 1 -> idle x 2 -> random ani idx 2 반복 
    local idle_index = 0
    local idle_repeat = 2
    local random_index = 0
    local prev_ani
    local ani_handler
    ani_handler = function()
        local ani

        -- 변신 애니인 경우
        if (prev_ani == 'change') then
            if (self.m_animator.m_aniAddName) then
                self.m_animator:setAniAddName()
            else
                self.m_animator:setAniAddName('_d')
            end
        end

        if (idle_motion) then
            idle_index = (idle_index) % idle_repeat + 1
            ani = 'idle'
            self.m_animator:changeAni(ani, false)
            self.m_animator:addAniHandler(ani_handler)

            if (idle_index == idle_repeat) then
                idle_motion = false
            end
        else
            random_index = (random_index) % #self.m_randomAnimationList + 1
            ani = self.m_randomAnimationList[random_index] or 'idle'
            self.m_animator:changeAni(ani, false)
            self.m_animator:addAniHandler(ani_handler)

            idle_motion = true

            -- 변신 애니인 경우 추가 이펙트 표시
            if (ani == 'change') then
                local effect = MakeAnimator('res/effect/effect_change_iris/effect_change_iris.vrp')
                if (effect.m_node) then
                    effect:changeAni('idle', false)
                    self.m_animator:addChild(effect.m_node)

                    -- 재생 후 삭제
                    local duration = effect:getDuration()
                    effect.m_node:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))
                end
            end
        end

        prev_ani = ani
    end

    ani_handler()

    if self.m_bTalkEnable then
        self.vars['talkSprite']:setVisible(true)
        self.vars['talkSprite']:stopAllActions()
        self.vars['talkLabel']:setString(self:getDragonSpeech(self.m_did, self.m_friendshipLv))

        self.vars['talkSprite']:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.Hide:create()))
    end

    self.m_animator.m_node:stopAllActions()
end

-------------------------------------
-- function getDragonSpeech
-------------------------------------
function UIC_DragonAnimator:getDragonSpeech(did, flv)
    local speech = TableDragonPhrase:getDragonPhrase(did, flv)
    return speech
end

-------------------------------------
-- function setTalkEnable
-------------------------------------
function UIC_DragonAnimator:setTalkEnable(enable)
    local vars = self.vars
    
    self.m_bTalkEnable = enable
    if (not self.m_bTalkEnable) then
        vars['talkSprite']:setVisible(false)
    end
end

-------------------------------------
-- function setIdle
-- @brief 드래곤 애니메이션 Idle만 출력
-------------------------------------
function UIC_DragonAnimator:setIdle()
    self.m_randomAnimationList = {}
    table.insert(self.m_randomAnimationList, 'idle')
end
