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
end


-------------------------------------
-- function setDragonAnimator
-------------------------------------
function UIC_DragonAnimator:setDragonAnimator(did, evolution, flv)
    self.m_friendshipLv = flv or 0
    
    if (self.m_did == did) and (self.m_evolution == evolution) then
        return
    end

    self.m_did = did
    self.m_evolution = evolution
    
    local table_dragon = TableDragon()
    local t_dragon = table_dragon:get(did)
    local res_name = t_dragon['res']
    local attr = t_dragon['attr']

    local dragon_res_name = AnimatorHelper:getDragonResName(res_name, evolution, attr)

    local vars = self.vars

    vars['dragonNode']:removeAllChildren()
    self.m_animator = AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)
    vars['dragonNode']:addChild(self.m_animator.m_node)

    -- 랜덤 에니메이션 리스트 생성
    self.m_randomAnimationList = {}
    for i,ani in ipairs(self.m_animator:getVisualList()) do
        if isExistValue(ani, 'attack', 'pose_1', 'pose_2') then
            table.insert(self.m_randomAnimationList, ani)
        end
    end

    self.m_timeStamp = nil
    self.vars['talkSprite']:setVisible(false)
end

-------------------------------------
-- function click_dragonButton
-------------------------------------
function UIC_DragonAnimator:click_dragonButton()

    local curr_time = Timer:getServerTime()

    if (self.m_timeStamp) and ((curr_time - self.m_timeStamp) < 3) then
        return
    end

    self.m_timeStamp = curr_time

    -- 에니메이션 랜덤
    local ani = table.getRandom(self.m_randomAnimationList)
    self.m_animator:changeAni(ani, false)

    local function ani_handler()
        self.m_animator:changeAni('idle', true)
    end

    self.m_animator:addAniHandler(ani_handler)

    do
        self.vars['talkSprite']:setVisible(true)
        self.vars['talkSprite']:stopAllActions()
        self.vars['talkLabel']:setString(self:getDragonSpeech(self.m_did, self.m_friendshipLv))

        self.vars['talkSprite']:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.Hide:create()))
    end
end

-------------------------------------
-- function getDragonSpeech
-------------------------------------
function UIC_DragonAnimator:getDragonSpeech(did, flv)
    local dragon_type = TableDragon:getDragonType(did)
    local speech = TableDragonType:getRandomSpeech(dragon_type, flv)
    return speech
end