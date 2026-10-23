#!/bin/bash

function print_services() {
  echo "1) cut"
  echo "2) color"
  echo "3) perm"
  echo "4) style"
  echo "5) trim"
}

echo "~~~~~ MY SALON ~~~~~"
echo

echo "Welcome to My Salon, how can I help you?"
echo
print_services
read SERVICE_ID_SELECTED

while [[ ! "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]] || [[ -z "$(psql -U postgres -d salon -tAc "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;")" ]]; do
  echo
  echo "I could not find that service. What would you like today?"
  print_services
  read SERVICE_ID_SELECTED
done

SERVICE_NAME=$(psql -U postgres -d salon -tAc "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

echo "What's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_ID=$(psql -U postgres -d salon -tAc "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

if [[ -z "$CUSTOMER_ID" ]]; then
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  psql -U postgres -d salon -c "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');" >/dev/null
  CUSTOMER_ID=$(psql -U postgres -d salon -tAc "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
else
  CUSTOMER_NAME=$(psql -U postgres -d salon -tAc "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
fi

echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

psql -U postgres -d salon -c "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');" >/dev/null

echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
