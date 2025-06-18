#!/bin/bash

# 定义要测试的程序
programs=("./target/mycat2" "./target/mycat3" "./target/mycat4" "./target/mycat5" "./target/mycat6")
test_file="test.txt"

# 拼接带参数的命令
commands=()
for prog in "${programs[@]}"; do
    commands+=("$prog $test_file")
done

# 运行 hyperfine 并保存输出
echo "Running hyperfine benchmarks..."
hyperfine --warmup 1 --min-runs 3 "${commands[@]}" --export-json hyperfine_results.json

# 从 JSON 中提取数据（推荐 Python）
echo "Extracting results..."
python3 - <<EOF
import json

with open("hyperfine_results.json") as f:
    data = json.load(f)

with open("hyperfine_results.txt", "w") as out:
    for entry in data["results"]:
        name = entry["command"].split()[0].split("/")[-1]
        mean = entry["mean"] * 1000  # seconds to ms
        out.write(f"{name},{mean:.3f} ms\n")
EOF

echo "Results saved to hyperfine_results.txt and hyperfine_results.json"
