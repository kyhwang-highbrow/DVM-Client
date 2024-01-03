-------------------------------------
---@class ConsentPlatform
---CMP/UMP SDK Wrapper class
---@author kms
---@date 23.12.28
---@link https://highbrow.atlassian.net/wiki/spaces/dev/pages/2710241545/DEV+Google+CMP+UMP
--[[
Data samples
Writing to storage: [IABTCF_CmpSdkID] 300
Writing to storage: [IABTCF_CmpSdkVersion] 2
Writing to storage: [IABTCF_PolicyVersion] 4
Writing to storage: [IABTCF_gdprApplies] 1
Writing to storage: [IABTCF_PublisherCC] KR
Writing to storage: [IABTCF_PurposeOneTreatment] 0
Writing to storage: [IABTCF_UseNonStandardStacks] 0
Writing to storage: [IABTCF_VendorConsents] 100100001111101100001111101100010101101101001000010100001011000000011110100111011101101000101110110000010000110000000010000100011101000110110100001000000001000010100001000010000000000000000001001000000100000010011000000000000101000000000000101001000000100000000101000000001010000010010000000001000000010100000011001010000000000100001000000000001000000000000000000000000000100000001001100100000100100001000000000000010000001000000000000000000000000001010000000000000001000000000000000000000000000000000000010000010000000000000000000000000000000000000000000000100000100000000000000000000010000000000000010000000000000000000000000000100000000000000000000000001000000000100000000000000000010000000000000000100000000000000000000000000000010000000000000000000010011000000010000000000000000000100000100000000000001000000000000000000010000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
Writing to storage: [IABTCF_VendorLegitimateInterests] 100000000111101100001011101100010101101101001000010100001011001000011110000101011100100000101100110000010000100000000010000101000101000110110100001000000001000010100000000010000000000000000001001000000100000010010000000000000001000000000000101001000000100000000001000000001010010000010000000001000000000000010010001010000000000000001000000000000000000000000000000000000000100000001001000000000100100000000000000000100000000000000010000000000000000000010000000000000101000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000100000100000000000000000000000000000000000010000000000000000000000000000000000000000000000000000001000000000100000000000000000000000000000000000100000000000000000000000000000010000000000000000000010001001000010000100000000000000100000100000000000001000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
Writing to storage: [IABTCF_PurposeConsents] 11111111111
Writing to storage: [IABTCF_PurposeLegitimateInterests] 01000011111
Writing to storage: [IABTCF_SpecialFeaturesOptIns] 1
Writing to storage: [IABTCF_TCString] CP3f0kAP3f0kAEsACBENAgEoAP_gAEPgABSIINJD7D7FbSFCwHp3aLsEMAhHRtCAQoQgAASBAmABQAKQIBQCgkAQFAygBCACAAAAICZBIQAECAAAAUAAQAAAAAEEAAAAAAAIIAAAgAEAAAAIAAACAIAAEAAIAAAAEAAAmAgAAIIACAAAhAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAQQaQD2F2K2kKFkPCuQWYIQBCijaEAhQBAAAkCBIAAgAUgQAgFIIAgAJFAAEAAAAAAQEgCQAAQABAAAIACgAAAAAAIAAAAAAAQQAAAAAIAAAAAAAAEAQAAAAAQAAAAIAABEhCAAQQAEAAAAAAAQAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAgAA
Writing to storage: [IABTCF_AddtlConsent] 1~2072.70.89.93.108.122.149.196.2253.2299.259.2328.2331.2357.311.313.317.323.2373.338.358.2415.385.415.449.2506.2526.482.486.494.495.2567.2568.2571.2572.2575.540.574.2624.609.2677.2710.2878.2898.864.981.1029.1048.1051.3100.1067.1095.1097.3234.1201.1205.1211.1276.1301.1329.1344.1365.1415.1449.1451.1516.1570.1577.1598.1616.1651.1716.1735.1753.1765.1782.1870.1878.1889.1917.1958.1960.1985
Writing to storage: [IABTCF_UserConsentRecordId] 5FE66506-7666-4CFA-8137-97D3803FA8D3
]]
-------------------------------------
ConsentPlatform = class({
})

---@type ConsentPlatform
local instance = nil

-------------------------------------
---@function getInstance
---@return ConsentPlatform
-------------------------------------
function ConsentPlatform.getInstance()
    if instance == nil then
        instance = ConsentPlatform()
    end
    return instance
end

-------------------------------------
---@function init
---@private
-------------------------------------
function ConsentPlatform:init()
end

-------------------------------------
---@function requestConsentForm
---동의서 관련 정보를 갱신하고 필요한 경우 (동의도 비동의도 받지 않은 상태) 동의 UI를 출력한다.  
---참고로 권한은 로컬에 저장하기 때문에 
---Ex. Android : sharedPreference에 저장  
---@param on_success fun()
---@param on_fail fun(info: string)
-------------------------------------
function ConsentPlatform:requestConsentForm(on_success, on_fail)
    PerpleSDK:cmpLoadConsentIfNeeded(function(ret, info)        
        if (ret == 'success') then
            SafeFuncCall(on_success)
        else
            SafeFuncCall(on_fail, info)
        end
    end)
end

-------------------------------------
---@function requestPrivacyOptionForm
---개인 정보 세부 설정 요청
---별다른 건 없고 requestConsentForm와 동일한 동의 UI를 출력한다.
---@param on_success fun()
---@param on_fail fun(info: string)
-------------------------------------
function ConsentPlatform:requestPrivacyOptionForm(on_success, on_fail)
    -- privacy option 설정이 가능한지 확인
    -- 미리 체크하지 않아도 불가능하면 cmpPresentPrivacyOptionForm 호출 시 실패처리 된다.
    if (self:requirePrivacyOption() == false) then
        SafeFuncCall(on_fail, 'not require privacy option.')
    end

    PerpleSDK:cmpPresentPrivacyOptionForm(function(ret, info)
        if (ret == 'success') then
            SafeFuncCall(on_success)
        else
            SafeFuncCall(on_fail, info)
        end
    end)
end

-------------------------------------
---@function canRequestAds
---광고 호출 가능 여부  
---requestConsentForm가 호출되면 true를 반환한다.
---@return boolean
-------------------------------------
function ConsentPlatform:canRequestAds()
    local ret = PerpleSDK:cmpCanRequestAds()
    return ret
end

-------------------------------------
---@function requirePrivacyOption
---개인 정보 세부 설정을 수정할 수 있는지 여부
---@return boolean
-------------------------------------
function ConsentPlatform:requirePrivacyOption()
    local ret = PerpleSDK:cmpRequirePrivacyOption()
    return ret
end