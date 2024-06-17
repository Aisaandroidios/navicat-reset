#!/bin/bash

set -e  # 如果某个命令以非零状态退出，则立即退出脚本。

# 读取 Navicat Premium 的 Info.plist 文件
file=$(defaults read /Applications/Navicat\ Premium.app/Contents/Info.plist)

# 使用正则表达式提取版本号
regex="CFBundleShortVersionString = \"([^\.]+)"
if [[ $file =~ $regex ]]; then
    version=${BASH_REMATCH[1]}
else
    echo "无法检测到 Navicat Premium 版本"
    exit 1
fi

echo "检测到 Navicat Premium 版本 $version"

# 根据版本确定相应的首选项文件
case $version in
    "17"|"16")
        pref_file=~/Library/Preferences/com.navicat.NavicatPremium.plist
        ;;
    "15")
        pref_file=~/Library/Preferences/com.prect.NavicatPremium15.plist
        ;;
    *)
        echo "不支持版本 '$version'"
        exit 1
        ;;
esac

echo "重置试用期时间..."

# 从首选项文件中提取哈希值
hash_regex="([0-9A-Z]{32}) = "
if [[ $(defaults read $pref_file) =~ $hash_regex ]]; then
    hash=${BASH_REMATCH[1]}
    echo "从 $pref_file 删除 $hash 数组..."
    defaults delete $pref_file $hash
else
    echo "在 $pref_file 中未找到哈希值"
fi

# 从支持目录中提取隐藏文件夹哈希值
support_dir=~/Library/Application\ Support/PremiumSoft\ CyberTech/Navicat\ CC/Navicat\ Premium/
folder_regex="\.([0-9A-Z]{32})"
if [[ $(ls -a "$support_dir" | grep '^\.') =~ $folder_regex ]]; then
    hash2=${BASH_REMATCH[1]}
    echo "从 $support_dir 删除 .$hash2 文件夹..."
    rm -rf "$support_dir.$hash2"
else
    echo "在 $support_dir 中未找到隐藏哈希文件夹"
fi

echo "完成"
