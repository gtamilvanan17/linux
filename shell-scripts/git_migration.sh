#!/bin/bash

set -euo pipefail

# ============================================================
# CONFIGURATION
# ============================================================

GITHUB_DEST_USER="gtamilvanan17"

NEW_AUTHOR_NAME="gtamilvanan17"
NEW_AUTHOR_EMAIL="tamilbecse139@gmail.com"

# ============================================================
# PATH CONFIGURATION
# ============================================================

# Directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Temporary working directory
BASE_DIR="${SCRIPT_DIR}/repo-migrations"

# Log directory
LOG_DIR="${SCRIPT_DIR}/migration-logs"

# Create required directories
mkdir -p "$BASE_DIR"
mkdir -p "$LOG_DIR"

# Unique log file for every migration run
LOG_FILE="${LOG_DIR}/migration_$(date '+%Y%m%d_%H%M%S').log"

# ============================================================
# SOURCE REPOSITORIES
# ============================================================

SOURCE_REPOS=(
    "git@github.com:org-name/spotlight-ui.git"
    "git@github.com:org-name/spotlight.git"
    "git@github.com:org-name/ai-slack-bot-devops.git"
    "git@github.com:org-name/jenkins-global-libs.git"
    "git@github.com:org-name/sales-data-visualizer-pro-02.git"
    "git@github.com:org-name/itops-apps-payment-tracker.git"
    "git@github.com:org-name/org-name-itops-asset-management.git"
    "git@github.com:org-name/n8n-itops.org-name.com.git"
    "git@github.com:org-name/architecture-diagrams.git"
    "git@github.com:org-name/org-name-finops.git"
    "git@github.com:org-name/achieve2.git"
    "git@github.com:org-name/achieve2-ui.git"
    "git@github.com:org-name/salary-lens-ui.git"
    "git@github.com:org-name/salary-lens.git"
    "git@github.com:org-name/infra-automation.git"
    "git@github.com:org-name/infra-automation-2.git"
    "git@github.com:org-name/deployment.git"
)

# ============================================================
# LOGGER
# ============================================================

TIMESTAMP() {
    date '+%Y-%m-%d %H:%M:%S'
}

log() {
    local LEVEL="$1"
    shift

    local MESSAGE="$*"

    echo "[$(TIMESTAMP)] [$LEVEL] $MESSAGE" | tee -a "$LOG_FILE"
}

log_info() {
    log "INFO" "$@"
}

log_warn() {
    log "WARN" "$@"
}

log_error() {
    log "ERROR" "$@"
}

log_success() {
    log "SUCCESS" "$@"
}

log_separator() {
    echo "------------------------------------------------------------" | tee -a "$LOG_FILE"
}

log_section() {
    echo "" | tee -a "$LOG_FILE"
    echo "============================================================" | tee -a "$LOG_FILE"
    echo "$1" | tee -a "$LOG_FILE"
    echo "============================================================" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}

# ============================================================
# REDIRECT ALL OUTPUT TO LOG + TERMINAL
# ============================================================

exec > >(tee -a "$LOG_FILE") 2>&1

# ============================================================
# ERROR HANDLER
# ============================================================

CURRENT_REPO="N/A"

trap 'log_error "Unexpected script failure at line $LINENO while processing repository: $CURRENT_REPO"' ERR

# ============================================================
# PRE-CHECKS
# ============================================================

log_section "PRE-CHECKS"

log_info "Script directory       : $SCRIPT_DIR"
log_info "Migration log file     : $LOG_FILE"
log_info "Migration started      : $(TIMESTAMP)"

# ------------------------------------------------------------
# Check Git
# ------------------------------------------------------------

if ! command -v git >/dev/null 2>&1; then
    log_error "git is not installed."
    exit 1
fi

log_success "git found: $(git --version)"

# ------------------------------------------------------------
# Check git-filter-repo
# ------------------------------------------------------------

if ! command -v git-filter-repo >/dev/null 2>&1 && \
   ! git filter-repo --help >/dev/null 2>&1; then

    log_error "git-filter-repo is not installed."
    log_error "Install it using:"
    log_error "  brew install git-filter-repo"

    exit 1
