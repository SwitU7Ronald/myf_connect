# Architectural and State Management Mandates

## 1. Impenetrable Clean Architecture
### 1. WHAT & WHERE
The application dictates a strict three-tier architecture: the Data layer (Repositories, External Sources), the Domain layer (Entities, Use Cases), and the Presentation layer (Widgets, BLoCs). The Domain acts as the pure epicenter, residing strictly between Data and Presentation.
### 2. HOW
The Flutter Engine interacts solely with the Presentation layer. User intent is captured and dispatched to a state management mechanism, which invokes a Domain Use Case. The Use Case relies on an abstract interface to request asynchronous processing from the Data layer. Data serialization and isolation span boundaries occur here, propagating pure entity maps back through the Domain layer, culminating in a state emission that reconciles the Widget Tree.
### 3. WHY
Dependency Inversion guarantees that the Domain layer—the intellectual core of the enterprise—remains entirely decoupled from external network flakiness, database migrations, or UI framework updates. It ensures absolute theoretical testability.
### 4. HOW/WHY NOT
If the Presentation layer bypasses the Domain layer to directly invoke the Data layer, it creates a catastrophic tight coupling. This anti-pattern prevents isolated unit testing, tightly binds UI lifecycle to network latency, and causes massive visual stuttering during garbage collection cycles.
### 5. PRODUCTION STANDARD
Every boundary crossover must be mediated by an abstract Dart interface. Concrete instantiation of Data components within the Presentation or Domain layers will result in instantaneous Pull Request rejection.

## 2. BLoC State Emission Mechanics
### 1. WHAT & WHERE
State management is exclusively localized within the Presentation layer utilizing the BLoC/Cubit paradigm.
### 2. HOW
The BLoC operates as a reactive finite state machine decoupled from the Widget Tree. It manages asynchronous Dart Streams on the Event Loop. When a strictly typed Event is received, the BLoC computes the transformation and yields a strictly typed, immutable State. The Flutter Engine observes this emission, marking specific elements in the Element Tree as dirty, executing a highly optimized, geometric repaint on the next rendering microtask.
### 3. WHY
By enforcing a unidirectional flow from Event to State, the UI becomes a mathematically perfect, passive reflection of the backend truth. The UI cannot alter its own reality without broadcasting its intent via an Event.
### 4. HOW/WHY NOT
Utilizing unstructured state mechanisms or mutating variables in place prevents the engine from accurately diffing the state tree. This results in phantom UI renders, infinite loading loops, and "dead clicks" where the visual representation physically diverges from the mathematical memory heap.
### 5. PRODUCTION STANDARD
UI widgets must remain entirely stateless where possible. Every state mutation must be defined as an immutable object possessing value equality, mapped strictly to a BLoC emission.

## 3. The `core/` vs. Local Isolation Matrix
### 1. WHAT & WHERE
The repository topology is split into the global `core/` directory and the isolated `features/` directories, governing the exact placement of all logic and UI assets.
### 2. HOW
When the Dart analyzer detects an entity, widget, or network client utilized by multiple distinct feature routes, the architecture mandates its physical relocation to the central `core/` directory. Conversely, if a component is accessed solely by a single feature's lifecycle, it is mathematically locked within that specific `features/feature_name/` directory matrix.
### 3. WHY
This enforces the ultimate DRY principle while simultaneously preventing the creation of a tangled monolithic binary. Features operate as mathematically independent micro-frontends, accelerating compilation and enabling concurrent enterprise team development.
### 4. HOW/WHY NOT
Cross-feature contamination creates an unmanageable dependency web. If Feature A directly imports a model from Feature B, any minor architectural patch in B will trigger catastrophic, untraceable regressions in A, violating the isolation law.
### 5. PRODUCTION STANDARD
A feature directory must never contain import statements traversing into disparate feature directories. Shared interaction must occur strictly via centralized routing payloads or the global Domain layer.
