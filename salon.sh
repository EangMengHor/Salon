
#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align"

echo ""
echo "~~~~~ MY SALON ~~~~~"

while true
do
  echo ""
  echo "Welcome to My Salon, how can I help you?"
  echo ""

  SERVICES=$($PSQL -c "SELECT service_id || ') ' || name FROM services ORDER BY service_id")
  printf '%s\n' "$SERVICES"

  read SERVICE_ID_SELECTED || exit 0

  # Validate service ID
  case "$SERVICE_ID_SELECTED" in
    ''|*[!0-9]*)
      echo "Please select a valid service."
      continue
      ;;
  esac

  SERVICE_NAME=$($PSQL -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [ -z "$SERVICE_NAME" ]; then
    echo "Please select a valid service."
    continue
  fi

  break
done

echo ""
echo "What's your phone number?"
read CUSTOMER_PHONE || exit 0

# Escape single quotes for SQL
SAFE_PHONE=$(printf '%s' "$CUSTOMER_PHONE" | sed "s/'/''/g")

CUSTOMER_NAME=$($PSQL -c "SELECT name FROM customers WHERE phone = '$SAFE_PHONE' LIMIT 1")

if [ -z "$CUSTOMER_NAME" ]; then
  echo ""
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME || exit 0

  SAFE_NAME=$(printf '%s' "$CUSTOMER_NAME" | sed "s/'/''/g")

  $PSQL -c "INSERT INTO customers(phone, name) VALUES ('$SAFE_PHONE', '$SAFE_NAME')" > /dev/null || exit 1
fi

CUSTOMER_ID=$($PSQL -c "SELECT customer_id FROM customers WHERE phone = '$SAFE_PHONE' LIMIT 1")

echo ""
echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME || exit 0

SAFE_TIME=$(printf '%s' "$SERVICE_TIME" | sed "s/'/''/g")

$PSQL -c "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SAFE_TIME')" > /dev/null || exit 1

echo ""
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
