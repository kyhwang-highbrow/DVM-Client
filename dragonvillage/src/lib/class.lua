-------------------------------------
-- function class_
-- @brief 단일 상속 구조를 지원하고,
--        클래스 정의에 없는 멤버를 요청했을 때는 조용히 nil을 리턴하는 것이 아니라 에러를 낸다.
--        인스턴스 테이블에 대해 멤버를 요청했는데 그게 인스턴스 테이블에는 없고 클래스 정의에는 있는 경우,
--        해당 값이 함수인 경우에만 리턴해 준다. 아니면 무시한다.
-------------------------------------
function class_( a, b )
    local classDef, super
    if( b ) then -- class( 수퍼클래스, 멤버 정의 )
        super = a
        classDef = b
    else -- class( 멤버 정의 )
        classDef = a
    end

    assert( getmetatable( classDef ) == nil )

    local instanceMT = {
        __index = function( obj, k )
            local v = classDef[ k ]
            if( v == nil ) then
                error( 'unknown member: ' .. tostring( k ) )
            elseif( type( v ) == 'function' ) then
                return v
            else
                return nil
            end
        end;

        __newindex = function( obj, k, v )
            if( classDef[ k ] == nil ) then
                error( 'unknown member: ' .. tostring( k ) )
            end
            rawset( obj, k, v )
        end;

        def = classDef;
    }

    -- 클래스에 생성자 호출 체인 설치
    classDef.call_init = function( obj, ... )
        if( super ) then
            super.call_init( obj, ... )
        end
        
        local init = rawget( classDef, 'init' )
        if( init ) then
            init( obj, ... )
        end
    end
    classDef.super = super

    setmetatable( classDef, {
        __index = super;

        __call = function( _, ... )
            local obj = {}
            setmetatable( obj, instanceMT )

            classDef.call_init( obj, ... )
            if classDef.init_after then
                classDef.init_after( obj, ... )
            end
            return obj
        end;
    })

    return classDef
end

-------------------------------------
-- function class
-- @brief 다중 상속
-------------------------------------
function class(...)
    local arg = {...}

    if (#arg == 1) then
        return class_(arg[1])
    end

    local super = nil
    for i,v in ipairs(arg) do
        if (not super) then
            super = v
        else
            super = class_(super, v)
        end
    end

    return super
end

-------------------------------------
-- function isInstanceOf
-------------------------------------
function isInstanceOf(obj, cls)
    local mt = getmetatable(obj) -- getmetatable(nil/number) == nil
    if not mt then return false end

    local def = mt.def
    while def do
        if def == cls then return true end
        def = def.super
    end
    return false
end

-------------------------------------
-- function getClassName
-------------------------------------
function getClassName(class)
    for k, v in pairs(_G) do
        if (v == class) then
            return k
        end
    end
    return nil
end

-------------------------------------
-- function getsetGenerator
-- @brief 지정된 멤버변수의 getter/setter를 자동 생성한다.
-------------------------------------
function getsetGenerator(klass, class_name)
	-- 자동생성할 멤버 변수 수집
	local l_gen_var = {}
	for var, v in pairs(klass) do
		-- 자동생성하도록 지정된 멤버 변수를 찾는다.
		if (v == 'get_set_gen') then
			table.insert(l_gen_var, var)
		end
	end

	-- 대상 변수가 없다면 탈출
	if (#l_gen_var == 0) then
		return
	end

    -- 2017-07-11 sgkim class.lua파일이 다른 파일의 의존성이 없도록 하기 위한 수정
	local func_loader = load--pl.utils.load

	-- 대상 멤버 변수 함수 생성
	local code, func
	for _, var in pairs(l_gen_var) do
		-- getter, setter 생성
        local templete = 
	    [[
		    function klass:get_var() return self.var end
		    function klass:set_var(v) self.var = v end
	    ]]

		code = templete
		code = string.gsub(code, 'klass', class_name)
		code = string.gsub(code, 'var', var)

		-- compile
		func = func_loader(code)
		func()
	end
end     
 