fi

log_success "git-filter-repo is available."

log_info "Base directory: $BASE_DIR"

# ============================================================
# START MIGRATION
# ============================================================

log_section "STARTING REPOSITORY MIGRATION"

log_info "Destination GitHub user : $GITHUB_DEST_USER"
log_info "New author name         : $NEW_AUTHOR_NAME"
log_info "New author email        : $NEW_AUTHOR_EMAIL"
log_info "Total repositories      : ${#SOURCE_REPOS[@]}"
log_info "Base directory          : $BASE_DIR"
log_info "Log file                : $LOG_FILE"

SUCCESS_COUNT=0
FAILED_COUNT=0

# ============================================================
# PROCESS EACH REPOSITORY
# ============================================================

for SOURCE_REPO in "${SOURCE_REPOS[@]}"; do

    # --------------------------------------------------------
    # Extract repository name
    # --------------------------------------------------------

    REPO_NAME=$(basename "$SOURCE_REPO" .git)

    CURRENT_REPO="$REPO_NAME"

    DESTINATION_REPO="https://github.com/${GITHUB_DEST_USER}/${REPO_NAME}.git"

    REPO_DIR="${BASE_DIR}/${REPO_NAME}.git"

    # --------------------------------------------------------
    # Repository header
    # --------------------------------------------------------

    log_section "PROCESSING REPOSITORY: $REPO_NAME"

    log_info "Source repository      : $SOURCE_REPO"
    log_info "Destination repository : $DESTINATION_REPO"
    log_info "Working directory      : $REPO_DIR"

    # --------------------------------------------------------
    # Cleanup previous migration directory
    # --------------------------------------------------------

    if [ -d "$REPO_DIR" ]; then

        log_warn "Existing working directory found."
        log_info "Removing: $REPO_DIR"

        if rm -rf "$REPO_DIR"; then
            log_success "Existing working directory removed."
        else
            log_error "Failed to remove existing working directory."

            FAILED_COUNT=$((FAILED_COUNT + 1))
            continue
        fi
    fi

    # --------------------------------------------------------
    # Clone mirror
    # --------------------------------------------------------

    log_section "CLONING SOURCE: $REPO_NAME"

    log_info "Running mirror clone..."

    if git clone --mirror "$SOURCE_REPO" "$REPO_DIR"; then

        log_success "Mirror clone completed successfully."

    else

        log_error "Failed to clone source repository."
        log_error "Repository: $SOURCE_REPO"

        FAILED_COUNT=$((FAILED_COUNT + 1))
        continue
    fi

    # --------------------------------------------------------
    # Enter repository
    # --------------------------------------------------------

    if ! cd "$REPO_DIR"; then

        log_error "Failed to enter repository directory:"
        log_error "$REPO_DIR"

        FAILED_COUNT=$((FAILED_COUNT + 1))

        continue
    fi

    log_info "Current working directory: $(pwd)"

    # --------------------------------------------------------
    # Rewrite ALL authors and committers
    # --------------------------------------------------------

    log_section "REWRITING AUTHORS: $REPO_NAME"

    log_info "New author name  : $NEW_AUTHOR_NAME"
    log_info "New author email : $NEW_AUTHOR_EMAIL"

    if git filter-repo --force \
        --name-callback "return b'$NEW_AUTHOR_NAME'" \
        --email-callback "return b'$NEW_AUTHOR_EMAIL'"; then

        log_success "Author and committer information rewritten successfully."

    else

        log_error "Failed to rewrite author/committer information."

        cd "$SCRIPT_DIR"

        FAILED_COUNT=$((FAILED_COUNT + 1))

        continue
    fi

    # --------------------------------------------------------
    # Configure destination
    # --------------------------------------------------------

    log_section "CONFIGURING DESTINATION: $REPO_NAME"

    log_info "Removing existing origin..."

    git remote remove origin 2>/dev/null || true

    log_info "Adding destination origin..."

    if git remote add origin "$DESTINATION_REPO"; then

        log_success "Destination remote configured."

    else

        log_error "Failed to configure destination remote."

        cd "$SCRIPT_DIR"

        FAILED_COUNT=$((FAILED_COUNT + 1))

        continue
    fi

    log_info "Configured remotes:"
    git remote -v

    # --------------------------------------------------------
    # Verify author information
    # --------------------------------------------------------

    log_section "VERIFYING AUTHORS: $REPO_NAME"

    log_info "Showing first 20 commits after rewrite:"

    git log --all \
        -n 20 \
        --format='%h %an <%ae> | %cn <%ce>'

    # --------------------------------------------------------
    # Get all branches
    # --------------------------------------------------------

    log_section "DISCOVERING BRANCHES: $REPO_NAME"

    BRANCHES=$(git for-each-ref \
        --format='%(refname:strip=2)' \
        refs/heads/)

    if [ -z "$BRANCHES" ]; then

        log_warn "No branches found."

    else

        BRANCH_COUNT=$(echo "$BRANCHES" | wc -l | tr -d ' ')

        log_info "Branches found: $BRANCH_COUNT"

        while IFS= read -r BRANCH; do

            if [ -n "$BRANCH" ]; then
                log_info "Branch: $BRANCH"
            fi

        done <<< "$BRANCHES"

    fi

    # --------------------------------------------------------
    # Push ONLY branches
    # --------------------------------------------------------

    log_section "PUSHING BRANCHES: $REPO_NAME"

    PUSH_FAILED=0
    PUSHED_COUNT=0

    while IFS= read -r BRANCH; do

        if [ -n "$BRANCH" ]; then

            log_info "Pushing branch: $BRANCH"

            if git push origin \
                "refs/heads/$BRANCH:refs/heads/$BRANCH"; then

                log_success "Successfully pushed branch: $BRANCH"

                PUSHED_COUNT=$((PUSHED_COUNT + 1))

            else

                log_error "Failed to push branch: $BRANCH"

                PUSH_FAILED=1
            fi

        fi

    done <<< "$BRANCHES"

    # --------------------------------------------------------
    # Repository result
    # --------------------------------------------------------

    if [ "$PUSH_FAILED" -eq 0 ]; then

        log_section "SUCCESS: $REPO_NAME"

        log_success "Repository migration completed."
        log_success "Source      : $SOURCE_REPO"
        log_success "Destination : $DESTINATION_REPO"
        log_success "Branches    : $PUSHED_COUNT"

        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))

    else

        log_section "FAILED: $REPO_NAME"

        log_error "One or more branches failed to push."

        FAILED_COUNT=$((FAILED_COUNT + 1))

    fi

    # --------------------------------------------------------
    # Return to script directory
    # --------------------------------------------------------

    cd "$SCRIPT_DIR"

    CURRENT_REPO="N/A"

    log_info "Finished processing: $REPO_NAME"

done

# ============================================================
# FINAL SUMMARY
# ============================================================

log_section "MIGRATION SUMMARY"

log_info "Migration finished : $(TIMESTAMP)"

log_info "Total repositories : ${#SOURCE_REPOS[@]}"
log_success "Successful         : $SUCCESS_COUNT"
log_error "Failed             : $FAILED_COUNT"

echo ""

log_info "Destination user:"
log_info "  $GITHUB_DEST_USER"

echo ""

log_info "Author information:"
log_info "  Name  : $NEW_AUTHOR_NAME"
log_info "  Email : $NEW_AUTHOR_EMAIL"

echo ""

log_info "Migrated:"
log_info "  - All branches"
log_info "  - All commit history"
log_info "  - All author names/emails rewritten"
log_info "  - All committer names/emails rewritten"

echo ""

log_info "Ignored:"
log_info "  - Tags"
log_info "  - Pull requests"
log_info "  - Other hidden refs"

echo ""

log_info "Migration log:"
log_info "  $LOG_FILE"

log_section "MIGRATION PROCESS COMPLETED"

if [ "$FAILED_COUNT" -gt 0 ]; then

    log_warn "Migration completed with failures."

    exit 1

else

    log_success "All repositories migrated successfully."

    exit 0

fi
