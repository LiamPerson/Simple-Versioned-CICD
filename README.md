# Simple Versioned CICD
<h3><b>Easily setup and run in less than a minute!</b></h3>

<br />

<i>
A simple command line interface (CLI) continuous integration/continuous development (CI/CD) that uses Git to listen for updates from a remote repository to automatically updates, logs, and contributes new changes.
</i>

<br />

Version control for this software is handled by <a href="https://git-scm.com/">Git</a>. Something has gone wrong? Simply <a href="https://stackoverflow.com/questions/4114095/how-do-i-revert-a-git-repository-to-a-previous-commit">roll back</a> to when you're happy!


<br />

# Requirements

This software requires <a href="https://git-scm.com/">Git</a> and <a href="https://www.gnu.org/software/coreutils/manual/html_node/tee-invocation.html">tee</a> to run. These will likely already be installed on most server's operating systems

<br />

# Usage

Simply run <code>SVCICD.sh</code> on your server and enter the correct details in the prompts. 

<b>Note:</b> All commits made by Simple Versioned CICD will be titled: <code>Automatic update from SVCICD</code>

<b>Remember:</b> Use <code>CTRL+C</code> to exit in shell.


<br />

# Troubleshooting

All the information you need will be stored in the <code>svcicd.log</code> file
