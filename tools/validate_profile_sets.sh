#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
status=0

for set_dir in "$ROOT"/profile-sets/*; do
  [ -d "$set_dir" ] || continue
  plan=$set_dir/plan.conf
  if [ ! -f "$plan" ]; then
    printf '[ERROR] missing plan.conf: %s\n' "$set_dir" >&2
    status=1
    continue
  fi
  while IFS='|' read -r source profiles; do
    case "$source" in ''|'#'*) continue ;; esac
    [ -n "$profiles" ] || {
      printf '[ERROR] empty profile list: %s\n' "$plan" >&2
      status=1
      continue
    }
    old_ifs=$IFS
    IFS=','
    for name in $profiles; do
      profile=$set_dir/profiles/$name
      if [ ! -f "$profile/profile.conf" ]; then
        printf '[ERROR] missing profile.conf: %s\n' "$profile" >&2
        status=1
        continue
      fi
      operation=$(awk -F= '$1 == "operation" {print $2; exit}' "$profile/profile.conf")
      expected=$(awk -F= '$1 == "expected_matches" {print $2; exit}' "$profile/profile.conf")
      case "$expected" in
        all) [ "$operation" = replace-method-result-all ] || {
          printf '[ERROR] expected_matches=all requires all-occurrence operation: %s\n' "$profile" >&2
          status=1
        } ;;
        ''|*[!0-9]*)
          printf '[ERROR] invalid expected_matches in %s\n' "$profile" >&2
          status=1 ;;
      esac
    done
    IFS=$old_ifs
  done < "$plan"
done

[ "$status" -eq 0 ] && printf 'profile sets: valid\n'
exit "$status"
