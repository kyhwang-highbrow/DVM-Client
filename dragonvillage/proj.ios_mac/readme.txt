<CocoaPods 설치>
Mac에 CocoaPods 가 설치되어 있지 않다면 아래 가이드에 따라 CocoaPods 을 먼저 설치할 것.

1. Homebrew 설치

    $ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

2. Ruby 설치

    $ brew install ruby

3. ruby gem 업데이트

    $ sudo gem update --system

4. CocoaPods 설치

    $ sudo gem install cocoapods
    $ pod setup

<프로젝트 pod 업데이트>
- 아래 명령어를 실행하여 pod 업데이트를 먼저 실행.

    $ pod update
    
<프로젝트 파일>
- DragonVillageM.xcodeproj 를 직접 열지 말고, DragonVillageM.xcworkspace 를 열어서 빌드할 것.