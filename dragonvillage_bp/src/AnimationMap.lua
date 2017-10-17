-------------------------------------
-- class AnimationMap
-------------------------------------
AnimationMap = class(MapManager, {
        m_node = 'GameWorld.m_bgNode',
        m_animator = 'Animator',

        m_lAniList = 'list',        -- 에니메이션 리스트
        m_aniIdx = 'number',        -- 현재 재생중인 에니메이션 
        m_maxAniIdx = 'number',     --

        m_changeAniList = 'list',   -- 웨이브 변경 재생될 에니메이션 리스트
        m_loopAniList = 'list',     -- 웨이브 지속시간 중에 반복될 에니메이션 리스트

        m_bStart = 'boolean',
        m_bChangeAniList = 'boolean',

        m_finishCB = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function AnimationMap:init(node, bg_res)
    self.m_node = node

    self.m_animator = MakeAnimator(bg_res)
    node:addChild(self.m_animator.m_node)
    self.m_animator.m_node:setDockPoint(cc.p(0.5, 0.5))
    self.m_animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_animator.m_node:setPositionX(1280/2)
    
    self.m_bStart = false

    --self:setAniList({'bg_02', 'bg_02', 'bg_02', 'bg_02'})
    self:setAniList({'start'})

    --self.m_animator:setTimeScale(2)
    --local time_scale = self.m_animator:getTimeScale()
    --cclog('time_scale : ' .. time_scale)
end

-------------------------------------
-- function changeAni
-------------------------------------
function AnimationMap:changeAni(ani_name, loop)
    self.m_animator:changeAni(ani_name, loop)
    self.m_animator:addAniHandler(function() self:aniHandler() end)
end

-------------------------------------
-- function setAniList
-------------------------------------
function AnimationMap:setAniList(l_animation_list)
    self.m_lAniList = l_animation_list
    self.m_maxAniIdx = #self.m_lAniList
    self.m_aniIdx = 0

    if (not self.m_bStart) then
        self.m_aniIdx = 1
        self:changeAni(self.m_lAniList[self.m_aniIdx], false)
        
        self.m_bStart = true
    end
end


-------------------------------------
-- function aniHandler
-------------------------------------
function AnimationMap:aniHandler()

    -- idx가 최대일 경우
    if (self.m_maxAniIdx <= self.m_aniIdx) then
        self.m_aniIdx = 1
        
        -- 
        if self.m_bChangeAniList then
            -- 웨이브 변경 연출 종료
            --cclog('# 웨이브 변경 연출 종료')
        end
        self.m_bChangeAniList = false

        if self.m_changeAniList then
            self:setAniList(self.m_changeAniList)
            self.m_changeAniList = nil
            self.m_bChangeAniList = true

        elseif self.m_loopAniList then
            self:setAniList(self.m_loopAniList)
            self.m_loopAniList = nil

            -- 실질적인 전투 시작
            if self.m_finishCB then
                self.m_finishCB()
            end
        end
    else
        self.m_aniIdx = self.m_aniIdx + 1
    end
    
    self:changeAni(self.m_lAniList[self.m_aniIdx], false)
end

-------------------------------------
-- function applyWaveScript
-------------------------------------
function AnimationMap:applyWaveScript(script)
    if (not script) then
        return false
    end

    -- 웨이브 변경 에니메이션 리스트가 있는지 여부
    local ret = false

    local change_ani_list = script['change_ani_list']

    if (change_ani_list) then
        self.m_changeAniList = clone(change_ani_list)
        ret = true
    end

    local loop_ani_list = script['loop_ani_list']

    if (loop_ani_list) then
        self.m_loopAniList = clone(loop_ani_list)
    end

    return ret
end