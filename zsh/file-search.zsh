_fuzzy_pick() {
  local picker_prompt="$1"
  local initial_query="$2"
  local result_action="${3:-open}"
  local picked selected_item

  picked=$(
    /usr/bin/awk 'NF && !seen[$0]++' |
      /opt/homebrew/bin/fzf \
        --multi \
        --layout=reverse \
        --height=85% \
        --border \
        --info=inline \
        --prompt="${picker_prompt}> " \
        --query="$initial_query" \
        --header='Enter: open  •  Ctrl-R: reveal in Finder  •  Ctrl-Y: copy path  •  Tab: multi-select' \
        --bind='ctrl-r:execute-silent(/usr/bin/open -R {})+abort' \
        --bind='ctrl-y:execute-silent(/usr/bin/printf %s {} | /usr/bin/pbcopy)+abort' \
        --preview='item={}; if [ -d "$item" ]; then /bin/ls -lah "$item"; else mime=$(/usr/bin/file -b --mime-type "$item"); case "$mime" in text/*|application/json|application/xml|application/x-shellscript) /opt/homebrew/bin/bat --color=always --style=numbers --line-range=:250 "$item" 2>/dev/null ;; *) /usr/bin/mdls -name kMDItemDisplayName -name kMDItemKind -name kMDItemFSSize -name kMDItemContentCreationDate -name kMDItemContentModificationDate "$item" ;; esac; fi' \
        --preview-window='right:55%:wrap'
  ) || return 0

  [[ -n "$picked" ]] || return 0
  while IFS= read -r selected_item; do
    [[ -e "$selected_item" ]] || continue
    if [[ "$result_action" == "reveal" ]]; then
      /usr/bin/open -R "$selected_item"
    else
      /usr/bin/open "$selected_item"
    fi
  done <<< "$picked"
}

_fuzzy_home_files() {
  /usr/bin/mdfind -onlyin "$HOME" 'kMDItemContentTypeTree == "public.data"' |
    /usr/bin/grep -Ev "^${HOME}/(Library|\\.Trash|\\.cache|\\.codex)/"
}

_fuzzy_exts() {
  local picker_prompt="$1"
  local initial_query="$2"
  shift 2

  local spotlight_query="" extension
  for extension in "$@"; do
    [[ -n "$spotlight_query" ]] && spotlight_query+=" || "
    spotlight_query+="kMDItemFSName == '*.${extension}'c"
  done

  /usr/bin/mdfind -onlyin "$HOME" "$spotlight_query" |
    /usr/bin/grep -Ev "^${HOME}/(Library|\\.Trash|\\.cache|\\.codex)/" |
    _fuzzy_pick "$picker_prompt" "$initial_query"
}

ff() { _fuzzy_home_files | _fuzzy_pick "Files" "$*"; }

freveal() { _fuzzy_home_files | _fuzzy_pick "Reveal" "$*" reveal; }

fcd() {
  local selected_directory
  selected_directory=$(
    /opt/homebrew/bin/fd --type d --hidden \
      --exclude Library --exclude .git --exclude .Trash --exclude .cache --exclude .codex \
      . "$HOME" |
      /opt/homebrew/bin/fzf --layout=reverse --height=80% --border --query="$*" --prompt='Folder> '
  ) || return 0
  [[ -n "$selected_directory" ]] && builtin cd "$selected_directory"
}

ffinder() {
  local selected_directory
  selected_directory=$(
    /opt/homebrew/bin/fd --type d --hidden \
      --exclude Library --exclude .git --exclude .Trash --exclude .cache --exclude .codex \
      . "$HOME" |
      /opt/homebrew/bin/fzf --layout=reverse --height=80% --border --query="$*" --prompt='Finder folder> '
  ) || return 0
  [[ -n "$selected_directory" ]] && /usr/bin/open "$selected_directory"
}

fhere() { /usr/bin/open "${1:-.}"; }

fcsv()   { _fuzzy_exts "CSV"          "$*" csv; }
fpdf()   { _fuzzy_exts "PDF"          "$*" pdf; }
fxlsx()  { _fuzzy_exts "Spreadsheet"  "$*" xlsx xls xlsm numbers ods csv; }
fxls()   { fxlsx "$@"; }
fxslx()  { fxlsx "$@"; }
fdoc()   { _fuzzy_exts "Document"     "$*" doc docx pages rtf txt md; }
fdocx()  { fdoc "$@"; }
fppt()   { _fuzzy_exts "Presentation" "$*" ppt pptx key; }
fpptx()  { fppt "$@"; }
fimg()   { _fuzzy_exts "Image"        "$*" png jpg jpeg heic webp gif svg; }
fmedia() { _fuzzy_exts "Media"        "$*" mp4 mov m4v mkv webm mp3 m4a wav; }
fcode()  { _fuzzy_exts "Code"         "$*" py js jsx ts tsx go rs rb java c h cpp swift sh zsh json yaml yml toml; }
fzip()   { _fuzzy_exts "Archive"      "$*" zip tar tgz gz bz2 xz 7z rar dmg pkg; }

fhelp() {
  /usr/bin/printf '%s\n' \
    'ff [words]       fuzzy-open any file' \
    'freveal [words]  fuzzy-reveal a file in Finder' \
    'fcd [words]      fuzzy-change terminal directory' \
    'ffinder [words]  fuzzy-open a directory in Finder' \
    'fhere            open the current directory in Finder' \
    'fcsv / fpdf / fxlsx / fdoc / fppt / fimg / fmedia / fcode / fzip' \
    'Inside the picker: Enter opens, Ctrl-R reveals, Ctrl-Y copies the path, Tab selects multiple.'
}
