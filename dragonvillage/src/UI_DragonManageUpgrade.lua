local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonManageUpgrade
-------------------------------------
UI_DragonManageUpgrade = class(PARENT,{
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonManageUpgrade:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonManageUpgrade'
    self.m_bVisible = true or false
    self.m_titleStr = Str('승급') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManageUpgrade:init()
    local vars = self:load('dragon_management_upgrade.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonManageUpgrade')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManageUpgrade:initUI()
    self:init_dragonTableView()
    --self:setDefaultSelectDragon()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManageUpgrade:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManageUpgrade:refresh()

    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars

    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    -- 등급 테이블
    local table_grade_info = TABLE:get('grade_info')
    local t_grade_info = table_grade_info[t_dragon_data['grade']]
    local t_next_grade_info = table_grade_info[t_dragon_data['grade'] + 1]

    -- 최대 등급인지 여부
    local is_max_grade = (t_dragon_data['grade'] >= MAX_DRAGON_GRADE)

    do -- 드래곤 이름
        vars['nameLabel']:setString(Str(t_dragon['t_name']))
    end

    do -- 드래곤 현재 정보 카드
        vars['termsIconNode']:removeAllChildren()
        local dragon_card = UI_DragonCard(t_dragon_data)
        vars['termsIconNode']:addChild(dragon_card.root)
    end

    do -- 드래곤 다음 등급 정보 카드
        vars['maxIconNode']:removeAllChildren()

        if is_max_grade then
            
        else
            local t_next_dragon_data = clone(t_dragon_data)
            t_next_dragon_data['grade'] = (t_next_dragon_data['grade'] + 1)
            local dragon_card = UI_DragonCard(t_next_dragon_data)
            vars['maxIconNode']:addChild(dragon_card.root)
        end
    end
    
    -- 등급 업이 될 때 표시 스프라이트
    vars['gradeUpSprite']:setVisible(false)

    -- 스킬 업이 될 때 표시 스프라이트
    vars['skillUpSprite']:setVisible(false)
    
    do -- 승급 경험치
        if is_max_grade then
            vars['upgradeExpLabel']:setString(Str('승급 경험치 MAX'))
            vars['upgradeGauge']:setPercentage(100)
        else
            local req_exp = t_grade_info['req_exp']
            local curr_exp = t_dragon_data['gexp']
            local percentage = (curr_exp / req_exp) * 100

            vars['upgradeExpLabel']:setString(Str('승급 경험치 {1}%', percentage))
            vars['upgradeGauge']:setPercentage(percentage)
        end
    end

    -- 레벨 표시
    do
        local curr_lv = t_dragon_data['lv']
        local max_lv = t_grade_info['max_lv']
        vars['termsLvLabel']:setString(Str('조건레벨 {1}/{2}', curr_lv, max_lv))

        if is_max_grade then
            vars['maxLvLabel']:setVisible(false)
        else
            vars['maxLvLabel']:setVisible(true)
            local next_max_lv = t_next_grade_info['max_lv']
            vars['maxLvLabel']:setString(Str('최대레벨 {1} > {2}', max_lv, next_max_lv))
        end
    end

    vars['selectLabel']:setString(Str('선택재료 {1} / 30', 0))
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManageUpgrade:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonManageUpgrade)
