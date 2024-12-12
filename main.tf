
resource "github_repository" "my_repo" {
  name = "github-terraform-task-VladyslavDmytruk"
}

# Add collaborator
resource "github_repository_collaborator" "collaborator" {
  repository = github_repository.my_repo.name
  username   = "softservedata"
  permission = "push"
}

# Protect the main branch
resource "github_branch_protection" "main" {
  repository = github_repository.my_repo.name
  branch     = "main"

  required_pull_request_reviews {
    dismiss_stale_reviews          = true
    required_approving_review_count = 1
  }

  enforce_admins = true
}

# Protect the develop branch
resource "github_branch_protection" "develop" {
  repository = github_repository.my_repo.name
  branch     = "develop"

  required_pull_request_reviews {
    dismiss_stale_reviews          = true
    required_approving_review_count = 2
  }

  enforce_admins = true
}

# Add pull request template
resource "github_repository_file" "pull_request_template" {
  repository = github_repository.my_repo.name
  file       = ".github/pull_request_template.md"
  content    = <<EOF
Describe your changes
Issue ticket number and link
Checklist before requesting a review:
- [ ] I have performed a self-review of my code
- [ ] If it is a core feature, I have added thorough tests
- [ ] Do we need to implement analytics?
- [ ] Will this be part of a product update? If yes, please write one phrase about this update
EOF

  commit_message = "Added pull request template"
}

# Add Deploy Key
resource "github_deploy_key" "deploy_key" {
  repository = github_repository.my_repo.name
  title      = "DEPLOY_KEY"
  key        = var.deploy_key
  read_only  = false
}

# Add Discord notification workflow
resource "github_repository_file" "discord_workflow" {
  repository = github_repository.my_repo.name
  file       = ".github/workflows/discord-notifications.yml"
  content    = <<EOF
name: PR Notifications to Discord

on:
  pull_request:
    types: [opened, synchronize, closed]

jobs:
  notify_discord:
    runs-on: ubuntu-latest
    steps:
      - name: Send PR notifications to Discord
        uses: peter-evans/discord-webhook-action@v1
        with:
          webhook-url: "https://discord.com/api/webhooks/1316764779423076434/OJZbjcaiXNrs_UGWjzoaqyT2MB3vjDREQshnvCGleih22sNSfQbPTJbpv3cgPQlTDH6o"
EOF

  commit_message = "Added Discord notification workflow"
}

# Add PAT to repository secrets
resource "github_actions_secret" "pat_secret" {
  repository    = github_repository.my_repo.name
  secret_name   = "PAT"
  plaintext_value = var.pat
}

resource "github_actions_secret" "discord_webhook" {
  repository    = github_repository.my_repo.name
  secret_name   = "DISCORD_WEBHOOK"
  plaintext_value = var.discord_webhook_url
}

# Variables
#variable "github_token" {}
#variable "github_owner" {}
#variable "deploy_key" {}
#variable "pat" {}
#variable "discord_webhook_url" {}

