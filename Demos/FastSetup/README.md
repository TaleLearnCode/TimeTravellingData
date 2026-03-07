# FastSetup — Shared Infrastructure for Both Fast Demos

This folder contains shared setup resources for the two **Time Travelling Data** conference demos.

## What's Here

| Folder | Purpose |
|--------|---------|
| `terraform/` | Provisions Azure SQL Server and both databases |

## Demos That Use This Setup

| Demo | Folder | Database |
|------|--------|---------|
| Demo 1 — T-SQL + SSMS | `../SQLDemoFast/` | `TemporalDemo` |
| Demo 2 — EF Core | `../EFCoreDemoFast/` | `TemporalEFDemo` |

Both databases live on the same Azure SQL Server. You only need to run `terraform apply` once before either demo.

## Quick Start

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Azure subscription ID, location, and SQL password
terraform init
terraform apply
```

See [`terraform/README.md`](terraform/README.md) for the full deployment guide.
