local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Poison
-------------------------------------
StatusEffect_Poison = class(PARENT, {
        m_dmg   = 'number',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Poison:init(file_name, body)
    self.m_dmg = 0
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_Poison:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    self:addTrigger('char_do_atk', function(t_event, ...)
        self:doDamage()
        self:reduceAllUnitDuration()
    end)
end

-------------------------------------
-- function onApplyOverlab
-- @brief �ش� ����ȿ���� ���� 1ȸ�� �����Ͽ� ��ø ����ɽø��� ȣ��
-------------------------------------
function StatusEffect_Poison:onApplyOverlab(unit)
    -- ������ ���, ���� ����
    local caster = unit:getCaster()
    local damage
	local damage_org

    if (self.m_bAbs) then
        damage_org = unit:getValue()
    else
        local atk_dmg = unit:getStandardStat()
	    local def_pwr = 0

        damage_org = math_floor(DamageCalc_P(atk_dmg, def_pwr))
        damage_org = damage_org * (unit:getValue() / 100)
    end

	-- �Ӽ� ȿ��
	local t_attr_effect = self.m_owner:checkAttributeCounter(caster)
	if t_attr_effect['damage'] then
		damage = damage_org * (1 + (t_attr_effect['damage'] / 100))
	else
		damage = damage_org
	end

    -- �ּ� �������� 1�� ����
    damage = math_max(1, damage)

    -- �ش� ������ �ӽ� ����
    unit:setParam('damage', damage)
	
    -- ������ ����
	self.m_dmg = self.m_dmg + damage
end

-------------------------------------
-- function onUnapplyOverlab
-- @brief �ش� ����ȿ���� ��ø �����ɽø��� ȣ��
-------------------------------------
function StatusEffect_Poison:onUnapplyOverlab(unit)
    -- ������ ����
    local damage = unit:getParam('damage')

    self.m_dmg = self.m_dmg - damage
end

-------------------------------------
-- function doDamage
-------------------------------------
function StatusEffect_Poison:doDamage()
	self.m_owner:setDamage(nil, self.m_owner, self.m_owner.pos.x, self.m_owner.pos.y, self.m_dmg, nil)

    -- ��ø�� �α� ó��
    for _, unit in pairs(self.m_lUnit) do
        -- @LOG_CHAR : ������ ������
        local damage = unit:getParam('damage')
        local caster = unit:getCaster()
	    caster.m_charLogRecorder:recordLog('damage', damage)
    end

    -- @LOG_CHAR : ����� ���ط�
	self.m_owner.m_charLogRecorder:recordLog('be_damaged', self.m_dmg)

	-- �ߵ� ����
	SoundMgr:playEffect('EFX', 'efx_poison')
end

-------------------------------------
-- function reduceAllUnitDuration
-- @brief ��� ��ø�� ���� �ð��� ����
-------------------------------------
function StatusEffect_Poison:reduceAllUnitDuration()
    for _, unit in ipairs(self.m_lUnit) do
        if (isInstanceOf(unit, StatusEffectUnit_Dot)) then
            unit.m_durationTimer = unit.m_durationTimer - unit.m_dotInterval
        end
    end
end