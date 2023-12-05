#############################################################################
## 각종 데이터 합치는 함수와 func 비교후 매핑해주는 코드입니다.
#############################################################################


from tools.sum_data.sum_DVM_plain_text import sum_DVM_plain_text
from tools.sum_data.sum_DVM_scenario_text import sum_DVM_scenario_text

sum_data_func = {}
sum_data_func['sum_DVM_plain_text'] = sum_DVM_plain_text
sum_data_func['sum_DVM_scenario_text'] = sum_DVM_scenario_text


def sum_data(func_name, all_data_list, all_data_dic, add_data, locale_list, date_str):
    return sum_data_func[func_name](all_data_list, all_data_dic, add_data, locale_list, date_str)
