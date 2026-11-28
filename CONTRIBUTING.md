# Contributing Guide

Thank you for taking the time to contribute to this repository in the Dataist ecosystem! You can contribute by reporting bugs, suggesting improvements, updating documentation, or submitting code.

## Getting Started & Local Setup

1. Fork or clone the repository:
   ```bash
   git clone <REPOSITORY_URL>
   cd <REPOSITORY_NAME>
   ```
   
    If applicable, copy .env.example to .env and configure the environment variables for your local setup.

    Install the project dependencies and run the service or module locally to verify everything works.

## Git Workflow & Branches

    Do not push changes directly to protected branches (such as main or heuristic).

    Create a dedicated branch for each task (e.g., feat/..., fix/..., or docs/...).

    Write clear, concise commit messages describing your changes.

    Before opening a Pull Request, ensure your changes align with the repository's structure and conventions.

## Code Quality Checks

Before finalizing a Pull Request, run the relevant linters, formatters, and static analysis tools for the project's language and make sure there are no unresolved errors or warnings. Also verify that no API keys, tokens, or sensitive credentials are included in your changes.
Submitting Issues & Pull Requests

    Bug Reports / Feature Requests: Provide a clear description of the issue or idea, steps to reproduce (for bugs), and the expected behavior.

    Pull Requests: Summarize what changed, why the change was made, and how it was tested in the PR description.

## License

By contributing to this repository, you agree that your contributions will be licensed under the terms of the project's LICENSE file.