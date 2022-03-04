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


# Installation & Usage
<h3>Simply run <code>SVCICD.sh</code> on your server and enter the correct details in the prompts. </h3>

<br />

<b>Note:</b> All commits made by Simple Versioned CICD will be titled: <code>Automatic update from SVCICD</code>

<b>Remember:</b> Use <code>CTRL+C</code> to exit in shell.

<hr />

<h3>Detailed Installation:</h3>
<ol>
  <li>Put file onto target machine. e.g: <code>wget https://raw.githubusercontent.com/YeloPartyHat/Simple-Versioned-CICD/main/SVCICD.sh</code></li>
  <li>Navigate to the location you put the files using <code>cd</code></li>
  <li>Run file using <code>sudo bash SVCICD.sh</code> or <code>sudo ./SVICD.sh</code></li>
  <li>Follow in-console prompts</li>
</ol>

<br />

# Notes
<ul>
  <li><code>svcicd.conf</code> automatically populates with what you provide in the setup</li>
  <li>You may notice you can't immediately run the file when you place it. This is because you don't have the adequate permissions. To fix this, use: <code>chmod +x SVCICD.sh</code></li>
</ul>

<br />

# Troubleshooting

All the information you need will be stored in the <code>svcicd.log</code> file
