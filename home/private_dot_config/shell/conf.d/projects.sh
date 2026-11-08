## Projects functions ##
# Guard: only load if fzf and fdfind (fd) exist
if ! command -v fzf &> /dev/null || ! command -v fdfind &> /dev/null; then
  return 0
fi

function fp {
  local projects target selected_category selected_project selected_path
  local sorted_projects category_width
  local project_path relative_path root_name category project

  sorted_projects=$(
    find "${PROJECTS_ROOT}" -mindepth 2 -maxdepth 2 -type d -print 2> /dev/null |
      while IFS= read -r project_path; do
        relative_path="${project_path#"${PROJECTS_ROOT}/"}"
        root_name="${PROJECTS_ROOT##*/}"
        category="${relative_path%%/*}"
        project="${relative_path#*/}"
        printf '%s\t%s\t%s\n' \
          "${root_name}/${category}" "${project}" "${project_path}"
      done |
        LC_ALL=C sort -t $'\t' -k1,1 -k2,2
  )

  if [[ -n "${sorted_projects}" ]]; then
    category_width=$(printf '%s\n' "${sorted_projects}" | cut -f1 | wc -L)
    projects=$(
      while IFS=$'\t' read -r category project project_path; do
        printf '\033[3m%-*s\033[0m\t%s\t%s\n' \
          "${category_width}" "${category}" "${project}" "${project_path}"
      done <<< "${sorted_projects}"
    )
  else
    projects=""
  fi

  target=$(printf '%s\n' "${projects}" |
    fzf --height 50% --no-hscroll --delimiter=$'\t' --with-nth=1,2 \
        --nth=1,2 --ansi --info=inline -1 -q "$*" --preview-window=right:60%:wrap:noinfo \
        --preview 'readme=$(fdfind README.{md,rst,txt} {3} 2> /dev/null | head -n1); [[ -n "${readme}" ]] && leaf --inline "ansi:${FZF_PREVIEW_COLUMNS:-80}" "${readme}" | sed -e "/./,\$!d"') || return

  IFS=$'\t' read -r selected_category selected_project selected_path <<< "${target}"
  [[ -n "${selected_path}" ]] && cd -- "${selected_path}"
}