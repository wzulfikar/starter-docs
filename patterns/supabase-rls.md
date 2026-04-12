# Supabase RLS Naming Convention

Use a consistent policy name format for row-level security on user-owned tables:

```
Allow select|insert|update|delete for own records
```

One policy per operation, one verb in the name. The pipe shows the alternatives — pick the one that matches the policy's command.

## Examples

```sql
-- profiles table with a user_id column
create policy "Allow select for own records"
  on profiles for select
  using (auth.uid() = user_id);

create policy "Allow insert for own records"
  on profiles for insert
  with check (auth.uid() = user_id);

create policy "Allow update for own records"
  on profiles for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Allow delete for own records"
  on profiles for delete
  using (auth.uid() = user_id);
```

## Why this format

- **Scannable in the dashboard**: all four policies sort together under "Allow … for own records"
- **Self-documenting**: the verb tells you the operation, "own records" tells you the scope
- **Predictable**: given a table name you can infer the policy names without opening the dashboard

## Column name

The convention assumes a `user_id uuid` column referencing `auth.users(id)`. If your table uses a different column name (e.g. `owner_id`, `created_by`), keep the policy name the same and only change the column in the expression:

```sql
create policy "Allow select for own records"
  on posts for select
  using (auth.uid() = owner_id);
```

The name stays stable; the implementation detail is in the body.

## `using` vs `with check`

| Clause | When it runs | Use for |
|--------|-------------|---------|
| `using` | Filtering existing rows | `select`, `update`, `delete` |
| `with check` | Validating new row values | `insert`, `update` |

`update` needs both: `using` to restrict which rows can be targeted, `with check` to prevent reassigning `user_id` to someone else's uid.
