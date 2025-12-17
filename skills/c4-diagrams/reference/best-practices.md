# C4 Diagram Best Practices

Practical guidance for creating clear, effective, and maintainable C4 architecture diagrams. Learn design patterns, layout tips, naming conventions, and common pitfalls to avoid.

## Table of Contents

1. [General Principles](#general-principles)
2. [Naming Conventions](#naming-conventions)
3. [Layout and Organization](#layout-and-organization)
4. [Relationship Design](#relationship-design)
5. [Using Boundaries Effectively](#using-boundaries-effectively)
6. [Styling and Visual Design](#styling-and-visual-design)
7. [Documentation and Maintenance](#documentation-and-maintenance)
8. [Common Anti-Patterns](#common-anti-patterns)
9. [Performance and Scalability](#performance-and-scalability)

---

## General Principles

### 1. Keep It Simple

**Guideline**: Diagrams should be understandable at a glance.

✅ **Do:**
- Show only essential elements
- Focus on the most important relationships
- Use clear, concise labels
- Avoid visual clutter

❌ **Don't:**
- Include every possible element or relationship
- Add unnecessary detail
- Create overly complex diagrams with dozens of elements

**Example**: For a Container diagram, show the 6-8 main containers, not all 30 microservices.

### 2. One Purpose per Diagram

**Guideline**: Each diagram should answer a specific question or serve a specific audience.

✅ **Do:**
- Create separate diagrams for different concerns
- Keep Context, Container, and Component diagrams separate
- Create focused Sequence diagrams for specific workflows

❌ **Don't:**
- Mix abstraction levels in a single diagram
- Try to show everything in one "mega diagram"
- Combine structural and temporal views

### 3. Design for Your Audience

**Guideline**: Match the technical depth to your audience's needs.

✅ **Do:**
- Use Context diagrams for non-technical stakeholders
- Add Container details for technical discussions
- Create Component diagrams for developers

❌ **Don't:**
- Show implementation details to business stakeholders
- Keep diagrams too high-level for developers

### 4. Iterate and Evolve

**Guideline**: Diagrams are living documents that evolve with the system.

✅ **Do:**
- Update diagrams when architecture changes
- Review diagrams regularly
- Get feedback and incorporate suggestions
- Version control your diagrams

❌ **Don't:**
- Create diagrams once and forget them
- Let diagrams become stale and inaccurate
- Treat diagrams as immutable

---

## Naming Conventions

### Element IDs

**Guideline**: Use consistent, descriptive, and valid identifiers.

✅ **Do:**
```plantuml
Person(customer, "Customer", "...")
System(order_system, "Order System", "...")
Container(web_app, "Web Application", "React", "...")
Component(user_service, "User Service", "Spring", "...")
```

**Pattern**: `{type}_{name}` in snake_case
- Examples: `api_gateway`, `product_db`, `payment_service`

❌ **Don't:**
```plantuml
Person(p1, "Customer", "...")           // Non-descriptive ID
System(order-system, "Order System", "...") // Hyphen (invalid)
Container(WebApp, "Web Application", "...") // Inconsistent case
```

### Element Names

**Guideline**: Use clear, business-friendly names that are meaningful to stakeholders.

✅ **Do:**
- "Customer Portal" (clear purpose)
- "Inventory Management API" (descriptive)
- "Payment Processing Service" (explains function)
- "User Database" (obvious content)

❌ **Don't:**
- "System A" (meaningless)
- "Thing" (vague)
- "svc-ord-proc-v2" (cryptic abbreviation)
- "The Big Database" (unprofessional)

### Element Descriptions

**Guideline**: Describe the responsibility or purpose, not the implementation.

✅ **Do:**
- "Handles customer orders and payment processing"
- "Stores user profiles and authentication credentials"
- "Provides REST API for mobile and web clients"

❌ **Don't:**
- "Node.js app" (that's the technology, not the purpose)
- "Contains 47 tables" (too detailed)
- "The main thing" (not specific)

### Relationship Labels

**Guideline**: Use active voice and describe the interaction clearly.

✅ **Do:**
- "Places orders"
- "Reads/writes customer data"
- "Sends order confirmation emails"
- "Fetches product information"

❌ **Don't:**
- "Uses" (too vague)
- "Talks to" (unprofessional)
- "Does stuff" (meaningless)
- "Connection" (obvious)

---

## Layout and Organization

### Visual Flow

**Guideline**: Arrange elements to show logical flow, typically top-to-bottom or left-to-right.

✅ **Do:**
- Position users/actors at the top or left
- Show data flow direction with layout
- Group related elements together
- Use directional relationships (Rel_D, Rel_R) to guide layout

**Example flow** (top to bottom):
```
User
  ↓
Web Application
  ↓
API Server
  ↓
Database
```

❌ **Don't:**
- Place elements randomly
- Create confusing or circular layouts
- Cross relationship lines unnecessarily

### Grouping with Boundaries

**Guideline**: Use boundaries to show ownership, deployment units, or logical grouping.

✅ **Do:**
- Group microservices by team ownership
- Show containers within a deployment boundary
- Indicate system/subsystem boundaries

**Example**:
```plantuml
System_Boundary(backend, "Backend Services") {
  Container(api, "API Gateway", "Kong", "Routes requests")
  Container(auth_service, "Auth Service", "Node.js", "Authentication")
  Container(user_service, "User Service", "Java", "User management")
}
```

❌ **Don't:**
- Use boundaries arbitrarily without meaning
- Over-nest boundaries (too many levels)
- Create boundaries with only one element

### Element Density

**Guideline**: Aim for 5-12 elements per diagram for optimal clarity.

✅ **Do:**
- Create multiple focused diagrams if needed
- Split complex systems across several Container diagrams
- Focus Component diagrams on specific subsystems

❌ **Don't:**
- Create diagrams with 20+ elements (too cluttered)
- Put everything in one diagram (information overload)

---

## Relationship Design

### Relationship Clarity

**Guideline**: Make relationships meaningful and specific.

✅ **Do:**
```plantuml
Rel(web_app, api, "Makes API requests", "HTTPS/REST")
Rel(api, database, "Reads and writes orders", "JDBC/SQL")
Rel(service, message_queue, "Publishes order events", "AMQP")
```

❌ **Don't:**
```plantuml
Rel(web_app, api, "Communicates")  // Too vague
Rel(api, database, "Uses")         // Not specific
Rel(service, queue, "Sends stuff") // Unprofessional
```

### Technology/Protocol Information

**Guideline**: Include technology or protocol when it's relevant or non-obvious.

✅ **Include technology when:**
- Multiple protocols are in use (REST, gRPC, WebSocket)
- Integration details matter (HTTPS, JDBC, AMQP)
- Specific technology is important (GraphQL, Kafka, Redis Protocol)

**Example**:
```plantuml
Rel(mobile_app, api, "Fetches data", "REST/JSON")
Rel(api, cache, "Checks cache", "Redis Protocol")
Rel(service, event_bus, "Publishes events", "Kafka")
```

❌ **Omit when obvious:**
```plantuml
Rel(api, database, "Queries data", "SQL")  // SQL is obvious for DB
```

### Bidirectional Relationships

**Guideline**: Use sparingly and only when both directions are equally important.

✅ **Use BiRel when:**
- Two services communicate symmetrically (peer-to-peer)
- WebSocket or bidirectional streaming connection
- True two-way data synchronization

**Example**:
```plantuml
BiRel(service_a, service_b, "Sync data", "gRPC streaming")
```

❌ **Don't use when:**
- One direction is request, other is response (normal request/response)
- Relationship is primarily one-way

---

## Using Boundaries Effectively

### When to Use Boundaries

**Guideline**: Use boundaries to convey meaningful grouping, not just for aesthetics.

✅ **Good reasons to use boundaries:**
- **Team ownership**: "Frontend Team", "Backend Team"
- **Deployment units**: "AWS us-east-1", "On-Premises Data Center"
- **Security zones**: "DMZ", "Internal Network", "Secure Zone"
- **Business domains**: "Order Management", "Inventory", "Shipping"
- **Technology layers**: "Presentation Layer", "Business Logic", "Data Layer"

❌ **Poor reasons:**
- Arbitrary grouping without meaning
- Visual decoration
- Grouping just one element

### Boundary Naming

**Guideline**: Use descriptive names that explain the grouping criterion.

✅ **Do:**
```plantuml
System_Boundary(mobile_team, "Mobile Team Services")
Container_Boundary(aws_region, "AWS us-west-2")
System_Boundary(payment_domain, "Payment Processing Domain")
```

❌ **Don't:**
```plantuml
System_Boundary(group1, "Group 1")        // Non-descriptive
Container_Boundary(boundary, "Boundary")  // Meaningless
System_Boundary(stuff, "The Stuff")       // Vague
```

### Boundary Nesting

**Guideline**: Limit nesting to 2-3 levels maximum.

✅ **Acceptable nesting**:
```plantuml
System_Boundary(enterprise, "Enterprise") {
  System_Boundary(backend, "Backend Services") {
    Container(api, "API", "Node.js", "Server")
    Container(db, "Database", "PostgreSQL", "Data")
  }
}
```

❌ **Excessive nesting** (4+ levels):
```plantuml
System_Boundary(company, "Company") {
  System_Boundary(division, "Division") {
    System_Boundary(department, "Department") {
      System_Boundary(team, "Team") {
        Container(service, "Service", "...", "...")
      }
    }
  }
}
```

---

## Styling and Visual Design

### Color Usage

**Guideline**: Use color purposefully to convey meaning, not randomly.

✅ **Good uses of color:**
- Distinguish your system from external systems (use _Ext variants)
- Highlight critical components
- Show system ownership by team
- Indicate environment (dev/staging/prod)

❌ **Poor uses:**
- Random colors with no meaning
- Too many colors (visual chaos)
- Colors that clash or reduce readability

### Element Sizing

**Guideline**: Let PlantUML handle sizing automatically - don't force specific sizes unless necessary.

✅ **Do:**
- Use default sizing
- Let descriptions wrap naturally

❌ **Don't:**
- Force elements to specific pixel dimensions
- Use excessive whitespace or padding

### Consistency Across Diagrams

**Guideline**: Maintain consistent styling across all diagrams in a project.

✅ **Do:**
- Use the same color scheme
- Apply consistent naming patterns
- Use the same technology labels

❌ **Don't:**
- Style each diagram differently
- Use different names for the same element across diagrams

---

## Documentation and Maintenance

### File Organization

**Guideline**: Use a consistent file structure and naming scheme.

✅ **Recommended structure**:
```
doc/diagrams/
├── context/
│   ├── system-overview.puml
│   └── system-overview.png
├── container/
│   ├── backend-services.puml
│   ├── backend-services.png
│   ├── frontend-apps.puml
│   └── frontend-apps.png
├── component/
│   ├── api-gateway.puml
│   ├── api-gateway.png
│   ├── order-service.puml
│   └── order-service.png
└── sequence/
    ├── user-authentication.puml
    ├── user-authentication.png
    ├── order-placement.puml
    └── order-placement.png
```

**File naming**: Use kebab-case for filenames: `system-overview.puml`, `order-service.puml`

### Version Control

**Guideline**: Commit both PUML source and rendered PNG images.

✅ **Do:**
- Commit `.puml` files (source of truth)
- Commit `.png` files (easy viewing in PRs)
- Write meaningful commit messages
- Review diagram changes in pull requests

❌ **Don't:**
- Commit only PNGs (not editable)
- Leave diagrams unversioned
- Update diagrams without explanation

### Update Triggers

**Guideline**: Update diagrams when the architecture changes.

✅ **Update diagrams when:**
- Adding new systems, containers, or components
- Changing communication patterns
- Switching technologies
- Refactoring structure
- Major feature additions

❌ **Don't:**
- Wait until diagrams are completely outdated
- Update only when reminded
- Ignore minor but important changes

### Documentation Links

**Guideline**: Link diagrams to related documentation.

✅ **Do:**
- Reference diagrams in README files
- Link to diagrams from Architecture Decision Records (ADRs)
- Include diagram references in onboarding docs
- Add diagram links to wiki/confluence pages

---

## Common Anti-Patterns

### Anti-Pattern 1: The "Everything" Diagram

**Problem**: Trying to show the entire system in one diagram.

**Symptoms**:
- 20+ elements in a single diagram
- Relationships crossing everywhere
- Tiny text and elements
- Overwhelming complexity

**Solution**: Split into multiple focused diagrams, each answering a specific question.

### Anti-Pattern 2: The "Mystery Box"

**Problem**: Elements with vague or missing descriptions.

**Symptoms**:
- Names like "Service A", "DB1", "System"
- No descriptions
- No technology information
- Unclear purpose

**Solution**: Use descriptive names, clear descriptions, and relevant technology labels.

### Anti-Pattern 3: The "Spaghetti"

**Problem**: Relationship lines crossing everywhere with no clear flow.

**Symptoms**:
- Confusing layout
- Lines crossing multiple times
- No logical flow direction
- Hard to follow paths

**Solution**: Use directional relationships (Rel_D, Rel_R), better element positioning, and boundaries.

### Anti-Pattern 4: The "Stale Diagram"

**Problem**: Diagram no longer matches reality.

**Symptoms**:
- Shows systems that were decommissioned
- Missing new components
- Wrong technology labels
- Outdated relationships

**Solution**: Establish a regular review schedule and update diagrams with architecture changes.

### Anti-Pattern 5: The "Over-Engineered"

**Problem**: Using advanced features unnecessarily.

**Symptoms**:
- Complex custom styling
- Deeply nested boundaries (4+ levels)
- Too many element types
- Overly detailed annotations

**Solution**: Keep it simple - use only the features that add clarity.

### Anti-Pattern 6: The "Cryptic"

**Problem**: Using jargon, acronyms, or internal terms without explanation.

**Symptoms**:
- Abbreviations like "OPMGSVC", "USRDB2"
- Internal code names
- Unclear relationship labels like "Syncs" or "Updates"

**Solution**: Use business-friendly language and expand acronyms.

### Anti-Pattern 7: The "Boundary Abuse"

**Problem**: Using boundaries without meaningful grouping.

**Symptoms**:
- Single-element boundaries
- Arbitrary groupings
- Boundaries with no clear purpose
- Over-nested boundaries

**Solution**: Only use boundaries when they convey meaningful information (ownership, deployment, security zones, etc.).

---

## Performance and Scalability

### Rendering Performance

**Guideline**: Keep diagrams renderable in reasonable time (<5 seconds).

✅ **Do:**
- Limit to ~15 elements per diagram
- Use separate diagrams for different concerns
- Test rendering time regularly

❌ **Don't:**
- Create massive diagrams with 50+ elements
- Include every possible detail

### PlantUML Server Limitations

**Guideline**: Be aware of public server rate limits and syntax constraints.

✅ **Do:**
- Use retry logic with exponential backoff (already in render script)
- Cache rendered images when possible
- Handle HTTP 400 errors gracefully (syntax issues)
- Respect rate limits (HTTP 429)

❌ **Don't:**
- Hammer the server with rapid requests
- Ignore error messages
- Assume unlimited rendering capacity

### Accessibility

**Guideline**: Make diagrams accessible to all stakeholders.

✅ **Do:**
- Use high-contrast colors
- Ensure text is readable (avoid tiny fonts)
- Provide alternative text descriptions
- Export to accessible formats when needed

❌ **Don't:**
- Use color as the only way to convey information
- Create low-contrast diagrams
- Ignore accessibility concerns

---

## Quick Checklist

Before finalizing a diagram, review against this checklist:

**Content**:
- [ ] Diagram has a clear title
- [ ] Element IDs are valid (no hyphens, no spaces)
- [ ] All elements have descriptive names
- [ ] All elements have meaningful descriptions
- [ ] Containers/components include technology information
- [ ] Relationships have clear, specific labels
- [ ] Only essential elements are included (5-12 typical)

**Structure**:
- [ ] Diagram type matches purpose (Context/Container/Component/Sequence)
- [ ] Elements are logically organized (top-to-bottom or left-to-right flow)
- [ ] Boundaries are used meaningfully (if at all)
- [ ] Layout is clear and uncluttered

**Consistency**:
- [ ] Naming conventions are consistent
- [ ] Styling matches other diagrams in the project
- [ ] Element references are consistent across diagrams

**Technical**:
- [ ] PUML syntax is correct (no errors)
- [ ] Diagram renders successfully
- [ ] Rendering time is reasonable (<5 seconds)
- [ ] PNG output is clear and readable

**Documentation**:
- [ ] Source .puml file is version controlled
- [ ] Rendered .png is version controlled
- [ ] Diagram is linked from relevant documentation
- [ ] Diagram has an obvious purpose and audience

**Sequence Diagrams Only**:
- [ ] Participants are in a flat list (no boundaries)
- [ ] No _Ext suffixes used
- [ ] Relationships are time-ordered
- [ ] Dividers mark logical steps (if applicable)

---

## Additional Resources

- **[C4 Model Concepts](./c4-model.md)** - Understand C4 model theory
- **[Diagram Types Guide](./diagram-types.md)** - When to use each diagram type
- **[Syntax Reference](./syntax-reference.md)** - Complete syntax guide
- **Official C4 Best Practices**: https://c4model.com/#bestPractices
- **PlantUML Documentation**: https://plantuml.com/
