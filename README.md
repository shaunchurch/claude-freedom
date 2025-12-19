# Claude Code Sandbox

Run Claude Code in Docker with full project access but isolated from host system.

## Quick Install

```bash
git clone https://github.com/youruser/claude-freedom ~/claude-freedom && \
echo 'claude-sandbox() { ~/claude-freedom/sandbox.sh "$(pwd)" "$@"; }' >> ~/.zshrc && \
source ~/.zshrc
```

Then run `claude-sandbox` from any project directory.

## What's Isolated
- Claude can ONLY see `/workspace` (your mounted project)
- No access to host filesystem, home directory, SSH keys, etc.
- Auth tokens persist in Docker volumes between sessions

## What's Allowed
- Full read/write to mounted project
- Internet access (for Claude API + web searches)
- Install packages, run builds, etc. within container
- Git commits (uses your host git config automatically)

## Usage

```bash
# Run on a project
./sandbox.sh /path/to/your/project

# Run on current directory
./sandbox.sh

# Skip rebuild (faster, use after first run)
./sandbox.sh --no-build

# Pass claude args
./sandbox.sh /path/to/project --resume

# Use API key instead of OAuth (optional)
ANTHROPIC_API_KEY=sk-xxx ./sandbox.sh /path/to/project
```

## Shell Alias

Add to `~/.zshrc` or `~/.bashrc`:

```bash
# Claude Code sandbox - run from any project directory
claude-sandbox() {
  /path/to/claude-freedom/sandbox.sh "$(pwd)" "$@"
}
```

Then `source ~/.zshrc` and use from any project:

```bash
cd ~/Code/my-project
claude-sandbox              # starts sandboxed claude in current dir
claude-sandbox --resume     # pass any claude args
claude-sandbox --no-build   # skip docker rebuild
```

## First Run
First run builds the image (~2-3 min). Subsequent runs are fast.

If using OAuth, authenticate on first run - creds persist in Docker volume.

## Multiple Projects
You can run multiple sandboxes simultaneously - each gets a unique container.

## Git Config
Your host's `git config --global user.name` and `user.email` are automatically passed to the container, so commits work out of the box.

## Cleanup

Reset Claude auth/settings (useful if auth breaks):

```bash
./cleanup.sh           # removes config volumes (prompts for confirmation)
./cleanup.sh --force   # skip confirmation
./cleanup.sh --full    # also remove docker image
```

## Customization

Edit `Dockerfile` to add language-specific tools:
```dockerfile
# For Python projects
RUN pip3 install poetry pipenv

# For Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# For Go
RUN wget -q https://go.dev/dl/go1.22.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz
```

After editing Dockerfile, run without `--no-build` to rebuild.
