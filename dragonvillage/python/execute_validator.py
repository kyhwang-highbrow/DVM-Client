import subprocess
import os

if __name__ == '__main__':
    print('----------------------------------------')

    # os.chdir("../bat")
    # result = os.system('0_PATCH_VALIDATOR.bat')
    
    # if result == 101:
    #     print('이리로 들어오나??')
    #     exit(-1)

    # os.chdir("../python")
    
    os.system('py xor.py')
    os.system('py xor_data.py')

    print('----------------------------------------')