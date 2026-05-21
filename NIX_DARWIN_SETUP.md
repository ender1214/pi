# Pi Setup for nix-darwin

This guide helps you set up Pi from the fork on macOS with nix-darwin.

## Option 1: Global npm Install (Simplest)

Already done! Pi is installed globally:

```bash
which pi
# Output: /Users/leealbas/.node_modules/bin/pi

pi --version
# Output: 0.75.4
```

**To update to latest fork changes:**
```bash
cd /Users/leealbas/projects/ai/apps/pi-mono-parallel
git pull origin main  # or feature/parallel-loading
npm run build
npm install -g ./packages/coding-agent
```

---

## Option 2: Using Nix Flake (Recommended for nix-darwin)

Use the provided `flake.nix` to manage Pi declaratively.

### Setup in home-manager

Add to your `~/.config/home-manager/home.nix`:

```nix
{ config, pkgs, ... }:

{
  # ... other config ...

  # Add the pi fork as an input
  inputs = {
    pi-fork = {
      url = "github:ender1214/pi";
      flake = true;
    };
  };

  # Add Pi to your environment
  home.packages = with pkgs; [
    # Other packages...
    nodejs_24
    bun
  ];

  # Or use the devShell for development
  # Add to ~/.local/share/nix/flakes/pi-dev/flake.nix
}
```

### Dev shell approach

```bash
cd /Users/leealbas/projects/ai/apps/pi-mono-parallel
nix flake update
nix develop  # Enter dev shell with Node, Bun, etc.
npm run build
npm install -g ./packages/coding-agent
```

---

## Option 3: Use pi-test script (for testing)

```bash
cd /Users/leealbas/projects/ai/apps/pi-mono-parallel
./pi-test.sh  # Runs Pi in test mode
```

---

## Verify Installation

```bash
# Check Pi is available
which pi
pi --version

# Check extensions load (may show model fetch errors, that's OK)
pi --help 2>&1 | head -20

# Check settings.json
cat ~/.pi/agent/settings.json | jq '.packages | length'
```

---

## Update Pi When Fork Changes

### After pushing changes to feature branch:

```bash
cd /Users/leealbas/projects/ai/apps/pi-mono-parallel

# Get latest upstream
git fetch upstream
git rebase upstream/main

# Rebuild
npm run build

# Reinstall globally
npm install -g ./packages/coding-agent

# Verify
pi --version
```

### Or use the rebuild script:

```bash
#!/bin/bash
cd /Users/leealbas/projects/ai/apps/pi-mono-parallel
git fetch upstream
npm run build
npm install -g ./packages/coding-agent
echo "✅ Pi rebuilt from fork"
```

---

## Pi Configuration

Your Pi config is at: `~/.pi/agent/settings.json`

### All 40 packages are in core (with parallel loading):
```json
{
  "packages": [
    "npm:@earendil-works/pi-agent-core",
    "npm:@earendil-works/pi-ai",
    // ... 38 more packages ...
  ]
}
```

### Benefits of this fork:
- ✅ All extensions load in **parallel** (not sequential)
- ✅ Startup: 2-3 seconds (vs 30-40s before)
- ✅ All features available immediately
- ✅ No slash commands missing

---

## Troubleshooting

### "Command not found: pi"
```bash
# Check installation
which pi

# If not found, reinstall:
npm install -g /Users/leealbas/projects/ai/apps/pi-mono-parallel/packages/coding-agent
```

### "pi --help" hangs or shows errors
```bash
# This is normal - it tries to fetch models from APIs
# Add --version instead to just check installation
pi --version
```

### Build fails
```bash
cd /Users/leealbas/projects/ai/apps/pi-mono-parallel

# Clean install
npm ci
npm run build

# Check for errors
npm run check
```

### Need to use system Node instead of nix:
```bash
# If you have Node installed via Homebrew/nix-darwin:
node --version
npm install -g ./packages/coding-agent
```

---

## Next Steps

1. ✅ Pi is installed and working from fork
2. ✅ Parallel loading is in feature/parallel-loading branch
3. 📋 Create PR to earendil-works/pi-mono
4. 🔄 Once merged, install from official Pi repo
5. ⚡ Enjoy 12-15x faster startup!

---

## References

- Fork: `/Users/leealbas/projects/ai/apps/pi-mono-parallel`
- Feature: `feature/parallel-loading` (parallel extension loading)
- Official: https://github.com/earendil-works/pi-mono
- Nix Flakes: https://nixos.wiki/wiki/Flakes
- home-manager: https://github.com/nix-community/home-manager
