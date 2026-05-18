#!/bin/bash
# build-symbol-map.sh
# Build a token-dense symbol map of the working tree.
# Output format (one symbol per line):
#   path:line  kind  name
# kind ∈ {fn, cls, iface, const, route}
#
# Prefers Universal Ctags when available (richer extraction across more
# languages); falls back to portable grep/regex for JS/TS, Python, Bash, Go,
# Rust, Ruby. Caps output at ~SYMBOL_CAP lines so the map stays
# token-friendly.

set -euo pipefail

TARGET_DIR="${1:-.}"
MEMORY_DIR="$TARGET_DIR/.ai-memory"
OUT_FILE="$MEMORY_DIR/symbol-map.txt"
SYMBOL_CAP="${TOKENSO_SYMBOL_CAP:-800}"

mkdir -p "$MEMORY_DIR"

# Excluded directories (kept in sync with init-smart-search.sh).
PRUNE_DIRS=(
  node_modules .git build dist .dart_tool Pods .gradle .venv venv
  __pycache__ .idea .vscode .expo .next .nuxt out coverage
  .nyc_output target .cargo .ai-memory vendor .terraform
)

list_files() {
  # Files matching one of our source extensions, OR extensionless executable
  # files (catches bin/tokenso-style shell scripts without .sh). Portable
  # across BSD find (macOS) and GNU find (Linux).
  find "$TARGET_DIR" \
    -type d \( \
      -name node_modules -o -name .git -o -name build -o -name dist \
      -o -name .dart_tool -o -name Pods -o -name .gradle -o -name .venv \
      -o -name venv -o -name __pycache__ -o -name .idea -o -name .vscode \
      -o -name .expo -o -name .next -o -name .nuxt -o -name out -o -name coverage \
      -o -name .nyc_output -o -name target -o -name .cargo -o -name .ai-memory \
      -o -name vendor -o -name .terraform \
    \) -prune -o \
    -type f \( \
      -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \
      -o -name "*.mjs" -o -name "*.cjs" -o -name "*.py" -o -name "*.sh" \
      -o -name "*.bash" -o -name "*.go" -o -name "*.rs" -o -name "*.rb" \
      -o \( ! -name "*.*" -perm -u+x \) \
    \) -print 2>/dev/null
}

