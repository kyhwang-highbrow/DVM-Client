local PARENT = UI

-------------------------------------
-- class UI_DragonSkillMove
-------------------------------------
UI_DragonSkillMove = class(PARENT,{
        m_tar_dragon_data = 'table',
        m_src_dragon_data = 'table',
        m_modified_dragon_data = 'table',
    })

-- 등급별 스킬 이전 가격
local MOVE_COST = {
    100, 
    200,
    700,
    1400,
    2800
}

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
        local birth_grade = TableDragon:getBirthGrade(self.m_tar_dragon_data['did'])
        vars['priceLabel']:setString(comma_value(MOVE_COST[birth_grade]))
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
        local node = vars['itemMenu1']
        node:removeAllChildren()

        local dragon_data = g_dragonsData:getDragonDataFromUid(self.m_tar_dragon_data['id'])
        local ui = UI_DragonSkillInfo(dragon_data)
        node:addChild(ui.root)
    end
    
    do -- 재료 드래곤 스킬 정보
        local node = vars['itemMenu2']
        node:removeAllChildren()

        local dragon_data = g_dragonsData:getDragonDataFromUid(self.m_src_dragon_data['id'])
        local ui = UI_DragonSkillInfo(dragon_data)
        node:addChild(ui.root)
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

        local t_prev_dragon_data = self.m_tar_dragon_data

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

        self:refresh()

        -- 재료 드래곤이 스킬레벨이 모두 1이거나 타겟 드래곤의 스킬레벨이 맥스면 팝업 바로 닫아줌
        if (not g_dragonsData:isSkillEnhanced(src_doid)) or (not g_dragonsData:haveSkillSpareLV(tar_doid)) then
            self:click_exitBtn()
        end

		-- 결과창 출력
        local mod_struct_dragon = self.m_modified_dragon_data
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
    end

    g_dragonsData:request_skillMove(src_doid, tar_doid, success_cb)
end

--@CHECK
UI:checkCompileError(UI_DragonSkillMove)
