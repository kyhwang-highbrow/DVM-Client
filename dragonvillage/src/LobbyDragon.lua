local PARENT = LobbyCharacter

-------------------------------------
-- class LobbyDragon
-------------------------------------
LobbyDragon = class(PARENT, {
        m_dragonID = 'number',
		m_flv = 'number',
		m_evolution = 'number',

        m_bAwake = 'bool',
        m_bWating = 'bool',
        m_targetX = '',
        m_targetY = '',
        m_targetTamer = '',
        m_bInitFirstPos = 'bool',

		m_hasGift = 'bool',
		m_giftAnimator = 'Animator',
		m_hasSomethingToTalk = 'bool',
		m_userDragon = 'bool',
		m_talkingTimer = 'timer',
		m_talkingNode = 'cc.Node',
     })

LobbyDragon.MOVE_ACTION = 100
LobbyDragon.DELAY_ACTION = 200
LobbyDragon.TINT_ACTION = 300
LobbyDragon.SPEED = 400
LobbyDragon.Y_OFFSET = 150
LobbyDragon.GIFT_HURRY_TIME = 5

-------------------------------------
-- function init
-------------------------------------
function LobbyDragon:init(did, flv, evolution, is_bot)
    self.m_dragonID = did
    self.m_bInitFirstPos = false
	self.m_flv = flv or 0
	self.m_evolution = evolution

	self.m_hasGift = false
	self.m_hasSomethingToTalk = false
	self.m_userDragon = not is_bot
	self.m_talkingTimer = 0
	
	-- TalkingNode 생성
	self.m_talkingNode = cc.Node:create()
	self.m_rootNode:addChild(self.m_talkingNode, 2)
end

-------------------------------------
-- function initAnimator
-------------------------------------
function LobbyDragon:initAnimator(file_name)
    -- Animator 삭제
    self:releaseAnimator()

    -- Animator 생성
    self.m_animator = AnimatorHelper:makeDragonAnimator(file_name)
    if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node, 1)
        self.m_animator.m_node:setPosition(0, LobbyDragon.Y_OFFSET)

		local scale
		if (string.find(file_name, 'common_')) then
			scale = 1
		else
			scale = 0.5
		end
		self.m_animator.m_node:setScale(scale)
    end
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function LobbyDragon:initState()
    self:addState('idle', LobbyDragon.st_idle, 'idle', true)
    self:addState('move', LobbyDragon.st_move, 'move', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function LobbyDragon.st_idle(self, dt)
    if (self.m_stateTimer == 0) then
        self.m_bAwake = false
        self.m_bWating = true
    end
end

-------------------------------------
-- function st_move
-------------------------------------
LobbyDragon.st_move = LobbyCharacter.st_move

-------------------------------------
-- function onEvent
-------------------------------------
function LobbyDragon:onEvent(event_name, t_event, ...)
    if (event_name == 'lobby_character_move') then
        local arg = {...}
        local lobby_tamer = arg[1]
        local x = arg[2]
        local y = arg[3]

        self.m_targetTamer = lobby_tamer

        self.m_targetX = x
        self.m_targetY = y

        -- 최초 위치가 설정되지 않았을 경우
        if (not self.m_bInitFirstPos) then
            local flip = lobby_tamer.m_animator.m_bFlip
			local factor = (self.m_evolution == 3) and 150 or 100
            if (not flip) then
                x = x - factor
            else
                x = x + factor
            end
            self:setPosition(x, y)
            self.m_animator:setFlip(flip)
            self.m_bInitFirstPos = true

        elseif (not self.m_bAwake) then
            local function func()
                self:awakeDragon()
            end
            cca.reserveFuncWithTag(self.m_rootNode, 1, func, LobbyDragon.DELAY_ACTION)
            self.m_bAwake = true

        elseif (not self.m_bWating) then
            local dragon_x, dragon_y = self.m_rootNode:getPosition()
            local distance_x = math_abs(x - dragon_x)
            local distance_y = math_abs(y - dragon_y)

            if (distance_x > 100) or (distance_y >= 80) then
                self:moveToTamer()
            end

        else
            -- 거리 체크
            local dragon_x, dragon_y = self.m_rootNode:getPosition()
            local distance_x = math_abs(x - dragon_x)
            local distance_y = math_abs(y - dragon_y)

            if (distance_x >= 200) or (distance_y >= 80) then
                self:awakeDragon()
                return
            end
        end
    end
end

-------------------------------------
-- function onMoveEnd
-------------------------------------
function LobbyDragon:onMoveEnd()
    if (not self.m_targetTamer) then
        return
    end

    local flip = self.m_targetTamer.m_animator.m_bFlip
    self.m_animator:setFlip(flip)
end

-------------------------------------
-- function awakeDragon
-------------------------------------
function LobbyDragon:awakeDragon()
    local node = self.m_rootNode
    cca.stopAction(node, LobbyDragon.DELAY_ACTION)

    self.m_bWating = false
    self:moveToTamer()
end

-------------------------------------
-- function moveToTamer
-------------------------------------
function LobbyDragon:moveToTamer()
    --local dragon_x, dragon_y = self.m_rootNode:getPosition()

    local x = self.m_targetX
	local y = self.m_targetY - 3

    local flip = self.m_targetTamer.m_animator.m_bFlip
	local factor = (self.m_evolution == 3) and 150 or 100
    if (not flip) then
        x = x - factor
    else
        x = x + factor
    end

    self:setMove(x, y, LobbyDragon.SPEED)
end

-------------------------------------
-- function update
-------------------------------------
function LobbyDragon:update(dt)
	PARENT.update(self, dt)
	
	-- user의 dragon만 동작
	if (self.m_userDragon) then
		self:update_gift(dt)
	end
end

-------------------------------------
-- 감성 기능
-------------------------------------

-------------------------------------
-- function hasGift
-------------------------------------
function LobbyDragon:hasGift()
	return self.m_hasGift
end

-------------------------------------
-- function hasSomethingToTalk
-------------------------------------
function LobbyDragon:hasSomethingToTalk()
	return self.m_hasSomethingToTalk
end

-------------------------------------
-- function takeGift
-------------------------------------
function LobbyDragon:takeGift()
	local function cb_func(ret)
		-- 선물 획득 연출
		local t_gift = ret['added_items']['items_list'][1]
		if (t_gift) then
			local item_id = t_gift['item_id']
			local gift_type = TableItem:getItemType(item_id)
			local gift_count = t_gift['count']
			SensitivityHelper:makeObtainEffect(gift_type, gift_count, self.m_rootNode)

			SoundMgr:playEffect('UI', 'ui_out_item_get')
		end

		-- 선물 수령 처리
		self.m_hasGift = false
		self.m_giftAnimator:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), cc.RemoveSelf:create()))
		self.m_giftAnimator = nil

		-- 선물 수령 후 최초 1회 대사 세팅
		self.m_hasSomethingToTalk = true
	end

	g_userData:requestDragonGift(cb_func)
