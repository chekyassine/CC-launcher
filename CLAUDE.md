# CC remote session folder tool

Windows right-click menu entries that start/stop a named `claude remote-control` session for any folder. PowerShell only, no build step, not a git repo.

## Files
- `Install-ContextMenu.ps1` / `Uninstall-ContextMenu.ps1`: add/remove the two folder context-menu entries (HKCU, no admin). Paths to the scripts are hardcoded to `C:\projects\CC remote session folder tool`.
- `Launch-CCRemoteSession.ps1 -Path <folder>`: starts a new shell window running `claude remote-control`.
- `Stop-CCRemoteSession.ps1 -Path <folder>`: kills the processes for that folder.

## Conventions
- Session name: `--name '<COMPUTERNAME> <folder>'`, prefix `<COMPUTERNAME>-<folder>`, window title `cc-remote: <folder>`. Launch and Stop both match on these strings; change them in both scripts together.
- Spawn mode: `worktree` if the folder has `.git`, otherwise `same-dir` (local mode).
- Launch is a no-op if a process with the same `--name` is already running.
- Stop uses a prefix match (no closing quote) so derived worktree sub-sessions (`<prefix>-1`) are killed too.
- Sessions run with `--permission-mode bypassPermissions --chrome` (Claude in Chrome on by default).

## Testing
No test suite. Manual: run `Install-ContextMenu.ps1`, right-click a git folder and a non-git folder, launch, then stop; confirm no `claude` process remains.
