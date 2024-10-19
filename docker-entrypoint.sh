#!/bin/bash

# 克隆仓库
# set -x  # 开启调试模式
set -e
targetBranch=$1
if [ -n "$REPO_BRANCH" ]; then
    targetBranch="$REPO_BRANCH"
fi
if [ -z "$targetBranch" ]; then
    targetBranch="main"
fi
mkdir -p /root/.ssh
echo -e "$KEY" >/root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa

cloneRepo() {
    repoName=$1
    repoUrl=$2
    branchName=$3
    if [ ! -d "/${repoName}/.git" ]; then
        echo "未检查到${repoName}仓库，拉取中..."
        git clone "${repoUrl}" /"${repoName}"
        git -C "/${repoName}" fetch --all
        git -C "/${repoName}" checkout "${branchName}"
        cd "/${repoName}"  # 切换到仓库目录
        return 0
    else
        echo "更新${repoName}仓库..."
        git -C "/${repoName}" fetch --all
        git -C "/${repoName}" checkout "${branchName}"
        git -C "/${repoName}" reset --hard origin/"${branchName}"
        git -C "/${repoName}" pull origin "${branchName}" --rebase
        cd "/${repoName}"  # 切换到仓库目录
        return 0
    fi
}

# timezone
ln -sf /usr/share/zoneinfo/${TZ:-"Asia/Shanghai"} /etc/localtime
echo ${TZ:-"Asia/Shanghai"} > /etc/timezone

# create gateway
\cp -rf /gateway.js /surgio/

# config
ssh-keyscan "$REPO_DOMAIN" >/root/.ssh/known_hosts
cloneRepo surgio_repo "$REPO_URL" "$targetBranch"
rm -rf /surgio/provider/* /surgio/template/*
\cp -rf /surgio_repo/app/* /surgio/

# custom config
if [ -f /surgio/package.json ];then
    sed -i '/"scripts": {/a "generage": "surgio generate",' /surgio/package.json
fi

# generate rules and run gateway
cd /surgio
npm run generage && node gateway.js