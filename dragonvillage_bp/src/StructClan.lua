local PARENT = Structure

-------------------------------------
-- class StructClan
-------------------------------------
StructClan = class(PARENT, {
        id = 'string',
        
        name = 'string', -- Ŭ�� �̸�
        intro = 'string', -- Ŭ�� ����

        member_cnt = 'number',
        join = 'boolean', -- �ڵ� ���� ����
        
        last_attd = 'number', -- ���� �⼮ Ƚ��

        master = 'string', -- Ŭ�� ������ �г���
    })

local THIS = StructClan

-------------------------------------
-- function init
-------------------------------------
function StructClan:init(data)
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructClan:getClassName()
    return 'StructClan'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructClan:getThis()
    return THIS
end