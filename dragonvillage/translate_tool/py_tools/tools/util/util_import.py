import importlib

def install_and_import(package):
    try:
        importlib.import_module(package)
    except ImportError:
        import pip
        print('INSTALL DEPENDENCY MODULE :', package)
        pip.main(['install', package])
    finally:
        globals()[package] = importlib.import_module(package)


def install_if_no_exist(package):
    try:
        importlib.import_module(package)
    except ImportError:
        import pip
        print('INSTALL DEPENDENCY MODULE :', package)
        pip.main(['install', package])