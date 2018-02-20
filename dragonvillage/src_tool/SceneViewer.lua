local FONT_PATH = 'res/font/common_font_01.ttf'
local ENTRY_FILE = 'res/character/dragon/godaeshinryong_light_01/godaeshinryong_light_01.json'

-- 드래곤의 피격박스 사이즈는 20이지만 scale 0.5를 사용하기 때문에 상대적으로 40의 크기를 가진다.
local t_PHYSICS_SIZE = {40, 30, 40, 60, 100, 200}
local t_PHYSICS_TEXT = {'드래곤', '소형', '중형', '대형', '특대형', '특특대형'}

-------------------------------------
-- class SceneViewer
-------------------------------------
SceneViewer = class(PerpleScene,{
		m_uiVars = 'table',

        m_animator = '',

		m_vrpResName = 'string',
		m_visualName = 'string',
		m_visual = 'VRP',
		m_eclv = 'number',
		m_heroGrade = 'number',

		m_visualNameList = 'table',
		m_currVisualIdx = 'number',

		m_bgName = 'string',

        m_dragonScale = 'number',
        m_effctNode = 'cc.Node',
		m_uiNode = 'cc.Node',
		m_mapNode = 'cc.Node',
		
        m_editBox = '',

		m_zero_point = '',
		m_physical_box = '',
		m_physics_index = 'number',

		m_dummy = 'vrp',
		m_mapManager = 'map ani',

        m_bDarkMode = 'boolean',
        m_mBoneEffect = 'table',
	})

-------------------------------------
-- function init
-------------------------------------
function SceneViewer:init()
    self.m_bShowTopUserInfo = false
	self.m_uiVars = {}
	self.m_vrpResName = ENTRY_FILE
	self.m_visualName = 'idle'
	self.m_visual = nil

	self.m_eclv = 0
	self.m_heroGrade = 1
	self.m_visualNameList = {}
	self.m_currVisualIdx = 1

	self.m_zero_point = nil
	self.m_physical_box = nil
	self.m_physics_index = 1

	self.m_bgName = 'map_canyon'

	self.m_dummy = nil

    self.m_bDarkMode = false
    self.m_mBoneEffect = {}

end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneViewer:onEnter()
	PerpleScene.onEnter(self)
	
	-- button 들이 위치하는 ui node 
	do
		self.m_uiNode = cc.Node:create()
		self.m_uiNode:setPosition(0, 0)
		self.m_uiNode:setContentSize(cc.Director:getInstance():getVisibleSize())
		self.m_uiNode:setAnchorPoint(cc.p(0.5, 0.5))
		self.m_uiNode:setDockPoint(cc.p(0.5, 0.5))
		self.m_scene:addChild(self.m_uiNode, 7)
		
		self:makeUI()
	end
	
	-- effect 표시하는 root node
	do
		self.m_effctNode = cc.Node:create()
		self.m_effctNode:setPosition(0, 0)
		self.m_effctNode:setDockPoint(cc.p(0.5, 0.5))
		self.m_scene:addChild(self.m_effctNode, 10)
		self:makeTouchLayer(self.m_effctNode)
			
		self.m_dragonScale = 0.4

		if (self.m_bDarkMode) then
            self:makeDarkModeHeroVisual()
        else
			self:makeHeroVisual()
        end
	end

	-- scroll map node 
	do
		self.m_mapNode = cc.Node:create()
		self.m_mapNode:setPosition(0, 0)
		self.m_mapNode:setDockPoint(cc.p(0.5, 0.5))
		self.m_scene:addChild(self.m_mapNode, 5)
		
		self:changeBG()
		self.m_scene:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
	end
end

-------------------------------------
-- function onExit
-------------------------------------
function SceneViewer:onExit()
end

