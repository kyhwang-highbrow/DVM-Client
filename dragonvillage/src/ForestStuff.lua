local PARENT = ForestObject

-------------------------------------
-- class ForestStuff
-------------------------------------
ForestStuff = class(PARENT, {
        m_tStuffInfo = 'string',
        m_ui = 'ForestStuffUI',
     })

-------------------------------------
-- function init
-------------------------------------
function ForestStuff:init(t_stuff)
    self.m_objectType = 'stuff'
    self.m_tStuffInfo = t_stuff
end

-------------------------------------
-- function initUI
-------------------------------------
function ForestStuff:initUI()
    self.m_ui = ForestStuffUI(self.m_tStuffInfo)
    self.m_rootNode:addChild(self.m_ui.root, 2)
end

-------------------------------------
-- function initAnimator
-------------------------------------
function ForestStuff:initAnimator(file_name)
    -- Animator 삭제
    self:releaseAnimator()

    -- Animator 생성
    local res = self.m_tStuffInfo['res']
    self.m_animator = MakeAnimator(res)
    if (self.m_animator) then
        self.m_rootNode:addChild(self.m_animator.m_node)

        -- 위치 지정
        self:setPosition(self.m_tStuffInfo['x'], self.m_tStuffInfo['y'])
    end
end

-------------------------------------
-- function update
-------------------------------------
function ForestStuff:update(dt)
    self.m_ui:updateTime()
end

-------------------------------------
-- function getStuffType
-------------------------------------
function ForestStuff:getStuffType()
    return self.m_tStuffInfo['stuff_type']
end

-------------------------------------
-- function showEmotionEffect
-- @brief 감정 이펙트 연출
-------------------------------------
function ForestStuff:showEmotionEffect()
    local animator = MakeAnimator('res/ui/a2d/emotion/emotion.vrp')

    do -- 에니메이션 지정
        local sum_random = SumRandom()
        sum_random:addItem(1, 'curious')
        sum_random:addItem(2, 'exciting')
        sum_random:addItem(2, 'like')
        sum_random:addItem(2, 'love')
        local ani_name = sum_random:getRandomValue()     
        animator:changeAni(ani_name, false)
    end

    -- 위치 지정
    animator:setPosition(-70, 200)
    
    -- 재생 후 삭제
    local duration = animator.m_node:getDuration()
    animator:setScale(0.7)
    animator.m_node:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))
    self.m_rootNode:addChild(animator.m_node, 3)
end