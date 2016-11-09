local PARENT = UI_DragonManage_Base
local MAX_DRAGON_UPGRADE_MATERIAL_MAX = 30 -- 한 번에 사용 가능한 재료 수

-------------------------------------
-- class UI_DragonManagementEvolution
-------------------------------------
UI_DragonManagementEvolution = class(PARENT,{
        m_bChangeDragonList = 'boolean',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonManagementEvolution:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonManagementEvolution'
    self.m_bVisible = true or false
    self.m_titleStr = Str('진화') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManagementEvolution:init()
    self.m_bChangeDragonList = true

    local vars = self:load('dragon_management_evolution.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonManagementEvolution')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManagementEvolution:initUI()
    local vars = self.vars
    self:init_dragonTableView()
    --self:setDefaultSelectDragon()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManagementEvolution:initButton()
    local vars = self.vars
    vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManagementEvolution:refresh()

    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars

    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    -- 최대 진화도인지 여부
    local is_max_evolution = (t_dragon_data['evolution'] >= MAX_DRAGON_EVOLUTION)

    if is_max_evolution then
        UIManager:toastNotificationGreen(Str('최대 진화단계의 드래곤입니다.'))
    end

    -- 왼쪽 정보(현재 진화 단계)
    self:refresh_currDragonInfo(t_dragon_data, t_dragon)

    -- 가운데 정보(다음 진화 단계)
    self:refresh_nextDragonInfo(t_dragon_data, t_dragon, is_max_evolution)

    -- 오른쪽 정보(스킬)
    self:refresh_nextSkillInfo(t_dragon_data, t_dragon, is_max_evolution)

    -- 진화 재료
    self:refresh_evolutionStones(t_dragon_data, t_dragon, is_max_evolution)

    -- 진화하기 버튼 갱싱
    self:refresh_evolutionButton(t_dragon_data, t_dragon, is_max_evolution)
end

-------------------------------------
-- function refresh_currDragonInfo
-- @brief 왼쪽 정보(현재 진화 단계)
-------------------------------------
function UI_DragonManagementEvolution:refresh_currDragonInfo(t_dragon_data, t_dragon)
    local vars = self.vars

    -- 드래곤 이름
    vars['nameLabel']:setString(Str(t_dragon['t_name']))

    -- 진화도 (해치, 해츨링, 성룡)
    local evolution = t_dragon_data['evolution']
    local evolution_name = evolutionName(evolution)
    vars['beforeLabel']:setString(evolution_name)

    do -- 드래곤 리소스
        local evolution = t_dragon_data['evolution']
        vars['beforeNode']:removeAllChildren()
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        vars['beforeNode']:addChild(animator.m_node)

        animator:changeAni('pose_1', false)
        animator:addAniHandler(function() animator:changeAni('idle', true) end)
    end
end

-------------------------------------
-- function refresh_nextDragonInfo
-------------------------------------
function UI_DragonManagementEvolution:refresh_nextDragonInfo(t_dragon_data, t_dragon, is_max_evolution)
    local vars = self.vars

    if is_max_evolution then
        vars['afterLabel']:setString('')
        vars['afterNode']:removeAllChildren()
        return
    end

    -- 진화도 (해치, 해츨링, 성룡)
    local evolution = t_dragon_data['evolution'] + 1
    local evolution_name = evolutionName(evolution)
    vars['afterLabel']:setString(evolution_name)

    do -- 드래곤 리소스
        local evolution = t_dragon_data['evolution'] + 1
        vars['afterNode']:removeAllChildren()
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        vars['afterNode']:addChild(animator.m_node)

        animator:changeAni('pose_1', false)
        animator:addAniHandler(function() animator:changeAni('idle', true) end)
    end
end

-------------------------------------
-- function refresh_nextSkillInfo
-- @brief 오른쪽 정보(스킬)
-------------------------------------
function UI_DragonManagementEvolution:refresh_nextSkillInfo(t_dragon_data, t_dragon, is_max_evolution)
    local vars = self.vars

    local table_skill = TABLE:get('dragon_skill')
            
    vars['skillNode']:removeAllChildren()
    vars['skillNameLabel']:setString('')
    vars['skillTypeLabel']:setString('')
    vars['skillInfoLabel']:setString('')

    if is_max_evolution then
        return        
    end

    local evolution = t_dragon_data['evolution'] + 1
    local skill_id = t_dragon['skill_' .. evolution]
    local skill_type = t_dragon['skill_type_' .. evolution]

    if (skill_id == 'x') then
        vars['skillInfoLabel']:setString('스킬이 지정되지 않았습니다.')
    else
        -- 스킬 아이콘
        local icon = UI_SkillCard('dragon', skill_id, skill_type)
        vars['skillNode']:addChild(icon.root)

        -- 스킬 이름
        local str = icon:getSkillNameStr(skill_id)
        vars['skillNameLabel']:setString(str)

        -- 스킬 타입
        local str = icon:getSkillTypeStr(skill_type)
        vars['skillTypeLabel']:setString(str)

        -- 스킬 설명
        local str = icon:getSkillDescStrPure(skill_id, skill_type)
        vars['skillInfoLabel']:setString(str)
    end
end

-------------------------------------
-- function refresh_evolutionStones
-- @brief 진화재료
-------------------------------------
function UI_DragonManagementEvolution:refresh_evolutionStones(t_dragon_data, t_dragon, is_max_evolution)
    local vars = self.vars

    local did = t_dragon['did']

    local table_dragon_evolution = TABLE:get('dragon_evolution')
    local t_dragon_evolution = table_dragon_evolution[did]
    
    if is_max_evolution then
        for i=1,3 do
            vars['plusSprite' .. i]:setVisible(false) -- ??
            vars['moveBtn' .. i]:setVisible(false)
            vars['numberLabel' .. i]:setString('')
            vars['materialLabel' .. i]:setString('')
            vars['materialItemNode' .. i]:removeAllChildren()
        end
        return
    end

    -- 진화 단계에 따른 문자열
    local evolution = t_dragon_data['evolution'] + 1
    local evolution_str = ''
    if (evolution == 2) then
        evolution_str = 'hatchling'
    elseif (evolution == 3) then
        evolution_str = 'adult'
    else
        error('evolution : ' .. evolution)
    end

    -- 진화 재료 1~3개 셋팅
    local table_evolution_item = TABLE:get('evolution_item')
    for i=1,3 do
        vars['moveBtn' .. i]:setVisible(true)

        local item_id = t_dragon_evolution[evolution_str .. '_item' .. i]
        local item_value = t_dragon_evolution[evolution_str .. '_value' .. i]

        local t_evolution_item = table_evolution_item[item_id]

        do -- 진화재료 이름
            local name = Str(t_evolution_item['t_name'])
            vars['materialLabel' .. i]:setString(name)
        end

        do -- 진화재료 아이콘
            vars['materialItemNode' .. i]:removeAllChildren()
            local item_icon = IconHelper:getItemIcon(item_id)
            vars['materialItemNode' .. i]:addChild(item_icon)
        end
        
        do -- 갯수 체크
            local req_count = item_value
            local own_count = g_userData:get('evolution_stones', tostring(item_id)) or 0
            vars['numberLabel' .. i]:setString(Str('{1} / {2}', own_count, req_count))
        end
    end
end

-------------------------------------
-- function refresh_evolutionButton
-- @brief 진화하기 버튼 갱신
-------------------------------------
function UI_DragonManagementEvolution:refresh_evolutionButton(t_dragon_data, t_dragon, is_max_evolution)
    local vars = self.vars

    if is_max_evolution then
        vars['priceLabel']:setString('0')
        return
    end

    local did = t_dragon['did']

    local table_dragon_evolution = TABLE:get('dragon_evolution')
    local t_dragon_evolution = table_dragon_evolution[did]

    -- 진화 단계에 따른 문자열
    local evolution = t_dragon_data['evolution'] + 1
    local evolution_str = ''
    if (evolution == 2) then
        evolution_str = 'hatchling'
    elseif (evolution == 3) then
        evolution_str = 'adult'
    else
        error('evolution : ' .. evolution)
    end

    -- 가격 설정
    local price = t_dragon_evolution[evolution_str .. '_gold']
    vars['priceLabel']:setString(comma_value(price))
end

-------------------------------------
-- function click_upgradeBtn
-------------------------------------
function UI_DragonManagementEvolution:click_upgradeBtn()
    if (self.m_selectDragonData['evolution'] >= MAX_DRAGON_EVOLUTION) then
        UIManager:toastNotificationGreen(Str('최대 진화단계의 드래곤입니다.'))
        return
    end

    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID

    local function success_cb(ret)
        -- 진화 재료 갱신
        if ret['remain_evolution_stones'] then
            g_serverData:applyServerData(ret['remain_evolution_stones'], 'user', 'evolution_stones')
        end

        -- 승급된 드래곤 갱신
        if ret['dragon'] then
            g_dragonsData:applyDragonData(ret['dragon'])
        end

        -- 골드 갱신
        if ret['remain_gold'] then
            g_serverData:applyServerData(ret['remain_gold'], 'user', 'gold')
            g_topUserInfo:refreshData()
        end

        -- UI 갱신
        self:refresh_dragonIndivisual(doid)
        self:refresh()
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/evolution')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManagementEvolution:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonManagementEvolution)
