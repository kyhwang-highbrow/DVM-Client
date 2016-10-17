--[[
    ex) 
    SecurityNumber:init('a') -- 게임시작 시 골드를 저장할 공간 세팅
    SecurityNumber:add('a', v) -- 골드 v만큼 증가
    local gold = SecurityNumber:get('a') -- 서버에 획득골드를 보내기 전에 get으로 얻어옴
    gold와 같이 중요하고 민감한 정보는 SecurityNumber를 2개 만들어서 최종적으로 두 값을 
    비교해서 같은 경우에만 정상으로 간주하여 이중 보안 처리.
]]--
local KEY = '102p'

SecurityNumber = {
}

SecurityData = {
}

local function get_crc(v)
    local c = 0
    local _v = math.floor(v)
    if _v < 0 then _v = -math.floor(v) end

    while math.floor(_v*0.1) > 0 do
        c = c + (_v % 10)
        c = c % 10
        _v = math.floor(_v*0.1)
    end
    
    return c
end

function SecurityNumber:clear()
    SecurityData = {}
end

function SecurityNumber:init(name)
    --[[
    '101p'는 임의의 prefix. 
    해킹툴로 메모리를 볼 경우 이러한 필드 이름 자체로 유추가
    가능할 수도 있기 때문에 이상한 이름으로 세팅함.
    SecurityNumber:init('gold')와 같이 이름
    을 정하는 것은 위험할 수 있기 때문에 관련성 없는 임의의 
    이름으로 정하는 것이 좋다.
    ]]--
    local name = self:getName(name)
    SecurityData[KEY..name] = nil
end

function SecurityNumber:get(name)
    local name = self:getName(name)
    if not SecurityData[KEY..name] then return 0 end

    -- crc가 다르면 값을 지워버리고 0을 리턴
    local c = get_crc(SecurityData[KEY..name].x)
    if not SecurityData[KEY..name].z or c ~= SecurityData[KEY..name].z then
        SecurityData[KEY..name] = nil
        return 0
    end

    return SecurityData[KEY..name].x - SecurityData[KEY..name].y
end

function SecurityNumber:add(name, v)
    local name = self:getName(name)
    local t = {x=0,y=0,z=0}
    local tn = KEY..name
    local r = math.random(-6758472,7637467)
    if SecurityData[tn] then
        t.x = SecurityData[tn].x - SecurityData[tn].y + v + r
        t.z = SecurityData[tn].z
    else
        t.x = r + v
    end
    t.y = r
    -- crc를 항상 다시 세팅
    t.z = get_crc(t.x)
    SecurityData[tn] = t
end

function SecurityNumber:set(name, v)
    local name = self:getName(name)
    local t = {x=0,y=0,z=0}
    local tn = KEY..name
    local r = math.random(-6758472,7637467)
    t.x = r + v
    t.y = r
    -- crc를 항상 다시 세팅
    t.z = get_crc(t.x)
    SecurityData[tn] = t
end

-------------------------------------
-- table
-------------------------------------
local T_NAME_LIST = {}
T_NAME_LIST['gold'] = 'dk'

-------------------------------------
-- function getName
-------------------------------------
function SecurityNumber:getName(name)
    if T_NAME_LIST[name] then
        return T_NAME_LIST[name]
    else
        return name
    end
end


-------------------------------------------------------
-- 무한돌파 삼국지에 적용된 메모리보안 항목
-------------------------------------------------------
--[[
    -- 골드(두개로 저장 후 최후에 비교)
    SecurityNumber:init('aa')   -- gold_1
    SecurityNumber:init('ab')   -- gold_2
    
    -- 무한던전
    SecurityNumber:init('c')    -- 무한던전 남은 시간
    SecurityNumber:init('d')    -- 무한던전 기본점수
    SecurityNumber:init('e')    -- 무한던전 보너스 점수
    SecurityNumber:init('f')    -- 무한던전 최종 점수
    
    -- 토벌전
    SecurityNumber:init('sp')   -- 토벌전 점수
    SecurityNumber:init('sp')   -- 토벌전 보너스
--]]
-------------------------------------------------------