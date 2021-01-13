-------------------------------------
-- global variable
-------------------------------------
-- src/frameworks/dragonvillage 를 기준으로 한 상대 경로
ASSETS_PATH = '..\\assets\\100mb'
ASSETS_PATH_FULL = '..\\assets\\full'
ASSETS_PATH_EXPANSION = '..\\assets\\expansion'

-- obb 압축용 경로
OBB_FORMAT = '..\\main.%d.%s.obb' -- main.11.com.perplelab.dragonvillagem.kr.obb

-- 100MB 기준 사이즈 : 바이너리 사이즈에 따라 달라질 수도 있다...
MB_TO_BYTE = (1024 * 1024)
UNDER_100MB = (150 * MB_TO_BYTE)