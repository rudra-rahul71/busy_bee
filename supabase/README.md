# Busy Bee - Supabase Backend & CLI Operations

Backend setup and database migrations for **Busy Bee** are managed via the **Supabase CLI**.

---

## 1. Prerequisites & Linking

Install the Supabase CLI (if not already installed) and log in:
```bash
brew install supabase/tap/supabase
supabase login
```

Link this project to your Supabase project:
```bash
supabase link --project-ref <your-project-ref>
```

---

## 2. Database Migrations

All database tables, schemas, and security policies are defined as migrations inside `supabase/migrations/`.

### Apply migrations to remote Supabase:
```bash
supabase db push
```

---

## 3. Local Development Workflow (Optional)

To spin up a local Supabase environment with Docker:
```bash
# Start local containers
supabase start

# Reset local database and apply all migrations
supabase db reset
```
