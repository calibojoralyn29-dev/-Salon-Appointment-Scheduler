#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -X -q -tA"

sql_quote() {
  local value=${1//\'/\'\'}
  printf "'%s'" "$value"
}

printf '%s\n\n' '~~~~~ MY SALON ~~~~~'
printf '%s\n\n' 'Welcome to My Salon, how can I help you?'

while true; do
  while IFS='|' read -r SERVICE_ID SERVICE_NAME; do
    printf '%s) %s\n' "$SERVICE_ID" "$SERVICE_NAME"
  done < <($PSQL -F '|' -c 'SELECT service_id, name FROM services ORDER BY service_id')

  read SERVICE_ID_SELECTED
  if [[ "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]; then
    SERVICE_NAME=$($PSQL -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  else
    SERVICE_NAME=''
  fi

  if [[ -n "$SERVICE_NAME" ]]; then
    break
  fi

  printf '\n%s\n' 'I could not find that service. What would you like today?'
done

printf '\n%s\n' "What's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_PHONE_SQL=$(sql_quote "$CUSTOMER_PHONE")
CUSTOMER_RECORD=$($PSQL -F '|' -c "SELECT customer_id, name FROM customers WHERE phone = $CUSTOMER_PHONE_SQL")
if [[ -n "$CUSTOMER_RECORD" ]]; then
  IFS='|' read -r CUSTOMER_ID CUSTOMER_NAME <<< "$CUSTOMER_RECORD"
else
  printf '\n%s\n' "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  CUSTOMER_NAME_SQL=$(sql_quote "$CUSTOMER_NAME")
  CUSTOMER_ID=$($PSQL -c "INSERT INTO customers (name, phone) VALUES ($CUSTOMER_NAME_SQL, $CUSTOMER_PHONE_SQL) RETURNING customer_id")
fi

printf '\nWhat time would you like your %s, %s?\n' "$SERVICE_NAME" "$CUSTOMER_NAME"
read SERVICE_TIME
SERVICE_TIME_SQL=$(sql_quote "$SERVICE_TIME")
$PSQL -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, $SERVICE_TIME_SQL)" >/dev/null

printf '\nI have put you down for a %s at %s, %s.\n' "$SERVICE_NAME" "$SERVICE_TIME" "$CUSTOMER_NAME"