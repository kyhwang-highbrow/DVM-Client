local PARENT = Structure

-------------------------------------
-- class StructClan
-------------------------------------
StructClan = class(PARENT, {
        id = 'string',
        
        name = 'string', -- Ŭ�� �̸�
        intro = 'string', -- Ŭ�� ����
        mark = 'string', -- Ŭ�� ����
        notice = 'string', -- Ŭ�� ����

        member_cnt = 'number',
        join = 'boolean', -- �ڵ� ���� ����
        
        last_attd = 'number', -- ���� �⼮ Ƚ��

        master = 'string', -- Ŭ�� ������ �г���
        empty = '', -- ??

        m_structClanMark = 'StructClanMark',
    })

local THIS = StructClan

-------------------------------------
-- function init
-------------------------------------
function StructClan:init(data)

    if (data['mark']) then
        self.m_structClanMark = StructClanMark:create(data['mark'])
    else
        self.m_structClanMark = StructClanMark()
    end
    
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

-------------------------------------
-- function getClanObjectID
-------------------------------------
function StructClan:getClanObjectID()
    return self['id']
end

-------------------------------------
-- function makeClanMarkIcon
-------------------------------------
function StructClan:makeClanMarkIcon()
    local icon = self.m_structClanMark:makeClanMarkIcon()
    return icon
end