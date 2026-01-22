---
name: bootstrap-new-project
description: Bootstrap a new full-stack project with systematic infrastructure, backend (Node.js + Clean Architecture + CQRS), frontend (React + TypeScript + Vite + MUI), and agent placeholders
---

# Bootstrap New Project Skill

This skill creates a complete full-stack project structure following systematic development best practices.

## What This Skill Does

When invoked, this skill will:

1. **Verify Infrastructure Dependencies**
   - Check if Docker is installed
   - Provide installation instructions if missing

2. **Create Backend Structure** (Node.js + TypeScript)
   - Clean Architecture file structure (domain, interface, usecases)
   - CQRS pattern implementation
   - OpenAPI specification setup
   - Swagger API documentation at `/api-docs`
   - Health check endpoint at `/health`
   - Express.js server configuration
   - TypeScript configuration optimized for backend development

3. **Create Frontend Structure** (React + TypeScript + Vite + MUI)
   - Vite build tool setup
   - Material-UI (MUI) component library
   - Atomic design structure (atoms, molecules, organisms, templates, pages)
   - Landing page component
   - TypeScript configuration optimized for React
   - Basic routing setup

4. **Create Database Placeholder**
   - Reserved directory structure for future database implementation
   - README placeholder for database design

5. **Create Agent Placeholder**
   - Reserved directory structure for agentic AI workflows
   - README placeholder for agent implementation

## Project Structure Created

```
project-root/
├── docker-compose.yml
├── .dockerignore
├── .gitignore
├── README.md
│
├── backend/
│   ├── package.json
│   ├── tsconfig.json
│   ├── .env.example
│   ├── Dockerfile
│   ├── src/
│   │   ├── index.ts
│   │   ├── server.ts
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── value-objects/
│   │   ├── usecases/
│   │   │   ├── commands/
│   │   │   └── queries/
│   │   ├── interface/
│   │   │   ├── http/
│   │   │   │   ├── routes/
│   │   │   │   ├── controllers/
│   │   │   │   └── middleware/
│   │   │   └── dto/
│   │   ├── infrastructure/
│   │   │   ├── database/
│   │   │   ├── repositories/
│   │   │   └── config/
│   │   └── shared/
│   │       ├── types/
│   │       └── utils/
│   └── openapi.yaml
│
├── frontend/
│   ├── package.json
│   ├── tsconfig.json
│   ├── tsconfig.node.json
│   ├── vite.config.ts
│   ├── index.html
│   ├── .env.example
│   ├── Dockerfile
│   ├── public/
│   └── src/
│       ├── main.tsx
│       ├── App.tsx
│       ├── components/
│       │   ├── atoms/
│       │   ├── molecules/
│       │   ├── organisms/
│       │   ├── templates/
│       │   └── pages/
│       │       └── LandingPage.tsx
│       ├── theme/
│       │   └── index.ts
│       ├── routes/
│       │   └── index.tsx
│       └── assets/
│
├── database/
│   └── README.md
│
└── agent/
    └── README.md
```

## Usage

Invoke this skill when starting a new full-stack project:

```bash
/systematic-dev-kit:bootstrap-new-project
```

The skill will interactively prompt for:
- Project name
- Project root directory location
- Whether to initialize git repository
- Whether to install dependencies immediately

## Installation Steps Performed

### Backend Dependencies
- express
- cors
- dotenv
- swagger-ui-express
- swagger-jsdoc
- zod (for validation)
- Development: typescript, @types/node, @types/express, tsx, nodemon

### Frontend Dependencies
- react
- react-dom
- react-router-dom
- @mui/material
- @emotion/react
- @emotion/styled
- Development: typescript, @types/react, @types/react-dom, @vitejs/plugin-react, vite

## Post-Bootstrap Instructions

After the skill completes, you should:

1. Review the generated `.env.example` files and create `.env` files
2. Customize the OpenAPI specification in `backend/openapi.yaml`
3. Start development with Docker Compose: `docker-compose up`
4. Access the application:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:4000
   - API Documentation: http://localhost:4000/api-docs
   - Health Check: http://localhost:4000/health

## Best Practices Enforced

- **Clean Architecture**: Clear separation of concerns (domain, usecases, interface, infrastructure)
- **CQRS Pattern**: Commands and queries separated for better scalability
- **OpenAPI First**: API design documented before implementation
- **Type Safety**: Full TypeScript coverage in both backend and frontend
- **Atomic Design**: Component reusability and maintainability
- **Docker Ready**: Containerized services for consistent environments
- **Environment Configuration**: Proper secrets management with .env files

## Instructions for Claude Code

When this skill is invoked:

1. **Ask for project details** using AskUserQuestion:
   - Project name (default: "my-project")
   - Target directory (default: current directory)
   - Initialize git? (yes/no)
   - Install dependencies? (yes/no)

2. **Check Docker installation**:
   ```bash
   docker --version
   ```
   If not installed, provide platform-specific installation instructions and halt.

3. **Create directory structure**:
   - Use mkdir -p for all nested directories
   - Create all files following the structure above

4. **Generate backend files**:
   - package.json with all required dependencies
   - tsconfig.json optimized for Node.js backend
   - Express server with health endpoint
   - OpenAPI specification with basic structure
   - Swagger UI integration
   - Sample CQRS command and query handlers
   - Clean Architecture folder structure with README files

5. **Generate frontend files**:
   - package.json with React, Vite, MUI dependencies
   - Vite configuration
   - tsconfig.json optimized for React
   - MUI theme configuration
   - Atomic design folder structure
   - Landing page component using MUI
   - Basic routing setup
   - index.html entry point

6. **Generate Docker configuration**:
   - Dockerfile for backend (Node.js)
   - Dockerfile for frontend (Nginx for production)
   - docker-compose.yml orchestrating all services

7. **Generate placeholder directories**:
   - database/README.md with notes about future implementation
   - agent/README.md with notes about agentic AI workflows

8. **Generate root-level files**:
   - .gitignore (node_modules, .env, dist, build, etc.)
   - .dockerignore
   - README.md with project overview and getting started instructions

9. **Initialize git** (if requested):
   ```bash
   git init
   git add .
   git commit -m "feat: bootstrap project with systematic-dev-kit"
   ```

10. **Install dependencies** (if requested):
    ```bash
    cd backend && npm install
    cd ../frontend && npm install
    ```

11. **Provide summary** to the user:
    - List all created files and directories
    - Show next steps
    - Display access URLs for services

## Error Handling

- If Docker is not installed, provide clear installation instructions and stop
- If target directory already exists and is not empty, ask user to confirm overwrite
- If npm install fails, report the error but don't halt (user can install manually)
- Validate project name (no spaces, special characters)

## Future Enhancements

- Database schema design integration (PostgreSQL/MongoDB options)
- Authentication/authorization boilerplate
- Testing setup (Jest, React Testing Library)
- CI/CD pipeline configuration
- Agent workflow templates (LangChain, LangGraph patterns)
