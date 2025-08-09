name: 'Terraform CI/CD via SSH to tools_ec2'

on:
  push:
    branches:
      - main
  pull_request:

permissions:
  contents: read
  pull-requests: write

jobs:
  terraform-on-ec2:
    name: 'Terraform on tools_ec2'
    runs-on: ubuntu-latest

    steps:
      - name: 'Checkout code'
        uses: actions/checkout@v4

      - name: 'Set up SSH Key'
        uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.ID_RSA }}

      - name: 'Create known_hosts'
        run: |
          mkdir -p ~/.ssh
          touch ~/.ssh/known_hosts
          echo "${{ secrets.EC2_HOST_KEY }}" >> ~/.ssh/known_hosts
          chmod 644 ~/.ssh/known_hosts

      - name: 'Sync Terraform code to tools_ec2'
        run: |
          REPO_NAME=$(echo "${{ github.repository }}" | cut -d'/' -f2)
          RUN_ID="${{ github.run_id }}"
          REMOTE_BASE_PATH="/home/${{ secrets.EC2_USER }}/terraform_runs"
          REMOTE_PROJECT_PATH="${REMOTE_BASE_PATH}/${REPO_NAME}/${RUN_ID}"

          ssh -o StrictHostKeyChecking=yes \
            ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }} "mkdir -p ${REMOTE_PROJECT_PATH}"

          # Using rsync is generally more efficient if available and configured
          rsync -avz -e "ssh -o StrictHostKeyChecking=yes" \
            ./ ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }}:${REMOTE_PROJECT_PATH}/

      - name: 'Run Terraform Init, Validate, Plan on tools_ec2'
        id: plan
        if: github.event_name == 'pull_request' || (github.event_name == 'push' && github.ref == 'refs/heads/main')
        run: |
          REPO_NAME=$(echo "${{ github.repository }}" | cut -d'/' -f2)
          RUN_ID="${{ github.run_id }}"
          REMOTE_PROJECT_PATH="/home/${{ secrets.EC2_USER }}/terraform_runs/${REPO_NAME}/${RUN_ID}"
          TERRAFORM_DIR_IN_REPO="."
          SSH_COMMANDS="
          cd ${REMOTE_PROJECT_PATH}/${TERRAFORM_DIR_IN_REPO} && \
          echo 'Running Terraform Init...' && \
          terraform init -input=false && \
          echo 'Running Terraform Validate...' && \
          terraform validate && \
          echo 'Running Terraform Plan...' && \
          terraform plan -input=false -no-color -out=tfplan
          "
          echo "Attempting to run Terraform commands on tools_ec2..."
          ssh -o StrictHostKeyChecking=yes \
            ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }} "${SSH_COMMANDS}" \
            > plan_output.txt
          cat plan_output.txt # Output to GitHub Actions logs
          echo "Terraform commands sent."
          PLAN_CONTENT=$(sed -n '/Plan: /,$p' plan_output.txt)
          echo "TF_PLAN<<EOF" >> $GITHUB_ENV
          echo "$PLAN_CONTENT" >> $GITHUB_ENV
          echo "EOF" >> $GITHUB_ENV

      - name: 'Comment PR with Terraform Plan'
        if: github.event_name == 'pull_request' && env.TF_PLAN != ''
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const output = `#### Terraform Plan (from tools_ec2) 📜:
            \`\`\`terraform\n
            ${process.env.TF_PLAN}
            \`\`\`
            *Pushed by: @${{ github.actor }}, Action: ${{ github.event_name }}*`;
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })

      - name: 'Run Terraform Apply on tools_ec2'
        if: github.ref == 'refs/heads/main' && github.event_name == 'push' # Add && steps.plan.outcome == 'success' if plan step is reliable
        run: |
          REPO_NAME=$(echo "${{ github.repository }}" | cut -d'/' -f2)
          RUN_ID="${{ github.run_id }}"
          REMOTE_PROJECT_PATH="/home/${{ secrets.EC2_USER }}/terraform_runs/${REPO_NAME}/${RUN_ID}"
          TERRAFORM_DIR_IN_REPO="." # Or e.g., "terraform/"

          echo "Attempting to apply Terraform configuration on tools_ec2..."
          ssh -o StrictHostKeyChecking=yes \
            ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }} "cd ${REMOTE_PROJECT_PATH}/${TERRAFORM_DIR_IN_REPO} && terraform apply -auto-approve -input=false tfplan"
          echo "Terraform Apply command sent."

      - name: 'Clean up synced code on tools_ec2'
        if: always() # Run this step even if previous steps fail
        run: |
          REPO_NAME=$(echo "${{ github.repository }}" | cut -d'/' -f2)
          RUN_ID="${{ github.run_id }}"
          REMOTE_PROJECT_PATH="/home/${{ secrets.EC2_USER }}/terraform_runs/${REPO_NAME}/${RUN_ID}"
          echo "Cleaning up remote directory: ${REMOTE_PROJECT_PATH}"
          ssh -o StrictHostKeyChecking=yes \
            ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }} "rm -rf ${REMOTE_PROJECT_PATH}"
          echo "Cleanup command sent."

