#!/bin/bash
# Derived from setAutoLogin (20210911) - Copyright (c) 2021 Joel Bruner (https://github.com/brunerd)
# Licensed under the MIT License
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial
# portions of the Software.

thisString="${1}"

#macOS cipher hex ascii representation array
cipherHex_array=( 7D 89 52 23 D2 BC DD EA A3 B9 1F )

#converted to hex representation with spaces
read -r -a thisStringHex_array <<<"$(echo -n "${thisString}" | xxd -p -u | sed 's/../& /g')"

#get padding by subtraction if under 12
if [ "${#thisStringHex_array[@]}" -lt 12  ]; then
  padding=$(( 12 -  ${#thisStringHex_array[@]} ))
#get padding by subtracting remainder of modulo 12 if over 12
elif [ "$(( ${#thisStringHex_array[@]} % 12 ))" -ne 0  ]; then
  padding=$(( (12 - ${#thisStringHex_array[@]} % 12) ))
#otherwise even multiples of 12 still need 12 padding
else
  padding=12
fi

encodedString=""
#cycle through each element of the array + padding
for ((i=0; i < $(( ${#thisStringHex_array[@]} + padding)); i++)); do
  #use modulus to loop through the cipher array elements
  charHex_cipher=${cipherHex_array[$(( i % 11 ))]}

  #get the current hex representation element
  charHex=${thisStringHex_array[${i}]}

  #use $(( shell Aritmethic )) to ^ XOR the two 0x## values (extra padding is 0x00)
  #take decimal value and printf convert to two char hex value
  #use xxd to convert hex to actual value and append to the encodedString variable
  encodedString+=$(printf "%02X" "$(( 0x${charHex_cipher} ^ 0x${charHex:-00} ))" | xxd -r -p)
done

#return the string without a newline
echo -n "${encodedString}" > /etc/kcpassword

#ensure ownership and permissions (600)
chown root:wheel /etc/kcpassword
chmod u=rw,go= /etc/kcpassword

