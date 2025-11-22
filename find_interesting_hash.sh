#!/bin/bash
# 面白いコミットハッシュを見つけるまでコミットを繰り返すスクリプト

check_interesting_pattern() {
    local hash="$1"
    local found=0
    local patterns=""

    # 同じ文字が5つ以上連続 - これが見つかったら終了！
    if echo "$hash" | grep -qE '(.)\1{4,}'; then
        local match=$(echo "$hash" | grep -oE '(.)\1{4,}' | head -1)
        patterns="${patterns}  - 同じ文字の連続（${#match}文字）: ${match}\n"
        found=2  # 終了条件
    fi

    # 16進数連番チェック（昇順）- 境界をまたぐパターンも含む
    if echo "$hash" | grep -qE '(012|123|234|345|456|567|678|789|89a|9ab|abc|bcd|cde|def|ef0|f01)'; then
        local match=$(echo "$hash" | grep -oE '(012|123|234|345|456|567|678|789|89a|9ab|abc|bcd|cde|def|ef0|f01)' | head -1)
        patterns="${patterns}  - 16進数連番: ${match}\n"
        if [ $found -lt 1 ]; then
            found=1
        fi
    fi

    # 16進数逆連番チェック（降順）- 境界をまたぐパターンも含む
    if echo "$hash" | grep -qE '(987|876|765|654|543|432|321|210|10f|0fe|fed|edc|dcb|cba|ba9|a98)'; then
        local match=$(echo "$hash" | grep -oE '(987|876|765|654|543|432|321|210|10f|0fe|fed|edc|dcb|cba|ba9|a98)' | head -1)
        patterns="${patterns}  - 16進数逆連番: ${match}\n"
        if [ $found -lt 1 ]; then
            found=1
        fi
    fi

    # 特定の単語パターン
    if echo "$hash" | grep -qE '(dead|beef|cafe|babe|face|fade|deed|feed|bad|dad|fab)'; then
        local match=$(echo "$hash" | grep -oE '(dead|beef|cafe|babe|face|fade|deed|feed|bad|dad|fab)' | head -1)
        patterns="${patterns}  - 単語パターン: ${match}\n"
        if [ $found -lt 1 ]; then
            found=1
        fi
    fi

    # 結果を返す
    if [ $found -gt 0 ]; then
        echo -e "$patterns"
        return $found
    fi
    return 0
}

counter=0
max_attempts=10000
echo "面白いコミットハッシュを探索中（上限: ${max_attempts}回）..."
echo "============================================================"

while [ $counter -lt $max_attempts ]; do
    ((counter++))

    # カウンターファイルを更新
    echo "$counter" > counter.txt
    echo "Generated at: $(date)" >> counter.txt

    # コミット作成
    git add counter.txt >/dev/null 2>&1
    git commit -m "Attempt #${counter}" >/dev/null 2>&1

    # 最新のコミットハッシュを取得
    commit_hash=$(git rev-parse HEAD)

    # パターンチェック
    patterns=$(check_interesting_pattern "$commit_hash")
    pattern_strength=$?

    # 進捗表示（100回ごと）
    if [ $((counter % 100)) -eq 0 ]; then
        echo "試行回数: ${counter}, 最新ハッシュ: ${commit_hash:0:12}..."
    fi

    # 面白いパターンが見つかったら報告
    if [ $pattern_strength -gt 0 ]; then
        echo ""
        echo "============================================================"
        echo "🎉 面白いハッシュを発見！"
        echo "試行回数: ${counter}"
        echo "コミットハッシュ: ${commit_hash}"
        echo "パターン:"
        echo -e "$patterns"
        echo "============================================================"

        # より強いパターンなら終了
        if [ $pattern_strength -ge 2 ]; then
            echo ""
            echo "非常に面白いパターンが見つかったので終了します！"
            break
        fi
    fi
done

# 上限に達した場合のメッセージ
if [ $counter -ge $max_attempts ]; then
    echo ""
    echo "============================================================"
    echo "上限（${max_attempts}回）に達しました。"
    echo "5文字以上の連続は見つかりませんでしたが、他の面白いパターンはありました！"
    echo "============================================================"
fi
