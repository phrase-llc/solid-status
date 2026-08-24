# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Setup & Development Server
- `bin/setup` - Complete development environment setup (install deps, prepare DB, start server)
- `bin/dev` - Start development server with CSS watching (recommended for daily development)
- `bin/rails server` - Start Rails server only

### Testing
- `bundle exec rspec` - Run all RSpec tests
- `bundle exec rspec spec/system/users/sign_up_spec.rb` - Run specific test file
- `bundle exec rake parallel:spec` - Run specs in parallel for faster execution

### Code Quality
- `bin/rubocop` - Run RuboCop linter (Rails Omakase style guide)
- `bin/brakeman` - Run security analysis

### Asset Building
- `yarn build:css` - Build CSS from SCSS (compile + autoprefix)
- `yarn watch:css` - Watch SCSS files and auto-rebuild CSS

### Database
- `bin/rails db:prepare` - Setup database if new, or migrate if exists (seeds only on first setup)
- `bin/rails db:setup` - Create database, load schema, and run seeds (always seeds)
- `bin/rails db:migrate` - Run pending migrations
- `bin/rails db:seed` - Load environment-specific seed data
- `bin/rails db:seed:replant` - Reset and reload seed data

## Architecture Overview

### Multi-Tenant B2B SaaS Structure
The application follows a hierarchical organization model:
- **Organizations** contain **Users** and **Status Pages**
- **Users** have roles (`admin`/`member`) within their organization
- **Incidents** belong to status pages and contain **Incident Entries** for timeline updates

### Authorization Pattern (Pundit-based)
Organization-level authorization system:
- Users can only access resources in their own organization.
- `admin` users can create, update, and delete status pages, incidents, and incident entries.
- `member` users can view status pages and incidents in their organization.

### Controller Hierarchy
Nested namespace pattern mirrors data model:
```
StatusPagesController
└── StatusPages::IncidentsController
    └── StatusPages::Incidents::IncidentEntriesController
```

All controllers include `AccessControllable` concern for consistent Pundit integration.

### Key Policy Classes
- `StatusPagePolicy`, `IncidentPolicy`, and `IncidentEntryPolicy`
- Authorization methods verify organization ownership and the `admin` role for mutations.

### Turbo Integration
Modern Hotwire approach with Turbo Streams for dynamic interactions:
- Forms submit via AJAX with turbo_stream responses
- CRUD operations update DOM in-place without full page refreshes
- Progressive enhancement with HTML fallbacks

### Data Model Notes
- Organization isolation ensures complete tenant separation
- Dependent destroys maintain referential integrity
- Incident entries track status progression timeline
