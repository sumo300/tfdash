# TfDash

TfDash is a set of PowerShell functions provided within modules that wrap the existing TFS command-line tool, tf.exe, the Team Foundation Power Tools (TFPT) command-line tool tfpt.exe, and TFPT's included PowerShell cmdlets.

In no way is this an exhaustive list of wrappers and it is very likely that these commands don't fit your style of working with TFS.  These scripts assume a workspace is mapped to the root of a branch and most of the commands are intended to make switching from branch to branch (without requiring full branch downloads) as simple as it is in Subversion, Git, and Mercurial.

## Installation

Clone this repository directly into your Modules directory 

```powershell
PS> Set-Location (Split-Path $profile)
PS> hg clone https://bitbucket.org/Sumo/tfdash
```

Open your PowerShell profile for editing

```powershell
PS> notepad $profile
```

Import this module

```powershell
Import-Module tfdash
```

and modify your prompt function to display the current TFS status!

```powershell
function prompt {
  Write-Host $pwd -NoNewLine
  Write-TfsVcsStatus
  '> '
}
```

## PowerShell Prompt

This prompt function provides helpful TFS workspace information when the current directory is a mapped workspace folder. It's not as fancy as posh-git or posh-hg due to the client/server nature of TFS.  It only displays the name of the currently mapped branch (assuming workspaces are mapped to a single branch), the changeset # of the workspace, and optionally the changeset # of the server if different from the workspace version.

In the example prompt below, you can see that we're on the `Main` branch (a TFS naming convention for the master branch). And the changeset number, 12345, is listed. When only one changeset is displayed, we are synchronized with the server.

```powershell
PS [Main 12345]>
``` 

In the example prompt here, you can see that there are two changesets, indicating that the server is ahead of our local workspace.

```powershell
PS [Main 12345 *12350]>
```

You can further customize the PowerShell prompt with a shorter working path representation. Replace the writing of the special working directory variable (`$pwd`) with this

```powershell
function prompt {
  Write-ShortenedPath
  Write-TfsVcsStatus
  '> '
}
```

A shortened prompt will look something like this, with each directory in the path before the current one being shortened to just it's first character.

```powershell
§ {X:\a\b\c\SomeMappedFolder} [Main 12345]>
```

## Usage

This is not an exhaustive list. Run this command to see all of the available functions and aliases.

```powershell
PS> Get-Command -Module tfdash
```

### `Get-TfsHistory`, `tf-history`, `tf-hist`, `tf-hi`, or `tf-log`

Calls the `Get-TfsItemHistory` TFPT PowerShell cmdlet to get a table-formatted history of checkins. It is hard-coded to use "." (current folder) as the path, defaults to the newest 5 checkins, and does so recursively so that the history is more like what you'd get from `svn log` or `hg log`. Optionally, a section of this function can be commented out if there's a desire to remove an active directory domain name from the Committer field.  Just replace `[ActiveDirectoryDomainNameHere]` with the full name of the domain as it would appear in TFS checkins.  Take a look at `tf history` if you're unsure.

### `Invoke-TfsSync`, `tf-sync`, `tf-switch`, `tf-sy`, or `tf-sw`

Switches your TFS workfolder mapping to the provided TFS path and gets the latest version of the files.  The `Invoke-TfsSync` function calls `Invoke-TfsPull` and `Invoke-TfsUpdate` in order to provide branch switching functionality.

### `Get-TfsStatus`, `tf-status`, or `tf-st`

Gets the TFS status of files from the current directory.  The Get-TfsStatus function uses the TFS `tf status` command-line command to check on the status of TFS-tracked files.  Provide the `-all` switch and it will also provide a listing of untracked files by using `tf folderdiff`.

### `Invoke-TfsScorch`, `tf-scorch`, or `tf-sc`

Recursively scorches the current workfolder from the current directory.  The `Invoke-TfsScorch` function uses the TFS Power Tools `tfpt scorch` command to recursively delete untracked files and get the latest version based on a diff of the local and server versions of files.

This command is basically a clean-up to bring the local workspace to an exact match of the remote path.  If your TFS server or network connection is slow, if your machine is slow, or if your branch is large, this can take a while.

### `Invoke-TfsClean`, `tf-clean`, or `tf-cl`

Recursively deletes files and folders not under version control.  The `Invoke-TfsClean` function uses the TFS Power Tools "tfpt treeclean" command to recursively delete files and folders not under version control.

This command is basically a clean-up to remove untracked files/folders and is an alternative to `Invoke-TfsScorch` if all you need to do is remove untracked files.

### `Invoke-TfsUndoUnchanged` or `tf-uu`

Undo unchanged files.  Uses the `tfpt uu` command to undo any unchanged files recursively when compared to the latest changes.

This is one of the most helpful commands as files tend to get accidentally or unknowingly checked out and TFS does not detect unchanged files during a checkin.  If you have junior developers who check out a whole solution, tracking down changes in history is almost impossible.  This command, when used properly, can help alleviate the problem and do so quickly so that it can become a part of a developer's normal process.

 [1]: http://stackoverflow.com/questions/15119039/is-it-possible-to-configure-tab-completion-with-powertab-for-aliased-functions