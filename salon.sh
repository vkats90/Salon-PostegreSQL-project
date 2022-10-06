#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

SET_APPOINTMENT() {
 echo -e "\nPlease enter your desired $SERVICE_NAME_SELECTED time,$CUSTOMER_NAME:"
 read SERVICE_TIME
 INSERT_APPOINTMENT_RESULT="$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")"
 if [[ $INSERT_APPOINTMENT_RESULT = "INSERT 0 1" ]]
 then
  echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
 fi
}

CHECK_CUSTOMER() {
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE
     
  if [[ ! $CUSTOMER_PHONE =~ ^[0-9][0-9][0-9]-*[0-9][0-9][0-9]-*[0-9][0-9][0-9][0-9]$ ]]
  then
    echo -e "\nNot a valid number"
    CHECK_CUSTOMER
  else 
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT="$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")"
      if [[ $INSERT_CUSTOMER_RESULT = "INSERT 0 1" ]]
      then
        echo -e "\nHello $CUSTOMER_NAME."
      fi
    else
      echo -e "\nHello $CUSTOMER_NAME."
    fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
}

MAIN_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1, choose a service:\n " 
  else
    echo -e "\nWelcome to the salon, please choose a service:\n"
  fi

  
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id,name FROM services") 
  echo "$AVAILABLE_SERVICES" | sed 's/|/) /'

  read SERVICE_ID_SELECTED
  
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Please enter a valid number"
  else
    SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
    if [[ -z $SERVICE_AVAILABILITY ]]
    then
     MAIN_MENU "Service not available" 
    else
     SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
     CHECK_CUSTOMER
     SET_APPOINTMENT
    fi
  fi
}

MAIN_MENU
