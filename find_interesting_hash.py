#!/usr/bin/env python3
"""
面白いコミットハッシュを見つけるまでコミットを繰り返すスクリプト
"""
import subprocess
import re
import sys
from datetime import datetime

def check_interesting_pattern(hash_str):
    """
    コミットハッシュに面白いパターンがあるかチェック
    """
    patterns = []

    # 同じ文字が4つ以上連続
    if re.search(r'(.)\1{3,}', hash_str):
        match = re.search(r'(.)\1{3,}', hash_str)
        patterns.append(f"同じ文字の連続: {match.group()}")

    # 連番（昇順）3文字以上
    for i in range(len(hash_str) - 2):
        substr = hash_str[i:i+3]
        if len(substr) == 3:
            chars = [ord(c) for c in substr]
            if chars[1] == chars[0] + 1 and chars[2] == chars[1] + 1:
                patterns.append(f"連番（昇順）: {substr}")
                break

    # 連番（降順）3文字以上
    for i in range(len(hash_str) - 2):
        substr = hash_str[i:i+3]
        if len(substr) == 3:
            chars = [ord(c) for c in substr]
            if chars[1] == chars[0] - 1 and chars[2] == chars[1] - 1:
                patterns.append(f"連番（降順）: {substr}")
                break

    # 回文パターン（5文字以上）
    for i in range(len(hash_str) - 4):
        for length in range(5, min(8, len(hash_str) - i + 1)):
            substr = hash_str[i:i+length]
            if substr == substr[::-1]:
                patterns.append(f"回文: {substr}")
                break

    # ぞろ目（先頭6文字が全て同じ）
    if len(set(hash_str[:6])) == 1:
        patterns.append(f"先頭6文字ぞろ目: {hash_str[:6]}")

    # 特定の単語っぽいパターン
    interesting_words = ['dead', 'beef', 'cafe', 'babe', 'face', 'fade', 'deed', 'feed']
    for word in interesting_words:
        if word in hash_str:
            patterns.append(f"単語パターン: {word}")

    return patterns

def create_commit(counter):
    """
    新しいコミットを作成
    """
    # ファイルに現在のカウンターを書き込む
    with open('counter.txt', 'w') as f:
        f.write(f"{counter}\n")
        f.write(f"Generated at: {datetime.now()}\n")

    # git add
    subprocess.run(['git', 'add', 'counter.txt'], check=True, capture_output=True)

    # git commit
    result = subprocess.run(
        ['git', 'commit', '-m', f'Attempt #{counter}'],
        check=True,
        capture_output=True,
        text=True
    )

    # 最新のコミットハッシュを取得
    hash_result = subprocess.run(
        ['git', 'rev-parse', 'HEAD'],
        check=True,
        capture_output=True,
        text=True
    )

    return hash_result.stdout.strip()

def main():
    counter = 0
    print("面白いコミットハッシュを探索中...")
    print("=" * 60)

    try:
        while True:
            counter += 1

            # コミットを作成
            commit_hash = create_commit(counter)

            # パターンをチェック
            patterns = check_interesting_pattern(commit_hash)

            # 進捗表示（100回ごと）
            if counter % 100 == 0:
                print(f"試行回数: {counter}, 最新ハッシュ: {commit_hash[:12]}...")

            # 面白いパターンが見つかったら報告
            if patterns:
                print("\n" + "=" * 60)
                print(f"🎉 面白いハッシュを発見！")
                print(f"試行回数: {counter}")
                print(f"コミットハッシュ: {commit_hash}")
                print(f"パターン:")
                for pattern in patterns:
                    print(f"  - {pattern}")
                print("=" * 60)

                # より強いパターンなら終了（複数パターンまたは5文字以上の連続）
                if len(patterns) >= 2 or any('5' in p or '6' in p or 'ぞろ目' in p for p in patterns):
                    print("\n非常に面白いパターンが見つかったので終了します！")
                    break

    except KeyboardInterrupt:
        print(f"\n\n中断されました。試行回数: {counter}")
        sys.exit(0)

if __name__ == '__main__':
    main()
