local PARENT = UI

-------------------------------------
-- class UI_DragonSkillMove
-------------------------------------
UI_DragonSkillMove = class(PARENT,{
        m_tar_dragon_data = 'table',
        m_src_dragon_data = 'table',
        
        m_tar_ui = 'ui',
        m_src_ui = 'ui',
        
        m_modified_dragon_data = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkillMove:init(tar_dragon_data, src_dragon_data)
    local vars = self:load('dragon_skill_enhance_move.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_tar_dragon_data = tar_dragon_data
    self.m_src_dragon_data = src_dragon_data

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonSkillMove')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSkillMove:initUI()
    local vars = self.vars

    do -- 스킬레벨 이전 가격
        local price = self:getSkillMovePrice() 
        vars['priceLabel']:setString(comma_value(price))
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonSkillMove:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['moveBtn']:registerScriptTapHandler(function() self:click_moveBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSkillMove:refresh()
    local vars = self.vars

    do -- 타겟 드래곤 스킬 정보
        local node = vars['itemNode1']
        node:removeAllChildren()

        local dragon_data = g_dragonsData:getDragonDataFromUid(self.m_tar_dragon_data['id'])
        local ui = UI_DragonSkillInfo(dragon_data)
        node:addChild(ui.root)

        self.m_tar_ui = ui
    end
    
    do -- 재료 드래곤 스킬 정보
        local node = vars['itemNode2']
        node:removeAllChildren()

        local dragon_data = g_dragonsData:getDragonDataFromUid(self.m_src_dragon_data['id'])
        local ui = UI_DragonSkillInfo(dragon_data)
        node:addChild(ui.root)

        self.m_src_ui = ui
    end

    -- 할인 이벤트
    local only_value = true
    g_hotTimeData:setDiscountEventNode(HOTTIME_SALE_EVENT.SKILL_MOVE, vars, 'moveEventSprite', only_value)
end

-------------------------------------
-- function getSkillMovePrice
-------------------------------------
function UI_DragonSkillMove:getSkillMovePrice()
    local birth_grade = TableDragon:getBirthGrade(self.m_tar_dragon_data['did'])
    if (birth_grade < SKILL_MOVE_DRAGON_GRADE) then
        return 0
    end

    local map_skill_move_price = g_dragonsData.m_mSkillMovePrice

    local price = map_skill_move_price[tostring(birth_grade)]
    if (not price) then
        return 0
    end

    -- 스킬 이전 할인 합산
    local dc_value = g_hotTimeData:getDiscountEventValue(HOTTIME_SALE_EVENT.SKILL_MOVE)
    local dc_rate = (100 - dc_value)/100

    -- *와 floor함수 과정에서 1값이 버려지는 경우가 있어서 100을 곱했다가 나누도록 임시로 처리함
	return math_floor(price * 100 * dc_rate / 100)
end

-------------------------------------
-- function show_effect
-- @brief 스킬 강화 연출
-------------------------------------
function UI_DragonSkillMove:show_effect(finish_cb)
    local block_ui = UI_BlockPopup() 
    local res_path = 'res/ui/a2d/dragon_skill_enhance_move/dragon_skill_enhance_move.vrp'

    -- SKILL LV UP 
    do
        local ui = self.m_tar_ui
        local slot = g_dragonsData:getChangeSkillLvSlot(self.m_tar_dragon_data)
        local target_node = ui.vars['skillNode'..slot]

        local effect = MakeAnimator(res_path)
        effect:changeAni('lvup', false)
        effect:setPosition(ZERO_POINT)
        effect:setScale(1.2)
        target_node:addChild(effect.m_node)

        local duration = effect:getDuration()
        effect:runAction(cc.Sequence:create(
            cc.DelayTime:create(duration),
            cc.CallFunc:create(function() 
                if (finish_cb) then
                    finish_cb()
                end
                block_ui:close()
            end),
            cc.RemoveSelf:create()
        ))
    end

    -- SKILL LV DOWN 
    do
        local ui = self.m_src_ui
        local slot = g_dragonsData:getChangeSkillLvSlot(self.m_src_dragon_data)
        local target_node = ui.vars['skillNode'..slot]

        local effect = MakeAnimator(res_path)
        effect:changeAni('lvdown', false)
        effect:setPosition(ZERO_POINT)
        effect:setScale(1.2)
        target_node:addChild(effect.m_node)

        local duration = effect:getDuration()
        effect:runAction(cc.Sequence:create(
            cc.DelayTime:create(duration),
            cc.RemoveSelf:create()
        ))
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonSkillMove:click_exitBtn()
    local modified_dragon_data = self.m_modified_dragon_data
    if (modified_dragon_data) then
        self.m_closeCB(modified_dragon_data)
    end
    
    self.m_closeCB = nil
    self:close()
end

-------------------------------------
-- function click_moveBtn
-------------------------------------
function UI_DragonSkillMove:click_moveBtn()
    local src_doid = self.m_src_dragon_data['id']
    local tar_doid = self.m_tar_dragon_data['id']

    local function success_cb(ret)
        -- @analytics
        Analytics:trackUseGoodsWithRet(ret, '드래곤 스킬 레벨 이전')

        -- 드래곤 정보 갱신
        if (ret['modified_dragons']) then
			for _, t_dragon in ipairs(ret['modified_dragons']) do
                if (tar_doid == t_dragon['id']) then
                    self.m_modified_dragon_data = StructDragonObject(t_dragon)
                end

				g_dragonsData:applyDragonData(t_dragon)
			end
		end

        -- 갱신
        g_serverData:networkCommonRespone(ret)

        local finish_cb = function()
		    -- 결과창 출력
            local mod_struct_dragon = self.m_modified_dragon_data
            local t_prev_dragon_data = self.m_tar_dragon_data
            if (mod_struct_dragon) then
                local ui = UI_DragonSkillEnhance_Result(t_prev_dragon_data, mod_struct_dragon)
		        ui:setCloseCB(function()
                    local doid = t_prev_dragon_data['id']
			        local impossible, msg = g_dragonsData:impossibleSkillEnhanceForever(doid)
			        if (impossible) then
				        UIManager:toastNotificationRed(msg)
			        end
		        end)
            end

            -- 바뀐 드래곤 데이터로 갱신
		    self.m_tar_dragon_data = mod_struct_dragon
            self.m_src_dragon_data = StructDragonObject(g_dragonsData:getDragonDataFromUid(src_doid))
            self:refresh()

            -- 재료 드래곤이 스킬레벨이 모두 1이거나 타겟 드래곤의 스킬레벨이 맥스면 팝업 바로 닫아줌
            if (not g_dragonsData:isSkillEnhanced(src_doid)) or (not g_dragonsData:haveSkillSpareLV(tar_doid)) then
                self:click_exitBtn()
            end
        end
        
        self:show_effect(finish_cb)
    end

    local request_func = function()
        g_dragonsData:request_skillMove(src_doid, tar_doid, success_cb)
    end

    -- 확인 팝업
    local price = self:getSkillMovePrice()
    local msg = Str('다이아몬드 {1}개를 사용하여\n드래곤 스킬을 이전하시겠습니까?', comma_value(price))
    UI_ConfirmPopup('cash', price, msg, request_func)
end

--@CHECK
UI:checkCompileError(UI_DragonSkillMove)