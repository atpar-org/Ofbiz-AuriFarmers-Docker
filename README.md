Okay, here is the README content enhanced with Markdown styling to improve readability and differentiate instructions, commands, and explanations.

I've used:

*   **Headings (`##`, `###`)** for structure.
*   **Emojis** for visual cues on headings.
*   **Bold text (`**bold**`)** for emphasis and key terms.
*   **Inline code (`code`)** for commands, filenames, variables, paths, and technical terms within sentences.
*   **Code blocks (```bash ... ```)** for multi-line commands and file structure.
*   **Numbered and bulleted lists** for steps and points.
*   **Blockquotes (`>`)** for important notes.

```markdown
# Ofbiz & ACM Docker Compose Setup

This repository provides a Docker Compose setup to run the **Ofbiz ETH Postgres** database and the **ACM** project (*assuming ACM means Alfresco Content Management - adjust if incorrect*), including its database dependencies (**Postgres** and **MySQL**).

The setup supports multiple environments (`dev`, `staging`, `prod`) using separate configuration files and helper scripts for easy management.

## ✅ Prerequisites

*   **Docker:** Ensure Docker Engine is installed and running. [Install Docker](https://docs.docker.com/engine/install/)
*   **Docker Compose:** Ensure Docker Compose (v2 or later recommended) is installed. [Install Docker Compose](https://docs.docker.com/compose/install/)
*   **Linux/macOS Environment:** Required for the `chown` command to set volume permissions correctly. On Windows, you might need WSL (Windows Subsystem for Linux) or adjust permissions manually based on your Docker setup.
*   **Git:** To clone the repository (if applicable).

## 📂 Project Structure

```
.
├── docker-compose.base.yml     # Common services and base configurations
├── docker-compose.dev.yml      # Development environment overrides
├── docker-compose.staging.yml  # Staging environment overrides
├── docker-compose.prod.yml     # Production environment overrides
├── .env.dev                    # Environment variables for Development
├── .env.staging                # Environment variables for Staging
├── .env.prod                   # Environment variables for Production
├── compose-up.sh               # Helper script to start services
├── compose-down.sh             # Helper script to stop services
└── data/                       # Directory for persistent data volumes (created during setup)
├── acm-content/
└── acm-db-data/
├── mysql/
├── postgres/
└── postgres-replica/
```

## ⚙️ Initial Setup

Before running the application for the first time, follow these steps:

1.  **Clone the Repository** (if you haven't already):
    ```bash
    git clone <your-repository-url>
    cd <your-repository-directory>
    ```

2.  **Create Required Directories:**
    These directories will be used for persistent data storage (volumes).
    ```bash
    mkdir -p ./data/acm-db-data/mysql
    mkdir -p ./data/acm-db-data/postgres
    mkdir -p ./data/acm-db-data/postgres-replica
    mkdir -p ./data/acm-content
    ```

3.  **Set Volume Permissions:**
    These commands ensure the containers have the correct permissions to write to the mounted volumes. The User IDs (**UID**) and Group IDs (**GID**) should match the users running inside the respective containers.

    ```bash
    # Set ownership for MySQL data volume (user ID 999, group ID 999)
    sudo chown -R 999:999 ./data/acm-db-data/mysql

    # Set ownership for PostgreSQL data volume (user ID 70, group ID 70)
    sudo chown -R 70:70 ./data/acm-db-data/postgres

    # Set ownership for ACM content volume (user ID 999, group ID 999 - adjust if needed)
    sudo chown -R 999:999 ./data/acm-content

    # Note: Permissions for postgres-replica might depend on the specific image/setup.
    # Adjust the command below if necessary, potentially using 70:70 like the primary.
    sudo chown -R 70:70 ./data/acm-db-data/postgres-replica
    ```
    > **Important:** Using `sudo` requires administrator privileges. Ensure these UIDs/GIDs (`999`, `70`) match the container users. Incorrect permissions are a common issue.

4.  **Make Helper Scripts Executable:**
    ```bash
    chmod +x compose-up.sh
    chmod +x compose-down.sh
    ```

5.  **Configure Environment Variables:**
    Review and update the `.env.dev`, `.env.staging`, and `.env.prod` files with your specific configurations (database passwords, ports, secrets, etc.) before starting the services.
    > **Security Note:** Do **not** commit sensitive information directly into Git history, especially for `.env.prod`. Consider using a `.gitignore` file and managing production secrets securely.

## 🚀 Running the Application

Use the `compose-up.sh` script to start the Docker containers for the desired environment.

**Syntax:** `./compose-up.sh <environment> [options] [service...]`

*   `<environment>`: `dev`, `staging`, or `prod`.
*   `[options]`: Optional flags like `-d` for detached mode.
*   `[service...]`: Optional list of specific services to start.

**Examples:**

*   **Start Development Environment (Attached Mode):**
    ```bash
    ./compose-up.sh dev
    ```
    *_(You will see logs in your terminal. Press `Ctrl+C` to stop.)*

*   **Start Development Environment (Detached Mode):**
    ```bash
    ./compose-up.sh dev -d
    ```
    *_(Containers run in the background.)*

*   **Start Staging Environment (Detached Mode):**
    ```bash
    ./compose-up.sh staging -d
    ```

*   **Start Production Environment (Detached Mode):**
    ```bash
    ./compose-up.sh prod -d
    ```

*   **Start Only Specific Services** (e.g., `redis` and `ofbiz` in `dev`):
    ```bash
    ./compose-up.sh dev redis ofbiz
    ```
    *_(Run in detached mode by adding `-d`):*
    ```bash
    ./compose-up.sh dev -d redis ofbiz
    ```

## 🧹 Stopping the Application

Use the `compose-down.sh` script to stop the Docker containers.

**Syntax:** `./compose-down.sh <environment> [service...]`

*   `<environment>`: `dev`, `staging`, or `prod`.
*   `[service...]`: Optional list of specific services to stop. If omitted, all services for the environment are stopped and **cleaned up** (containers, default network, anonymous volumes removed).

**Examples:**

*   **Stop All Services in Development Environment (Full Cleanup):**
    ```bash
    ./compose-down.sh dev
    ```
    *_(This is the standard way to fully stop and clean up an environment.)*

*   **Stop Only Specific Services** (e.g., `redis` and `ofbiz` in `prod`) without removing networks or named volumes:
    ```bash
    ./compose-down.sh prod redis ofbiz
    ```
    *_(Useful if you only want to temporarily stop specific containers without losing data or network settings.)*

*   **Stop All Services in Production Environment (Full Cleanup):**
    ```bash
    ./compose-down.sh prod
    ```

## 📄 Environment Configuration

Environment-specific variables (like database credentials, API keys, hostnames, etc.) are managed using `.env` files:

| Environment | Configuration File(s)                                      | Variables File |
| :---------- | :--------------------------------------------------------- | :------------- |
| Development | `docker-compose.base.yml`<br/>`docker-compose.dev.yml`     | `.env.dev`     |
| Staging     | `docker-compose.base.yml`<br/>`docker-compose.staging.yml` | `.env.staging` |
| Production  | `docker-compose.base.yml`<br/>`docker-compose.prod.yml`     | `.env.prod`    |

The `compose-up.sh` script automatically selects the correct `.env` file based on the specified environment. Ensure these files are present and correctly configured before starting the services.

## 📜 Viewing Logs

You can view the logs of the running containers.

*   **View Logs for All Services in an Environment** (e.g., `dev`):
    *(Requires specifying the compose files manually or potentially adapting the script)*
    ```bash
    # Using docker-compose directly (recommended for clarity)
    docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml logs -f
    ```

*   **View Logs for Specific Services** (e.g., `ofbiz` in `dev`):
    ```bash
    # Using docker-compose directly
    docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml logs -f ofbiz

    # Or using docker compose ps to find container name and then logs
    # docker compose -p dev ps # (Find service name, e.g., dev-ofbiz-1)
    # docker logs -f dev-ofbiz-1
    ```
    *(Replace `dev` and `ofbiz` with the relevant environment and service name)*

*   **Using Docker Desktop:** If you use Docker Desktop, you can easily view container logs through its graphical interface by selecting the container.

## ⚠️ Notes

*   Ensure the `chown` commands in the setup are executed correctly. **Incorrect volume permissions** are a common source of issues, especially for databases failing to start or write data.
*   The specific **UIDs/GIDs** (`999`, `70`) used in the `chown` commands are based on the user configurations *inside* common official Docker images (e.g., standard `postgres` image often uses UID/GID `70`, `mysql` often uses `999`). If you use custom images or configurations, these might need adjustment. Check the image documentation if unsure.
*   **Regularly back up** the data stored in the `./data` directory, especially in `staging` and `production` environments. This directory contains your persistent database and content data.
```

This version should be significantly easier to read and follow on platforms that render Markdown, like GitHub, GitLab, etc.