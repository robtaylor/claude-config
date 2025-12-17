# C4 Model Concepts

The C4 model is a lean graphical notation technique for modeling the architecture of software systems. It provides a structured approach to creating architecture diagrams at different levels of abstraction.

## Table of Contents

1. [What is the C4 Model?](#what-is-the-c4-model)
2. [The Four Levels](#the-four-levels)
3. [Core Principles](#core-principles)
4. [When to Use C4 Diagrams](#when-to-use-c4-diagrams)
5. [Comparison with Other Approaches](#comparison-with-other-approaches)
6. [Best Practices](#best-practices)

---

## What is the C4 Model?

The C4 model was created by Simon Brown as a way to help software development teams describe and communicate software architecture, both during up-front design sessions and when retrospectively documenting an existing codebase.

**Key characteristics:**
- **Hierarchical** - Zoom in and out of different levels of abstraction
- **Simple** - Easy to learn, minimal notation
- **Tooling independent** - Can be drawn by hand or with tools
- **Audience-aware** - Different diagrams for different stakeholders

**The name "C4"** refers to the four levels:
1. **Context** - System in its environment
2. **Container** - High-level technical building blocks
3. **Component** - Internal structure of containers
4. **Code** - Implementation details (not covered by this skill)

---

## The Four Levels

The C4 model uses a hierarchical set of diagrams that provide different levels of abstraction, each useful for different audiences and purposes.

### Level 1: System Context

**Purpose**: Show the big picture - what the system does and who uses it.

**Scope**: A single software system and its interactions with users and other systems.

**Elements**:
- **People** - Users, actors, roles
- **Software Systems** - The system you're building and external systems it interacts with

**Audience**: Everyone - technical and non-technical stakeholders, including developers, operations, business stakeholders, and end users.

**Questions it answers**:
- What does this system do?
- Who uses it?
- What other systems does it depend on?
- What is inside/outside the system boundary?

**Example scenario**: "Show me how our e-commerce platform fits into the broader business ecosystem."

---

### Level 2: Container

**Purpose**: Zoom into the system to show high-level technical building blocks.

**Scope**: A single software system, decomposed into containers (applications, data stores, microservices, etc.).

**Elements**:
- **Containers** - Separately runnable/deployable units (web apps, mobile apps, databases, microservices, file systems, etc.)
- Technology choices become visible at this level

**Audience**: Technical stakeholders - developers, architects, operations teams.

**Questions it answers**:
- What are the main technical building blocks?
- How do they communicate?
- What technologies are used?
- What are the deployment units?

**Important**: A "container" in C4 is NOT a Docker container - it's any separately runnable/deployable unit. Examples:
- Web application running on a server
- Mobile app running on a device
- Database (PostgreSQL, MongoDB, etc.)
- Microservice
- Serverless function
- File system or content store

**Example scenario**: "Show me the runtime architecture of the e-commerce platform - what applications and databases does it consist of?"

---

### Level 3: Component

**Purpose**: Zoom into an individual container to show its internal structure.

**Scope**: A single container, decomposed into components.

**Elements**:
- **Components** - Groupings of related functionality encapsulated behind a well-defined interface (controllers, services, repositories, modules, packages)
- Relationships between components

**Audience**: Developers and architects working on the system.

**Questions it answers**:
- How is this container structured internally?
- What are the major components?
- How do components interact?
- What are the responsibilities of each component?

**Example scenario**: "Show me the internal structure of the API server - how is the business logic organized?"

---

### Level 4: Code (Out of Scope)

**Purpose**: Show implementation details using UML class diagrams, ER diagrams, etc.

**Scope**: Individual components mapped to code constructs (classes, interfaces, objects, functions, etc.).

**Note**: This level is typically handled by IDE tooling and is NOT covered by this C4 Diagrams Skill. The first three levels provide sufficient architectural documentation for most purposes.

---

## Core Principles

### 1. Abstraction-First Approach

Start with high-level context and progressively zoom in:
- **Context** → Understanding the ecosystem
- **Container** → Understanding the architecture
- **Component** → Understanding the structure
- **Code** → Understanding the implementation

Each level answers different questions for different audiences.

### 2. Consistent Notation

Use consistent notation across all levels:
- Boxes represent elements
- Lines represent relationships
- Labels describe interactions
- Colors and shapes distinguish element types

### 3. Audience Awareness

Different diagrams serve different stakeholders:
- **Non-technical** → Context diagrams only
- **Architects/Technical leads** → Context + Container
- **Developers** → Container + Component
- **Team members working on specific containers** → Component + Code

### 4. Essential Details Only

Include only what's necessary at each level:
- Context: System names and purposes (not implementation)
- Container: Technology choices and communication patterns (not internal structure)
- Component: Component responsibilities and interfaces (not code details)

Avoid cluttering diagrams with unnecessary detail.

---

## When to Use C4 Diagrams

### Up-Front Design

**Use C4 diagrams when:**
- Planning a new system or major feature
- Making architecture decisions
- Communicating design proposals
- Evaluating different architectural approaches

**Start with**: Context diagram to establish scope, then drill down to Container and Component as needed.

### Documentation

**Use C4 diagrams to:**
- Document existing systems
- Onboard new team members
- Create architecture decision records (ADRs)
- Support compliance and audit requirements

**Start with**: Understanding the current state, then create diagrams at each relevant level.

### Communication

**Use C4 diagrams to:**
- Facilitate architecture discussions
- Align teams on technical direction
- Present to stakeholders
- Create shared understanding

**Choose the level** based on your audience's needs and technical background.

### Evolution and Change

**Use C4 diagrams when:**
- Planning migrations (monolith → microservices)
- Refactoring large systems
- Identifying technical debt
- Tracking architectural evolution over time

**Create before/after diagrams** to show the transition.

---

## Comparison with Other Approaches

### C4 vs. UML

**UML** (Unified Modeling Language):
- Comprehensive notation with many diagram types
- Steep learning curve
- Often too detailed for high-level architecture discussions
- Strong at code-level modeling (Level 4)

**C4**:
- Focused specifically on architecture communication
- Simple, lightweight notation
- Optimized for hierarchical abstraction (Levels 1-3)
- Weaker at code-level details (Level 4)

**When to use C4**: Architecture discussions, documentation, onboarding.
**When to use UML**: Detailed design, complex domain modeling, formal specifications.

### C4 vs. ArchiMate

**ArchiMate**:
- Enterprise architecture standard
- Business, application, and technology layers
- Complex metamodel with many element types
- Often used for enterprise-wide modeling

**C4**:
- Software-centric
- Simpler, more accessible
- Focused on software systems specifically
- Better for agile teams

**When to use C4**: Software team architecture documentation.
**When to use ArchiMate**: Enterprise architecture, business/IT alignment.

### C4 vs. Informal Boxes and Lines

**Informal diagrams**:
- Quick to create
- No rules or standards
- Open to interpretation
- Often ambiguous

**C4**:
- Structured approach with clear rules
- Consistent notation
- Clear semantics for each level
- Unambiguous element types

**When to use C4**: Any scenario where clarity and consistency matter.
**When to use informal**: Very early brainstorming (but transition to C4 afterward).

---

## Best Practices

### 1. Start High, Drill Down

Always start with Context diagrams to establish the big picture, then zoom into Container and Component as needed.

**Don't jump straight to components** - you'll lose the forest for the trees.

### 2. One Diagram Type per File

Keep Context, Container, Component, and Sequence diagrams in separate files.

**Don't mix levels** - it creates confusion about scope and audience.

### 3. Show the "Interesting" Parts

Not every container needs a component diagram - focus on the most complex, important, or changing parts of your system.

**Don't create diagrams just for completeness** - create them when they provide value.

### 4. Keep Diagrams Current

Architecture diagrams are only useful if they reflect reality.

**Update diagrams when:**
- Adding new systems, containers, or components
- Changing technology choices
- Modifying communication patterns
- Refactoring structure

**Use version control** to track changes over time.

### 5. Use Meaningful Names and Descriptions

Every element should have:
- **ID**: Clear, sanitized identifier (e.g., `web_app`)
- **Name**: Human-readable label (e.g., "Web Application")
- **Description**: Purpose or responsibility (e.g., "Provides user interface for customers")

For containers and components, include **technology** (e.g., "React", "Node.js", "PostgreSQL").

### 6. Show Key Relationships

Focus on the most important interactions - don't try to show every possible connection.

**Include:**
- Primary data flows
- Critical dependencies
- Key integration points

**Exclude:**
- Trivial or obvious relationships
- Implementation details that clutter the diagram

### 7. Use Color and Styling Consistently

Apply consistent visual styling:
- **Your system** - One color scheme
- **External systems** - Different color/style (use _Ext variants)
- **Important elements** - Highlight with custom styling

**Don't use random colors** - they should convey meaning.

### 8. Consider Your Audience

Match the diagram level to your audience:
- **Executives, business stakeholders** → Context only
- **Architects, technical leads** → Context + Container
- **Development teams** → Container + Component
- **Individual developers** → Component (for their area)

**Don't overwhelm non-technical audiences** with Container or Component diagrams.

### 9. Supplement with Sequence Diagrams

Use Sequence diagrams to show:
- Complex workflows that span multiple containers
- API call chains
- Authentication/authorization flows
- Error handling paths

**Sequence diagrams complement structural diagrams** by showing temporal flow.

### 10. Iterate and Refine

Diagrams are living documents:
- Start simple, add detail as needed
- Get feedback from stakeholders
- Refine based on questions and confusion
- Remove obsolete elements

**Don't aim for perfection on the first pass** - evolve your diagrams over time.

---

## Additional Resources

- **[Diagram Types Guide](./diagram-types.md)** - Detailed guide on when to use each diagram type
- **[Syntax Reference](./syntax-reference.md)** - Complete C4-PlantUML syntax reference
- **[Best Practices](./best-practices.md)** - Practical tips for creating effective diagrams
- **Official C4 Model Website**: https://c4model.com/
- **C4-PlantUML Library**: https://github.com/plantuml-stdlib/C4-PlantUML
