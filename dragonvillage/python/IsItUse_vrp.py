# PNG 파일마다 사용된 UI, LUA, CSV 이름을 찾아줌
# UI, LUA, CSV 파일 이름은 전부 유니크하다고 가정.

import os
import re
import csv
import sys

RES_ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "res")
LUA_ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "src")
CSV_ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "data")

EXCEPT_DIR = ["a2d", "bg"]  # 탐색에서 제외할 디렉토리 이름
MAKE_CSV_NAME = "result/USED_AT_png.csv"


# brief : UI 파일 하나 안에서 사용된 PNG 파일을 찾음
def find_used_UI(file_path):
    used_name_list = []

    # 정규식으로 사용된 ui 이름들 찾음
    with open(file_path, "r", encoding="utf-8") as f:
        all_data = f.read()
        reg_find_case = re.compile(r"file_name = '(.+?)'")
        find_datas = reg_find_case.findall(all_data)
        for find_data in find_datas:
            used_name_list.append(find_data)
    return used_name_list


# brief : LUA 파일 하나 안에서 사용된 PNG 파일을 찾음
def find_used_LUA(file_path):
    used_name_list = []

    # 정규식으로 사용된 ui 이름들 찾음
    with open(file_path, "r", encoding="utf-8") as f:
        all_data = f.read()
        reg_find_case_1 = re.compile(r"\'(.*\.png?)\'")
        reg_find_case_2 = re.compile(r"\"(.*\.png?)\"")
        find_datas = reg_find_case_1.findall(all_data)
        find_datas.extend(reg_find_case_2.findall(all_data))

        for find_data in find_datas:
            used_name_list.append(find_data)
    return used_name_list


# brief : CSV 파일 하나 안에서 사용된 PNG 파일을 찾음
def find_used_CSV(file_path):
    used_name_list = []

    reg_check = re.compile(r".*\.png")

    # 정규식으로 사용된 ui 이름들 찾음
    with open(file_path, "r", encoding="utf-8") as f:
        csv_file = csv.reader(f)
        csv_data = []
        for line in csv_file:
            csv_data.append(line)
        header_data, body_data = csv_data[0], csv_data[1:]

        for i, header in enumerate(header_data):
            for body in body_data:
                data = body[i]
                if reg_check.search(data):  # png 파일 이름이 포함되어 있다면
                    used_name_list.append(data)
    return used_name_list


# brief : 파일 경로를 돌면서 PNG 파일들 사용된 거 기록
def get_used_point(root, png_list, find_ext, find_func):
    png_dic = make_list_to_dic(png_list)

    file_name_list = os.listdir(root)
    for file_name in file_name_list:
        full_file_name = os.path.join(root, file_name)

        if os.path.isdir(full_file_name):
            # 하위 폴더에 재귀
            sub_png_dic = get_used_point(full_file_name, png_list, find_ext, find_func)

            # 합산
            for png in sub_png_dic:
                sub_list = sub_png_dic[png]
                for used_at in sub_list:
                    png_dic[png].append(used_at)

        else:
            ext = os.path.splitext(full_file_name)[-1]
            if ext == find_ext:
                used_png_list = find_func(full_file_name)
                for used_png in used_png_list:
                    if used_png in png_dic:
                        png_dic[used_png].append(file_name)
                    else:
                        png_name = os.path.basename(used_png)
                        for png_path in png_list:
                            if png_path.find(png_name) >= 0:
                                png_dic[png_path].append(file_name)
                                break

    return png_dic


# brief : PNG 파일 경로 리스트 반환
def get_png_file_list(root):
    png_list = []

    file_name_list = os.listdir(root)
    for file_name in file_name_list:
        full_file_name = os.path.join(root, file_name)

        if os.path.isdir(full_file_name):
            if EXCEPT_DIR.count(file_name) == 0:
                sub_png_list = get_png_file_list(full_file_name)
                for png_name in sub_png_list:
                    if png_list.count(png_name) == 0:
                        png_list.append(png_name)

        else:
            ext = os.path.splitext(full_file_name)[-1]
            if ext == ".png":
                png_res = "res" + full_file_name[len(RES_ROOT) :].replace(
                    "\\", "/"
                )  # res/XXX/YYY.png 꼴로 저장
                png_list.append(png_res)

    return png_list


# breif : file name list를 dic(key: filename, value : list of used file)으로 바꿔줌
def make_list_to_dic(name_list):
    data_dic = {}
    for name in name_list:
        data_dic[name] = []  # 해당 파일이 사용된 파일들의 이름 리스트가 생길 것
    return data_dic


# breif : file name list를 dic(key: filename, value : list of used file)으로 바꿔줌
def make_dic_to_list(name_dic):
    data_list = []
    for name in name_dic:
        data = []
        data.append(name)
        if len(name_dic[name]) > 0:
            str = ", ".join(name_dic[name])
            data.append(str)
        else:
            data.append("사용 중인 곳이 없습니다.")

        data_list.append(data)
    return data_list


# brief : csv 생성에 쓰일 헤더 생성
def make_header():
    return ["name", "used_at"]


def make_csv(data_list):
    header = make_header()
    # 폴더가 없을시 생성
    if os.path.exists("./result") == False:
        os.mkdir("./result")

    # 정규식으로 사용된 ui 이름들 찾음
    with open(MAKE_CSV_NAME, "w", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(header)
        for data in data_list:
            w.writerow(data)


def main():
    print("# Is it Use? .png files")

    # PNG 파일 이름 리스트 얻음
    png_name_list = get_png_file_list(RES_ROOT)

    png_dic = make_list_to_dic(png_name_list)

    # UI에서 사용된 데이터 받기
    ui_dic = get_used_point(RES_ROOT, png_name_list, ".ui", find_used_UI)

    # LUA에서 사용된 데이터 받기
    lua_dic = get_used_point(LUA_ROOT, png_name_list, ".lua", find_used_LUA)

    # CSV에서 사용된 데이터 받기
    csv_dic = get_used_point(CSV_ROOT, png_name_list, ".csv", find_used_CSV)

    # 합산
    for png in png_dic:
        used_ui_list = ui_dic[png]
        for ui_name in used_ui_list:
            png_dic[png].append(ui_name)

        used_lua_list = lua_dic[png]
        for lua_name in used_lua_list:
            png_dic[png].append(lua_name)

        used_csv_list = csv_dic[png]
        for csv_name in used_csv_list:
            png_dic[png].append(csv_name)

    # 다시 리스트로 변환 후 CSV 생성하기
    data_list = make_dic_to_list(png_dic)
    make_csv(data_list)

    print("# FINISH :", MAKE_CSV_NAME)

    os.system("pause")


if __name__ == "__main__":
    main()
