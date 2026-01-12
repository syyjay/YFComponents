#!/bin/bash

# YFComponents 发布脚本
# 功能：自动修改 source_files 路径后推送到 Specs 仓库

set -e

# 配置
SPECS_REPO="YFSpecs"
VERSION="1.1.0"

# 临时目录
TMP_DIR=$(mktemp -d)
echo "临时目录: $TMP_DIR"

# 组件列表
PODS=("YFLogger" "YFExtensions" "YFStorage" "YFRouter" "YFNetwork" "YFUIKit" "YFMedia" "YFWebView")

# 处理每个组件
for POD in "${PODS[@]}"; do
    echo "处理 $POD..."

    # 复制 podspec 到临时目录
    cp "$POD/$POD.podspec" "$TMP_DIR/"

    # 修改 source_files 路径（添加组件名前缀）
    if [ "$POD" == "YFExtensions" ]; then
        # YFExtensions 有 subspecs，需要特殊处理
        sed -i '' "s|ss.source_files = 'Classes/|ss.source_files = 'YFExtensions/Classes/|g" "$TMP_DIR/$POD.podspec"
    elif [ "$POD" == "YFUIKit" ]; then
        # YFUIKit 有 resource_bundles
        sed -i '' "s|s.source_files = 'Classes/|s.source_files = 'YFUIKit/Classes/|g" "$TMP_DIR/$POD.podspec"
        sed -i '' "s|'YFUIKit' => \['Assets/|'YFUIKit' => ['YFUIKit/Assets/|g" "$TMP_DIR/$POD.podspec"
    else
        # 普通组件
        sed -i '' "s|s.source_files = 'Classes/|s.source_files = '$POD/Classes/|g" "$TMP_DIR/$POD.podspec"
    fi

    # 复制到 Specs 仓库
    mkdir -p ~/.cocoapods/repos/$SPECS_REPO/$POD/$VERSION
    cp "$TMP_DIR/$POD.podspec" ~/.cocoapods/repos/$SPECS_REPO/$POD/$VERSION/
done

# 提交并推送 Specs 仓库
cd ~/.cocoapods/repos/$SPECS_REPO
git add .
git commit -m "Release YFComponents $VERSION"
git push

# 清理临时目录
rm -rf "$TMP_DIR"

echo "发布完成！"
