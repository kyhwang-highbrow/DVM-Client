#############################################################################
## 시나리오 파일 간 정렬을 위한 비교 코드입니다.
#############################################################################


def cmp_scenario(x, y):
    if ('scen_' in x[0] and 'event' not in x[0]) and ('scen_' in y[0] and 'event' not in y[0]):
        x_list = x[0].split('_')
        y_list = y[0].split('_')

        if int(x_list[1]) < int(y_list[1]): 
            return -1
        if int(x_list[1]) > int(y_list[1]):
            return 1
        
        if int(x_list[2]) < int(y_list[2]):
            return -1
        if int(x_list[2]) > int(y_list[2]):
            return 1

        if x_list[3] > y_list[3]:
            return -1
        if x_list[3] < y_list[3]:
            return 1

    else:
        if x[0] < y[0]:
            return -1
        if x[0] > y[0]:
            return 1

    if int(x[1]) < int(y[1]):
        return -1
    if int(x[1]) > int(y[1]):
        return 1
    
    return 0