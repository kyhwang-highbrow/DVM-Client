#############################################################################
## 각종 병합 함수와 func 비교후 매핑해주는 코드입니다.
#############################################################################


from tools.merge.merge_DVM_plain_text import merge_DVM_plain_text
from tools.merge.merge_DVM_scenario_text import merge_DVM_scenario_text

merge_func = {}
merge_func['merge_DVM_plain_text'] = merge_DVM_plain_text
merge_func['merge_DVM_scenario_text'] = merge_DVM_scenario_text


def merge(func_name, spreadsheet_id, delta_sheet_name, backup_sheet_name, locale_list):
    return merge_func[func_name](spreadsheet_id, delta_sheet_name, backup_sheet_name, locale_list)
