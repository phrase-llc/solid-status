# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

```mermaid
erDiagram
  ORGANIZATIONS ||--o{ APPLICATIONS : has_many
  ORGANIZATIONS ||--o{ USERS : has_many

  APPLICATIONS ||--o{ COMPONENTS : has_many
  APPLICATIONS ||--o{ INCIDENTS : has_many
  APPLICATIONS ||--o{ MEMBERSHIPS : has_many

  USERS ||--o{ MEMBERSHIPS : has_many

  ORGANIZATIONS {
    int id
    string name
    datetime created_at
    datetime updated_at
  }

  USERS {
    int id
    string email
    string encrypted_password
    int organization_id
    datetime created_at
    datetime updated_at
  }

  APPLICATIONS {
    int id
    string name
    string domain
    int organization_id
    datetime created_at
    datetime updated_at
  }

  COMPONENTS {
    int id
    string name
    string status
    int application_id
    datetime created_at
    datetime updated_at
  }

  INCIDENTS {
    int id
    string title
    text description
    string status
    datetime started_at
    datetime resolved_at
    int application_id
    datetime created_at
    datetime updated_at
  }

  MEMBERSHIPS {
    int id
    int user_id
    int application_id
    string role
    datetime created_at
    datetime updated_at
  }

```