# Universal Ctags path. Each language's parser emits lines like
#   name<TAB>file<TAB>line;"<TAB>kind<TAB>...
# We use --fields=+nK so kind is the full word and line is explicit.
extract_with_ctags() {
  local exclude_args=()
  for d in "${PRUNE_DIRS[@]}"; do exclude_args+=("--exclude=$d"); done

  ctags -R -f - --fields=+nK --extras=+q "${exclude_args[@]}" "$TARGET_DIR" 2>/dev/null \
    | awk -F'\t' '
      {
        name=$1; path=$2; line=""; kind=""
        for (i=3; i<=NF; i++) {
          if ($i ~ /^line:/) { line=$i; sub(/^line:/,"",line) }
          else if ($i ~ /^kind:/) { kind=$i; sub(/^kind:/,"",kind) }
          else if (i==NF && $i !~ /:/) kind=$i
        }
        if (name=="" || path=="" || line=="") next
        k="fn"
        if (kind ~ /^(class|struct|module|namespace)$/) k="cls"
        else if (kind ~ /^(interface|typedef|type)$/) k="iface"
        else if (kind ~ /^(variable|constant|enumerator|enum)$/) k="const"
        else if (kind ~ /^(function|method|procedure|subroutine|prototype)$/) k="fn"
        else next
        sub(/^\.\//,"",path)
        printf "%s:%s\t%s\t%s\n", path, line, k, name
      }
    '
}

# Portable awk extractor for JS/TS, Python, Bash, Go, Rust, Ruby.
# Regexes are passed as STRINGS to match() because POSIX awk converts
# regex literals to numeric 0/1 when used as function arguments.
awk_extract() {
  local lang=$1 file=$2
  awk -v lang="$lang" '
    function extract(re,   x) {
      if (match($0, re)) { return substr($0, RSTART, RLENGTH) } else { return "" }
    }
    function strip(s, re) { sub(re, "", s); return s }
    {
      if (lang == "js") {
        if ($0 ~ "^[[:space:]]*(export[[:space:]]+(default[[:space:]]+)?)?(async[[:space:]]+)?function[[:space:]]+[A-Za-z_$][A-Za-z0-9_$]*") {
          n = strip(extract("function[[:space:]]+[A-Za-z_$][A-Za-z0-9_$]*"), "^function[[:space:]]+")
          if (n != "") printf "%s:%d\tfn\t%s\n", FILENAME, NR, n
        }
        if ($0 ~ "^[[:space:]]*(export[[:space:]]+(default[[:space:]]+)?)?(abstract[[:space:]]+)?class[[:space:]]+[A-Za-z_$][A-Za-z0-9_$]*") {
          n = strip(extract("class[[:space:]]+[A-Za-z_$][A-Za-z0-9_$]*"), "^class[[:space:]]+")
          if (n != "") printf "%s:%d\tcls\t%s\n", FILENAME, NR, n
        }
        if ($0 ~ "^[[:space:]]*(export[[:space:]]+)?interface[[:space:]]+[A-Za-z_$][A-Za-z0-9_$]*") {
          n = strip(extract("interface[[:space:]]+[A-Za-z_$][A-Za-z0-9_$]*"), "^interface[[:space:]]+")
          if (n != "") printf "%s:%d\tiface\t%s\n", FILENAME, NR, n
        }
        if ($0 ~ "^[[:space:]]*(export[[:space:]]+)?type[[:space:]]+[A-Za-z_$][A-Za-z0-9_$]*[[:space:]]*=") {
          n = strip(extract("type[[:space:]]+[A-Za-z_$][A-Za-z0-9_$]*"), "^type[[:space:]]+")
          if (n != "") printf "%s:%d\tiface\t%s\n", FILENAME, NR, n
        }
        if ($0 ~ "^[[:space:]]*export[[:space:]]+(const|let|var|enum)[[:space:]]+[A-Za-z_$][A-Za-z0-9_$]*") {
          n = strip(extract("(const|let|var|enum)[[:space:]]+[A-Za-z_$][A-Za-z0-9_$]*"), "^(const|let|var|enum)[[:space:]]+")
          if (n != "") printf "%s:%d\tconst\t%s\n", FILENAME, NR, n
        }
      } else if (lang == "py") {
        if ($0 ~ "^[[:space:]]*def[[:space:]]+[A-Za-z_][A-Za-z0-9_]*") {
          n = strip(extract("def[[:space:]]+[A-Za-z_][A-Za-z0-9_]*"), "^def[[:space:]]+")
          if (n != "") printf "%s:%d\tfn\t%s\n", FILENAME, NR, n
        }
        if ($0 ~ "^[[:space:]]*class[[:space:]]+[A-Za-z_][A-Za-z0-9_]*") {
          n = strip(extract("class[[:space:]]+[A-Za-z_][A-Za-z0-9_]*"), "^class[[:space:]]+")
          if (n != "") printf "%s:%d\tcls\t%s\n", FILENAME, NR, n
        }
        if ($0 ~ "^[A-Z][A-Z0-9_]*[[:space:]]*=") {
          n = extract("^[A-Z][A-Z0-9_]*")
          if (n != "") printf "%s:%d\tconst\t%s\n", FILENAME, NR, n
        }
      } else if (lang == "sh") {
        if ($0 ~ "^[[:space:]]*function[[:space:]]+[a-zA-Z_][a-zA-Z0-9_-]*") {
          n = strip(extract("function[[:space:]]+[a-zA-Z_][a-zA-Z0-9_-]*"), "^function[[:space:]]+")
          if (n != "") printf "%s:%d\tfn\t%s\n", FILENAME, NR, n
        } else if ($0 ~ "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_-]*[[:space:]]*\\(\\)") {
          n = extract("^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_-]*")
          sub("^[[:space:]]+", "", n)
          if (n != "") printf "%s:%d\tfn\t%s\n", FILENAME, NR, n
        }
      } else if (lang == "go") {
        if ($0 ~ "^func[[:space:]]+\\([^)]+\\)[[:space:]]+[A-Za-z_][A-Za-z0-9_]*") {
          n = strip(extract("\\)[[:space:]]+[A-Za-z_][A-Za-z0-9_]*"), "^\\)[[:space:]]+")
          if (n != "") printf "%s:%d\tfn\t%s\n", FILENAME, NR, n
        } else if ($0 ~ "^func[[:space:]]+[A-Za-z_][A-Za-z0-9_]*") {
          n = strip(extract("^func[[:space:]]+[A-Za-z_][A-Za-z0-9_]*"), "^func[[:space:]]+")
          if (n != "") printf "%s:%d\tfn\t%s\n", FILENAME, NR, n
        }
        if ($0 ~ "^type[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]+struct") {
          n = strip(extract("^type[[:space:]]+[A-Za-z_][A-Za-z0-9_]*"), "^type[[:space:]]+")
          if (n != "") printf "%s:%d\tcls\t%s\n", FILENAME, NR, n
        } else if ($0 ~ "^type[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]+interface") {
          n = strip(extract("^type[[:space:]]+[A-Za-z_][A-Za-z0-9_]*"), "^type[[:space:]]+")
          if (n != "") printf "%s:%d\tiface\t%s\n", FILENAME, NR, n
        }
      } else if (lang == "rs") {
        if ($0 ~ "^[[:space:]]*(pub[[:space:]]+)?(async[[:space:]]+)?fn[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*") {
          n = strip(extract("fn[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*"), "^fn[[:space:]]+")
          if (n != "") printf "%s:%d\tfn\t%s\n", FILENAME, NR, n
        }
        if ($0 ~ "^[[:space:]]*(pub[[:space:]]+)?(struct|enum)[[:space:]]+[A-Za-z_][A-Za-z0-9_]*") {
          n = strip(extract("(struct|enum)[[:space:]]+[A-Za-z_][A-Za-z0-9_]*"), "^(struct|enum)[[:space:]]+")
          if (n != "") printf "%s:%d\tcls\t%s\n", FILENAME, NR, n
        }
        if ($0 ~ "^[[:space:]]*(pub[[:space:]]+)?trait[[:space:]]+[A-Za-z_][A-Za-z0-9_]*") {
          n = strip(extract("trait[[:space:]]+[A-Za-z_][A-Za-z0-9_]*"), "^trait[[:space:]]+")
          if (n != "") printf "%s:%d\tiface\t%s\n", FILENAME, NR, n
        }
      } else if (lang == "rb") {
        if ($0 ~ "^[[:space:]]*def[[:space:]]+[a-zA-Z_][a-zA-Z0-9_!?=]*") {
          n = strip(extract("def[[:space:]]+[a-zA-Z_][a-zA-Z0-9_!?=]*"), "^def[[:space:]]+")
          if (n != "") printf "%s:%d\tfn\t%s\n", FILENAME, NR, n
        }
        if ($0 ~ "^[[:space:]]*(class|module)[[:space:]]+[A-Z][a-zA-Z0-9_:]*") {
          n = strip(extract("(class|module)[[:space:]]+[A-Z][a-zA-Z0-9_:]*"), "^(class|module)[[:space:]]+")
          if (n != "") printf "%s:%d\tcls\t%s\n", FILENAME, NR, n
        }
      }
    }
  ' "$file" 2>/dev/null
}

lang_for() {
  # Map a file to one of our supported langs, or empty string.
  case "$1" in
    *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs)  echo js ;;
    *.py)                                echo py ;;
    *.sh|*.bash)                         echo sh ;;
    *.go)                                echo go ;;
    *.rs)                                echo rs ;;
    *.rb)                                echo rb ;;
    *)
      # Extensionless executable: peek at the shebang.
      if [ -r "$1" ]; then
        local first
        first=$(head -c 80 "$1" 2>/dev/null)
        case "$first" in
          '#!/bin/bash'*|'#!/usr/bin/env bash'*|'#!/bin/sh'*|'#!/usr/bin/env sh'*) echo sh ;;
          '#!/usr/bin/env python'*|'#!/usr/bin/python'*) echo py ;;
          '#!/usr/bin/env ruby'*|'#!/usr/bin/ruby'*)     echo rb ;;
          '#!/usr/bin/env node'*|'#!/usr/bin/node'*)     echo js ;;
        esac
      fi
      ;;
  esac
}

