-------------------------------------
-- table SkillHelper
-- @brief 스킬 사용에 전역적으로 필요한 함수 모음
-------------------------------------
SkillHelper = {}

-------------------------------------
-- function getAttributeRes
-- @brief 스킬에서 사용할 리소스 경로를 만들어 반환하는데 객체 생성전에 사용되므로 주의
-------------------------------------
function SkillHelper:getAttributeRes(res, owner)
	if (not res) then 
		error('비어있는 스킬 리소스 문자열')
	elseif (res == 'x') then
		return nil
	else
		return string.gsub(res, '@', owner:getAttributeForRes())
	end
end


-------------------------------------
-- function calculatePositionX
-- @brief 주어진 x를 기준으로 지정된 간격의 n개의 좌표를 구한다.
-------------------------------------
function SkillHelper:calculatePositionX(line_cnt, space, pos_x)
    local pos_x = pos_x
	local space = space
	local line_cnt = line_cnt
	
	local l_ret = {}
	local half = math_floor(line_cnt/2)

	-- 홀수
	if ((line_cnt % 2) == 1) then
		-- 중앙값
		table.insert(l_ret, pos_x)
		-- 좌우값
		for i = 1, half do
			table.insert(l_ret, pos_x + (space * i))
			table.insert(l_ret, pos_x - (space * i))
		end
	-- 짝수
	else
		-- 좌우값
		for i = 1, half do
			table.insert(l_ret, pos_x + (space * (i - 1 + 0.5)))
			table.insert(l_ret, pos_x - (space * (i - 1 + 0.5)))
		end
	end

	return l_ret
end

-------------------------------------
-- function makePassiveSkillSpeech
-- @brief 드래곤 패시브 스킬 발동시 말풍선을 생성
-------------------------------------
function SkillHelper:makePassiveSkillSpeech(dragon, str)
    local animatorWindow = MakeAnimator('res/ui/a2d/ingame_dragon_skill/ingame_dragon_skill.vrp')
    animatorWindow:setVisual('skill_gauge', 'bubble')
    animatorWindow:setRepeat(false)
    animatorWindow:setPosition(0, 50)
    dragon.m_unitInfoNode:addChild(animatorWindow.m_node, 10)

    local duration = animatorWindow:getDuration()
    animatorWindow:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))

    -- 대사
    do
        self.m_speechLabel = cc.Label:createWithTTF(str, 'res/font/common_font_01.ttf', 24, 0, cc.size(340, 100), 1, 1)
        self.m_speechLabel:setAnchorPoint(cc.p(0.5, 0.5))
	    self.m_speechLabel:setDockPoint(cc.p(0, 0))
	    self.m_speechLabel:setColor(cc.c3b(255, 255, 255))

        local socketNode = animatorWindow.m_node:getSocketNode('skill_bubble')
        socketNode:addChild(self.m_speechLabel, 1)
    end
end