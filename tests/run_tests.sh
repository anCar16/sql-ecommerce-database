#!/usr/bin/env bash
# Builds the database from scratch and checks the stored procedure's behaviour.
# Usage: MYSQL="mysql -h127.0.0.1 -uroot -proot" ./tests/run_tests.sh
set -euo pipefail

MYSQL=${MYSQL:-"mysql -uroot"}
cd "$(dirname "$0")/.."
failures=0

sql()   { $MYSQL -N -B venta_linea -e "$1"; }
check() {  # check "description" "query" "expected"
    local got
    got=$(sql "$2")
    if [[ "$got" == "$3" ]]; then echo "PASS  $1"; else echo "FAIL  $1 (expected '$3', got '$got')"; failures=$((failures + 1)); fi
}
expect_error() {  # expect_error "description" "statement" "message fragment"
    local out
    if out=$($MYSQL -N -B venta_linea -e "$2" 2>&1); then
        echo "FAIL  $1 (no error raised)"; failures=$((failures + 1))
    elif [[ "$out" == *"$3"* ]]; then echo "PASS  $1"
    else echo "FAIL  $1 (unexpected error: $out)"; failures=$((failures + 1)); fi
}

$MYSQL -e "DROP DATABASE IF EXISTS venta_linea"
for f in sql/01_schema.sql sql/02_seed_data.sql sql/03_place_order_procedure.sql; do $MYSQL < "$f"; done

check "seed: 3 customers"            "SELECT COUNT(*) FROM clientes" "3"
check "seed: 4 order lines"          "SELECT COUNT(*) FROM detalles_pedido" "4"

check "valid order returns 1"        "CALL realizar_pedido(1, 1, 2, @r); SELECT @r" "1"
check "only the ordered product loses stock" \
      "SELECT GROUP_CONCAT(inventario ORDER BY id_producto) FROM productos" "13,13,10"
check "order, line and shipment are created" \
      "SELECT CONCAT(COUNT(*), '/', (SELECT COUNT(*) FROM detalles_pedido), '/', (SELECT COUNT(*) FROM envios)) FROM pedidos" "4/5/3"

check "ordering the exact remaining stock is allowed" \
      "CALL realizar_pedido(2, 3, 10, @r); SELECT CONCAT(@r, ':', inventario) FROM productos WHERE id_producto = 3" "1:0"

expect_error "insufficient stock raises an error" "CALL realizar_pedido(1, 2, 999, @r)" "No hay suficientes existencias"
check "failed order writes nothing" \
      "SELECT CONCAT((SELECT COUNT(*) FROM pedidos), '/', inventario) FROM productos WHERE id_producto = 2" "5/13"

expect_error "unknown product raises an error"  "CALL realizar_pedido(1, 99, 1, @r)" "El producto no existe"
expect_error "zero quantity raises an error"    "CALL realizar_pedido(1, 1, 0, @r)"  "mayor que cero"
expect_error "unknown customer is rolled back"  "CALL realizar_pedido(99, 1, 1, @r)" "foreign key"
check "rolled-back order left stock untouched" "SELECT inventario FROM productos WHERE id_producto = 1" "13"

$MYSQL < sql/04_example_queries.sql > /dev/null && echo "PASS  example queries run" || { echo "FAIL  example queries"; failures=$((failures + 1)); }

echo
if (( failures )); then echo "$failures check(s) failed"; exit 1; fi
echo "All checks passed"
