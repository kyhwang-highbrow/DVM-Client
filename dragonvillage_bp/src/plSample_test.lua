-------------------------------------
-- function test_stringLambda
-------------------------------------
function plSample:test_stringLambda()
	-- string lambda test
	do
		local string_lambda = pl.utils.string_lambda
		local add_step = string_lambda('|x|x+1')
		cclog(add_step(1))
		local polynomial = string_lambda("|x, y, z|x + 2 * y + 3 * z")
		cclog(polynomial(1, 2, 3))
	end
end

-------------------------------------
-- function test_string
-------------------------------------
function plSample:test_string()

	-- pl.utils 의 string 관련 함수 -- 정규표현식 사용
	do
		local str_sample = 'ac/dc'
		ccdump(pl.utils.split(str_sample, '%s/'))
	end

end

-------------------------------------
-- function test_others
-------------------------------------
function plSample:test_others()
	-- pl.func.tail
	-- first를 제외한 테이블 반환 (꼬리가 길다)
	do
		local l_sample = {1, 2, 3, 4, 5}
		ccdump(pl.func.tail(l_sample))
	end

	-- pl.utils.load
	-- string 상태인 lua code compile하여 실행
	do
		local str = [[
			local a = 1
			local b = 3
			cclog(a, b, a + b)
		]]
		local fn = pl.utils.load(str)
		fn()
	end
end

-------------------------------------
-- function test_class
-------------------------------------
function plSample:test_class()
	-- pl.class
	-- 기존에 사용하던 class 와 비교하여 좀더 유연한 형태를 가짐
	-- metatable을 수정하는 것이 가능
	-- 상속구조와 framework라는 측면이 강조되어 있음
	do
		Cat = pl.class()
		function Cat:_init(name) -- constructor
			self.name = name
		end
		Cat.a_func = function() print(self.name .. ' meow~') end
	
		Puma = pl.class(Cat)
		function Puma:c_func() print(self.name .. ' c_func test') end

		pl.class.Lion(Cat)
		function Lion:b_func() print(self.name .. ' b_func test') end

		local puma = Puma("puma")
		puma.puma_claw = 5
		local lion = Lion('lion')

		puma:c_func()
		print(puma.puma_claw)
		Lion.b_func(lion)

		if lion:is_a(Cat) then
			print 'lion is Cat'
		end
		if lion:is_a() == Lion then
			print 'lion is Lion'
		end

		if Cat:class_of(lion) then
			print 'Cat is lion'
		end

	end
end

-------------------------------------
-- function test_date
-------------------------------------
function plSample:test_date()
	local time = 1231541515
	-- 날짜 정보 세팅
	local date = pl.Date()
	date:set(time)

	-- 날짜 포맷 세팅
	local date_format = pl.Date.Format('yyyy-mm-dd')
	str = date_format:tostring(date)

	print(str)
end