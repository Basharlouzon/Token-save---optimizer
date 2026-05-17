---
name: tokenso
description: Use when you want to minimize token waste, intelligently search files without overflowing the context, and refresh memory across agents (Claude Code, Cline, Roo, Antigravity) using Tokenso.
risk: low
source: local
---

# Tokenso — Context Optimizer & Token Saver

This skill is designed to prevent context window bloat, eliminate token waste, and stop agents from duplicating efforts or spinning in circles. 

As an AI agent, you must strictly follow these rules when this skill is active or when you are operating in a repository with `.ai-memory` initialized by Tokenso.

## 1. The Search Diet (Zero-Waste Searching)
- **Do not read full files blindly**: Before using tools to read an entire file, check its size or use targeted search.
- **Find first, read second**: ALWAYS use semantic search, `grep_search`, or lightweight bash commands (`rg -l`) to find the *names* of files first. 
- **Targeted viewing**: Once a file is identified, read *only the specific line ranges* you need. NEVER load a 2,000-line file into context just to read a single function. 

## 2. Smart Initialization
- **Use the Repo Map**: If you need to understand the project structure, do not run `ls -R` or `find`. Instead, execute `tokenso map` or run `bash scripts/init-smart-search.sh .`.
- **Read the Map**: This script generates an ultra-compressed tree structure at `.ai-memory/repo-map.txt`. Read this tiny file instead of manually exploring the workspace.

## 3. The Memory Refresh Protocol (Prevent Duplication & Looping)
- **Check State**: Before making any significant architectural decisions or writing new features, ALWAYS check if `.ai-memory/state.md` exists. If it does, read it (or run `tokenso state`). This is your core long-term memory.
- **Write State**: Upon completing a milestone, fixing a major bug, or taking multiple steps that bloat your context, you MUST compress your findings. Update `.ai-memory/state.md` (or use `tokenso save "[Custom Note]"`) with:
  - `[x]` Completed tasks
  - `[ ]` Next actions
  - `!` Key findings or architectural rules discovered.
- **Context Pruning**: After writing to `.ai-memory/state.md`, explicitly acknowledge in your thoughts that you are offloading previous raw context and only relying on the compressed memory. If you detect that you are repeating the same failed command or idea, **STOP**, update the memory state, and ask the user for clarification.

## 4. Cross-Agent Compatibility
- If requested by the user, you can inject these memory-saving rules into other agents' configurations (like Cline, Roo, or Claude Code) by running:
  `bash scripts/apply-cross-rules.sh <project_directory>`

## Output Format
When you update memory or prune context, output a brief summary to the user:
```markdown
> [!TIP]
> **Tokenso Optimized**: Condensed insights into `.ai-memory/state.md` and pruned immediate context to save tokens.
```
