# This is my .files DOTSH (dot shell)
Your dotfiles are how you personalize your system. These are mine.

## Getting Started
- A Unix-like operating system: macOS, Linux, BSD. On Windows: WSL2 is preferred, but cygwin or msys also mostly work.
- `curl` or `wget` should be installed
- `git` should be installed (recommended v2.4.11 or higher)
### Basic Installation

DOT Shell is installed by running one of the following commands in your terminal. You can install this via the command-line with either `curl`, `wget` or another similar tool.

| Method    | Command                                                                                           |
|:----------|:--------------------------------------------------------------------------------------------------|
| **curl**  | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/mfinkelstine/dotsh/master/installer.sh))"` |
| **wget**  | `sh -c "$(wget -O- https://raw.githubusercontent.com/mfinkelstine/dotsh/master/installer.sh)"`   |
| **fetch** | `sh -c "$(fetch -o - https://raw.githubusercontent.com/mfinkelstine/dotsh/master/installer.sh)"` |

#### Manual inspection

It's a good idea to inspect the install script from projects you don't yet know. You can do
that by downloading the install script first, looking through it so everything looks normal,
then running it:

```shell
wget https://raw.githubusercontent.com/mfinkelstine/dotsh/master/installer.sh 
sh install.sh
```




Tell Git who you are using these commands:

```
git config -f ~/.gitlocal user.email "email@yoursite.com"
git config -f ~/.gitlocal user.name "Name Lastname"
```
