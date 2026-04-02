{ lib }:

{
  withWorkspace ? false,
}:

# bash
''
  test_root="$TMPDIR/test-env"
  home_dir="$test_root/home"
  tmp_dir="$test_root/tmp"

  ${lib.optionalString withWorkspace /* bash */ ''
    workspace="$test_root/workspace"
  ''}

  mkdir -p \
    "$home_dir/.config" \
    "$home_dir/.local/share" \
    "$home_dir/.cache" \
    "$home_dir/.local/state" \
    "$tmp_dir"

  ${lib.optionalString withWorkspace /* bash */ ''
    mkdir -p "$workspace"
  ''}

  export HOME="$home_dir"
  export XDG_CONFIG_HOME="$home_dir/.config"
  export XDG_DATA_HOME="$home_dir/.local/share"
  export XDG_CACHE_HOME="$home_dir/.cache"
  export XDG_STATE_HOME="$home_dir/.local/state"
  export TMPDIR="$tmp_dir"
  export TMP="$tmp_dir"
  export TEMP="$tmp_dir"
''