end

-------------------------------------
-- function clickUserDragon
-------------------------------------
function LobbyDragon:clickUserDragon()
	if (not self.m_userDragon) then
		return
	end
	
	local case_type
	-- 선물 수령
	if (self:hasGift()) then
		self:takeGift()
		case_type = 'lobby_get_gift'

	-- 선물 주고 난 이후 최초 1회 대사
	elseif (self:hasSomethingToTalk()) then
		self.m_hasSomethingToTalk = false
		case_type = 'lobby_after_gift'

	-- 평상시
	else
		case_type = 'lobby_touch'

	end

	-- 감성 말풍선 실동작
	self.m_talkingNode:removeAllChildren()
	SensitivityHelper:doActionBubbleText(self.m_talkingNode, self.m_dragonID, self.m_flv, case_type)
end

-------------------------------------
-- function update_gift
-------------------------------------
function LobbyDragon:update_gift(dt)
	-- 선물이 있는 경우
	if (self.m_hasGift) then
		-- 선물이 가능할 경우 하이라이팅 위한 연출
		if (self.m_talkingTimer == 0) then
			local animator = MakeAnimator('res/ui/a2d/lobby_dragon/lobby_dragon.vrp')
			
			self.m_rootNode:addChild(animator.m_node, 2)
			animator:changeAni('dragon_fx', true)
			animator:setPosition(0, LobbyDragon.Y_OFFSET)
			animator:setIgnoreLowEndMode(true)

			self.m_giftAnimator = animator
		end

		self.m_talkingTimer = self.m_talkingTimer + dt

		-- 선물 재촉 대사
		if (self.m_talkingTimer > LobbyDragon.GIFT_HURRY_TIME) then
			self.m_talkingNode:removeAllChildren()
			SensitivityHelper:doActionBubbleText(self.m_talkingNode, self.m_dragonID, self.m_flv, 'lobby_hurry_gift')

			self.m_talkingTimer = self.m_talkingTimer - LobbyDragon.GIFT_HURRY_TIME
		end

	-- 선물이 없는 경우
	else
		local gift_time = g_userData:getDragonGiftTime()
		local curr_time = Timer:getServerTime()

		-- 선물 가능 상태로 전환
		if (curr_time > gift_time) then
			self.m_hasGift = true
			self.m_talkingTimer = 0
		end
	end
end