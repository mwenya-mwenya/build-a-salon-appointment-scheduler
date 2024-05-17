#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Bobby's Salon ~~~~~\n"
MAIN_MENU() {
  VERIFY() {
    if [[ $1 ]]; then
      echo -e "\n$1"
    else
      echo -e "How may I help you?\n"
    fi

    HAIR_CUTS=$($PSQL "SELECT service_id,name FROM services")
    echo "$HAIR_CUTS" | while read HAIRCUT_NUMBER BAR HAIRCUT_NAME; do
      echo "$HAIRCUT_NUMBER) $HAIRCUT_NAME"
    done

    read SERVICE_ID_SELECTED
    SERVICE_ID_SELECTED_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
    if [[ -z $SERVICE_ID_SELECTED_RESULT ]]; then
      VERIFY "I could not find that service. What would you like today?"
    fi
  }
  VERIFY

  BOOKING() {
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CHECK_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CHECK_CUSTOMER_ID ]]; then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      CEATE_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")

    fi
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'" | sed 's/ //g')
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'" | sed 's/ //g')
    echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"

    read SERVICE_TIME

    GET_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    CREATE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES('$GET_CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."

  }
  BOOKING

}
MAIN_MENU
