#!/bin/bash

BOLD='\033[1m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
MAGENTA='\033[35m'
NC='\033[0m'


# Install KOREAN
# Function check if Korean
check_korean_support() {
    if locale -a | grep -q "ko_KR.utf8"; then
        return 0  # Korean support is installed
    else
        return 1  # Korean support is not installed
    fi
}

# Install KOREAN if not 
if check_korean_support; then
    echo -e "${CYAN}한글있긔 설치넘기긔.${NC}"
else
    echo -e "${CYAN}한글없긔, 설치하겠긔.${NC}"
    sudo apt-get install language-pack-ko -y
    sudo locale-gen ko_KR.UTF-8
    sudo update-locale LANG=ko_KR.UTF-8 LC_MESSAGES=POSIX
    echo -e "${CYAN}설치 완료했긔.${NC}"
fi

remove_and_reinstall_docker() {
echo -e "${RED}도커 삭제 및 관련 패키지 삭제 중...${NC}"
# 켜져있는 도커 종료하기
docker rm -f $(docker ps -qa)

# 도커 관련 패키지 삭제하기
sudo apt-get purge docker-ce docker-ce-cli containerd.io
sudo apt-get purge -y docker-engine docker docker.io docker-ce docker-ce-cli
sudo apt-get autoremove -y --purge docker-engine docker docker.io docker-ce

# 남아있는 파일들 삭제하기
sudo groupdel docker
sudo rm -rf /var/lib/docker
sudo rm -rf /var/run/docker.sock
sudo rm -rf ~/.docker
sudo rm -rf /etc/docker
sudo rm -rf /usr/local/bin/docker-compose
sudo rm -rf /var/lib/docker /etc/docker

echo -e "${CYAN}도커가 말끔하게 제거되었습니다."

echo -ne "${MAGENTA}도커를 다시 설치하고 싶으신가요? [y/n]${NC} :"
read -p response
if [[ "$response" =~ ^[yY]$ ]]; then
    echo -e "${BOLD}${CYAN}도커 재설치 중...${NC}"
	curl -fsSL https://get.docker.com -o get-docker.sh
	sudo sh get-docker.sh
	sudo curl -L https://github.com/docker/compose/releases/download/$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | jq .name -r)/docker-compose-$(uname -s)-$(uname -m) -o /usr/bin/docker-compose
	sudo chmod 755 /usr/bin/docker-compose

else
	echo -e "${MAGENTA}스크립트를 종료합니다${NC}"
	exit 1
fi
echo -e "${BOLD}${YELLOW}도커 삭제 및 재설치가 완료됐습니다.${NC}"
}
remove_and_reinstall_golang() {

# Golang 제거하기
echo -e "${CYAN}Go 언어 제거하기${NC}"
sudo apt-get purge golang-go -y
sudo rm -rf /usr/local/go

echo -e "${CYAN}GOPATH 환경 변수가 설정된 경우 제거${NC}"
if [ -d "$GOPATH" ]; then
    sudo rm -rf "$GOPATH"
fi

# 남아잇는 파일들 삭제하기
echo -e "${CYAN}~/bashrc 또는 ~/.profile에서 go 관련된 항목 제거 (수동으로 파일 열어서 제거할 수 있음)${NC}"
sed -i '/export GOROOT=\/usr\/local\/go/d' ~/.bashrc
sed -i '/export PATH=\$PATH:\$GOROOT\/bin/d' ~/.bashrc
sed -i '/export GOPATH=\$HOME\/go/d' ~/.bashrc
sed -i '/export PATH=\$PATH:\$GOPATH\/bin/d' ~/.bashrc

echo -e "${CYAN}설정 파일 다시 적용${NC}"
source ~/.bashrc
source ~/.profile

echo -e "${CYAN}golang이 말끔하게 제거되었습니다."
go version

echo -ne "${MAGENTA}golang을 다시 설치하고 싶으신가요? [y/n]${NC} :"
read -p response
if [[ "$response" =~ ^[yY]$ ]]; then
	# updating go
	echo -e "${CYAN}installing golang...${NC}"
	sudo apt remove golang-go -y
	sudo apt autoremove -y
	wget https://go.dev/dl/go1.23.1.linux-amd64.tar.gz
	sudo rm -rf /usr/local/go
	sudo tar -C /usr/local -xzf go1.23.1.linux-amd64.tar.gz
	rm go1.23.1.linux-amd64.tar.gz
	export PATH=$PATH:/usr/local/go/bin
	echo -e "${CYAN}source $HOME/.bash_profile${NC}"
	source $HOME/.bash_profile
	echo -e "${CYAN}source $HOME/.bashrc${NC}"
	source $HOME/.bashrc
	echo -e "${CYAN}go version${NC}"
	go version
else
	echo -e "${MAGENTA}스크립트를 종료합니다${NC}"
	exit 1
fi
echo -e "${BOLD}${YELLOW}golang 삭제 및 재설치가 완료됐습니다.${NC}"
}

