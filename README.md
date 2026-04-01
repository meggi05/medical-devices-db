# Medical Devices Database

PostgreSQL database for managing medical devices, manufacturers, suppliers, sales, and clients. Includes analytical functions for reporting and statistics.

## Database Structure

### Tables

- **cities** – list of cities (id, name).
- **manufacturers** – device manufacturers (id, name, city_id).
- **suppliers** – device suppliers (id, name, city_id).
- **medical_devices** – devices with attributes: name, release date, manufacturer, supplier, price, acquisition date, age group, defect flag.
- **clients** – customers (id, name).
- **sales** – sales records (id, device_id, client_id, sale_date, sale_price).
  

### Functions (Analytical Queries)

| Function | Description |
|----------|-------------|
| `avg_sale_price_in_period(start_date, end_date)` | Average sale price within a date range. |
| `cheap_devices_share(supplier_name, max_price)` | Share of devices from a supplier cheaper than given price. |
| `defective_devices_by_manufacturer(manuf_name)` | List defective devices for a manufacturer. |
| `device_extremes()` | Most expensive, cheapest, and average device price. |
| `device_info()` | Full device details including manufacturer, supplier, city, sales, client. |
| `devices_above_manufacturer_avg(manuf_name)` | Devices from a manufacturer priced above their average. |
| `devices_by_age_group(age_grp)` | Devices filtered by age group (e.g., '3+', '18+'). |
| `devices_by_manufacturer(manuf_name)` | Devices for a given manufacturer. |
| `devices_by_release_date(target_date)` | Devices released on a specific date. |
| `devices_by_sale_date()` | Devices with their sale date and price. |
| `devices_manuf_sales_in_period(manuf_name, start, end)` | Sales of devices from a manufacturer in a date range. |
| `devices_price_range(min_price, max_price)` | Devices within a price range. |
| `devices_sold_to_client_in_period(client_name, start, end)` | Devices sold to a client in a date range. |
| `devices_supplier_above_avg_city(supplier_name, city_name)` | Devices from a supplier priced above average for that city. |
| `expensive_share(threshold)` | Share of devices priced above a threshold. |
| `sales_share_in_period(start_date, end_date)` | Share of sales occurring in a date range. |

## Sample Data

The dump includes sample data:
- 11 cities
- 5 manufacturers
- 5 suppliers
- 35 medical devices
- 8 clients
- 33 sales records

## Usage

### Restore the Database

```bash
psql -U postgres -d your_database_name < medical_devices.sql
```

### Permissions
The script grants privileges to three roles:
  - user1 – read-only access
  - operator1 – insert/select on certain tables
  - analyst1 – insert/update/select on most tables

Adjust roles as needed for your environment.

## Requirements
PostgreSQL 17 or higher

Basic understanding of SQL and PL/pgSQL

Author
@meggi05 — Student at Novosibirsk State Technical University (NSTU)
