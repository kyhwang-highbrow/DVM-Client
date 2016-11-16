-------------------------------------
-- class SkillIndicator_Tamer
-------------------------------------
SkillIndicator_Tamer = class(SkillIndicator, {
        m_indicatorEffect01 = '',
        m_indicatorLinkEffect = '',

        m_descLabel = 'Label',
        m_lFriendshipPercentLabel = 'list[label]',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_Tamer:init()
end

-------------------------------------
-- function onEnterAppear
-------------------------------------
function SkillIndicator_Tamer:onEnterAppear()
    do -- 드래곤별 친밀도를 얻어옴
        local world = self:getWorld()
        self.m_lFriendshipPercentLabel = {}

        for _,char in pairs(world.m_lDragonList) do
            if (char.m_charType == 'dragon') then
                local dragon_id = char.m_charTable['id']

                local t_friendship_data, t_friendship = g_friendshipData:getFriendship(dragon_id)
                --ccdump(t_friendship_data)

                local label = self:makeFriendshipPercentLabel(25)
                local t_data = {dragon=char, label=label}

                table.insert(self.m_lFriendshipPercentLabel, t_data)
            end
        end
    end

    if (not self.m_descLabel) then
        local desc = Str('드래곤의 일반 공격이 일정 확률로 대상을 공격합니다.')
        self.m_descLabel = cc.Label:createWithTTF(desc, 'res/font/common_font_01.ttf', 40, 2, cc.size(1280, 100), 1, 1)
        self.m_descLabel:setDockPoint(cc.p(0.5, 0.5))
        self.m_descLabel:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_descLabel:setPosition(1280/2, 270)
        g_gameScene.m_gameHighlightNode:addChild(self.m_descLabel, 100)
    end
end

-------------------------------------
-- function onDisappear
-------------------------------------
function SkillIndicator_Tamer:onDisappear()
    -- 라벨들 삭제
    for _,t_data in pairs(self.m_lFriendshipPercentLabel) do
        local label = t_data['label']

        if label then
            label:removeFromParent()
        end
    end
    self.m_lFriendshipPercentLabel = {}

    -- 라벨 삭제
    if (self.m_descLabel) then
        self.m_descLabel:removeFromParent()
        self.m_descLabel = nil
    end
end


-------------------------------------
-- function makeFriendshipPercentLabel
-------------------------------------
function SkillIndicator_Tamer:makeFriendshipPercentLabel(percent)
    local label = cc.Label:createWithTTF(tostring(percent) .. '%', 'res/font/common_font_01.ttf', 25, 2, cc.size(250, 100), 1, 1)
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(0.5, 0.5))
    
    self.m_indicatorRootNode:addChild(label)

    return label
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_Tamer:onTouchMoved(x, y)

    do -- 라벨들 위치 동기화
        local pos_x, pos_y = self.m_indicatorRootNode:getPosition()
        for _,t_data in pairs(self.m_lFriendshipPercentLabel) do
            local dragon = t_data['dragon']
            local label = t_data['label']

            label:setPosition(dragon.pos['x'] - pos_x, dragon.pos['y'] - pos_y)
        end
    end

    if (self.m_siState == SI_STATE_READY) then
        return
    end

    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()

    local old_target = self.m_targetChar
    local skill_indicator_mgr = self:getSkillIndicatorMgr()

    if old_target then
        skill_indicator_mgr:removeHighlightList(old_target)
        old_target:removeTargetEffect(v)
    end

    self.m_targetChar = self:getTamerBasicTarget(x, y)

    if self.m_targetChar then
        x = self.m_targetChar.pos['x']
        y = self.m_targetChar.pos['y']

        if (not self.m_targetChar.m_targetEffect) then
            skill_indicator_mgr:addHighlightList(self.m_targetChar)
            self:makeTargetEffect(self.m_targetChar, 'appear_enemy', 'idle_enemy')
        end

        self.m_hero:setTamerTarget(self.m_targetChar)
    end

    -- 이펙트 위치
    LinkEffect_refresh(self.m_indicatorLinkEffect, 0, 0, x - pos_x, y - pos_y)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_Tamer:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
        local indicator = MakeAnimator('res/indicator/indicator_effect_cast/indicator_effect_cast.vrp')
        indicator:setTimeScale(5)
        indicator:changeAni('normal', true)
        root_node:addChild(indicator.m_node)
        self.m_indicatorEffect01 = indicator
    end

    do
        local link_effect = LinkEffect('res/indicator/indicator_type_target/indicator_type_target.vrp', 'enemy_bar_idle', 'enemy_start_idle', 'enemy_end_idle', 200, 200)
        root_node:addChild(link_effect.m_node)
        self.m_indicatorLinkEffect = link_effect
    end
end

-------------------------------------
-- function getTamerBasicTarget
-- @brief 터치 위치에서 가장 가까운 적 리턴
-------------------------------------
function SkillIndicator_Tamer:getTamerBasicTarget(x, y)
    local world = self:getWorld()
    local l_target = world:getTargetList(self.m_hero, x, y, 'enemy', 'x', 'distance_line', nil)    
    return l_target[1]
end
