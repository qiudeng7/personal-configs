#!/bin/sh

set -eu

agent_source_root=$1
home_dir=$2
source_agent_file="$agent_source_root/AGENTS.md"
source_skills_root="$agent_source_root/skills"
target_codex_root="$home_dir/.codex"
target_skills_root="$target_codex_root/skills"

mkdir -p "$target_skills_root"
rsync --archive "$source_agent_file" "$target_codex_root/AGENTS.md"

for skill_source in "$source_skills_root"/*; do
    [ -d "$skill_source" ] || continue

    skill_name=${skill_source##*/}
    skill_target="$target_skills_root/$skill_name"

    mkdir -p "$skill_target"
    rsync --archive --delete "$skill_source/" "$skill_target/"
done
