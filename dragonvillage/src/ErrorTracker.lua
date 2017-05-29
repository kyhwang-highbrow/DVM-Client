-------------------------------------
-- class ErrorTracker
-- @brief Error, Bug 관련 정보 수집
-------------------------------------
ErrorTracker = class({
	lastScene = 'get_set_gen',
	lastUI = 'get_set_gen',
	lastAPI = 'get_set_gen',
	lastFailedRes = 'get_set_gen',
})

-------------------------------------
-- function init
-- @brief 생성자
-------------------------------------
function ErrorTracker:init()
	getsetGenerator(ErrorTracker)	
	self.lastScene = 'get_set_gen'
	self.lastUI = 'get_set_gen'
	self.lastAPI = 'get_set_gen'
	self.lastFailedRes = 'get_set_gen'
end

-------------------------------------
-- function getInstance
------------------------------------- 
function ErrorTracker:getInstance()
    if g_errorTracker then
        return g_errorTracker
    end

    g_errorTracker = ErrorTracker()
    return g_errorTracker
end









