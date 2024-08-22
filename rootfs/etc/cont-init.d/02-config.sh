#!/usr/bin/with-contenv bash
# shellcheck shell=bash

TZ=${TZ:-UTC}


echo "Setting timezone to ${TZ}..."
ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
echo ${TZ} > /etc/timezone

msmtprc_file="/etc/msmtprc"

# to maintain backward compatibility
forbidden_accounts="HOST PORT TLS STARTTLS AUTH USER PASSWORD DOMAIN FROM SET REMOVE UNDISCLOSED DSN"

# prepare variables
declare -A ENV_VARS
prefix="SMTP_"
for key in $(env | grep "^SMTP_" | cut -s -d= -f1); do
  value=$(printenv "$key")
  
  ENV_VARS[$key]="$value"
done


# backward compatibility
OLD_VARIABLES=(
    "HOST"
    "PORT"
    "TLS"
    "STARTTLS"
    "TLS_CHECKCERT"
    "AUTH"
    "USER"
    "USER_FILE"
    "PASSWORD"
    "PASSWORD_FILE"
    "DOMAIN"
    "FROM"
    "SET_FROM_HEADER"
    "SET_DATE_HEADER"
    "REMOVE_BCC_HEADERS"
    "UNDISCLOSED_RECIPIENTS"
    "DSN_NOTIFY"
    "DSN_RETURN"
)

for var in "${OLD_VARIABLES[@]}"; do
    default_var="SMTP_DEFAULT_$var"
    main_var="SMTP_$var"

    if [ -z "${ENV_VARS[$default_var]}" ] && [ -n "${ENV_VARS[$main_var]}" ]; then
        ENV_VARS[$default_var]="${ENV_VARS[$main_var]}"
    fi
done

#edge case of tls_starttls
ENV_VARS[TLS_STARTTLS]="${ENV_VARS[STARTTLS]}"
unset ENV_VARS[STARTTLS]

accounts=$(for key in "${!ENV_VARS[@]}"; do
  echo "$key" | cut -d_ -f2
done | sort | uniq)

is_forbidden_account() {
    account="$1"
    for forbidden in $forbidden_accounts; do
        if [ "$account" = "$forbidden" ]; then
            return 0
        fi
    done
    return 1
}

stringContain() { case $2 in *$1* ) return 0;; *) return 1;; esac ;}

add_account_to_file() {
  account="$1"
  account_lower=$(echo "$account" | tr '[:upper:]' '[:lower:]')
  account_prefix=SMTP_${account}



  if is_forbidden_account "$account"; then
    forbidden_list=$(echo "$forbidden_accounts" | tr ' ' ',')
    echo "> env ${account_prefix}* are deprecated. Maybe you used a deprecated variable, or a forbidden account name. Forbidden accounts are: $forbidden_list"
    return
  fi

  HOST_VAR="${account_prefix}_HOST"
  if [ -z "${ENV_VARS["$HOST_VAR"]}" ]; then
    echo "> ${HOST_VAR} is required to configure this account . Skipped"
    return 1
  fi

  echo "Creating configuration for account : $account_lower"

  #handle username from file
  if [ ! -z "${ENV_VARS["${account_prefix}_USER_FILE"]}" ]; then
    ENV_VARS["${account_prefix}_USER"]="$(< "${ENV_VARS["${account_prefix}_USER_FILE"]}")"
    unset ENV_VARS["${account_prefix}_USER_FILE"]
  fi

  #handle password from file or not
  if [ ! -z "${ENV_VARS["${account_prefix}_PASSWORD_FILE"]}" ]; then
    ENV_VARS["${account_prefix}_PASSWORDEVAL"]="cat ${ENV_VARS["${account_prefix}_PASSWORD_FILE"]}"
    unset ENV_VARS["${account_prefix}_PASSWORD"]
    unset ENV_VARS["${account_prefix}_PASSWORD_FILE"]
  fi

  echo "account $account_lower" >> "$msmtprc_file"

  for key in "${!ENV_VARS[@]}"; do
    if ! stringContain "${account_prefix}_" "$key"; then
      continue;
    fi

    config=$(echo "$key" | cut -d_ -f3- | tr '[:upper:]' '[:lower:]')
    value=${ENV_VARS[$key]}

    #default values
    if [ -n "$value" ]; then
      case "$config" in
        "logfile")
            config="-"
          ;;
        "syslog")
            config="off"
          ;;
        *)
          ;;
      esac
    fi

    echo "$config $value" >> "$msmtprc_file"
  done
  
  # add en empty line to separate accounts
  echo "" >> "$msmtprc_file"
}

echo "Creating configuration..."

if [ -z "$ENV_VARS[SMTP_DEFAULT_HOST]" ]; then
  >&2 echo "ERROR: SMTP_DEFAULT_HOST must be defined"
  exit 1
fi

if ! add_account_to_file "DEFAULT"; then
  >&2 echo "Default account fail to be configured"
  exit 1
fi

for account in $accounts; do
  if [ $(echo "$account" | tr '[:upper:]' '[:lower:]') == "default" ]; then continue; fi

  add_account_to_file "$account"
done

echo ""
echo cat $msmtprc_file
cat $msmtprc_file