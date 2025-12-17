# C4 Diagram Types Guide

Detailed guide on the four main C4 diagram types: Context, Container, Component, and Sequence. Learn when to use each type, what elements they contain, and see practical examples.

## Table of Contents

1. [Context Diagrams](#context-diagrams)
2. [Container Diagrams](#container-diagrams)
3. [Component Diagrams](#component-diagrams)
4. [Sequence Diagrams](#sequence-diagrams)
5. [Choosing the Right Diagram Type](#choosing-the-right-diagram-type)
6. [Combining Diagram Types](#combining-diagram-types)

---

## Context Diagrams

### Overview

**System Context diagrams** show your system at the highest level of abstraction, focusing on the system's place in the world.

**Key question**: "What does this system do and who uses it?"

### Elements

**People**:
- Users, actors, roles
- Both internal and external users
- Examples: Customer, Administrator, Support Agent

**Systems**:
- Your software system (the thing you're building)
- External systems (third-party services, legacy systems, other team's systems)
- Examples: Payment Gateway, Email Service, CRM System

### When to Use

**Use Context diagrams when you need to:**
- Explain the purpose and scope of a system
- Show stakeholders what the system does at a high level
- Identify system boundaries (what's in/out of scope)
- Document integrations with external systems
- Onboard new team members to the big picture
- Create a shared understanding across technical and non-technical audiences

**Ideal for:**
- Project kickoffs
- Architecture overviews
- Stakeholder presentations
- System documentation homepages

### What to Include

✅ **Include:**
- The system you're building (central focus)
- All people who interact with the system
- All external systems the system integrates with
- Key relationships showing data flow or interactions

❌ **Don't include:**
- Internal structure of your system (save for Container diagrams)
- Implementation technologies (save for Container/Component diagrams)
- Detailed workflows (use Sequence diagrams)
- Every minor integration (focus on the important ones)

### Example Scenarios

**E-commerce Platform**:
```
People: Customer, Admin, Support Agent
Your System: E-commerce Platform
External Systems: Payment Gateway, Shipping Provider, Email Service, Inventory System

Relationships:
- Customer → E-commerce Platform: Browses and purchases products
- E-commerce Platform → Payment Gateway: Processes payments
- E-commerce Platform → Shipping Provider: Arranges delivery
- E-commerce Platform → Email Service: Sends order confirmations
```

**Healthcare Records System**:
```
People: Patient, Doctor, Nurse, Administrator
Your System: Healthcare Records System
External Systems: Lab Results API, Insurance Verification Service, Pharmacy System

Relationships:
- Doctor → Healthcare Records System: Views and updates patient records
- Healthcare Records System → Lab Results API: Retrieves test results
- Healthcare Records System → Insurance Verification Service: Verifies patient coverage
```

### Audience

**Perfect for:**
- Executives and business stakeholders
- Product managers
- New team members
- Anyone who needs the "big picture"

**Technical depth**: Low - no implementation details.

---

## Container Diagrams

### Overview

**Container diagrams** zoom into your software system to show the high-level technical building blocks (containers).

**Key question**: "What are the major runtime components and how do they communicate?"

**Important**: "Container" means any separately runnable/deployable unit, NOT just Docker containers.

### Elements

**Containers**:
- Web applications (frontend)
- Mobile applications (iOS, Android)
- Backend APIs and services
- Databases (SQL, NoSQL)
- File systems and blob storage
- Message queues and event streams
- Microservices
- Serverless functions

**Technology choices** become explicit at this level.

### When to Use

**Use Container diagrams when you need to:**
- Show the runtime architecture of a system
- Document deployment units
- Explain technology choices
- Show communication patterns between technical building blocks
- Plan infrastructure and deployment strategy
- Understand system scalability and resilience

**Ideal for:**
- Architecture design sessions
- Technical documentation
- Infrastructure planning
- DevOps and deployment discussions

### What to Include

✅ **Include:**
- All major containers (apps, services, databases)
- Technology stack for each container
- Communication protocols (HTTP/REST, gRPC, message queues, etc.)
- Key external systems (as containers)
- Boundaries to group related containers (optional)

❌ **Don't include:**
- Internal structure of containers (save for Component diagrams)
- Code-level details (classes, functions)
- Every minor dependency
- Non-technical elements (unless bridging from Context diagram)

### Example Scenarios

**Microservices E-commerce Platform**:
```
Containers:
- Web Application (React): Customer-facing UI
- Mobile App (React Native): iOS and Android app
- API Gateway (Kong): Routes requests to services
- Product Service (Node.js): Manages product catalog
- Order Service (Java/Spring): Handles orders
- Payment Service (Python/Flask): Payment processing
- Product Database (PostgreSQL): Product data
- Order Database (MongoDB): Order data
- Message Queue (RabbitMQ): Asynchronous event processing
- Redis Cache (Redis): Session and data caching

Relationships:
- Web Application → API Gateway: Makes API calls (HTTPS/REST)
- API Gateway → Product Service: Routes product requests (HTTP)
- Product Service → Product Database: Reads/writes (JDBC)
- Order Service → Message Queue: Publishes order events (AMQP)
- Payment Service → Message Queue: Subscribes to order events (AMQP)
```

**Monolithic Application**:
```
Containers:
- Web Application (ASP.NET MVC): Full-stack monolith
- Database (SQL Server): Application data
- File Storage (Azure Blob): Document storage
- Background Workers (Windows Service): Scheduled tasks

Relationships:
- Web Application → Database: Reads/writes (SQL)
- Web Application → File Storage: Stores documents (HTTPS)
- Background Workers → Database: Processes scheduled jobs (SQL)
```

### Audience

**Perfect for:**
- Software architects
- Development teams
- DevOps and infrastructure engineers
- Technical leads

**Technical depth**: Medium - shows technology choices and communication patterns.

---

## Component Diagrams

### Overview

**Component diagrams** zoom into an individual container to show its internal structure and organization.

**Key question**: "How is this container structured and what are its major components?"

### Elements

**Components**:
- Controllers (API endpoints, request handlers)
- Services (business logic)
- Repositories (data access)
- Modules and packages
- Libraries and frameworks
- Internal utilities and helpers

**Relationships**:
- Component dependencies
- Data flow between components
- Layer boundaries (presentation, business, data)

### When to Use

**Use Component diagrams when you need to:**
- Document internal structure of complex containers
- Explain separation of concerns and layering
- Onboard developers to a specific service or application
- Plan refactoring or restructuring
- Show how business logic is organized
- Clarify component responsibilities

**Ideal for:**
- Developer onboarding
- Code reviews
- Refactoring plans
- Team discussions about structure

### What to Include

✅ **Include:**
- Major components with clear responsibilities
- Technology/framework for each component (Spring MVC, React Hooks, etc.)
- Key relationships showing dependencies
- Layer or module boundaries (optional)

❌ **Don't include:**
- Every single class or function (too detailed)
- Implementation details (code-level)
- Components with trivial or obvious responsibilities
- External systems (those belong in Container diagrams)

### Example Scenarios

**API Service (Node.js/Express)**:
```
Components:
- Routes (Express Router): HTTP endpoint definitions
- Controllers (Express Middleware): Request/response handling
- Services (Business Logic): Core application logic
- Repositories (Data Access): Database queries
- Validators (Validation): Input validation
- Authentication Middleware (JWT): Auth verification

Relationships:
- Routes → Controllers: Maps HTTP requests
- Controllers → Validators: Validates input
- Controllers → Services: Delegates business logic
- Services → Repositories: Persists/retrieves data
- Authentication Middleware → Controllers: Protects endpoints
```

**Web Application (React)**:
```
Components:
- Pages (React Components): Top-level page components
- Components (React Components): Reusable UI components
- Hooks (React Hooks): Shared stateful logic
- Services (API Clients): Backend communication
- State Management (Redux): Application state
- Routing (React Router): Navigation

Relationships:
- Pages → Components: Composes UI
- Components → Hooks: Uses shared logic
- Hooks → Services: Fetches data
- Services → State Management: Updates state
- Pages → Routing: Handles navigation
```

### Audience

**Perfect for:**
- Developers working on the specific container
- Code reviewers
- New team members learning the codebase
- Technical leads planning refactoring

**Technical depth**: High - shows internal organization and component structure.

---

## Sequence Diagrams

### Overview

**Sequence diagrams** show how elements (people, systems, containers, components) interact with each other over time.

**Key question**: "What is the sequence of interactions to accomplish a task or workflow?"

### Elements

**Participants** (any C4 element):
- People
- Systems
- Containers
- Components

**Relationships** (time-ordered):
- Synchronous calls (request/response)
- Asynchronous messages (events, queues)
- Return values

**Grouping constructs**:
- Dividers (`== Step Name ==`) to mark logical phases
- Groups to show sub-processes

### When to Use

**Use Sequence diagrams when you need to:**
- Document complex workflows spanning multiple systems
- Show API call chains and integrations
- Explain authentication or authorization flows
- Document error handling and retry logic
- Show temporal ordering of operations
- Clarify race conditions or timing issues

**Ideal for:**
- API documentation
- Integration guides
- Troubleshooting and debugging
- Understanding complex workflows

### What to Include

✅ **Include:**
- All participants involved in the workflow
- Time-ordered sequence of interactions
- Key data or parameters being passed
- Important decision points or branches
- Error handling paths (if relevant)
- Technology/protocol for each interaction

❌ **Don't include:**
- Every possible edge case (focus on main flow)
- Implementation details within participants
- Unrelated background processes
- Boundaries or structural groupings (see constraints below)

### Important Constraints

**⚠️ Sequence diagrams have unique syntax constraints:**

❌ **NO boundaries** - Cannot use `System_Boundary`, `Container_Boundary`, etc.
- Participants must be in a **flat list**
- Structural grouping not supported

❌ **NO _Ext suffixes** - Cannot use `Container_Ext`, `System_Ext`, etc.
- Use regular variants: `Container()`, `System()`, etc.
- External/internal distinction not needed in temporal flow

✅ **Flat participant list only**:
```plantuml
Person(user, "User", "Description")
Container(web_app, "Web App", "React", "Frontend")
Container(api, "API", "Node.js", "Backend")
ContainerDb(database, "Database", "PostgreSQL", "Data")
```

✅ **Time-ordered relationships**:
```plantuml
Rel(user, web_app, "Requests page", "HTTPS")
Rel(web_app, api, "Fetches data", "REST")
Rel(api, database, "Queries data", "SQL")
Rel(api, web_app, "Returns JSON", "HTTPS")
Rel(web_app, user, "Displays page", "HTML")
```

### Example Scenarios

**User Authentication Flow**:
```
Participants:
- User (Person)
- Web App (Container - React)
- API Server (Container - Node.js)
- Database (ContainerDb - PostgreSQL)
- Redis Cache (Container - Redis)

Sequence:
== User Login ==
1. User → Web App: Enters credentials (HTTPS)
2. Web App → API Server: POST /auth/login (REST)
3. API Server → Database: SELECT user by email (SQL)
4. API Server → API Server: Verify password hash
5. API Server → Redis Cache: Store session token (Redis Protocol)
6. API Server → Web App: Return JWT token (JSON)
7. Web App → User: Redirect to dashboard

== Subsequent Requests ==
8. User → Web App: Navigates to profile (HTTPS)
9. Web App → API Server: GET /profile with JWT (REST)
10. API Server → Redis Cache: Verify session token (Redis Protocol)
11. API Server → Database: SELECT user profile (SQL)
12. API Server → Web App: Return profile data (JSON)
13. Web App → User: Display profile
```

**Payment Processing Flow**:
```
Participants:
- Customer (Person)
- Web App (Container)
- Order Service (Container)
- Payment Service (Container)
- Payment Gateway (Container - External)
- Message Queue (Container)

Sequence:
== Checkout Process ==
1. Customer → Web App: Submits order
2. Web App → Order Service: POST /orders (REST)
3. Order Service → Message Queue: Publish "OrderCreated" event (AMQP)
4. Payment Service → Message Queue: Consumes "OrderCreated" event
5. Payment Service → Payment Gateway: Process payment (API)
6. Payment Gateway → Payment Service: Return result (API Response)
7. Payment Service → Message Queue: Publish "PaymentCompleted" event
8. Order Service → Message Queue: Consumes "PaymentCompleted" event
9. Order Service → Web App: Update order status (Webhook)
10. Web App → Customer: Display confirmation
```

### Audience

**Perfect for:**
- Developers implementing integrations
- Technical writers creating API documentation
- Support engineers troubleshooting issues
- Architects reviewing workflows

**Technical depth**: Medium to High - shows temporal flow and protocols.

---

## Choosing the Right Diagram Type

Use this decision tree to select the appropriate diagram type:

### Ask: "What level of abstraction do I need?"

**Big Picture (ecosystem view)** → **Context Diagram**
- Shows: Systems and their relationships
- Audience: Everyone
- Example: "How does our platform fit into the business?"

**Runtime Architecture (deployment view)** → **Container Diagram**
- Shows: Applications, services, databases
- Audience: Technical teams
- Example: "What are we deploying?"

**Internal Structure (code organization)** → **Component Diagram**
- Shows: Components within a container
- Audience: Developers
- Example: "How is this service organized?"

**Temporal Flow (process view)** → **Sequence Diagram**
- Shows: Interactions over time
- Audience: Developers and architects
- Example: "How does this workflow execute?"

### Ask: "Who is my audience?"

**Non-technical stakeholders** → **Context Diagram**

**Technical stakeholders (architects, leads)** → **Context + Container Diagrams**

**Development team** → **Container + Component Diagrams**

**Developers implementing features** → **Component + Sequence Diagrams**

### Ask: "What question am I answering?"

| Question | Diagram Type |
|----------|--------------|
| What does the system do? | Context |
| Who uses the system? | Context |
| What systems does it integrate with? | Context |
| What are the deployment units? | Container |
| What technologies are used? | Container |
| How do services communicate? | Container |
| How is this service structured? | Component |
| What are the layers? | Component |
| How does this workflow execute? | Sequence |
| What's the API call chain? | Sequence |

---

## Combining Diagram Types

Most projects benefit from multiple diagram types working together:

### Small Project (Monolith)

**Recommended diagrams:**
1. **Context** - Show the monolith and external integrations
2. **Container** - Show the monolith, database, and supporting services
3. **Component** (1-2) - Show internal structure of the most complex parts
4. **Sequence** (optional) - Document critical workflows

### Medium Project (Microservices)

**Recommended diagrams:**
1. **Context** - Show all microservices as a single "system"
2. **Container** - Show all microservices, databases, and message queues
3. **Component** (3-5) - Show internal structure of key services
4. **Sequence** (2-3) - Document complex cross-service workflows

### Large Project (Multiple Systems)

**Recommended diagrams:**
1. **Context** (multiple) - One per major system or business domain
2. **Container** (multiple) - One per system, showing its containers
3. **Component** (5-10) - Focus on complex or frequently changed containers
4. **Sequence** (5-10) - Document critical integrations and workflows

### Progressive Disclosure Strategy

Start simple and add detail as needed:

**Phase 1: High-level overview**
- Create Context diagram
- Review with stakeholders

**Phase 2: Technical architecture**
- Create Container diagram
- Identify key deployment units
- Document technology choices

**Phase 3: Internal structure**
- Create Component diagrams for complex containers
- Focus on areas with the most churn or complexity

**Phase 4: Workflows**
- Create Sequence diagrams for critical flows
- Document complex integrations
- Show error handling paths

---

## Additional Resources

- **[C4 Model Concepts](./c4-model.md)** - Theory and principles of the C4 model
- **[Syntax Reference](./syntax-reference.md)** - Complete C4-PlantUML syntax guide
- **[Best Practices](./best-practices.md)** - Tips for creating effective diagrams
- **Official C4 Model Website**: https://c4model.com/
