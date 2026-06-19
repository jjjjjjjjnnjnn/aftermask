# MML Runtime — 游戏 AI 运行时

MML Runtime 的实验目录。完整的可行性验证报告在外部独立目录：
[`C:\Users\rongj\Desktop\mml-runtime\docs\mml_runtime_feasibility.md`](../../../../mml-runtime/docs/mml_runtime_feasibility.md)

## 当前基线数据摘要

| 指标 | 值 |
|------|------|
| **模型** | Qwen2.5-0.5B (GGUF Q4_K_M) |
| **体积** | 463 MB |
| **推理速度** | 118 tok/s (CPU, 16线程) |
| **LoRA 适配器** | 8.3 MB / 个 |
| **推理方式** | llama.cpp 直接调用，无中间层 |

## 目录结构

```
ai-runtime/
├── models/        ← GGUF 模型文件
├── scripts/       ← 实验脚本
├── adapters/      ← LoRA 适配器
└── docs/          ← 设计文档
```

## 状态

- 2026-06-19: 基线验证完成 ✅ — 见外部可行性报告
