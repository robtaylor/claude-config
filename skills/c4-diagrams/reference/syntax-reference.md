# C4-PlantUML Syntax Reference

Complete reference for C4-PlantUML syntax, including element macros, ID rules, boundaries, relationships, and diagram-specific constraints.

## Table of Contents

1. [Element Macros](#element-macros)
2. [ID Sanitization Rules](#id-sanitization-rules)
3. [Parameter Rules](#parameter-rules)
4. [Boundary Syntax](#boundary-syntax)
5. [Relationship Syntax](#relationship-syntax)
6. [Sequence Diagram Constraints](#sequence-diagram-constraints)
7. [Include Statements](#include-statements)
8. [Special Directives](#special-directives)

---

## Element Macros

### Base Element Types

**Person Elements** (all diagram types):
```plantuml
Person(id, "Name", "Description")
Person_Ext(id, "Name", "Description")  ' External person (different styling)
```

**System Elements** (Context diagrams):
```plantuml
System(id, "Name", "Description")
System_Ext(id, "Name", "Description")  ' External system (different styling)
```

**Container Elements** (Container and Sequence diagrams):
```plantuml
Container(id, "Name", "Technology", "Description")
ContainerDb(id, "Name", "Technology", "Description")      ' Database icon
ContainerQueue(id, "Name", "Technology", "Description")   ' Queue icon
Container_Ext(id, "Name", "Technology", "Description")    ' External container
ContainerDb_Ext(id, "Name", "Technology", "Description")  ' External database
```

**Component Elements** (Component and Sequence diagrams):
```plantuml
Component(id, "Name", "Technology", "Description")
ComponentDb(id, "Name", "Technology", "Description")      ' Database icon
ComponentQueue(id, "Name", "Technology", "Description")   ' Queue icon
Component_Ext(id, "Name", "Technology", "Description")    ' External component
```

**Note Elements** (all diagram types):
```plantuml
' Notes have different syntax - no parentheses
note right of element_id
  Note text here
end note

note left of element_id : Short note on one line
```

### Boundary Elements

**Available only in Context/Container/Component diagrams** (NOT in Sequence):
```plantuml
System_Boundary(id, "Name") {
  ' Elements inside boundary
}

System_Boundary(id, "Name", "Optional Description") {
  ' Elements inside boundary
}

Container_Boundary(id, "Name") {
  ' Elements inside boundary
}

Boundary(id, "Name") {
  ' Generic boundary
}
```

---

## ID Sanitization Rules

**Element IDs must be valid PlantUML identifiers:**

✅ **Valid characters**: Letters, numbers, underscores
❌ **Invalid characters**: Hyphens, spaces, special characters

**Sanitization examples:**
```
"web-app"         → "web_app"
"API Gateway"     → "API_Gateway"
"user@system"     → "user_system"
"my-service-1"    → "my_service_1"
```

**Best practices:**
- Always use underscores instead of hyphens
- Convert spaces to underscores
- Remove or replace special characters
- Keep IDs lowercase for consistency
- Use descriptive names that match the element

---

## Parameter Rules

### Basic Element Syntax

**Person and System** (2 parameters + description):
```plantuml
Person(id, "Name", "Description")
System(id, "Name", "Description")
```

**Container and Component** (3 parameters + description):
```plantuml
Container(id, "Name", "Technology", "Description")
Component(id, "Name", "Technology", "Description")
```

**Technology parameter is REQUIRED** for Container and Component elements:
```plantuml
' ❌ WRONG - missing technology
Container(api, "API Server", "Handles requests")

' ✅ CORRECT - includes technology
Container(api, "API Server", "Node.js/Express", "Handles requests")
```

### Parameter Order Summary

| Element Type | Parameters |
|--------------|------------|
| Person       | `id, "Name", "Description"` |
| System       | `id, "Name", "Description"` |
| Container    | `id, "Name", "Technology", "Description"` |
| Component    | `id, "Name", "Technology", "Description"` |
| Boundary     | `id, "Name"` or `id, "Name", "Description"` |

---

## Boundary Syntax

**⚠️ Boundaries are ONLY supported in Context/Container/Component diagrams**

They are **NOT supported in Sequence diagrams**.

### Basic Boundary Structure

```plantuml
System_Boundary(boundary_id, "Boundary Name") {
  System(system1, "System 1", "Description")
  System(system2, "System 2", "Description")
}
```

### Nested Boundaries

```plantuml
System_Boundary(enterprise, "Enterprise") {
  System_Boundary(backend, "Backend Systems") {
    Container(api, "API", "Node.js", "Handles requests")
    ContainerDb(db, "Database", "PostgreSQL", "Stores data")
  }
}
```

### Indentation Rules

- Elements inside boundaries should be indented with **2 spaces**
- Nested boundaries should follow consistent indentation
- Always close boundaries with `}`

---

## Relationship Syntax

### Basic Relationship

```plantuml
Rel(source_id, target_id, "Description")
Rel(source_id, target_id, "Description", "Technology/Protocol")
```

### Directional Relationships

Control layout by specifying direction:

```plantuml
Rel_U(source, target, "Description")  ' Up
Rel_D(source, target, "Description")  ' Down
Rel_L(source, target, "Description")  ' Left
Rel_R(source, target, "Description")  ' Right
```

### Bidirectional Relationships

```plantuml
BiRel(id1, id2, "Description")
BiRel(id1, id2, "Description", "Technology")
```

### Relationship Examples

```plantuml
' Basic relationship
Rel(user, web_app, "Uses")

' With technology
Rel(web_app, api, "Makes API calls", "REST/JSON")

' Directional for layout control
Rel_D(api, database, "Reads/writes", "JDBC")

' Bidirectional
BiRel(service1, service2, "Communicates with", "gRPC")
```

---

## Sequence Diagram Constraints

**⚠️ CRITICAL: Sequence diagrams have different syntax rules than structural diagrams**

### What's NOT Allowed in Sequence Diagrams

❌ **Boundaries are NOT supported**:
```plantuml
' ❌ WRONG - boundaries not allowed in sequence diagrams
Container_Boundary(backend, "Backend") {
  Container(api, "API", "Node.js", "Server")
}

' ✅ CORRECT - flat participant list
Container(api, "API", "Node.js", "Server")
```

❌ **_Ext suffixes are NOT supported**:
```plantuml
' ❌ WRONG - _Ext suffix not valid in sequence diagrams
Container_Ext(payment, "Payment Service", "Java", "Handles payments")

' ✅ CORRECT - use regular variant
Container(payment, "Payment Service", "Java", "Handles payments")
```

### What IS Allowed in Sequence Diagrams

✅ **Flat participant list**:
```plantuml
Person(user, "User", "Customer")
Container(web_app, "Web App", "React", "UI")
Container(api, "API Server", "Node.js", "Backend")
ContainerDb(database, "Database", "PostgreSQL", "Data store")
Container(cache, "Cache", "Redis", "Caching layer")
```

✅ **Time-ordered relationships**:
```plantuml
' Relationships execute from top to bottom in time order
Rel(user, web_app, "Requests page", "HTTPS")
Rel(web_app, api, "Fetches data", "REST")
Rel(api, cache, "Checks cache", "Redis Protocol")
Rel(api, database, "Queries data", "SQL")
Rel(api, web_app, "Returns response", "JSON")
```

✅ **Dividers for logical steps**:
```plantuml
== Initial Request ==
Rel(user, web_app, "Opens application")

== Authentication ==
Rel(web_app, api, "Validates session")

== Data Retrieval ==
Rel(api, database, "Fetches user data")
```

✅ **Groups for sub-processes**:
```plantuml
group Login Flow
  Rel(user, web_app, "Submits credentials")
  Rel(web_app, api, "Validates credentials")
  Rel(api, database, "Checks user table")
end
```

### Why These Constraints Exist

**Sequence diagrams are fundamentally different:**
- **Structural diagrams** (Context/Container/Component) show static architecture
- **Sequence diagrams** show temporal flow and interactions over time

**In sequence diagrams:**
- Layout is determined by the temporal order of interactions
- Boundaries would conflict with time-based vertical layout
- External markers (_Ext) are unnecessary since the sequence shows interaction flow
- Nesting doesn't make sense in a time-ordered representation

---

## Include Statements

Each diagram type requires a specific include statement at the top of the file:

```plantuml
@startuml

' Context diagram
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml

' Container diagram
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml

' Component diagram
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Component.puml

' Sequence diagram
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Sequence.puml

@enduml
```

**Important:** Use the correct include for your diagram type. The include determines which element types are available.

---

## Special Directives

### Hide Stereotypes

Remove `<<stereotype>>` labels from elements:
```plantuml
HIDE_STEREOTYPE()
```

### Show Element Descriptions

Display descriptions in the diagram (useful for sequence diagrams):
```plantuml
SHOW_ELEMENT_DESCRIPTIONS()
```

### Layout Direction

Change diagram layout direction:
```plantuml
LAYOUT_LEFT_RIGHT()    ' Horizontal layout
LAYOUT_TOP_DOWN()      ' Vertical layout (default)
LAYOUT_LANDSCAPE()     ' Landscape orientation
```

### Custom Styling

Apply custom colors and styling:
```plantuml
' Update element colors
UpdateElementStyle(person, $bgColor="lightblue")
UpdateElementStyle(system, $bgColor="lightyellow")

' Update relationship colors
UpdateRelStyle(user, system, $lineColor="red")
```

---

## Common Syntax Errors

### Error: Unclosed Boundary

❌ **Wrong:**
```plantuml
System_Boundary(backend, "Backend") {
  System(api, "API", "Server")
' Missing closing brace
```

✅ **Correct:**
```plantuml
System_Boundary(backend, "Backend") {
  System(api, "API", "Server")
}
```

### Error: Invalid ID with Hyphen

❌ **Wrong:**
```plantuml
Container(web-app, "Web App", "React", "UI")
```

✅ **Correct:**
```plantuml
Container(web_app, "Web App", "React", "UI")
```

### Error: Missing Technology Parameter

❌ **Wrong:**
```plantuml
Container(api, "API Server", "Handles requests")
```

✅ **Correct:**
```plantuml
Container(api, "API Server", "Node.js", "Handles requests")
```

### Error: Boundary in Sequence Diagram

❌ **Wrong:**
```plantuml
!include C4_Sequence.puml

Container_Boundary(backend, "Backend") {
  Container(api, "API", "Node.js", "Server")
}
```

✅ **Correct:**
```plantuml
!include C4_Sequence.puml

' Flat participant list
Container(api, "API", "Node.js", "Server")
```

### Error: _Ext Suffix in Sequence Diagram

❌ **Wrong:**
```plantuml
!include C4_Sequence.puml

Container_Ext(payment, "Payment API", "Java", "External service")
```

✅ **Correct:**
```plantuml
!include C4_Sequence.puml

Container(payment, "Payment API", "Java", "External service")
```

---

## Quick Reference Table

| Feature | Context | Container | Component | Sequence |
|---------|---------|-----------|-----------|----------|
| Person, Person_Ext | ✅ | ✅ | ✅ | ✅ (no _Ext) |
| System, System_Ext | ✅ | ❌ | ❌ | ❌ |
| Container, Container_Ext | ❌ | ✅ | ✅ | ✅ (no _Ext) |
| Component, Component_Ext | ❌ | ❌ | ✅ | ✅ (no _Ext) |
| Boundaries | ✅ | ✅ | ✅ | ❌ |
| Relationships | ✅ | ✅ | ✅ | ✅ (time-ordered) |
| Dividers (`==`) | ❌ | ❌ | ❌ | ✅ |
| Groups | ❌ | ❌ | ❌ | ✅ |

---

## Additional Resources

- **[C4 Model Concepts](./c4-model.md)** - Understand the C4 model theory
- **[Diagram Types Guide](./diagram-types.md)** - When to use each diagram type
- **[Best Practices](./best-practices.md)** - Design patterns and tips
- **[C4-PlantUML Library Docs](./c4-plantuml-readme.md)** - Complete upstream documentation
