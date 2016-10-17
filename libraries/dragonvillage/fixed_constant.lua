IS_EIM_TEST_VERSION = false

-- @LIVE_QA_VERSION 상용서버일때 QA서버로 접속할지 여부
LIVE_QA_VERSION = false

-- @APP_TARGET
-- 국내 버전  nil, 'KOREA'
-- GSP 버전   'GSP'
-- 중국 버전  'CHINA'
APP_TARGET = 'GSP'

-- 카카오 버전일 경우
if useKakao and (useKakao() == 1) then
    APP_TARGET = 'KAKAO'
end