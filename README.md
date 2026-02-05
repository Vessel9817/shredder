# Shredder

A secure file removal tool, built for Windows on top of the Linux
[`shred`][shred] command. Skimming its manpage is highly recommended,
as the type of filesystem you're using may not benefit from the use
of file shredding.

## Usage

- **Explorer**: Run `installer.ps1`. **This is what most users will want.**
  By selecting a file(s) and/or folder(s), right-click and hover over
  the "Send to" option. If it's not available, click "Show more options."
  From there, you can click the Shredder option to securely erase the files.
- **Batch**: Run `win_shredder.cmd`, the Batch wrapper of the PowerShell script.
- **PowerShell**: Run `win_shredder.ps1`. Run without arguments for help.

[shred]: https://www.gnu.org/software/coreutils/shred#:~:text=The%20shred%20command%20relies%20on%20a%20crucial%20assumption
