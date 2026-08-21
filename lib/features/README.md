# Feature architecture

Each product capability owns its files under `lib/features/<feature>/`.

- `model/`: feature-specific data and state models.
- `view/`: screens and route-level UI.
- `presentation/`: providers, controllers, and presentation logic.
- `widgets/`: reusable UI owned by that feature.
- `services/`: external or platform-facing feature services, when required.
- `repository/`: feature data access abstractions and implementations, when required.

Create only the folders a feature currently needs. Cross-feature application infrastructure belongs in `core/`; reusable UI with no feature ownership belongs in `shared/widgets/`. New files must stay with the feature that owns their behavior instead of being added to a generic folder.
