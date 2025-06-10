# Requires to run "git config --local core.hooksPath .githooks/" to link the hooks!
# "post-merge":
#   Makes sure "private-config" is updated as well.
#   This is VITAL to avoid a failed rebuild! If it fails, the failure is cached, and that stops any other rebuilds of the same commit, even if the submodule is updated. Very annoying!
#   The solution is to run "nixos-rebuild" again with "--option eval-cache false"
