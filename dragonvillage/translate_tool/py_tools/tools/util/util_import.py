import importlib

def install_and_import(package):
    try:
        importlib.import_module(package)
    except ImportError:
        print('INSTALL DEPENDENCY MODULE :', package)
        try:
            from pip import main as pipmain
        except:
            from pip._internal.main import main as pipmain
        pipmain(['install', package])
    finally:
        globals()[package] = importlib.import_module(package)


def install_if_no_exist(package):
    try:
        importlib.import_module(package)
    except ImportError:
        print('INSTALL DEPENDENCY MODULE :', package)
        try:
            from pip import main as pipmain
        except:
            from pip._internal.main import main as pipmain
        pipmain(['install', package])