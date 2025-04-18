```markdown
# Ofbiz & ACM Docker Compose Setup

This repository provides a Docker Compose setup to run the **Ofbiz ETH Postgres** database and the **ACM** project (*assuming ACM means Alfresco Content Management - adjust if incorrect*), including its database dependencies (**Postgres** and **MySQL**).

The setup supports multiple environments (`dev`, `staging`, `prod`) using separate configuration files and a unified helper script (`compose.sh`) for easy management.

## ✅ Prerequisites

*   **Docker:** Ensure Docker Engine is installed and running. [Install Docker](https://docs.docker.com/engine/install/)
*   **Docker Compose:** Ensure Docker Compose (v2 or later recommended) is installed. [Install Docker Compose](https://docs.docker.com/compose/install/)
*   **Linux/macOS Environment:** Required for the `chown` command to set volume permissions correctly. On Windows, you might need WSL (Windows Subsystem for Linux) or adjust permissions manually based on your Docker setup.
*   **Git:** To clone the repository (if applicable).
*   **Bash:** Required to run the `compose.sh` helper script.

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
├── compose.sh                  # Unified helper script for Docker Compose commands
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

4.  **Make Helper Script Executable:**
    ```bash
    chmod +x compose.sh
    ```

5.  **Configure Environment Variables:**
    Review and update the `.env.dev`, `.env.staging`, and `.env.prod` files with your specific configurations (database passwords, ports, secrets, etc.) before starting the services.
    > **Security Note:** Do **not** commit sensitive information directly into Git history, especially for `.env.prod`. Consider using a `.gitignore` file and managing production secrets securely.

## 🚀 Running & Managing the Application

Use the unified `compose.sh` script to manage the Docker containers for the desired environment. It acts as a wrapper around `docker-compose`, setting the correct environment file and compose files.

**Syntax:** `./compose.sh <environment> [docker-compose-command] [options] [service...]`

*   `<environment>`: `dev`, `staging`, or `prod`.
*   `[docker-compose-command]`: The `docker-compose` command to execute (e.g., `up`, `down`, `ps`, `logs`, `build`, `pull`, `stop`, `start`, `exec`).
*   `[options]`: Options for the `docker-compose` command (e.g., `-d` for detached mode with `up`).
*   `[service...]`: Optional list of specific services to target.

**Examples:**

*   **Start Development Environment (Attached Mode):**
    ```bash
    ./compose.sh dev up
    ```
    *_(You will see logs in your terminal. Press `Ctrl+C` to stop.)*

*   **Start Development Environment (Detached Mode):**
    ```bash
    ./compose.sh dev up -d
    ```
    *_(Containers run in the background.)*

*   **Start Staging Environment (Detached Mode):**
    ```bash
    ./compose.sh staging up -d
    ```

*   **Start Production Environment (Detached Mode):**
    ```bash
    ./compose.sh prod up -d
    ```

*   **Start Only Specific Services** (e.g., `redis` and `ofbiz` in `dev`, detached):
    ```bash
    ./compose.sh dev up -d redis ofbiz
    ```

*   **Stop All Services & Remove Containers/Networks (Full Cleanup) for Dev:**
    ```bash
    ./compose.sh dev down
    ```
    *_(This is the standard way to fully stop and clean up an environment.)*

*   **Stop Only Specific Services** (e.g., `redis` and `ofbiz` in `prod`):
    ```bash
    ./compose.sh prod stop redis ofbiz
    ```
    *_(Useful for temporarily stopping containers without losing data or network settings.)*

*   **Stop and Remove a Specific Service Container** (using the script's custom command):
    ```bash
    ./compose.sh prod remove redis
    ```
    *_(This stops and removes only the `redis` container for the `prod` environment.)*

*   **View Running Services for Staging:**
    ```bash
    ./compose.sh staging ps
    ```

*   **Build Images for Production:**
    ```bash
    ./compose.sh prod build
    ```

*   **Execute a Command in a Running Container** (e.g., bash shell in `ofbiz` container for `dev`):
    ```bash
    ./compose.sh dev exec ofbiz bash
    ```

## 📄 Environment Configuration

Environment-specific variables (like database credentials, API keys, hostnames, etc.) are managed using `.env` files:

| Environment | Configuration File(s)                                      | Variables File |
| :---------- | :--------------------------------------------------------- | :------------- |
| Development | `docker-compose.base.yml`<br/>`docker-compose.dev.yml`     | `.env.dev`     |
| Staging     | `docker-compose.base.yml`<br/>`docker-compose.staging.yml` | `.env.staging` |
| Production  | `docker-compose.base.yml`<br/>`docker-compose.prod.yml`     | `.env.prod`    |

The `compose.sh` script automatically selects the correct `.env` file based on the specified environment and exports its variables before running `docker-compose`. Ensure these files are present and correctly configured.

## 📜 Viewing Logs

You can view the logs of the running containers using the `logs` command via the helper script.

*   **View Logs for All Services (Following)** (e.g., `dev` environment):
    ```bash
    ./compose.sh dev logs -f
    ```

*   **View Logs for Specific Services (Following)** (e.g., `ofbiz` in `dev`):
    ```bash
    ./compose.sh dev logs -f ofbiz
    ```
    *(Replace `dev` and `ofbiz` with the relevant environment and service name. Remove `-f` to view logs without following.)*

*   **Using Docker Desktop:** If you use Docker Desktop, you can easily view container logs through its graphical interface by selecting the container.

## ⚠️ Notes

*   Ensure the `chown` commands in the setup are executed correctly. **Incorrect volume permissions** are a common source of issues, especially for databases failing to start or write data.
*   The specific **UIDs/GIDs** (`999`, `70`) used in the `chown` commands are based on the user configurations *inside* common official Docker images (e.g., standard `postgres` image often uses UID/GID `70`, `mysql` often uses `999`). If you use custom images or configurations, these might need adjustment. Check the image documentation if unsure.
*   **Regularly back up** the data stored in the `./data` directory, especially in `staging` and `production` environments. This directory contains your persistent database and content data.
*   The `compose.sh` script requires `bash` to run correctly.
```