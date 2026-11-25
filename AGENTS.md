# Spotify iOS Coding Standards

## Language

- Objective-C only.
- UIKit for all UI implementations.
- Masonry for Auto Layout.
- Follow MVC architecture.

## Formatting

- Follow the root `.clang-format`.
- Use 4 spaces for indentation.
- Maximum preferred line length: 120.
- Use consistent spacing and blank lines.
- Organize implementation files with `#pragma mark`.

## Naming

- All custom classes use the SC prefix.
- Properties use lowerCamelCase.
- Methods must have descriptive names.

## Architecture

- ViewController handles coordination and navigation.
- View handles UI and layout.
- Model handles data and validation.
- Avoid massive ViewControllers.

## Masonry

- All handwritten UI layout must use Masonry. Do not create business layout constraints with native Auto Layout APIs (`NSLayoutConstraint`, `NSLayoutAnchor`, `activateConstraints:`, `constraintEqualToAnchor:`, `constraintEqualToConstant:`, `addConstraint:`, or `addConstraints:`).
- Do not substitute manual `frame` assignments or `CGRectMake` for ordinary Auto Layout. System-generated constraints are exempt.
- Create constraints with `mas_makeConstraints:`, update them with `mas_updateConstraints:`, and replace them with `mas_remakeConstraints:`. Animate layout changes with `layoutIfNeeded` as needed.
- In every custom View, put UI creation in `setupUI` under `#pragma mark - UI Setup`, and constraint creation in `setupConstraints` under `#pragma mark - Constraints`. Keep layout out of ViewController lifecycle methods.
- For scroll content/frame guides and the keyboard guide, use Masonry `MASViewAttribute` adapters with explicit attributes; do not create a second set of native constraints.
- Keep constraints readable.
- Group constraints by view.
- Avoid unnecessary hardcoded dimensions.
- Before delivery, scan handwritten `.h` and `.m` files in scope for forbidden native constraint creation and manual frame-based layout, resolve violations, review the diff, and run the relevant build.

## Quality

- Do not change unrelated modules.
- Do not introduce unnecessary dependencies.
- Do not modify behavior during formatting tasks.
- Review the diff before completing changes.

## Additional Objective-C Style and Verification

- Use the repository-root `.clang-format` for all newly written or edited Objective-C code. The verified formatter is Apple clang-format 17.0.0.
- Follow Google Objective-C style with this project's overrides: four spaces, no tabs, 120 columns, attached braces, right-aligned pointers, and preserved import order.
- Use SC-prefixed classes, descriptive lowerCamelCase members, and ownership attributes appropriate to their semantics (`copy` for strings/blocks, `weak` for delegates, `assign` for scalars).
- Keep private properties in class extensions. Do not rename existing public APIs for style alone.
- Order implementation sections as applicable: Lifecycle, Public Methods, UI Setup, Constraints, Actions, Delegate / DataSource, Private Methods, Getters. Separate methods with a blank line and use `#pragma mark -` only for populated sections.
- Keep each Masonry constraint statement on its own line inside a consistently indented block. Formatting must not change layout values, control flow, navigation, or validation rules.
- Format only the files in scope. Leave empty placeholder files and vendored dependencies untouched.
- Before delivery, verify formatting with clang-format `--dry-run --Werror`, inspect the diff, and run the relevant build when available.