optimize_vps() {
# 시스템 청소 및 불필요한 패키지 제거
echo -e "${CYAN}불필요한 패키지 및 캐시 제거 중...${NC}"
sudo apt autoremove -y
rm /root/*.deb
apt-get clean
sudo rm -rf /tmp/*
rm -rf ~/.cache/*
sudo rm -f /root/*.sh /root/*.rz

# APT 캐시 및 백업 데이터 정리
echo -e "${CYAN}APT 캐시 및 백업 데이터 정리 중...${NC}"
sudo apt-get autoclean
sudo rm -rf /var/cache/apt/archives/* /var/backups/*
sudo rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin

# 오래된 로그 파일 삭제
echo -e "${CYAN}오래된 로그 파일 삭제 중...${NC}"
sudo find /var/log -type f -name "*.log" -exec rm -f {} \;
sudo journalctl --vacuum-time=7d  # 7일 이전의 journal 로그 삭제

# 메모리 스왑 청소 (사용하지 않은 메모리를 해제)
echo -e "${CYAN}메모리 스왑 청소 중...${NC}"
sudo swapoff -a && sudo swapon -a

# Docker 관련 정리 작업
echo -e "${CYAN}Docker 관련 정리 작업을 실행 중...${NC}"
docker container prune -f  # 중지된 모든 컨테이너 제거
docker image prune -a -f   # 사용하지 않는 모든 이미지 제거
docker volume prune -f     # 사용하지 않는 모든 볼륨 제거
docker system prune -a -f  # 사용하지 않는 모든 데이터 정리

# 모든 파티션에서 디스크 사용량 최적화
echo -e "${CYAN}디스크 사용량 최적화 중...${NC}"
sudo fstrim -av

# 서버 업데이트
echo -e "${CYAN}서버 업데이트${NC}"
sudo apt update -y
sudo apt-get upgrade -y

echo -e "${BOLD}${CYAN}서버 최적화 완료${NC}"
}
# 메인 메뉴
echo && echo -e "${BOLD}${RED}서버에 사용 가능한 기본 명령어 모음집${NC} by 비욘세제발죽어
 ${CYAN}원하는 거 고르시고 실행하시고 그러세효. ${NC}
 ———————————————————————
 ${GREEN} 1. docker 삭제 및 재설치(원하는 경우에) ${NC}
 ${GREEN} 2. golnag 삭제 및 재설치 (원하는 경우에) ${NC}
 ${GREEN} 3. 서버 최적화(업데이트 & 불필요한 패키지 및 파일 삭제) ${NC}
 ———————————————————————" && echo

# 사용자 입력 대기
echo -ne "${BOLD}${MAGENTA}어떤 작업을 수행하고 싶으신가요? 위 항목을 참고해 숫자를 입력해 주세요: ${NC}"
read -e num

case "$num" in
1)
    remove_and_reinstall_docker
    ;;
2)
    remove_and_reinstall_golang
    ;;
3)
    optimize_vps
    ;;

*)
    echo -e "${BOLD}${RED}그럴 수도 있죠. 다시 실행해 보아요~${NC}"
    ;;
esac