extract_with_regex() {
  local files
  files=$(list_files)
  [ -z "$files" ] && return 0

  echo "$files" | while IFS= read -r f; do
    local lang
    lang=$(lang_for "$f")
    [ -n "$lang" ] && awk_extract "$lang" "$f"
  done
}

# Pick extraction backend. We only use ctags if it's Universal Ctags;
# BSD/Xcode ctags doesn't support the flags we need and will silently produce
# nothing useful.
backend="regex"
if command -v ctags >/dev/null 2>&1 \
   && ctags --version 2>/dev/null | grep -qi "Universal Ctags"; then
  backend="ctags"
fi

# Extract → sort by path → cap to SYMBOL_CAP.
{
  if [ "$backend" = "ctags" ]; then
    extract_with_ctags
  else
    extract_with_regex
  fi
} 2>/dev/null | sort -t$'\t' -k1,1 | head -n "$SYMBOL_CAP" > "$OUT_FILE.tmp"

# Atomic install + provenance header.
total=$(wc -l < "$OUT_FILE.tmp" | tr -d ' ')
{
  echo "# Tokenso symbol map — $(date +"%Y-%m-%d %H:%M") — backend: $backend — symbols: $total"
  echo "# Format: path:line<TAB>kind<TAB>name    (kind ∈ fn, cls, iface, const, route)"
  echo "# Cap: $SYMBOL_CAP. Override via TOKENSO_SYMBOL_CAP."
  cat "$OUT_FILE.tmp"
} > "$OUT_FILE"
rm -f "$OUT_FILE.tmp"

echo "Symbol map: $OUT_FILE ($total symbols, backend=$backend)"
