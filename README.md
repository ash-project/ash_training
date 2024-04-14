# Twitter

## Setup

To get started, you will want to ensure that you have

- a terminal (Terminal.app, iTerm2)
- a recent version of Elixir
- a recent version of Erlang
- a recent version of Postgresql
- a code editor

These instructions are for mac & linux. If you are on windows, we will figure it out in person. It is absolutely not a problem if you are.

### Terminal

You can use the builtin terminal. Otherwise,I recommend iTerm2.

### Installing `homebrew`

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Installing `asdf`

If you already have `asdf` installed, you can skip this section. If you don't know your shell, use `echo $SHELL` in your terminal. If you use a different shell, we'll figure it out in person.

```bash
brew install asdf

# if your shell is bash
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.bashrc
echo -e "\n. \"$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash\"" >> ~/.bashrc

# if your shell is zsh
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.zshrc
echo -e "\n. \"$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash\"" >> ~/.zshrc
```

### Installing Elixir/Erlang with asdf

```bash
# in the project root directory
asdf install
```

### Installing Postgresql

```bash
brew install postgresql
brew services start postgresql
```
