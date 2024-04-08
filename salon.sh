#!/bin/bash
PSQL="psql --username=postgres --dbname=salon -t --no-align -c"
echo -e "\n ~~~~ Welcome To Gollie's Salon ~~~~ \n"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
# Get a list of available services
AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo -e "\nHow can we help you today?\n"  
  echo "$AVAILABLE_SERVICES" | while IFS='|' read SERVICE_ID NAME
    do
      echo -e "$SERVICE_ID) $NAME"
    done
    read SERVICE_ID_SELECTED
    # if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-5]$ ]]
    then
      MAIN_MENU "That is not a valid selection."
    else
      # Get customer info
      echo -e "\nWhat is your phone number"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # if customer does not exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # Get new customer info
        echo -e "\nWhat is your name?"
        read CUSTOMER_NAME
        # Add customer to database
        INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")             
      fi
    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'")
    # set appointment time
    echo -e "\nWhat time would you like to come in, $CUSTOMER_NAME"
    read SERVICE_TIME
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
    NAME_OF_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id ='$SERVICE_ID_SELECTED'")
    echo -e "\nI have put you down for a $NAME_OF_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
    
    fi
}
SERVICES_MENU() {
  echo "Service Menu"  
}
RETURN_MENU() {
  echo "Return Menu"
}
EXIT() {
  echo "Exit Menu"
}
MAIN_MENU