-------------------------------------
-- function makeUI
-------------------------------------
function SceneViewer:makeUI()

		----------------------------------------------------------------------
		do -- vrp 리소스명
			local function editBoxTextEventHandle(strEventName, pSender)
				local edit = pSender
				self.m_bgName = edit:getText()
				self:changeBG()
			end

			local editBoxSize = cc.size(600, 40)
			local edit_box = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create('res/common/tool/a_button_0103.png'))
			edit_box:setFontSize(20)
			edit_box:setFontName(FONT_PATH)
			edit_box:setFontColor(cc.c3b(255,255,255))
			edit_box:setPlaceHolder('배경이미지')
			edit_box:setPlaceholderFontColor(cc.c3b(255,0,0))
			edit_box:setMaxLength(20)
			edit_box:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
			edit_box:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
			edit_box:registerScriptEditBoxHandler(editBoxTextEventHandle)
			edit_box:setText(self.m_bgName)
			self.m_uiNode:addChild(edit_box)

			edit_box:setPosition(0, 50)
			edit_box:setDockPoint(cc.p(0.5, 0))
		end
		----------------------------------------------------------------------

		----------------------------------------------------------------------
		do -- 새로고침 버튼
			local function touchEvent(sender,eventType)
				if eventType == ccui.TouchEventType.ended then
					if (self.m_bDarkMode) then
                        self:makeDarkModeHeroVisual()
                    else
					    self:makeHeroVisual()
                    end

                    self.m_dragonScale = 1
                    self.m_effctNode:setPosition(0, 0)
                    self.m_effctNode:setScale(self.m_dragonScale)
                    self.m_uiVars['scaleLable']:setString('스케일 ' .. self.m_dragonScale)
				end
			end

			local button = ccui.Button:create()
			button:setTitleFontName(FONT_PATH)
			button:setTitleFontSize(30)
			button:setTitleText('새로고침')

			button:setTouchEnabled(true)
			button:loadTextures("res/common/tool/a_button_0801.png", "res/common/tool/a_button_0802.png", "")
			button:setPosition(0, 120)
			button:setDockPoint(cc.p(0.5, 0))
			button:addTouchEventListener(touchEvent)
			self.m_uiNode:addChild(button)
		end
		----------------------------------------------------------------------

        ----------------------------------------------------------------------
		do -- vrp 리소스명 버튼
			local function touchEvent(sender,eventType)
				if eventType == ccui.TouchEventType.ended then
                    self.m_vrpResName = openFileDialog()
                    self.m_editBox:setText(self.m_vrpResName)

					if (self.m_bDarkMode) then
                        self:makeDarkModeHeroVisual()
                    else
					    self:makeHeroVisual()
                    end
				end
			end

			local button = ccui.Button:create()
			button:setTitleFontName(FONT_PATH)
			button:setTitleFontSize(30)
			button:setTitleText('열기')

			button:setTouchEnabled(true)
			button:loadTextures("res/common/tool/a_button_0801.png", "res/common/tool/a_button_0802.png", "")
			button:setPosition(0, -50)
			button:setDockPoint(cc.p(0.5, 1))
			button:addTouchEventListener(touchEvent)
			self.m_uiNode:addChild(button)
		end
		----------------------------------------------------------------------

		----------------------------------------------------------------------
		do -- vrp 리소스명
			local function editBoxTextEventHandle(strEventName, pSender)
				local edit = pSender
				self.m_vrpResName = edit:getText()

				if (self.m_bDarkMode) then
                    self:makeDarkModeHeroVisual()
                else
					self:makeHeroVisual()
                end
			end

			local editBoxSize = cc.size(600, 40)
			local edit_box = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create('res/common/tool/a_button_0103.png'))
			edit_box:setFontSize(20)
			edit_box:setFontName(FONT_PATH)
			edit_box:setFontColor(cc.c3b(255,255,255))
			edit_box:setPlaceHolder('*.vrp명')
			edit_box:setPlaceholderFontColor(cc.c3b(255,0,0))
			edit_box:setMaxLength(20)
			edit_box:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
			edit_box:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
			edit_box:registerScriptEditBoxHandler(editBoxTextEventHandle)
			edit_box:setText(self.m_vrpResName)
			self.m_uiNode:addChild(edit_box)

			edit_box:setPosition(0, -100)
			edit_box:setDockPoint(cc.p(0.5, 1))

            self.m_editBox = edit_box
		end
		----------------------------------------------------------------------

		----------------------------------------------------------------------
		do -- 비주얼명
			local function editBoxTextEventHandle(strEventName, pSender)
				local edit = pSender
				self.m_visualName = edit:getText()

				if (self.m_bDarkMode) then
                    self:makeDarkModeHeroVisual()
                else
					self:makeHeroVisual()
                end
			end

			local editBoxSize = cc.size(250, 40)
			local edit_box = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create('res/common/tool/a_button_0103.png'))
			edit_box:setFontSize(20)
			edit_box:setFontName(FONT_PATH)
			edit_box:setFontColor(cc.c3b(255,255,255))
			edit_box:setPlaceHolder('비주얼명')
			edit_box:setPlaceholderFontColor(cc.c3b(255,0,0))
			edit_box:setMaxLength(20)
			edit_box:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
			edit_box:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
			edit_box:registerScriptEditBoxHandler(editBoxTextEventHandle)
			edit_box:setText(self.m_visualName)
			self.m_uiVars['visualName'] = edit_box
			self.m_uiNode:addChild(edit_box)

			edit_box:setPosition(-125, -150)
			edit_box:setDockPoint(cc.p(0.5, 1))
		end
		----------------------------------------------------------------------

		----------------------------------------------------------------------
		do -- 비주얼 <
			local function touchEvent(sender,eventType)
				if eventType == ccui.TouchEventType.ended then
					self:changeVisual(false)
				end
			end

			local custom_button = ccui.Button:create()
			custom_button:setTouchEnabled(true)
			custom_button:loadTextures("res/common/tool/arrow0101.png", "res/common/tool/arrow0102.png", "")
			custom_button:setScale(0.7)
			custom_button:setPosition(150, -150)
			custom_button:setDockPoint(cc.p(0.5, 1))
			custom_button:addTouchEventListener(touchEvent)
			self.m_uiNode:addChild(custom_button)
		end

		do -- 비주얼 >
			local function touchEvent(sender,eventType)
				if eventType == ccui.TouchEventType.ended then
					self:changeVisual(true)
				end
			end

			local custom_button = ccui.Button:create()
			custom_button:setTouchEnabled(true)
			custom_button:loadTextures("res/common/tool/arrow0101.png", "res/common/tool/arrow0102.png", "")
			custom_button:setScale(0.7)
			custom_button:setPosition(220, -150)
			custom_button:setDockPoint(cc.p(0.5, 1))
			custom_button:addTouchEventListener(touchEvent)
			custom_button:setScaleX(-0.7)
			self.m_uiNode:addChild(custom_button)
		end
		----------------------------------------------------------------------


		----------------------------------------------------------------------
		-- Label
		local editBoxSize = cc.size(250, 40)
		local custom_label = cc.Label:createWithTTF('스케일 : 1', FONT_PATH, 20.0, 0, editBoxSize, cc.TEXT_ALIGNMENT_LEFT)
		custom_label:setPosition(-125, -210)
		custom_label:setDockPoint(cc.p(0.5, 1))
		self.m_uiNode:addChild(custom_label)
		self.m_uiVars['scaleLable'] = custom_label
		----------------------------------------------------------------------

		----------------------------------------------------------------------
		do -- 스케일 <
			local function touchEvent(sender,eventType)
				if eventType == ccui.TouchEventType.ended then
					self:changeScale(false)
				end
			end

			local custom_button = ccui.Button:create()
			custom_button:setTouchEnabled(true)
			custom_button:loadTextures("res/common/tool/arrow0101.png", "res/common/tool/arrow0102.png", "")
			custom_button:setScale(0.7)
			custom_button:setPosition(150, -210)
			custom_button:setDockPoint(cc.p(0.5, 1))
			custom_button:addTouchEventListener(touchEvent)
			self.m_uiNode:addChild(custom_button)
		end

		do -- 스케일 >
			local function touchEvent(sender,eventType)
				if eventType == ccui.TouchEventType.ended then
					self:changeScale(true)
				end
			end

			local custom_button = ccui.Button:create()
			custom_button:setTouchEnabled(true)
			custom_button:loadTextures("res/common/tool/arrow0101.png", "res/common/tool/arrow0102.png", "")
			custom_button:setScale(0.7)
			custom_button:setPosition(220, -210)
			custom_button:setDockPoint(cc.p(0.5, 1))
			custom_button:addTouchEventListener(touchEvent)
			custom_button:setScaleX(-0.7)
			self.m_uiNode:addChild(custom_button)
		end

		-- 스케일 프리셋 버튼
		local SCALE_PRESET = {0.5, 0.8, 1.0}
		local SCALE_NAME = {'에뮬', '0.8', '실제'}
		do
			for i = 1, 3 do
				local function touchEvent(sender,eventType)
					if eventType == ccui.TouchEventType.ended then
						self:changeScale(nil, SCALE_PRESET[i])
					end
				end

				local button = ccui.Button:create()
				button:setTitleFontName(FONT_PATH)
				button:setTitleFontSize(16)
				button:setTitleText(SCALE_NAME[i])

				button:setTouchEnabled(true)
				button:loadTextures("res/common/tool/a_button_0801.png", "res/common/tool/a_button_0802.png", "")
				button:setPosition(220 + 100 * i, -210)
				button:setDockPoint(cc.p(0.5, 1))
				button:addTouchEventListener(touchEvent)
				self.m_uiNode:addChild(button)
			end
		end
		----------------------------------------------------------------------

		----------------------------------------------------------------------
		do -- 0,0 표시
			local function touchEvent(sender,eventType)
				if eventType == ccui.TouchEventType.ended then
					self.m_zero_point:setVisible(not self.m_zero_point:isVisible())
				end
			end

			local button = ccui.Button:create()
			button:setTitleFontName(FONT_PATH)
			button:setTitleFontSize(20)
			button:setTitleText('영점')

			button:setTouchEnabled(true)
			button:loadTextures("res/common/tool/a_button_0801.png", "res/common/tool/a_button_0802.png", "")
			button:setPosition(50, 200)
			button:setDockPoint(cc.p(0, 0.5))
			button:addTouchEventListener(touchEvent)
			self.m_uiNode:addChild(button)
		end
		----------------------------------------------------------------------

		----------------------------------------------------------------------
		do -- 피격박스 표시
			local function touchEvent(sender,eventType)
				if eventType == ccui.TouchEventType.ended then
					self.m_physical_box:setVisible(not self.m_physical_box:isVisible())
				end
			end

			local button = ccui.Button:create()
			button:setTitleFontName(FONT_PATH)
			button:setTitleFontSize(20)
			button:setTitleText('피격박스')

			button:setTouchEnabled(true)
			button:loadTextures("res/common/tool/a_button_0801.png", "res/common/tool/a_button_0802.png", "")
			button:setPosition(50, 100)
			button:setDockPoint(cc.p(0, 0.5))
			button:addTouchEventListener(touchEvent)
			self.m_uiNode:addChild(button)
		end

		-- 피격박스 사이즈 label
		do
			local physics_text = t_PHYSICS_TEXT[self.m_physics_index]
			local custom_label = cc.Label:createWithTTF(physics_text, FONT_PATH, 20.0, 0, cc.size(70,50), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
			custom_label:setPosition(150, 100)
			custom_label:setDockPoint(cc.p(0, 0.5))
			self.m_uiNode:addChild(custom_label)
			self.m_uiVars['physicsLabel'] = custom_label
		end

		do -- 피격박스 크기 <
			local function touchEvent(sender,eventType)
				if eventType == ccui.TouchEventType.ended then
					self:changePhysicsBox(false)
				end
			end

			local custom_button = ccui.Button:create()
			custom_button:setTouchEnabled(true)
			custom_button:loadTextures("res/common/tool/arrow0101.png", "res/common/tool/arrow0102.png", "")
			custom_button:setScale(0.5)
			custom_button:setPosition(100, 100)
			custom_button:setDockPoint(cc.p(0, 0.5))
			custom_button:addTouchEventListener(touchEvent)
			self.m_uiNode:addChild(custom_button)
		end

		do -- 피격박스 크기 >
			local function touchEvent(sender,eventType)
				if eventType == ccui.TouchEventType.ended then
					self:changePhysicsBox(true)
				end
			end

			local custom_button = ccui.Button:create()
			custom_button:setTouchEnabled(true)
			custom_button:loadTextures("res/common/tool/arrow0101.png", "res/common/tool/arrow0102.png", "")
			custom_button:setScale(0.5)
			custom_button:setScaleX(-0.5)
			custom_button:setPosition(200, 100)
			custom_button:setDockPoint(cc.p(0, 0.5))
			custom_button:addTouchEventListener(touchEvent)
			self.m_uiNode:addChild(custom_button)
		end
        ----------------------------------------------------------------------

		----------------------------------------------------------------------
		do -- 다크 모드
            local function touchEvent(sender,eventType)
				if eventType == ccui.TouchEventType.ended then
                    for effect, _ in pairs(self.m_mBoneEffect) do
                        effect:release()
                    end
                    self.m_mBoneEffect = {}

                    self.m_bDarkMode = not self.m_bDarkMode

                    if (self.m_bDarkMode) then
                        self:makeDarkModeHeroVisual()
                    else
					    self:makeHeroVisual()
                    end
				end
			end

			local button = ccui.Button:create()
			button:setTitleFontName(FONT_PATH)
			button:setTitleFontSize(20)
			button:setTitleText('다크모드')

			button:setTouchEnabled(true)
			button:loadTextures("res/common/tool/a_button_0801.png", "res/common/tool/a_button_0802.png", "")
			button:setPosition(50, 0)
			button:setDockPoint(cc.p(0, 0.5))
			button:addTouchEventListener(touchEvent)
			self.m_uiNode:addChild(button)
        end
		----------------------------------------------------------------------

		----------------------------------------------------------------------

		local t_dummy_res = {
			'res/character/dragon/godaeshinryong_light_01/godaeshinryong_light_01.json',
			'res/character/dragon/godaeshinryong_light_02/godaeshinryong_light_02.json',
			'res/character/dragon/godaeshinryong_light_03/godaeshinryong_light_03.json',
		}

		for i = 1, 3 do
			local function touchEvent(sender,eventType)
				if eventType == ccui.TouchEventType.ended then
					if self.m_dummy then
						self.m_dummy:release()
						self.m_dummy = nil
					else
						self.m_dummy = self:MakeAnimator(t_dummy_res[i])
						self.m_dummy:setPosition(0, 0)
						self.m_dummy.m_node:setDockPoint(cc.p(0.5, 0.5))
						self.m_dummy.m_node:setScale(0.5)
						self.m_effctNode:addChild(self.m_dummy.m_node, -1)
					end
				end
			end

			local button = ccui.Button:create()
			button:setTitleFontName(FONT_PATH)
			button:setTitleFontSize(16)
			button:setTitleText('더미 ' .. i)

			button:setTouchEnabled(true)
			button:loadTextures("res/common/tool/a_button_0801.png", "res/common/tool/a_button_0802.png", "")
			button:setPosition(50, -50 * (i + 1))
			button:setDockPoint(cc.p(0, 0.5))
			button:addTouchEventListener(touchEvent)
			self.m_uiNode:addChild(button)
		end
end

-------------------------------------
-- function makeHeroVisual
-------------------------------------
function SceneViewer:makeHeroVisual()

    if self.m_animator then
        self.m_animator:release()
        self.m_animator = nil
    end

	if self.m_dummy then
		self.m_dummy:release()
		self.m_dummy = nil
	end

    -- 초기화
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
	cc.AzVisual:removeCacheAll()
	cc.AzVRP:removeCacheAll()
    sp.SkeletonAnimation:removeCacheAll()

    local vrp_res_name = self.m_vrpResName
    self.m_animator = self:MakeAnimator(self:getResName(vrp_res_name))
    self.m_animator:setPosition(0, 0)
    self.m_animator.m_node:setDockPoint(cc.p(0.5, 0.5))
    self.m_effctNode:addChild(self.m_animator.m_node)

    self.m_visualNameList = self.m_animator:getVisualList()
    self.m_animator:setSkin(self.m_heroGrade)

    self.m_currVisualIdx = 3
    self:changeVisual(false)


	-- 피격박스 표시 sprite
	do
		local radius = t_PHYSICS_SIZE[self.m_physics_index]
		self:drawPhysicsBox(radius)
		self.m_physical_box:setVisible(false)
	end

	-- 0, 0 표시 sprite
	do
		self:drawZeroPoint()
		self.m_zero_point:setVisible(false)
	end

end

-------------------------------------
-- function makeDarkModeHeroVisual
-------------------------------------
function SceneViewer:makeDarkModeHeroVisual()
    self:makeHeroVisual()

    -- 이미지 반전
    self.m_animator:setFlip(true)

    -- 기본 쉐이더 변경
    self.m_animator:setBaseShader(SHADER_DARK)

    -- 이펙트 슬롯 숨김
    local slotList = self.m_animator:getSlotList()
    for i, slotName in ipairs(slotList) do
        if startsWith(slotName, 'effect_') then
            self.m_animator.m_node:setVisibleSlot(slotName, false)
        end
    end

    local function makeDarkModeBoneEffect(bone_name, res, visual_name)
        -- 해당 본이 존재하는지 체크
        if (not self.m_animator.m_node:isExistBone(bone_name)) then return end

        local visual_name = visual_name or 'idle'

        -- 본 위치 사용 준비
        self.m_animator.m_node:useBonePosition(bone_name)

        local effect = MakeAnimator(res)
        effect:changeAni(visual_name, true)
                
        self.m_mBoneEffect[effect] = bone_name

        return effect
    end

    do -- 안광
        for i = 1, 6 do
            local effect = makeDarkModeBoneEffect('monstereye_' .. i, 'res/effect/effect_monsterdragon/effect_monsterdragon_eye.vrp', 'idle')
            if (effect) then
                self.m_animator.m_node:addChild(effect.m_node)
            else
                break
            end
        end
    end
    
    do -- 이펙트(앞 레이어)
        local effect = makeDarkModeBoneEffect('monstereffect', 'res/effect/effect_monsterdragon/effect_monsterdragon_f.vrp')
        if (effect) then
            self.m_animator.m_node:addChild(effect.m_node)
        end
    end
    
    do -- 이펙트(뒤 레이어)
        local effect = makeDarkModeBoneEffect('monstereffect', 'res/effect/effect_monsterdragon/effect_monsterdragon_b.vrp')
        if (effect) then
            self.m_effctNode:addChild(effect.m_node, -1)
        end
    end
end

-------------------------------------
-- function drawCircle
-------------------------------------
function SceneViewer:drawCircle(radius, color)
	local circle = cc.DrawNode:create()
	for angle = 0, 2 * 3.14159, 0.01 do
		circle:drawSegment(cc.p(0, 0), cc.p(radius*math_cos(angle), radius*math_sin(angle)), 1, color)
	end
	return circle
end

-------------------------------------
-- function drawZeroPoint
-------------------------------------
function SceneViewer:drawZeroPoint()
	local radius = 5
	local zero_color = cc.c4b(255,150,50,215)
	local zero_point = self:drawCircle(radius, zero_color)

	self.m_zero_point = zero_point
	self.m_animator.m_node:addChild(zero_point, 99)
end

-------------------------------------
-- function drawPhysicsBox
-------------------------------------
function SceneViewer:drawPhysicsBox(radius)
	local physics_color = cc.c4b(0,50,255,215)
	local physics_box = self:drawCircle(radius, physics_color)

	self.m_physical_box = physics_box
	self.m_animator.m_node:addChild(physics_box, 50)
end

-------------------------------------
-- function changePhysicsBox
-------------------------------------
function SceneViewer:changePhysicsBox(b_next)

	if b_next then
        self.m_physics_index = self.m_physics_index + 1
		if self.m_physics_index > table.count(t_PHYSICS_SIZE) then
			self.m_physics_index = 1
		end
	else
        self.m_physics_index = self.m_physics_index - 1
		if self.m_physics_index < 1 then
			self.m_physics_index = table.count(t_PHYSICS_SIZE)
		end
	end
	local radius = t_PHYSICS_SIZE[self.m_physics_index]
	local physics_text = t_PHYSICS_TEXT[self.m_physics_index]

    self.m_physical_box:removeFromParent()
	self.m_physical_box = nil
	self:drawPhysicsBox(radius)

    self.m_uiVars['physicsLabel']:setString(physics_text)
end

-------------------------------------
-- function getResName
-------------------------------------
function SceneViewer:getResName(res_name)
    local res_name = string.gsub(res_name, '\\', '/')
    return res_name
end


-------------------------------------
-- function MakeAnimator
-------------------------------------
function SceneViewer:MakeAnimator(res_name)

    local org_res = res_name

    -- 기본 이름으로 검색
    local animator = MakeAnimator(res_name)
    if animator and animator.m_node then
        return animator
    end

    -- 드래곤 캐릭터 검색
    local res_name = 'res/spine/' .. org_res .. '/' .. org_res .. '.spine'
    animator = MakeAnimator(res_name)
    if animator and animator.m_node then
        return animator
    end

    -- missile 리소스 검색
    local res_name = 'res/missile/' .. org_res .. '/' .. org_res .. '.spine'
    animator = MakeAnimator(res_name)
    if animator and animator.m_node then
        return animator
    end

    -- missile 리소스 검색
    local res_name = 'res/missile/' .. org_res .. '/' .. org_res .. '.vrp'
    animator = MakeAnimator(res_name)
    if animator and animator.m_node then
        return animator
    end


    return MakeAnimator(ENTRY_FILE)
end


-------------------------------------
-- function changeVisual
-------------------------------------
function SceneViewer:changeVisual(b_next)

	if not self.m_animator then
		return
	end

	if #self.m_visualNameList then

		if b_next then
			self.m_currVisualIdx = self.m_currVisualIdx + 1
		else
			self.m_currVisualIdx = self.m_currVisualIdx - 1
		end

		if self.m_currVisualIdx > #self.m_visualNameList then
			self.m_currVisualIdx = 1
		elseif self.m_currVisualIdx <= 0 then
			self.m_currVisualIdx = #self.m_visualNameList
		end
	end

	self.m_visualName = self.m_visualNameList[self.m_currVisualIdx]
	self.m_uiVars['visualName']:setText(self.m_visualName)
	self.m_animator:changeAni(self.m_visualName, true, false)

    --[[
	if not self.m_visual then
		return
	end

	if #self.m_visualNameList then

		if b_next then
			self.m_currVisualIdx = self.m_currVisualIdx + 1
		else
			self.m_currVisualIdx = self.m_currVisualIdx - 1
		end

		if self.m_currVisualIdx > #self.m_visualNameList then
			self.m_currVisualIdx = 1
		elseif self.m_currVisualIdx <= 0 then
			self.m_currVisualIdx = #self.m_visualNameList
		end
	end

	self.m_visualName = self.m_visualNameList[self.m_currVisualIdx]
	self.m_uiVars['visualName']:setText(self.m_visualName)
	self.m_visual:setVisual('group', self.m_visualName)
    --]]
end

-------------------------------------
-- function changeGrade
-------------------------------------
function SceneViewer:changeGrade(b_next)
	if b_next then
		if (self.m_heroGrade >=6) then
			if (self.m_eclv>=3) then
				self.m_heroGrade = 1
				self.m_eclv = 0
			else
				self.m_eclv = self.m_eclv + 1
			end
		else
			self.m_heroGrade = self.m_heroGrade + 1
		end
	else
		if 1 <= self.m_eclv then
			self.m_eclv = self.m_eclv - 1
		else
			if self.m_heroGrade <= 1 then
				self.m_heroGrade = 6
				self.m_eclv = 3
			else
				self.m_heroGrade = self.m_heroGrade - 1
			end
		end
	end

	if self.m_eclv >= 1 then
		self.m_uiVars['gradeLable']:setString(string.format('등급 : 초월 %d', self.m_eclv))
	else
		self.m_uiVars['gradeLable']:setString(string.format('등급 : %d', self.m_heroGrade))
	end


	self:makeHeroVisual()
end

-------------------------------------
-- function changeScale
-------------------------------------
function SceneViewer:changeScale(b_next, tar_scale)
	if tar_scale then
		self.m_dragonScale = tar_scale
	elseif b_next then
        self.m_dragonScale = self.m_dragonScale + 0.1
	else
        self.m_dragonScale = self.m_dragonScale - 0.1
	end
    self.m_effctNode:setScale(self.m_dragonScale)

    self.m_uiVars['scaleLable']:setString('스케일 ' .. self.m_dragonScale)
end


-------------------------------------
-- function changeBG
-------------------------------------
function SceneViewer:changeBG()
	if self.m_mapManager then 
		self.m_mapManager = nil
	end
	
	self.m_mapManager = ScrollMap(self.m_mapNode)
	self.m_mapManager:setBg(self.m_bgName)
	self.m_mapManager:setSpeed(-100)
end

-------------------------------------
-- function makeTouchLayer
-------------------------------------
function SceneViewer:makeTouchLayer(target_node)
    local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(function(touch, event) return self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    --listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    --listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_CANCELLED)

	local eventDispatcher = target_node:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function SceneViewer:onTouchBegan(touch, event)
    return true
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SceneViewer:onTouchMoved(touch, event)
    local delte = touch:getDelta()
    local x, y = self.m_effctNode:getPosition()
    self.m_effctNode:setPosition(x + delte['x'], y + delte['y'])
end

-------------------------------------
-- function update
-------------------------------------
function SceneViewer:update(dt)
	if (self.m_mapManager) then
		self.m_mapManager:update(dt)

        self.m_mapNode:setVisible(not self.m_bDarkMode)
	end

    if (self.m_animator) then
        for effect, bone_name in pairs(self.m_mBoneEffect) do
            local pos = self.m_animator.m_node:getBonePosition(bone_name)
            local scale = self.m_animator.m_node:getBoneScale(bone_name)

            if (effect.m_node:getParent() ~= self.m_animator.m_node) then
                effect:setPositionX(-pos.x)
                effect:setPositionY(pos.y)
                effect:setScale(self.m_animator:getScale() * scale.y)
            else
                effect:setPosition(pos)
                effect:setScale(scale.y)
            end
        end
    end
end