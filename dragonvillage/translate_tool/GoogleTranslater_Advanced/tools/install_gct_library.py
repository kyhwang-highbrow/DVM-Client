
def install_if_no_exist(package):
    try:
        return __import__(package)
    except ImportError:
        print('# INSTALL DEPENDENCY MODULE :', package)
        try:
            from pip import main as pipmain
        except:
            from pip._internal.main import main as pipmain

        pipmain(['install', package])


# 만약 라이브러리 없다면 설치함
install_if_no_exist('google-cloud-translate')
