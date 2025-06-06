# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ghostfire is a Docker containerization project for Ghost CMS, maintained by FirePress.org. It creates optimized Docker images for running Ghost in production environments, with a focus on security, performance, and enterprise-grade DevOps practices.

## Technology Stack

- **Base**: Ghost CMS (currently v5.102.0) on Node.js 20.18.1 Alpine Linux
- **Database**: SQLite (default), MySQL support available
- **Security**: gosu for privilege dropping, non-root user execution
- **Build**: Multi-stage Docker builds with aggressive optimization
- **CI/CD**: GitHub Actions with comprehensive testing and security scanning

## Development Commands

### Docker Operations
```bash
# Build current version
docker build -t ghostfire:test v5/

# Run basic container
docker run -d --name ghostblog -p 2368:2368 -e url=http://localhost:2368 ghostfire:test

# Run with persistent data
docker run -d --name ghostblog -p 2368:2368 \
  -e url=http://localhost:2368 \
  -v /local/path/content:/var/lib/ghost/content \
  -v /local/path/config.production.json:/var/lib/ghost/config.production.json \
  ghostfire:test
```

### Testing
```bash
# Run tests (from v5/test/)
cd v5/test && ./config.sh
```

## Architecture

### Directory Structure
- `v5/` - Current production version (Ghost 5.x)
  - `Dockerfile` - Multi-stage build configuration
  - `config.production.json` - Ghost configuration template
  - `docker-entrypoint.sh` - Container startup script
  - `test/` - Testing configuration
- `z_archived/` - Historical versions and experimental builds

### Key Design Patterns

**Multi-stage Docker Build**:
1. `mynode` - Base Node.js environment with gosu and timezone setup
2. `debug` - Package version debugging layer
3. `builder` - Ghost installation and native dependency compilation
4. `final` - Minimal runtime image with only necessary components

**Security Model**:
- Runs as non-root `node` user
- Uses `gosu` for secure privilege dropping
- Implements proper file ownership and permissions
- Volume mounts for persistent data at `/var/lib/ghost/content`

**Optimization Strategy**:
- Conditional native dependency installation (sharp, sqlite3)
- Aggressive cleanup of build dependencies and caches
- Virtual package management for temporary build tools
- Multi-architecture support (amd64, arm64, arm/v7)

### Configuration Management

Ghost configuration is handled via `config.production.json` with these key areas:
- Database connection (SQLite default path: `/var/lib/ghost/content/data/ghost.db`)
- Mail configuration (SMTP/Mailgun template provided)
- Logging with rotation (7-day retention, 5-day rotation)
- Content path mapping to `/var/lib/ghost/content`

### CI/CD Pipeline

The GitHub Actions workflow (`ghostv5.yml`) implements:
- Multi-architecture builds
- Security scanning (Snyk, Dockle, Trivy)
- Lighthouse audits
- Automated deployment to Docker Swarm
- Slack notifications
- Comprehensive testing with Ghost-specific validations

### Branching Strategy

- `master` - Stable releases (tags: `stable_X.Y.Z_hash_date`)
- `edge_ca2` - Development branch (tags: `edge_X.Y.Z_hash_date`)
- Tags follow semantic versioning with commit hash and timestamp

### Volume Mounts and Persistence

Critical paths for data persistence:
- `/var/lib/ghost/content` - All Ghost content, themes, uploads
- `/var/lib/ghost/config.production.json` - Runtime configuration
- `/var/lib/ghost/content/logs` - Application logs
- `/var/lib/ghost/content/data/ghost.db` - SQLite database

When editing configurations or troubleshooting, always consider the containerized environment and volume mount requirements for data persistence.